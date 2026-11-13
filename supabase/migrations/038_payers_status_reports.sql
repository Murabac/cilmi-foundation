-- 038: Monthly payers list, per-member amounts, monthly member status + history,
--      and the WhatsApp group title.
-- Run once in the Supabase SQL Editor after 037. Safe to re-run.
-- Then run supabase/seed_payers_qaadhaan.sql to load the current payers list.

-- ── 1. New profile columns ──────────────────────────────────────────────────
ALTER TABLE reer_sh_yoonis.profiles
  ADD COLUMN IF NOT EXISTS monthly_amount NUMERIC(10,2)
    CHECK (monthly_amount IS NULL OR monthly_amount >= 0),
  ADD COLUMN IF NOT EXISTS life_status TEXT
    CHECK (life_status IS NULL OR life_status IN (
      'school', 'university', 'working', 'business',
      'unemployed', 'homemaker', 'retired', 'too_young'
    )),
  ADD COLUMN IF NOT EXISTS status_updated_at TIMESTAMPTZ;

COMMENT ON COLUMN reer_sh_yoonis.profiles.monthly_amount IS
  'Monthly contribution in USD. NULL or 0 = does not pay (exempt).';
COMMENT ON COLUMN reer_sh_yoonis.profiles.life_status IS
  'Monthly status: school, university, working, business, unemployed, homemaker, retired, too_young.';

ALTER TABLE reer_sh_yoonis.global_settings
  ADD COLUMN IF NOT EXISTS whatsapp_group_title VARCHAR(120)
    NOT NULL DEFAULT 'AHMED CILMI GROUP';

-- ── 2. Only admins/managers may change monthly_amount ───────────────────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.protect_monthly_amount()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
BEGIN
  IF current_setting('reer_sh_yoonis.bypass_profile_guard', true) = 'on' THEN
    RETURN NEW;
  END IF;
  IF TG_OP = 'INSERT' THEN
    IF NEW.monthly_amount IS NOT NULL AND NOT reer_sh_yoonis.is_admin_or_manager() THEN
      NEW.monthly_amount := NULL;
    END IF;
    RETURN NEW;
  END IF;
  IF NEW.monthly_amount IS DISTINCT FROM OLD.monthly_amount
     AND NOT reer_sh_yoonis.is_admin_or_manager() THEN
    RAISE EXCEPTION 'cannot_change_monthly_amount';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS rsy_protect_monthly_amount ON reer_sh_yoonis.profiles;
CREATE TRIGGER rsy_protect_monthly_amount
  BEFORE INSERT OR UPDATE ON reer_sh_yoonis.profiles
  FOR EACH ROW EXECUTE FUNCTION reer_sh_yoonis.protect_monthly_amount();

-- ── 3. Exemption = not on the payers list ───────────────────────────────────
-- Only members with monthly_amount > 0 pay. Everyone else is exempt.
-- billing_override = 'exempt' still pauses a payer temporarily.
CREATE OR REPLACE FUNCTION reer_sh_yoonis.is_profile_payment_exempt(p_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_amount NUMERIC(10,2);
  v_override TEXT;
  v_marital TEXT;
BEGIN
  SELECT monthly_amount, billing_override, marital_status::text
    INTO v_amount, v_override, v_marital
  FROM reer_sh_yoonis.profiles
  WHERE id = p_profile_id;

  IF NOT FOUND THEN
    RETURN TRUE;
  END IF;
  IF v_marital = 'deceased' OR v_override = 'exempt' THEN
    RETURN TRUE;
  END IF;
  RETURN COALESCE(v_amount, 0) <= 0;
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.is_profile_payment_exempt(UUID)
  TO authenticated, service_role;

-- ── 4. Billing uses each payer's own amount ─────────────────────────────────
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
  v_count INT := 0;
BEGIN
  IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  PERFORM reer_sh_yoonis.purge_exempt_contributions();

  INSERT INTO contributions (user_id, billing_month, billing_year, amount_due, status)
  SELECT p.id, p_month, p_year, p.monthly_amount, 'pending'
  FROM profiles p
  WHERE NOT reer_sh_yoonis.is_profile_payment_exempt(p.id)
  ON CONFLICT (user_id, billing_month, billing_year) DO NOTHING;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

-- purge_exempt_contributions (037) now uses the rule above. Only unpaid rows
-- are removed so a member who paid and was later taken off the list keeps
-- their payment history.
CREATE OR REPLACE FUNCTION reer_sh_yoonis.purge_exempt_contributions()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_count INT := 0;
BEGIN
  IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  DELETE FROM reer_sh_yoonis.contributions c
  WHERE c.status <> 'approved'
    AND reer_sh_yoonis.is_profile_payment_exempt(c.user_id);

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

-- ── 5. Monthly status history ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reer_sh_yoonis.member_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES reer_sh_yoonis.profiles(id) ON DELETE CASCADE,
  period DATE NOT NULL,                       -- first day of the month
  life_status TEXT,
  occupation VARCHAR(255),
  marital_status TEXT,
  updated_by UUID REFERENCES reer_sh_yoonis.profiles(id) ON DELETE SET NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (profile_id, period)
);

CREATE INDEX IF NOT EXISTS member_status_history_period_idx
  ON reer_sh_yoonis.member_status_history (period);

ALTER TABLE reer_sh_yoonis.member_status_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "rsy_status_history_read" ON reer_sh_yoonis.member_status_history;
CREATE POLICY "rsy_status_history_read"
  ON reer_sh_yoonis.member_status_history FOR SELECT TO authenticated
  USING (
    reer_sh_yoonis.is_admin_or_manager()
    OR profile_id = reer_sh_yoonis.current_profile_id()
  );

REVOKE ALL ON reer_sh_yoonis.member_status_history FROM anon;
GRANT SELECT ON reer_sh_yoonis.member_status_history TO authenticated;
REVOKE INSERT, UPDATE, DELETE ON reer_sh_yoonis.member_status_history FROM authenticated;

-- ── 6. Update a member's monthly status (self or admin) ─────────────────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.update_member_status(
  p_profile_id UUID,
  p_life_status TEXT,
  p_occupation TEXT DEFAULT NULL,
  p_marital_status TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_is_admin BOOLEAN := reer_sh_yoonis.is_admin_or_manager();
  v_me UUID := reer_sh_yoonis.current_profile_id();
  v_period DATE := date_trunc('month', NOW())::date;
  v_occ TEXT := NULLIF(trim(p_occupation), '');
  v_marital TEXT := NULLIF(trim(p_marital_status), '');
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;
  IF NOT v_is_admin AND (v_me IS NULL OR v_me <> p_profile_id) THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;
  IF p_life_status IS NOT NULL AND p_life_status NOT IN (
    'school', 'university', 'working', 'business',
    'unemployed', 'homemaker', 'retired', 'too_young'
  ) THEN
    RAISE EXCEPTION 'invalid_life_status';
  END IF;
  IF v_marital IS NOT NULL AND v_marital NOT IN ('single', 'married', 'deceased') THEN
    RAISE EXCEPTION 'invalid_marital_status';
  END IF;
  IF v_marital = 'deceased' AND NOT v_is_admin THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  UPDATE profiles
  SET life_status = p_life_status,
      occupation = CASE WHEN p_life_status IN ('working', 'business') THEN v_occ ELSE occupation END,
      marital_status = COALESCE(v_marital::reer_sh_yoonis.marital_status, marital_status),
      status_updated_at = NOW()
  WHERE id = p_profile_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'invalid_profile';
  END IF;

  INSERT INTO member_status_history (
    profile_id, period, life_status, occupation, marital_status, updated_by, updated_at
  )
  SELECT p.id, v_period, p.life_status, p.occupation, p.marital_status::text, v_me, NOW()
  FROM profiles p WHERE p.id = p_profile_id
  ON CONFLICT (profile_id, period) DO UPDATE
    SET life_status = EXCLUDED.life_status,
        occupation = EXCLUDED.occupation,
        marital_status = EXCLUDED.marital_status,
        updated_by = EXCLUDED.updated_by,
        updated_at = EXCLUDED.updated_at;
END;
$$;

REVOKE ALL ON FUNCTION reer_sh_yoonis.update_member_status(UUID, TEXT, TEXT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.update_member_status(UUID, TEXT, TEXT, TEXT)
  TO authenticated, service_role;

NOTIFY pgrst, 'reload config';
