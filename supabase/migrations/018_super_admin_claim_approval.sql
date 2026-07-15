-- Restrict profile link approval to super_admin only (managers cannot approve/reject).

CREATE OR REPLACE FUNCTION reer_sh_yoonis.approve_profile_claim(p_request_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_req reer_sh_yoonis.profile_claim_requests%ROWTYPE;
  v_reviewer UUID;
BEGIN
  IF reer_sh_yoonis.current_user_role() IS DISTINCT FROM 'super_admin' THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_reviewer := reer_sh_yoonis.current_profile_id();

  SELECT * INTO v_req
  FROM reer_sh_yoonis.profile_claim_requests
  WHERE id = p_request_id AND status = 'pending'
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'claim_not_found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM reer_sh_yoonis.profiles
    WHERE id = v_req.profile_id AND auth_user_id IS NULL
  ) THEN
    RAISE EXCEPTION 'profile_not_available';
  END IF;

  DELETE FROM reer_sh_yoonis.profiles
  WHERE auth_user_id = v_req.auth_user_id
    AND father_id IS NULL
    AND id <> v_req.profile_id;

  PERFORM set_config('reer_sh_yoonis.bypass_profile_guard', 'on', true);

  UPDATE reer_sh_yoonis.profiles
  SET
    auth_user_id = v_req.auth_user_id,
    phone_number = COALESCE(v_req.requester_phone, phone_number)
  WHERE id = v_req.profile_id;

  PERFORM set_config('reer_sh_yoonis.bypass_profile_guard', 'off', true);

  UPDATE reer_sh_yoonis.profile_claim_requests
  SET
    status = 'approved',
    reviewed_by = v_reviewer,
    reviewed_at = NOW()
  WHERE id = p_request_id;

  UPDATE reer_sh_yoonis.profile_claim_requests
  SET
    status = 'rejected',
    reviewed_by = v_reviewer,
    reviewed_at = NOW(),
    rejection_reason = COALESCE(rejection_reason, 'Another claim was approved.')
  WHERE status = 'pending'
    AND id <> p_request_id
    AND (profile_id = v_req.profile_id OR auth_user_id = v_req.auth_user_id);
END;
$$;

CREATE OR REPLACE FUNCTION reer_sh_yoonis.reject_profile_claim(
  p_request_id UUID,
  p_reason TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_reviewer UUID;
BEGIN
  IF reer_sh_yoonis.current_user_role() IS DISTINCT FROM 'super_admin' THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_reviewer := reer_sh_yoonis.current_profile_id();

  UPDATE reer_sh_yoonis.profile_claim_requests
  SET
    status = 'rejected',
    reviewed_by = v_reviewer,
    reviewed_at = NOW(),
    rejection_reason = NULLIF(trim(p_reason), '')
  WHERE id = p_request_id AND status = 'pending';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'claim_not_found';
  END IF;
END;
$$;

DROP POLICY IF EXISTS "rsy_admins_read_claim_requests" ON reer_sh_yoonis.profile_claim_requests;
CREATE POLICY "rsy_super_admin_read_claim_requests"
  ON reer_sh_yoonis.profile_claim_requests FOR SELECT TO authenticated
  USING (reer_sh_yoonis.current_user_role() = 'super_admin');

NOTIFY pgrst, 'reload config';
