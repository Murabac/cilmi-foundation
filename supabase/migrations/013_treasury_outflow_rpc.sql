-- Atomic treasury disbursement: reject when pool balance is insufficient.
CREATE OR REPLACE FUNCTION reer_sh_yoonis.record_treasury_outflow(
  p_beneficiary_id uuid,
  p_amount numeric,
  p_reason text,
  p_approved_by uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_in numeric;
  v_out numeric;
  v_balance numeric;
BEGIN
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE EXCEPTION 'invalid_amount';
  END IF;

  IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT COALESCE(SUM(amount_paid), 0)
    INTO v_in
    FROM reer_sh_yoonis.contributions
   WHERE status = 'approved';

  SELECT COALESCE(SUM(amount), 0)
    INTO v_out
    FROM reer_sh_yoonis.treasury_outflows;

  v_balance := v_in - v_out;

  IF p_amount > v_balance THEN
    RAISE EXCEPTION 'insufficient_pool_balance';
  END IF;

  INSERT INTO reer_sh_yoonis.treasury_outflows (
    beneficiary_id,
    amount,
    reason,
    approved_by
  )
  VALUES (
    p_beneficiary_id,
    p_amount,
    p_reason,
    p_approved_by
  );
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.record_treasury_outflow(uuid, numeric, text, uuid)
  TO authenticated;

NOTIFY pgrst, 'reload config';
