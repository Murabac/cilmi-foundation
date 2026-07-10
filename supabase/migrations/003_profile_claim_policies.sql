-- Allow users to claim an existing unlinked family profile on registration
DROP POLICY IF EXISTS "rsy_users_claim_unlinked_profile" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_users_claim_unlinked_profile"
  ON reer_sh_yoonis.profiles FOR UPDATE TO authenticated
  USING (auth_user_id IS NULL)
  WITH CHECK (auth_user_id = auth.uid());

-- Users may set father_id on their own profile during lineage setup
DROP POLICY IF EXISTS "rsy_users_set_own_father" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_users_set_own_father"
  ON reer_sh_yoonis.profiles FOR UPDATE TO authenticated
  USING (auth_user_id = auth.uid())
  WITH CHECK (auth_user_id = auth.uid());

NOTIFY pgrst, 'reload config';
