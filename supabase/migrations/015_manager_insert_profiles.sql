-- Super admins and managers can add unclaimed family tree members.
DROP POLICY IF EXISTS "rsy_super_admin_insert_profiles" ON reer_sh_yoonis.profiles;
DROP POLICY IF EXISTS "rsy_managers_insert_profiles" ON reer_sh_yoonis.profiles;

CREATE POLICY "rsy_admins_insert_profiles"
  ON reer_sh_yoonis.profiles FOR INSERT TO authenticated
  WITH CHECK (reer_sh_yoonis.is_admin_or_manager());

NOTIFY pgrst, 'reload config';
