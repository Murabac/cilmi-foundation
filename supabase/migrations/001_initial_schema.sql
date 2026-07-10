-- Reer Sh Yoonis — Multi-schema setup (one Supabase project, many app schemas)
-- Default app schema: reer_sh_yoonis
-- Change the schema name below if your convention differs, then update SUPABASE_SCHEMA in the Flutter app.

CREATE SCHEMA IF NOT EXISTS reer_sh_yoonis;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. ENUMS (scoped to app schema)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TYPE reer_sh_yoonis.user_role AS ENUM ('super_admin', 'manager', 'family_member');
CREATE TYPE reer_sh_yoonis.demographic_type AS ENUM ('adult', 'student', 'child');
CREATE TYPE reer_sh_yoonis.payment_status AS ENUM ('pending', 'approved', 'rejected');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. GLOBAL SETTINGS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE reer_sh_yoonis.global_settings (
    id INT PRIMARY KEY DEFAULT 1,
    current_adult_rate NUMERIC(10, 2) NOT NULL DEFAULT 50.00,
    app_language VARCHAR(5) NOT NULL DEFAULT 'en' CHECK (app_language IN ('en', 'so')),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT single_row CHECK (id = 1)
);

INSERT INTO reer_sh_yoonis.global_settings (id) VALUES (1) ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. PROFILES (linked to shared auth.users)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE reer_sh_yoonis.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(50),
    role reer_sh_yoonis.user_role NOT NULL DEFAULT 'family_member',
    demographic reer_sh_yoonis.demographic_type NOT NULL DEFAULT 'adult',
    care_rating INT NOT NULL DEFAULT 2 CHECK (care_rating BETWEEN 1 AND 5),
    father_id UUID REFERENCES reer_sh_yoonis.profiles(id) ON DELETE SET NULL,
    mother_id UUID REFERENCES reer_sh_yoonis.profiles(id) ON DELETE SET NULL,
    spouse_id UUID REFERENCES reer_sh_yoonis.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_rsy_profiles_auth_user ON reer_sh_yoonis.profiles(auth_user_id);
CREATE INDEX idx_rsy_profiles_father ON reer_sh_yoonis.profiles(father_id);
CREATE INDEX idx_rsy_profiles_mother ON reer_sh_yoonis.profiles(mother_id);
CREATE INDEX idx_rsy_profiles_care_rating ON reer_sh_yoonis.profiles(care_rating);

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. CONTRIBUTIONS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE reer_sh_yoonis.contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES reer_sh_yoonis.profiles(id) ON DELETE CASCADE,
    billing_month INT NOT NULL CHECK (billing_month BETWEEN 1 AND 12),
    billing_year INT NOT NULL,
    amount_due NUMERIC(10, 2) NOT NULL,
    amount_paid NUMERIC(10, 2) DEFAULT 0.00,
    status reer_sh_yoonis.payment_status NOT NULL DEFAULT 'pending',
    transaction_reference VARCHAR(255),
    receipt_url TEXT,
    verified_by UUID REFERENCES reer_sh_yoonis.profiles(id),
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (user_id, billing_month, billing_year)
);

CREATE INDEX idx_rsy_contributions_user ON reer_sh_yoonis.contributions(user_id);
CREATE INDEX idx_rsy_contributions_status ON reer_sh_yoonis.contributions(status);

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. TREASURY OUTFLOWS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE reer_sh_yoonis.treasury_outflows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    beneficiary_id UUID REFERENCES reer_sh_yoonis.profiles(id) ON DELETE SET NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    reason TEXT NOT NULL,
    approved_by UUID REFERENCES reer_sh_yoonis.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. HELPER FUNCTIONS (live in app schema)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.current_profile_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  SELECT id FROM profiles WHERE auth_user_id = auth.uid() LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION reer_sh_yoonis.current_user_role()
RETURNS reer_sh_yoonis.user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  SELECT role FROM profiles WHERE auth_user_id = auth.uid() LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION reer_sh_yoonis.is_admin_or_manager()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE auth_user_id = auth.uid()
    AND role IN ('super_admin', 'manager')
  );
$$;

-- Only create a profile when sign-up metadata targets this app schema.
-- Flutter passes: data: { app: 'reer_sh_yoonis', full_name: '...' }
CREATE OR REPLACE FUNCTION reer_sh_yoonis.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
BEGIN
  IF COALESCE(NEW.raw_user_meta_data->>'app', '') = 'reer_sh_yoonis' THEN
    INSERT INTO profiles (auth_user_id, full_name, email, role, demographic)
    VALUES (
      NEW.id,
      COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
      NEW.email,
      'family_member',
      'adult'
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS rsy_on_auth_user_created ON auth.users;
CREATE TRIGGER rsy_on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION reer_sh_yoonis.handle_new_user();

CREATE OR REPLACE FUNCTION reer_sh_yoonis.generate_monthly_billing(
  p_month INT DEFAULT EXTRACT(MONTH FROM NOW())::INT,
  p_year INT DEFAULT EXTRACT(YEAR FROM NOW())::INT
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_rate NUMERIC(10,2);
  v_count INT := 0;
BEGIN
  IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT current_adult_rate INTO v_rate FROM global_settings WHERE id = 1;

  INSERT INTO contributions (user_id, billing_month, billing_year, amount_due, status)
  SELECT p.id, p_month, p_year, v_rate, 'pending'
  FROM profiles p
  WHERE p.demographic = 'adult'
  ON CONFLICT (user_id, billing_month, billing_year) DO NOTHING;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 7. ROW LEVEL SECURITY
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE reer_sh_yoonis.global_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reer_sh_yoonis.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE reer_sh_yoonis.contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE reer_sh_yoonis.treasury_outflows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "rsy_read_settings"
  ON reer_sh_yoonis.global_settings FOR SELECT TO authenticated USING (true);

CREATE POLICY "rsy_super_admin_update_settings"
  ON reer_sh_yoonis.global_settings FOR UPDATE TO authenticated
  USING (reer_sh_yoonis.current_user_role() = 'super_admin');

CREATE POLICY "rsy_read_profiles"
  ON reer_sh_yoonis.profiles FOR SELECT TO authenticated USING (true);

CREATE POLICY "rsy_users_update_own_profile"
  ON reer_sh_yoonis.profiles FOR UPDATE TO authenticated
  USING (auth_user_id = auth.uid())
  WITH CHECK (auth_user_id = auth.uid());

CREATE POLICY "rsy_super_admin_update_profiles"
  ON reer_sh_yoonis.profiles FOR UPDATE TO authenticated
  USING (reer_sh_yoonis.current_user_role() = 'super_admin');

CREATE POLICY "rsy_super_admin_insert_profiles"
  ON reer_sh_yoonis.profiles FOR INSERT TO authenticated
  WITH CHECK (reer_sh_yoonis.current_user_role() = 'super_admin');

CREATE POLICY "rsy_read_own_contributions"
  ON reer_sh_yoonis.contributions FOR SELECT TO authenticated
  USING (user_id = reer_sh_yoonis.current_profile_id());

CREATE POLICY "rsy_managers_read_contributions"
  ON reer_sh_yoonis.contributions FOR SELECT TO authenticated
  USING (reer_sh_yoonis.is_admin_or_manager());

CREATE POLICY "rsy_adults_insert_contributions"
  ON reer_sh_yoonis.contributions FOR INSERT TO authenticated
  WITH CHECK (user_id = reer_sh_yoonis.current_profile_id());

CREATE POLICY "rsy_adults_update_pending_contributions"
  ON reer_sh_yoonis.contributions FOR UPDATE TO authenticated
  USING (
    user_id = reer_sh_yoonis.current_profile_id()
    AND status = 'pending'
  );

CREATE POLICY "rsy_managers_verify_contributions"
  ON reer_sh_yoonis.contributions FOR UPDATE TO authenticated
  USING (reer_sh_yoonis.is_admin_or_manager());

CREATE POLICY "rsy_managers_read_outflows"
  ON reer_sh_yoonis.treasury_outflows FOR SELECT TO authenticated
  USING (reer_sh_yoonis.is_admin_or_manager());

CREATE POLICY "rsy_managers_insert_outflows"
  ON reer_sh_yoonis.treasury_outflows FOR INSERT TO authenticated
  WITH CHECK (reer_sh_yoonis.is_admin_or_manager());

-- ─────────────────────────────────────────────────────────────────────────────
-- 8. GRANTS (required for PostgREST / Supabase client access)
-- ─────────────────────────────────────────────────────────────────────────────
GRANT USAGE ON SCHEMA reer_sh_yoonis TO authenticated, anon, service_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA reer_sh_yoonis
  TO authenticated, service_role;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA reer_sh_yoonis
  TO authenticated, service_role;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA reer_sh_yoonis
  TO authenticated, service_role;

-- Expose schema to PostgREST (Supabase API)
-- Dashboard → Project Settings → API → Exposed schemas → add reer_sh_yoonis
-- Or run (requires appropriate privileges):
ALTER ROLE authenticator SET pgrst.db_schemas = 'public, reer_sh_yoonis';
NOTIFY pgrst, 'reload config';

-- ─────────────────────────────────────────────────────────────────────────────
-- 9. STORAGE (schema-scoped bucket name to avoid collisions)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public)
VALUES ('reer-sh-yoonis-receipts', 'reer-sh-yoonis-receipts', false)
ON CONFLICT DO NOTHING;

CREATE POLICY "rsy_users_upload_receipts"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'reer-sh-yoonis-receipts'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "rsy_users_read_own_receipts"
  ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'reer-sh-yoonis-receipts'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "rsy_managers_read_all_receipts"
  ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'reer-sh-yoonis-receipts'
    AND reer_sh_yoonis.is_admin_or_manager()
  );
