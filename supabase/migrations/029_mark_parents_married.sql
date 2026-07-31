-- Mark parents in the tree as married.
-- Rule: anyone who has at least one child (father_id points to them) is married.
-- Only updates null/single — leaves any other status alone.
-- Safe without migration 027 (does not reference deceased).
-- Run in the Supabase SQL editor after the family tree is loaded.

BEGIN;

SELECT set_config('reer_sh_yoonis.bypass_profile_guard', 'on', true);

UPDATE reer_sh_yoonis.profiles AS p
SET marital_status = 'married'
WHERE EXISTS (
  SELECT 1
  FROM reer_sh_yoonis.profiles AS child
  WHERE child.father_id = p.id
)
AND (p.marital_status IS NULL OR p.marital_status = 'single');

-- Preview counts after update
SELECT
  marital_status::text AS status,
  COUNT(*) AS members
FROM reer_sh_yoonis.profiles
GROUP BY marital_status
ORDER BY status NULLS FIRST;

SELECT set_config('reer_sh_yoonis.bypass_profile_guard', 'off', true);

COMMIT;
