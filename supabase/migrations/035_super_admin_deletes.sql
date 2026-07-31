-- Super admin can delete individual payments, treasury rows, and members.

DROP POLICY IF EXISTS "rsy_super_admin_delete_contributions" ON reer_sh_yoonis.contributions;
CREATE POLICY "rsy_super_admin_delete_contributions"
  ON reer_sh_yoonis.contributions FOR DELETE TO authenticated
  USING (reer_sh_yoonis.current_user_role() = 'super_admin');

DROP POLICY IF EXISTS "rsy_super_admin_delete_inflows" ON reer_sh_yoonis.treasury_inflows;
CREATE POLICY "rsy_super_admin_delete_inflows"
  ON reer_sh_yoonis.treasury_inflows FOR DELETE TO authenticated
  USING (reer_sh_yoonis.current_user_role() = 'super_admin');

DROP POLICY IF EXISTS "rsy_super_admin_delete_outflows" ON reer_sh_yoonis.treasury_outflows;
CREATE POLICY "rsy_super_admin_delete_outflows"
  ON reer_sh_yoonis.treasury_outflows FOR DELETE TO authenticated
  USING (reer_sh_yoonis.current_user_role() = 'super_admin');

DROP POLICY IF EXISTS "rsy_super_admin_delete_profiles" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_super_admin_delete_profiles"
  ON reer_sh_yoonis.profiles FOR DELETE TO authenticated
  USING (
    reer_sh_yoonis.current_user_role() = 'super_admin'
    AND id IS DISTINCT FROM reer_sh_yoonis.current_profile_id()
  );

-- Safe member delete: clears claim requests, then removes the profile.
CREATE OR REPLACE FUNCTION reer_sh_yoonis.delete_family_member(p_profile_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_actor UUID;
  v_patriarch UUID;
BEGIN
  IF reer_sh_yoonis.current_user_role() IS DISTINCT FROM 'super_admin' THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_actor := reer_sh_yoonis.current_profile_id();
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'profile_required';
  END IF;

  IF p_profile_id IS NULL THEN
    RAISE EXCEPTION 'invalid_profile';
  END IF;

  IF p_profile_id = v_actor THEN
    RAISE EXCEPTION 'cannot_delete_self';
  END IF;

  v_patriarch := reer_sh_yoonis.patriarch_profile_id();
  IF v_patriarch IS NOT NULL AND p_profile_id = v_patriarch THEN
    RAISE EXCEPTION 'cannot_delete_patriarch';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM reer_sh_yoonis.profiles WHERE id = p_profile_id
  ) THEN
    RAISE EXCEPTION 'profile_not_found';
  END IF;

  DELETE FROM reer_sh_yoonis.profile_claim_requests
  WHERE profile_id = p_profile_id;

  -- Clear audit FKs that are not ON DELETE SET NULL.
  UPDATE reer_sh_yoonis.contributions
  SET verified_by = NULL
  WHERE verified_by = p_profile_id;

  UPDATE reer_sh_yoonis.treasury_outflows
  SET approved_by = NULL
  WHERE approved_by = p_profile_id;

  UPDATE reer_sh_yoonis.treasury_inflows
  SET recorded_by = NULL
  WHERE recorded_by = p_profile_id;

  -- Contributions cascade; father/mother/spouse FKs are ON DELETE SET NULL.
  DELETE FROM reer_sh_yoonis.profiles
  WHERE id = p_profile_id;
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.delete_family_member(UUID)
  TO authenticated;

NOTIFY pgrst, 'reload config';
