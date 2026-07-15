-- Quick check: what is already installed? (one result table)
-- Run in Supabase SQL Editor.

SELECT 'profiles table' AS item,
       CASE WHEN EXISTS (
         SELECT 1 FROM information_schema.tables
         WHERE table_schema = 'reer_sh_yoonis' AND table_name = 'profiles'
       ) THEN 'YES' ELSE 'NO' END AS status,
       1 AS sort_order

UNION ALL

SELECT 'birth_order column (016)',
       CASE WHEN EXISTS (
         SELECT 1 FROM information_schema.columns
         WHERE table_schema = 'reer_sh_yoonis'
           AND table_name = 'profiles'
           AND column_name = 'birth_order'
       ) THEN 'YES' ELSE 'NO — run 016_profile_birth_order.sql' END,
       2

UNION ALL

SELECT 'profile_claim_requests (017)',
       CASE WHEN EXISTS (
         SELECT 1 FROM information_schema.tables
         WHERE table_schema = 'reer_sh_yoonis' AND table_name = 'profile_claim_requests'
       ) THEN 'YES' ELSE 'NO — run migrations_017_018.sql' END,
       3

UNION ALL

SELECT 'signup trigger fix (019)',
       CASE WHEN EXISTS (
         SELECT 1
         FROM pg_proc p
         JOIN pg_namespace n ON n.oid = p.pronamespace
         WHERE n.nspname = 'reer_sh_yoonis'
           AND p.proname = 'handle_new_user'
           AND pg_get_functiondef(p.oid) LIKE '%bypass_profile_guard%'
       ) THEN 'YES' ELSE 'NO — run 019_fix_signup_handle_new_user.sql' END,
       4

UNION ALL

SELECT 'security hardening (021)',
       CASE WHEN EXISTS (
         SELECT 1
         FROM pg_proc p
         JOIN pg_namespace n ON n.oid = p.pronamespace
         WHERE n.nspname = 'reer_sh_yoonis'
           AND p.proname = 'is_profile_payment_exempt'
       ) THEN 'YES' ELSE 'NO — run 021_security_lineage_and_payment_hardening.sql' END,
       5

UNION ALL

SELECT 'seed family tree',
       (SELECT COUNT(*)::text FROM reer_sh_yoonis.profiles) || ' profiles',
       6

ORDER BY sort_order;
