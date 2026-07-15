-- Bootstrap the FIRST super admin: approve their pending profile link and grant role.
-- Run in Supabase SQL Editor after the user has signed up and submitted a claim.
--
-- Replace the phone/email below if needed (0634749276 → +252634749276).

DO $$
DECLARE
  v_auth_id UUID;
  v_claim reer_sh_yoonis.profile_claim_requests%ROWTYPE;
BEGIN
  SELECT u.id INTO v_auth_id
  FROM auth.users u
  WHERE u.email LIKE 'rsy.252634749276@%'
     OR u.raw_user_meta_data->>'phone' IN ('+252634749276', '252634749276')
     OR u.phone IN ('+252634749276', '252634749276')
  ORDER BY u.created_at DESC
  LIMIT 1;

  IF v_auth_id IS NULL THEN
    RAISE EXCEPTION 'No auth user found for 0634749276 — sign up in the app first.';
  END IF;

  SELECT * INTO v_claim
  FROM reer_sh_yoonis.profile_claim_requests
  WHERE auth_user_id = v_auth_id AND status = 'pending'
  ORDER BY created_at DESC
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No pending claim for this user. Submit a profile link request in the app first.';
  END IF;

  DELETE FROM reer_sh_yoonis.profiles
  WHERE auth_user_id = v_auth_id
    AND father_id IS NULL
    AND id <> v_claim.profile_id;

  PERFORM set_config('reer_sh_yoonis.bypass_profile_guard', 'on', true);

  UPDATE reer_sh_yoonis.profiles
  SET
    auth_user_id = v_auth_id,
    phone_number = COALESCE(v_claim.requester_phone, phone_number),
    role = 'super_admin'
  WHERE id = v_claim.profile_id;

  PERFORM set_config('reer_sh_yoonis.bypass_profile_guard', 'off', true);

  UPDATE reer_sh_yoonis.profile_claim_requests
  SET
    status = 'approved',
    reviewed_at = NOW(),
    rejection_reason = NULL
  WHERE id = v_claim.id;

  UPDATE reer_sh_yoonis.profile_claim_requests
  SET
    status = 'rejected',
    reviewed_at = NOW(),
    rejection_reason = COALESCE(rejection_reason, 'Another claim was approved.')
  WHERE status = 'pending'
    AND id <> v_claim.id
    AND (profile_id = v_claim.profile_id OR auth_user_id = v_auth_id);

  RAISE NOTICE 'Super admin linked to profile % (claim %). Restart the app.',
    v_claim.profile_id, v_claim.id;
END $$;
