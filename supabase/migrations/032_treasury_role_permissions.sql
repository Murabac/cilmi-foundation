-- Step 2: permissions for treasury role (run AFTER 031 has committed).
-- Hierarchy: super_admin > treasury (admin + pool) > manager (admin) > family_member

-- Payments / care: super_admin + treasury + manager.
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
      AND role IN ('super_admin', 'treasury', 'manager')
  );
$$;

-- Treasury pool: super_admin + treasury.
CREATE OR REPLACE FUNCTION reer_sh_yoonis.is_treasury_manager()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE auth_user_id = auth.uid()
      AND role IN ('super_admin', 'treasury')
  );
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.is_treasury_manager()
  TO authenticated, service_role;

-- Anyone signed in can see the pool total (not the full ledger).
CREATE OR REPLACE FUNCTION reer_sh_yoonis.get_pool_balance()
RETURNS NUMERIC
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_contrib NUMERIC;
  v_inflows NUMERIC;
  v_out NUMERIC;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT COALESCE(SUM(amount_paid), 0)
    INTO v_contrib
    FROM reer_sh_yoonis.contributions
   WHERE status = 'approved';

  SELECT COALESCE(SUM(amount), 0)
    INTO v_inflows
    FROM reer_sh_yoonis.treasury_inflows;

  SELECT COALESCE(SUM(amount), 0)
    INTO v_out
    FROM reer_sh_yoonis.treasury_outflows;

  RETURN v_contrib + v_inflows - v_out;
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.get_pool_balance()
  TO authenticated;

-- Treasury RPCs: only treasury managers.
CREATE OR REPLACE FUNCTION reer_sh_yoonis.record_treasury_inflow(
  p_amount NUMERIC,
  p_reason TEXT,
  p_donor_name TEXT DEFAULT NULL,
  p_donor_profile_id UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_recorder UUID;
  v_reason TEXT;
BEGIN
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE EXCEPTION 'invalid_amount';
  END IF;

  v_reason := NULLIF(TRIM(COALESCE(p_reason, '')), '');
  IF v_reason IS NULL THEN
    RAISE EXCEPTION 'reason_required';
  END IF;

  IF NOT reer_sh_yoonis.is_treasury_manager() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_recorder := reer_sh_yoonis.current_profile_id();
  IF v_recorder IS NULL THEN
    RAISE EXCEPTION 'profile_required';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtext('reer_sh_yoonis_treasury'));

  INSERT INTO reer_sh_yoonis.treasury_inflows (
    amount, reason, donor_name, donor_profile_id, recorded_by
  ) VALUES (
    p_amount, v_reason,
    NULLIF(TRIM(COALESCE(p_donor_name, '')), ''),
    p_donor_profile_id,
    v_recorder
  );
END;
$$;

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
  v_contrib NUMERIC;
  v_inflows NUMERIC;
  v_out NUMERIC;
  v_balance NUMERIC;
  v_approver UUID;
BEGIN
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE EXCEPTION 'invalid_amount';
  END IF;

  IF NOT reer_sh_yoonis.is_treasury_manager() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_approver := reer_sh_yoonis.current_profile_id();
  IF v_approver IS NULL THEN
    RAISE EXCEPTION 'profile_required';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtext('reer_sh_yoonis_treasury'));

  SELECT COALESCE(SUM(amount_paid), 0)
    INTO v_contrib
    FROM reer_sh_yoonis.contributions
   WHERE status = 'approved';

  SELECT COALESCE(SUM(amount), 0)
    INTO v_inflows
    FROM reer_sh_yoonis.treasury_inflows;

  SELECT COALESCE(SUM(amount), 0)
    INTO v_out
    FROM reer_sh_yoonis.treasury_outflows;

  v_balance := v_contrib + v_inflows - v_out;

  IF p_amount > v_balance THEN
    RAISE EXCEPTION 'insufficient_pool_balance';
  END IF;

  INSERT INTO reer_sh_yoonis.treasury_outflows (
    beneficiary_id, amount, reason, approved_by
  ) VALUES (
    p_beneficiary_id, p_amount, p_reason, v_approver
  );
END;
$$;

-- Treasury ledger read access.
DROP POLICY IF EXISTS "rsy_managers_read_inflows" ON reer_sh_yoonis.treasury_inflows;
CREATE POLICY "rsy_managers_read_inflows"
  ON reer_sh_yoonis.treasury_inflows FOR SELECT TO authenticated
  USING (reer_sh_yoonis.is_treasury_manager());

DROP POLICY IF EXISTS "rsy_managers_read_outflows" ON reer_sh_yoonis.treasury_outflows;
CREATE POLICY "rsy_managers_read_outflows"
  ON reer_sh_yoonis.treasury_outflows FOR SELECT TO authenticated
  USING (reer_sh_yoonis.is_treasury_manager());

DROP POLICY IF EXISTS "rsy_treasury_read_contributions" ON reer_sh_yoonis.contributions;
CREATE POLICY "rsy_treasury_read_contributions"
  ON reer_sh_yoonis.contributions FOR SELECT TO authenticated
  USING (reer_sh_yoonis.is_treasury_manager());

NOTIFY pgrst, 'reload config';
