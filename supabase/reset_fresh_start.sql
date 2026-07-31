-- Full reset: wipe all Reer Sh Yoonis data and auth accounts, then load seed_family.sql.
-- Run this in Supabase → SQL Editor (requires project owner / postgres role).
--
-- After this succeeds, run the entire contents of supabase/seed_family.sql in a second query.

BEGIN;

-- 1. Operational data (references profiles)
DELETE FROM reer_sh_yoonis.contributions;
DELETE FROM reer_sh_yoonis.treasury_inflows;
DELETE FROM reer_sh_yoonis.treasury_outflows;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'reer_sh_yoonis'
      AND table_name = 'profile_claim_requests'
  ) THEN
    DELETE FROM reer_sh_yoonis.profile_claim_requests;
  END IF;
END $$;

-- 2. Break lineage / claim links so profiles can be removed
UPDATE reer_sh_yoonis.profiles
SET
  father_id = NULL,
  mother_id = NULL,
  spouse_id = NULL,
  auth_user_id = NULL;

-- 3. Remove every tree member (seed + signup duplicates + orphans)
DELETE FROM reer_sh_yoonis.profiles;

-- 4. Delete all app auth accounts (you will need to sign up again)
DELETE FROM auth.users
WHERE COALESCE(raw_user_meta_data->>'app', '') = 'reer_sh_yoonis';

-- 5. Avatars: Supabase blocks DELETE on storage.objects from SQL.
--    To clear them: Dashboard → Storage → reer-sh-yoonis-avatars → select all → Delete
--    (Optional — old avatars won't affect the fresh tree seed.)

COMMIT;

-- Verify wipe (should all be 0 before seeding)
SELECT 'profiles' AS table_name, COUNT(*) AS rows FROM reer_sh_yoonis.profiles
UNION ALL
SELECT 'contributions', COUNT(*) FROM reer_sh_yoonis.contributions
UNION ALL
SELECT 'treasury_outflows', COUNT(*) FROM reer_sh_yoonis.treasury_outflows
UNION ALL
SELECT 'auth_users_app', COUNT(*)
FROM auth.users
WHERE COALESCE(raw_user_meta_data->>'app', '') = 'reer_sh_yoonis';

-- Next step: paste and run supabase/seed_family.sql
-- Expected result: 261 profiles, 1 patriarch (SHEEKH YONIS)
