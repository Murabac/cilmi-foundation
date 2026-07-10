-- Fix table grants and allow users to create their own profile on first login
-- Run if the app shows empty screens or "permission denied" errors.

GRANT USAGE ON SCHEMA reer_sh_yoonis TO authenticated, service_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA reer_sh_yoonis
  TO authenticated, service_role;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA reer_sh_yoonis
  TO authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA reer_sh_yoonis
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA reer_sh_yoonis
  GRANT EXECUTE ON FUNCTIONS TO authenticated, service_role;

-- Authenticated users can create their own profile row (links auth → app)
DROP POLICY IF EXISTS "rsy_users_insert_own_profile" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_users_insert_own_profile"
  ON reer_sh_yoonis.profiles FOR INSERT TO authenticated
  WITH CHECK (auth_user_id = auth.uid());

NOTIFY pgrst, 'reload config';
