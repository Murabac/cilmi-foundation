-- Lineage self-service lockdown, father-cycle validation, payment exemption in RLS,
-- unified patriarch helper, treasury attribution fix.

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Shared patriarch + payment exempt helpers
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.patriarch_profile_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  SELECT id
  FROM reer_sh_yoonis.profiles
  WHERE full_name ILIKE '%SHEEKH YONIS%'
    AND father_id IS NULL
  ORDER BY full_name
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION reer_sh_yoonis.is_profile_payment_exempt(p_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_demo reer_sh_yoonis.demographic_type;
  v_father_id UUID;
  v_patriarch_id UUID;
BEGIN
  SELECT demographic, father_id
    INTO v_demo, v_father_id
  FROM reer_sh_yoonis.profiles
  WHERE id = p_profile_id;

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  IF v_demo IN ('student', 'child') THEN
    RETURN TRUE;
  END IF;

  v_patriarch_id := reer_sh_yoonis.patriarch_profile_id();
  IF v_patriarch_id IS NOT NULL
     AND (p_profile_id = v_patriarch_id OR v_father_id = v_patriarch_id) THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END;
$$;

CREATE OR REPLACE FUNCTION reer_sh_yoonis.purge_exempt_contributions()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_count INT := 0;
BEGIN
  DELETE FROM reer_sh_yoonis.contributions c
  WHERE reer_sh_yoonis.is_profile_payment_exempt(c.user_id);

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.patriarch_profile_id() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.is_profile_payment_exempt(UUID) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.purge_exempt_contributions() TO authenticated, service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Block family members from self-service lineage edits
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.protect_profile_sensitive_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_role reer_sh_yoonis.user_role;
BEGIN
  IF current_setting('reer_sh_yoonis.bypass_profile_guard', true) = 'on' THEN
    RETURN NEW;
  END IF;

  v_role := reer_sh_yoonis.current_user_role();

  IF TG_OP = 'INSERT' THEN
    IF v_role IS DISTINCT FROM 'super_admin' THEN
      NEW.role := 'family_member';
    END IF;

    IF v_role IS NULL OR v_role = 'family_member' THEN
      IF NEW.auth_user_id IS NOT NULL AND NEW.auth_user_id IS DISTINCT FROM auth.uid() THEN
        RAISE EXCEPTION 'cannot_set_auth_user_id';
      END IF;
      IF NEW.father_id IS NOT NULL THEN
        RAISE EXCEPTION 'cannot_set_lineage_fields';
      END IF;
      IF COALESCE(NEW.birth_order, 0) <> 0 THEN
        RAISE EXCEPTION 'cannot_set_lineage_fields';
      END IF;
    END IF;

    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF v_role IS DISTINCT FROM 'super_admin' THEN
      IF NEW.role IS DISTINCT FROM OLD.role THEN
        RAISE EXCEPTION 'cannot_change_role';
      END IF;
      IF NEW.auth_user_id IS DISTINCT FROM OLD.auth_user_id THEN
        RAISE EXCEPTION 'cannot_change_auth_user_id';
      END IF;
    END IF;

    IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
      IF NEW.father_id IS DISTINCT FROM OLD.father_id THEN
        RAISE EXCEPTION 'cannot_change_lineage_fields';
      END IF;
      IF NEW.full_name IS DISTINCT FROM OLD.full_name THEN
        RAISE EXCEPTION 'cannot_change_lineage_fields';
      END IF;
      IF NEW.birth_order IS DISTINCT FROM OLD.birth_order THEN
        RAISE EXCEPTION 'cannot_change_lineage_fields';
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Father-cycle validation (all writers, including admins)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.validate_profile_father_id()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_current UUID;
  v_visited INT := 0;
BEGIN
  IF NEW.father_id IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.father_id = NEW.id THEN
    RAISE EXCEPTION 'father_cannot_be_self';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM reer_sh_yoonis.profiles WHERE id = NEW.father_id) THEN
    RAISE EXCEPTION 'father_not_found';
  END IF;

  v_current := NEW.father_id;
  WHILE v_current IS NOT NULL AND v_visited < 500 LOOP
    IF v_current = NEW.id THEN
      RAISE EXCEPTION 'father_cycle_detected';
    END IF;
    v_visited := v_visited + 1;
    SELECT father_id INTO v_current
    FROM reer_sh_yoonis.profiles
    WHERE id = v_current;
  END LOOP;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS rsy_validate_profile_father_id ON reer_sh_yoonis.profiles;
CREATE TRIGGER rsy_validate_profile_father_id
  BEFORE INSERT OR UPDATE OF father_id ON reer_sh_yoonis.profiles
  FOR EACH ROW EXECUTE FUNCTION reer_sh_yoonis.validate_profile_father_id();

-- Remove redundant policy (lineage updates blocked by trigger for members)
DROP POLICY IF EXISTS "rsy_users_set_own_father" ON reer_sh_yoonis.profiles;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Contribution RLS: block exempt members; keep pending rows user-owned
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "rsy_adults_insert_contributions" ON reer_sh_yoonis.contributions;
CREATE POLICY "rsy_adults_insert_contributions"
  ON reer_sh_yoonis.contributions FOR INSERT TO authenticated
  WITH CHECK (
    user_id = reer_sh_yoonis.current_profile_id()
    AND NOT reer_sh_yoonis.is_profile_payment_exempt(user_id)
  );

DROP POLICY IF EXISTS "rsy_adults_update_pending_contributions" ON reer_sh_yoonis.contributions;
CREATE POLICY "rsy_adults_update_pending_contributions"
  ON reer_sh_yoonis.contributions FOR UPDATE TO authenticated
  USING (
    user_id = reer_sh_yoonis.current_profile_id()
    AND status = 'pending'
    AND NOT reer_sh_yoonis.is_profile_payment_exempt(user_id)
  )
  WITH CHECK (
    user_id = reer_sh_yoonis.current_profile_id()
    AND status = 'pending'
    AND NOT reer_sh_yoonis.is_profile_payment_exempt(user_id)
  );

DROP POLICY IF EXISTS "rsy_managers_insert_contributions" ON reer_sh_yoonis.contributions;
CREATE POLICY "rsy_managers_insert_contributions"
  ON reer_sh_yoonis.contributions FOR INSERT TO authenticated
  WITH CHECK (
    reer_sh_yoonis.is_admin_or_manager()
    AND NOT reer_sh_yoonis.is_profile_payment_exempt(user_id)
  );

DROP POLICY IF EXISTS "rsy_managers_verify_contributions" ON reer_sh_yoonis.contributions;
CREATE POLICY "rsy_managers_verify_contributions"
  ON reer_sh_yoonis.contributions FOR UPDATE TO authenticated
  USING (reer_sh_yoonis.is_admin_or_manager())
  WITH CHECK (
    reer_sh_yoonis.is_admin_or_manager()
    AND NOT reer_sh_yoonis.is_profile_payment_exempt(user_id)
  );

SELECT reer_sh_yoonis.purge_exempt_contributions();

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Billing uses shared patriarch helper
-- ─────────────────────────────────────────────────────────────────────────────
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
  v_patriarch_id UUID;
BEGIN
  IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  PERFORM reer_sh_yoonis.purge_exempt_contributions();

  SELECT current_adult_rate INTO v_rate FROM global_settings WHERE id = 1;
  v_patriarch_id := reer_sh_yoonis.patriarch_profile_id();

  INSERT INTO contributions (user_id, billing_month, billing_year, amount_due, status)
  SELECT p.id, p_month, p_year, v_rate, 'pending'
  FROM profiles p
  WHERE p.demographic = 'adult'
    AND NOT reer_sh_yoonis.is_profile_payment_exempt(p.id)
  ON CONFLICT (user_id, billing_month, billing_year) DO NOTHING;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. Treasury: always attribute outflow to current profile
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.record_treasury_outflow(
  p_beneficiary_id UUID,
  p_amount NUMERIC,
  p_reason TEXT,
  p_approved_by UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_in NUMERIC;
  v_out NUMERIC;
  v_balance NUMERIC;
  v_approver UUID;
BEGIN
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE EXCEPTION 'invalid_amount';
  END IF;

  IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_approver := reer_sh_yoonis.current_profile_id();
  IF v_approver IS NULL THEN
    RAISE EXCEPTION 'profile_required';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtext('reer_sh_yoonis_treasury'));

  SELECT COALESCE(SUM(amount_paid), 0)
    INTO v_in
    FROM reer_sh_yoonis.contributions
   WHERE status = 'approved';

  SELECT COALESCE(SUM(amount), 0)
    INTO v_out
    FROM reer_sh_yoonis.treasury_outflows;

  v_balance := v_in - v_out;

  IF p_amount > v_balance THEN
    RAISE EXCEPTION 'insufficient_balance';
  END IF;

  INSERT INTO reer_sh_yoonis.treasury_outflows (
    beneficiary_id, amount, reason, approved_by
  ) VALUES (
    p_beneficiary_id, p_amount, p_reason, v_approver
  );
END;
$$;

NOTIFY pgrst, 'reload config';
