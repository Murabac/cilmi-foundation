-- Keep tree profiles when an auth account is deleted (unlink instead of CASCADE delete).
-- Also release profiles still pointing at deleted auth users.

ALTER TABLE reer_sh_yoonis.profiles
  DROP CONSTRAINT IF EXISTS profiles_auth_user_id_fkey;

ALTER TABLE reer_sh_yoonis.profiles
  ADD CONSTRAINT profiles_auth_user_id_fkey
  FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

-- Profiles left linked to auth users that no longer exist.
UPDATE reer_sh_yoonis.profiles p
SET auth_user_id = NULL
WHERE p.auth_user_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM auth.users u WHERE u.id = p.auth_user_id
  );

CREATE OR REPLACE FUNCTION reer_sh_yoonis.release_stale_profile_claims()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_count integer;
BEGIN
  IF reer_sh_yoonis.current_user_role() <> 'super_admin' THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  UPDATE reer_sh_yoonis.profiles p
  SET auth_user_id = NULL
  WHERE p.auth_user_id IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM auth.users u WHERE u.id = p.auth_user_id
    );

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

CREATE OR REPLACE FUNCTION reer_sh_yoonis.release_profile_claim(p_profile_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
BEGIN
  IF reer_sh_yoonis.current_user_role() <> 'super_admin' THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  UPDATE reer_sh_yoonis.profiles
  SET auth_user_id = NULL
  WHERE id = p_profile_id;
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.release_stale_profile_claims() TO authenticated;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.release_profile_claim(uuid) TO authenticated;

NOTIFY pgrst, 'reload config';

-- If a tree member disappeared after deleting their auth account (old CASCADE behavior),
-- re-run supabase/seed_family.sql in the SQL editor to restore missing profiles.
