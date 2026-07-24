-- Exempt everyone BELOW the grandchild generation from payment.
--
-- Example: Mire (uncle, depth 1) exempt; Nimco (his daughter, depth 2) may bill if adult;
-- Nimco's children (depth 3+) are exempt.
--
-- Depth from patriarch (walk up father_id chain):
--   0 = Sheekh Yonis (patriarch)          — exempt
--   1 = his sons (uncles, e.g. Mire)      — exempt
--   2 = grandchildren (e.g. Nimco)        — billable if adult
--   3+ = below grandchildren              — exempt (new rule)
--
-- Preview who will be newly exempt (depth >= 3):
/*
SELECT
  p.full_name,
  p.demographic,
  reer_sh_yoonis.generations_from_patriarch(p.id) AS depth_from_patriarch
FROM reer_sh_yoonis.profiles p
WHERE reer_sh_yoonis.generations_from_patriarch(p.id) >= 3
ORDER BY 3, p.full_name;
*/

CREATE OR REPLACE FUNCTION reer_sh_yoonis.generations_from_patriarch(p_profile_id UUID)
RETURNS INT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  WITH RECURSIVE chain AS (
    SELECT id, father_id, 0 AS depth
    FROM reer_sh_yoonis.profiles
    WHERE id = p_profile_id

    UNION ALL

    SELECT parent.id, parent.father_id, chain.depth + 1
    FROM reer_sh_yoonis.profiles parent
    INNER JOIN chain ON parent.id = chain.father_id
    WHERE chain.father_id IS NOT NULL
      AND chain.depth < 500
  )
  SELECT c.depth
  FROM chain c
  WHERE c.id = reer_sh_yoonis.patriarch_profile_id()
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION reer_sh_yoonis.is_profile_payment_exempt(p_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_demo reer_sh_yoonis.demographic_type;
  v_generations INT;
BEGIN
  SELECT demographic
    INTO v_demo
  FROM reer_sh_yoonis.profiles
  WHERE id = p_profile_id;

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  IF v_demo IN ('student', 'child') THEN
    RETURN TRUE;
  END IF;

  v_generations := reer_sh_yoonis.generations_from_patriarch(p_profile_id);

  -- Patriarch + uncles.
  IF v_generations IS NOT NULL AND v_generations <= 1 THEN
    RETURN TRUE;
  END IF;

  -- Below grandchild generation (great-grandchildren and deeper).
  IF v_generations IS NOT NULL AND v_generations >= 3 THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.generations_from_patriarch(UUID)
  TO authenticated, service_role;

SELECT reer_sh_yoonis.purge_exempt_contributions();

NOTIFY pgrst, 'reload config';
