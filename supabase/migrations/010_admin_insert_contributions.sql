-- Allow managers/admins to create contribution rows when recording phone payments
DROP POLICY IF EXISTS "rsy_managers_insert_contributions" ON reer_sh_yoonis.contributions;
CREATE POLICY "rsy_managers_insert_contributions"
  ON reer_sh_yoonis.contributions FOR INSERT TO authenticated
  WITH CHECK (reer_sh_yoonis.is_admin_or_manager());

NOTIFY pgrst, 'reload config';
