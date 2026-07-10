-- Allow super_admin to clear contributions and treasury outflows (operational reset).
DROP POLICY IF EXISTS "rsy_super_admin_delete_contributions" ON reer_sh_yoonis.contributions;
CREATE POLICY "rsy_super_admin_delete_contributions"
  ON reer_sh_yoonis.contributions FOR DELETE TO authenticated
  USING (reer_sh_yoonis.current_user_role() = 'super_admin');

DROP POLICY IF EXISTS "rsy_super_admin_delete_outflows" ON reer_sh_yoonis.treasury_outflows;
CREATE POLICY "rsy_super_admin_delete_outflows"
  ON reer_sh_yoonis.treasury_outflows FOR DELETE TO authenticated
  USING (reer_sh_yoonis.current_user_role() = 'super_admin');
