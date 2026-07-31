-- One-time donations / manual pool credits (separate from monthly contributions).

CREATE TABLE IF NOT EXISTS reer_sh_yoonis.treasury_inflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
  reason TEXT NOT NULL,
  donor_name TEXT,
  donor_profile_id UUID REFERENCES reer_sh_yoonis.profiles(id) ON DELETE SET NULL,
  recorded_by UUID REFERENCES reer_sh_yoonis.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rsy_treasury_inflows_created
  ON reer_sh_yoonis.treasury_inflows (created_at DESC);

ALTER TABLE reer_sh_yoonis.treasury_inflows ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "rsy_managers_read_inflows" ON reer_sh_yoonis.treasury_inflows;
CREATE POLICY "rsy_managers_read_inflows"
  ON reer_sh_yoonis.treasury_inflows FOR SELECT TO authenticated
  USING (reer_sh_yoonis.is_admin_or_manager());

DROP POLICY IF EXISTS "rsy_super_admin_delete_inflows" ON reer_sh_yoonis.treasury_inflows;
CREATE POLICY "rsy_super_admin_delete_inflows"
  ON reer_sh_yoonis.treasury_inflows FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM reer_sh_yoonis.profiles p
      WHERE p.id = reer_sh_yoonis.current_profile_id()
        AND p.role = 'super_admin'
    )
  );

GRANT SELECT, INSERT, DELETE ON reer_sh_yoonis.treasury_inflows TO authenticated;

-- Credit the pool (donation / one-time deposit).
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

  IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_recorder := reer_sh_yoonis.current_profile_id();
  IF v_recorder IS NULL THEN
    RAISE EXCEPTION 'profile_required';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtext('reer_sh_yoonis_treasury'));

  INSERT INTO reer_sh_yoonis.treasury_inflows (
    amount,
    reason,
    donor_name,
    donor_profile_id,
    recorded_by
  ) VALUES (
    p_amount,
    v_reason,
    NULLIF(TRIM(COALESCE(p_donor_name, '')), ''),
    p_donor_profile_id,
    v_recorder
  );
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.record_treasury_inflow(NUMERIC, TEXT, TEXT, UUID)
  TO authenticated;

-- Balance = approved contributions + manual inflows − outflows.
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

  IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
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

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.record_treasury_outflow(UUID, NUMERIC, TEXT, UUID)
  TO authenticated;

NOTIFY pgrst, 'reload config';
