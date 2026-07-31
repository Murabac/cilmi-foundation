-- Lift tree root to CILMI → AHMED → (SHEEKH YONIS | AADAN).
-- Adds Aadan's branch from the family spreadsheet.
-- Run after migrations 022–026. Migration 027 (deceased) is recommended but not
-- required — deceased is compared as text so this still runs without it.

BEGIN;

SELECT set_config('reer_sh_yoonis.bypass_profile_guard', 'on', true);

-- ── Ancestry ────────────────────────────────────────────────────────────────
-- CILMI (new patriarch / root)
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('63b69959-092a-41be-87d7-022ed6039508', 'CILMI', NULL, 'family_member', 'adult', 1, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- AHMED (son of Cilmi)
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9a8f920b-c582-4991-9ae0-1dc3d7715b4f', 'AHMED', NULL, 'family_member', 'adult', 1, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- AADAN (son of Ahmed; brother of Sheekh Yonis)
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a2b099ad-a92e-439d-99f0-f1aab7a2a3cf', 'AADAN', NULL, 'family_member', 'adult', 1, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- AADAN → MOHAMED
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fd8970ee-7c2a-420e-9f65-cbac25342ded', 'MOHAMED', NULL, 'family_member', 'adult', 1, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- MOHAMED → children
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order) VALUES
  ('39f65cc4-c191-42fd-9cc3-5864d5570002', 'MAWLIID', NULL, 'family_member', 'adult', 1, 0),
  ('09770a8e-e71e-4396-ba55-6c54127c23e8', 'DAAHIR', NULL, 'family_member', 'adult', 1, 1),
  ('873490b5-2422-43d5-abd4-1abdf0b57a55', 'CABDI', NULL, 'family_member', 'adult', 1, 2),
  ('5e69c86d-c5cd-45c4-a6dd-fd78a718aaa3', 'MARYAN', NULL, 'family_member', 'adult', 1, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- MAWLIID → children
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order) VALUES
  ('f7ae9941-7b4a-4443-a6e1-bc25cf256b23', 'C/NAASIR', NULL, 'family_member', 'adult', 1, 0),
  ('e60b2d5f-4d01-455b-9a7c-c0ed2217ce40', 'MOHAMED', NULL, 'family_member', 'adult', 1, 1),
  ('ccc0e36c-4593-4fd0-90e5-17ed5ecbe3da', 'SAKI', NULL, 'family_member', 'adult', 1, 2),
  ('fe63351c-1dc6-4f30-8f4c-241425ac0269', 'C/RASAQ', NULL, 'family_member', 'adult', 1, 3),
  ('5656aa51-5247-4f4c-829d-598855b90f89', 'YACQUUB', NULL, 'family_member', 'adult', 1, 4),
  ('05e0323f-a57e-4475-8d88-b4e4e0ed0b9c', 'C/LAAHI', NULL, 'family_member', 'adult', 1, 5),
  ('7a76bf5b-bd6a-4d1d-9e8b-2560a60d3dae', 'YAXYE', NULL, 'family_member', 'adult', 1, 6),
  ('096e0ed2-03f6-4854-8d47-5f2727cfc3a6', 'NAJMA', NULL, 'family_member', 'adult', 1, 7),
  ('1f0e90f4-7da7-48ee-b136-d8cf076db0fb', 'NAWAAD', NULL, 'family_member', 'adult', 1, 8),
  ('f6e301b0-f617-4f89-9fd2-26be035baecc', 'HODAN', NULL, 'family_member', 'adult', 1, 9),
  ('164b514f-3433-4175-a0ed-7a03042baf97', 'BILAN', NULL, 'family_member', 'adult', 1, 10),
  ('45b2aa90-200c-4f57-b0a9-58e1e776c56c', 'FAADUMO', NULL, 'family_member', 'adult', 1, 11),
  ('f9dc9f48-4105-4a92-9aaf-00e1405731bc', 'NAJAX', NULL, 'family_member', 'adult', 1, 12)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- DAAHIR → MOHAMED
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('bd25a3ec-a4cf-4dc4-977e-dc437b281013', 'MOHAMED', NULL, 'family_member', 'adult', 1, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- CABDI → SUHAYB
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('7aa6e616-c378-45ee-9731-72a264e9f0ea', 'SUHAYB', NULL, 'family_member', 'adult', 1, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- MARYAN → children
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order) VALUES
  ('12c11be0-ac78-4e7e-885a-96760188ec1d', 'MUNA', NULL, 'family_member', 'adult', 1, 0),
  ('87586536-6d35-43c8-8ae6-44b39dff0b94', 'SAWDA', NULL, 'family_member', 'adult', 1, 1),
  ('3847b610-2dc3-4823-9122-50a70f078342', 'MOHAMED', NULL, 'family_member', 'adult', 1, 2),
  ('4f2c3a66-9698-4c92-a78f-c213c43b3c54', 'NIMCO AYAN', NULL, 'family_member', 'adult', 1, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- ── Lineage links ────────────────────────────────────────────────────────────
UPDATE reer_sh_yoonis.profiles SET father_id = NULL
WHERE id = '63b69959-092a-41be-87d7-022ed6039508';

UPDATE reer_sh_yoonis.profiles SET father_id = '63b69959-092a-41be-87d7-022ed6039508'
WHERE id = '9a8f920b-c582-4991-9ae0-1dc3d7715b4f';

-- Existing Sheekh Yonis becomes son of Ahmed (no longer root).
UPDATE reer_sh_yoonis.profiles
SET father_id = '9a8f920b-c582-4991-9ae0-1dc3d7715b4f', birth_order = 0
WHERE id = '8bffc1ca-5143-453f-7520-3ac411fb32d4';

UPDATE reer_sh_yoonis.profiles
SET father_id = '9a8f920b-c582-4991-9ae0-1dc3d7715b4f', birth_order = 1
WHERE id = 'a2b099ad-a92e-439d-99f0-f1aab7a2a3cf';

UPDATE reer_sh_yoonis.profiles SET father_id = 'a2b099ad-a92e-439d-99f0-f1aab7a2a3cf'
WHERE id = 'fd8970ee-7c2a-420e-9f65-cbac25342ded';

UPDATE reer_sh_yoonis.profiles SET father_id = 'fd8970ee-7c2a-420e-9f65-cbac25342ded'
WHERE id IN (
  '39f65cc4-c191-42fd-9cc3-5864d5570002',
  '09770a8e-e71e-4396-ba55-6c54127c23e8',
  '873490b5-2422-43d5-abd4-1abdf0b57a55',
  '5e69c86d-c5cd-45c4-a6dd-fd78a718aaa3'
);

UPDATE reer_sh_yoonis.profiles SET father_id = '39f65cc4-c191-42fd-9cc3-5864d5570002'
WHERE id IN (
  'f7ae9941-7b4a-4443-a6e1-bc25cf256b23',
  'e60b2d5f-4d01-455b-9a7c-c0ed2217ce40',
  'ccc0e36c-4593-4fd0-90e5-17ed5ecbe3da',
  'fe63351c-1dc6-4f30-8f4c-241425ac0269',
  '5656aa51-5247-4f4c-829d-598855b90f89',
  '05e0323f-a57e-4475-8d88-b4e4e0ed0b9c',
  '7a76bf5b-bd6a-4d1d-9e8b-2560a60d3dae',
  '096e0ed2-03f6-4854-8d47-5f2727cfc3a6',
  '1f0e90f4-7da7-48ee-b136-d8cf076db0fb',
  'f6e301b0-f617-4f89-9fd2-26be035baecc',
  '164b514f-3433-4175-a0ed-7a03042baf97',
  '45b2aa90-200c-4f57-b0a9-58e1e776c56c',
  'f9dc9f48-4105-4a92-9aaf-00e1405731bc'
);

UPDATE reer_sh_yoonis.profiles SET father_id = '09770a8e-e71e-4396-ba55-6c54127c23e8'
WHERE id = 'bd25a3ec-a4cf-4dc4-977e-dc437b281013';

UPDATE reer_sh_yoonis.profiles SET father_id = '873490b5-2422-43d5-abd4-1abdf0b57a55'
WHERE id = '7aa6e616-c378-45ee-9731-72a264e9f0ea';

UPDATE reer_sh_yoonis.profiles SET father_id = '5e69c86d-c5cd-45c4-a6dd-fd78a718aaa3'
WHERE id IN (
  '12c11be0-ac78-4e7e-885a-96760188ec1d',
  '87586536-6d35-43c8-8ae6-44b39dff0b94',
  '3847b610-2dc3-4823-9122-50a70f078342',
  '4f2c3a66-9698-4c92-a78f-c213c43b3c54'
);

-- ── Helpers: patriarch is CILMI; Sheekh daughters stay special-cased ──────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.patriarch_profile_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  SELECT id
  FROM reer_sh_yoonis.profiles
  WHERE full_name ILIKE 'CILMI'
    AND father_id IS NULL
  ORDER BY full_name
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION reer_sh_yoonis.sheekh_yonis_profile_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  SELECT p.id
  FROM reer_sh_yoonis.profiles p
  WHERE p.full_name ILIKE '%SHEEKH YONIS%'
  ORDER BY
    (SELECT COUNT(*) FROM reer_sh_yoonis.profiles c WHERE c.father_id = p.id) DESC,
    (p.father_id IS NOT NULL) DESC,
    p.id
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION reer_sh_yoonis.is_patriarch_daughter(p_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM reer_sh_yoonis.profiles p
    WHERE p.id = p_profile_id
      AND p.father_id = reer_sh_yoonis.sheekh_yonis_profile_id()
      AND upper(trim(p.full_name)) NOT LIKE '%SHEEKH YONIS%'
      AND (
        upper(trim(p.full_name)) LIKE '% SHEEKH'
        OR upper(trim(p.full_name)) LIKE '% SHEEK'
      )
  );
$$;

-- Depths relative to Sheekh Yonis (same rule as Dart payment_exempt.dart):
-- sheekhDepth+0 Sheekh/Aadan peers via Cilmi, +1 their sons (uncles), +2 grandchildren billable, +3 below exempt
CREATE OR REPLACE FUNCTION reer_sh_yoonis.is_profile_payment_exempt(p_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_demo reer_sh_yoonis.demographic_type;
  v_override TEXT;
  v_father_id UUID;
  v_marital_text TEXT;
  v_generations INT;
  v_sheekh_id UUID;
  v_sheekh_depth INT;
BEGIN
  SELECT demographic, billing_override, father_id, marital_status::text
    INTO v_demo, v_override, v_father_id, v_marital_text
  FROM reer_sh_yoonis.profiles
  WHERE id = p_profile_id;

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  IF v_override = 'exempt' THEN
    RETURN TRUE;
  END IF;
  IF v_override = 'billable' THEN
    RETURN FALSE;
  END IF;

  IF v_demo IN ('student', 'child') THEN
    RETURN TRUE;
  END IF;

  -- Text compare so this works before marital_status enum includes 'deceased'.
  IF v_marital_text = 'deceased' THEN
    RETURN TRUE;
  END IF;

  v_generations := reer_sh_yoonis.generations_from_patriarch(p_profile_id);
  v_sheekh_id := reer_sh_yoonis.sheekh_yonis_profile_id();
  IF v_sheekh_id IS NULL THEN
    v_sheekh_depth := 0;
  ELSE
    v_sheekh_depth := COALESCE(
      reer_sh_yoonis.generations_from_patriarch(v_sheekh_id),
      0
    );
  END IF;

  -- Cilmi/Ahmed/Sheekh|Aadan + their sons (uncles); or legacy Sheekh + sons.
  IF v_generations IS NOT NULL AND v_generations <= v_sheekh_depth + 1 THEN
    RETURN TRUE;
  END IF;

  -- Kids of Sheekh Yonis daughters.
  IF v_father_id IS NOT NULL
     AND reer_sh_yoonis.is_patriarch_daughter(v_father_id) THEN
    RETURN TRUE;
  END IF;

  -- Below Sheekh-grandchild generation.
  IF v_generations IS NOT NULL AND v_generations >= v_sheekh_depth + 3 THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.patriarch_profile_id() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.sheekh_yonis_profile_id() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.is_patriarch_daughter(UUID) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.is_profile_payment_exempt(UUID) TO authenticated, service_role;

SELECT reer_sh_yoonis.purge_exempt_contributions();

SELECT set_config('reer_sh_yoonis.bypass_profile_guard', 'off', true);

COMMIT;

NOTIFY pgrst, 'reload config';
