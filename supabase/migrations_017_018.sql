-- Run this if you ALREADY have migrations 001-016 (do NOT run all_migrations.sql).
-- If you see "type user_role already exists", your DB is not empty â€” use this file instead.

-- 017_security_and_claim_requests.sql
-- Security hardening + admin-approved profile linking.
-- Run in Supabase SQL Editor after 016_profile_birth_order.sql.

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Profile claim requests (admin approval required before linking)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TYPE reer_sh_yoonis.claim_request_status AS ENUM (
  'pending',
  'approved',
  'rejected'
);

CREATE TABLE reer_sh_yoonis.profile_claim_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES reer_sh_yoonis.profiles(id) ON DELETE CASCADE,
  auth_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  requester_name VARCHAR(255) NOT NULL,
  requester_phone VARCHAR(50),
  status reer_sh_yoonis.claim_request_status NOT NULL DEFAULT 'pending',
  reviewed_by UUID REFERENCES reer_sh_yoonis.profiles(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_rsy_one_pending_claim_per_profile
  ON reer_sh_yoonis.profile_claim_requests (profile_id)
  WHERE status = 'pending';

CREATE UNIQUE INDEX idx_rsy_one_pending_claim_per_user
  ON reer_sh_yoonis.profile_claim_requests (auth_user_id)
  WHERE status = 'pending';

CREATE INDEX idx_rsy_claim_requests_status
  ON reer_sh_yoonis.profile_claim_requests (status, created_at DESC);

ALTER TABLE reer_sh_yoonis.profile_claim_requests ENABLE ROW LEVEL SECURITY;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Protect role / auth_user_id from client-side escalation
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
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS rsy_protect_profile_columns ON reer_sh_yoonis.profiles;
CREATE TRIGGER rsy_protect_profile_columns
  BEFORE INSERT OR UPDATE ON reer_sh_yoonis.profiles
  FOR EACH ROW EXECUTE FUNCTION reer_sh_yoonis.protect_profile_sensitive_columns();

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Claim RPCs (only path to link auth_user_id on seed profiles)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.submit_profile_claim(
  p_profile_id UUID,
  p_requester_name TEXT,
  p_requester_phone TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_id UUID;
  v_name TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_name := NULLIF(trim(p_requester_name), '');
  IF v_name IS NULL THEN
    RAISE EXCEPTION 'name_required';
  END IF;

  IF EXISTS (
    SELECT 1 FROM reer_sh_yoonis.profiles
    WHERE auth_user_id = auth.uid() AND father_id IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'already_linked';
  END IF;

  IF EXISTS (
    SELECT 1 FROM reer_sh_yoonis.profile_claim_requests
    WHERE auth_user_id = auth.uid() AND status = 'pending'
  ) THEN
    RAISE EXCEPTION 'pending_request_exists';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM reer_sh_yoonis.profiles
    WHERE id = p_profile_id AND auth_user_id IS NULL
  ) THEN
    RAISE EXCEPTION 'profile_not_available';
  END IF;

  IF EXISTS (
    SELECT 1 FROM reer_sh_yoonis.profile_claim_requests
    WHERE profile_id = p_profile_id AND status = 'pending'
  ) THEN
    RAISE EXCEPTION 'profile_pending_claim';
  END IF;

  INSERT INTO reer_sh_yoonis.profile_claim_requests (
    profile_id,
    auth_user_id,
    requester_name,
    requester_phone
  )
  VALUES (
    p_profile_id,
    auth.uid(),
    v_name,
    NULLIF(trim(p_requester_phone), '')
  )
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

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

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.submit_profile_claim(UUID, TEXT, TEXT)
  TO authenticated;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.approve_profile_claim(UUID)
  TO authenticated;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.reject_profile_claim(UUID, TEXT)
  TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. RLS: claim requests + remove direct profile claim policy
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "rsy_users_claim_unlinked_profile" ON reer_sh_yoonis.profiles;

DROP POLICY IF EXISTS "rsy_users_read_own_claim_requests" ON reer_sh_yoonis.profile_claim_requests;
CREATE POLICY "rsy_users_read_own_claim_requests"
  ON reer_sh_yoonis.profile_claim_requests FOR SELECT TO authenticated
  USING (auth_user_id = auth.uid());

DROP POLICY IF EXISTS "rsy_admins_read_claim_requests" ON reer_sh_yoonis.profile_claim_requests;
CREATE POLICY "rsy_super_admin_read_claim_requests"
  ON reer_sh_yoonis.profile_claim_requests FOR SELECT TO authenticated
  USING (reer_sh_yoonis.current_user_role() = 'super_admin');

-- Inserts/updates only via SECURITY DEFINER RPCs.

-- Remove anonymous full profile read (registration happens after sign-in).
DROP POLICY IF EXISTS "rsy_anon_read_profiles" ON reer_sh_yoonis.profiles;
REVOKE SELECT ON reer_sh_yoonis.profiles FROM anon;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Treasury: force balance-checked RPC (no direct INSERT)
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "rsy_managers_insert_outflows" ON reer_sh_yoonis.treasury_outflows;

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

  v_approver := COALESCE(p_approved_by, reer_sh_yoonis.current_profile_id());

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
    v_approver
  );
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.record_treasury_outflow(UUID, NUMERIC, TEXT, UUID)
  TO authenticated;

GRANT SELECT ON reer_sh_yoonis.profile_claim_requests TO authenticated;

NOTIFY pgrst, 'reload config';

-- 018_super_admin_claim_approval.sql
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
