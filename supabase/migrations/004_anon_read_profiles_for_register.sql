-- Allow reading family profiles during registration (before login)
-- Requires both RLS policy AND table-level GRANT for anon (see 005 if you get error 42501).

GRANT USAGE ON SCHEMA reer_sh_yoonis TO anon;
GRANT USAGE ON TYPE reer_sh_yoonis.user_role TO anon;
GRANT USAGE ON TYPE reer_sh_yoonis.demographic_type TO anon;
GRANT SELECT ON reer_sh_yoonis.profiles TO anon;

DROP POLICY IF EXISTS "rsy_anon_read_profiles" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_anon_read_profiles"
  ON reer_sh_yoonis.profiles FOR SELECT TO anon USING (true);

NOTIFY pgrst, 'reload config';
