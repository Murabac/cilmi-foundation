-- Fix error 42501 (permission denied) on the registration screen.
-- Migration 004 added the RLS policy but anon also needs table-level GRANTs.

GRANT USAGE ON SCHEMA reer_sh_yoonis TO anon;

GRANT USAGE ON TYPE reer_sh_yoonis.user_role TO anon;
GRANT USAGE ON TYPE reer_sh_yoonis.demographic_type TO anon;

GRANT SELECT ON reer_sh_yoonis.profiles TO anon;

-- Ensure RLS policy exists (idempotent with 004)
DROP POLICY IF EXISTS "rsy_anon_read_profiles" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_anon_read_profiles"
  ON reer_sh_yoonis.profiles FOR SELECT TO anon USING (true);

-- Ensure authenticated users can link profile after sign-up
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA reer_sh_yoonis
  TO authenticated;

DROP POLICY IF EXISTS "rsy_users_insert_own_profile" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_users_insert_own_profile"
  ON reer_sh_yoonis.profiles FOR INSERT TO authenticated
  WITH CHECK (auth_user_id = auth.uid());

DROP POLICY IF EXISTS "rsy_users_claim_unlinked_profile" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_users_claim_unlinked_profile"
  ON reer_sh_yoonis.profiles FOR UPDATE TO authenticated
  USING (auth_user_id IS NULL)
  WITH CHECK (auth_user_id = auth.uid());

DROP POLICY IF EXISTS "rsy_users_set_own_father" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_users_set_own_father"
  ON reer_sh_yoonis.profiles FOR UPDATE TO authenticated
  USING (auth_user_id = auth.uid())
  WITH CHECK (auth_user_id = auth.uid());

DROP POLICY IF EXISTS "rsy_users_delete_own_orphan_profile" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_users_delete_own_orphan_profile"
  ON reer_sh_yoonis.profiles FOR DELETE TO authenticated
  USING (auth_user_id = auth.uid() AND father_id IS NULL);

NOTIFY pgrst, 'reload config';
