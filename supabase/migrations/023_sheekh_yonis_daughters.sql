-- Daughters of Sheekh Yonis and their children (external fathers named in full_name).
-- Children link to their mother via father_id so they appear under her in the pedigree tree.
-- Run in Supabase SQL Editor after seed + migration 022.

BEGIN;

-- Required: migration 021 blocks lineage fields unless this bypass is set.
SELECT set_config('reer_sh_yoonis.bypass_profile_guard', 'on', true);

-- Patriarch reference: 8bffc1ca-5143-453f-7520-3ac411fb32d4 (SHEEKH YONIS)

-- ── Daughters ────────────────────────────────────────────────────────────────
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2730e806-b3f4-5cec-fb5b-94ab382d3d98', 'KHADRA SHEEKH', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('5356252b-2fb7-69a2-d1a6-0facb6342f05', 'CAASHA SHEEKH', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('19af258a-e1f2-4e9e-0d27-41dfe9090a55', 'SAADA SHEEKH', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0bfdba67-fce9-305f-b7fd-9a7328233f8c', 'XALIIMO SHEEKH', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ee53f67f-4a84-b095-c283-a777470c6dee', 'FOOSIYA SHEEKH', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('701ee62d-7b49-3725-b120-55479200bf32', 'FAYSA SHEEKH', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- ── KHADRA SHEEKH → children (father ISMAIL) ─────────────────────────────────
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order) VALUES
  ('494bc07a-5cac-4097-c1e3-d112379628bb', 'SAYNAB ISMAIL', NULL, 'family_member', 'adult', 2, 0),
  ('2b3d42ab-5cf0-aa3f-619a-c37a0760b88c', 'ROODA ISMAIL', NULL, 'family_member', 'adult', 2, 1),
  ('c77f09b5-eb0e-6a80-eb86-c581934790d9', 'YURUB ISMAIL', NULL, 'family_member', 'adult', 2, 2),
  ('d3f87f75-f278-d573-b45a-ecbfbae2aaf0', 'AHMED ISMAIL', NULL, 'family_member', 'adult', 2, 3),
  ('4aa9a804-e19c-9464-260f-60d9fbff5aaa', 'NAFIISA ISMAIL', NULL, 'family_member', 'adult', 2, 4),
  ('c4800595-5ed6-f950-bbd8-34673a9c3d67', 'SUCAAD ISMAIL', NULL, 'family_member', 'adult', 2, 5),
  ('2a250cb3-d437-3b81-2175-3e1b1938cc90', 'MUSTAFE ISMAIL', NULL, 'family_member', 'adult', 2, 6),
  ('a51807ec-6fb0-ef69-1bd6-ef15d8aa7515', 'AAMINA ISMAIL', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- ── CAASHA SHEEKH → children (father JAAMAC) ───────────────────────────────
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order) VALUES
  ('9ec1035f-46a2-472b-b881-350f4cb5d9da', 'AHMED JAAMAC', NULL, 'family_member', 'adult', 2, 0),
  ('9fde50f9-d97f-ea2c-9761-10798e27fc1b', 'SAFIYA JAAMAC', NULL, 'family_member', 'adult', 2, 1),
  ('921e25af-8c08-7c06-e268-a027787a3da8', 'MAHMOOD JAAMAC', NULL, 'family_member', 'adult', 2, 2),
  ('a53d0a9b-2ada-d3cc-675b-d1d600b578f2', 'MUKHTAR JAAMAC', NULL, 'family_member', 'adult', 2, 3),
  ('a4e27674-52b9-7924-88a2-cf0bae4ac996', 'MUHUMED JAAMAC', NULL, 'family_member', 'adult', 2, 4),
  ('25edc5fa-fbb5-c818-b1b8-aca570ad8b57', 'CUMAR JAAMAC', NULL, 'family_member', 'adult', 2, 5),
  ('a4de3d48-2571-29ea-1724-7a60e3d428c9', 'CABDI JAAMAC', NULL, 'family_member', 'adult', 2, 6),
  ('a3ebed01-65bf-d28e-d5f0-a7f44a528990', 'FAHIIMA JAAMAC', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- ── SAADA SHEEKH → children (father WARSAME) ───────────────────────────────
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order) VALUES
  ('d592e4a1-47ea-7755-893a-b64f6db13562', 'NACIIMA WARSAME', NULL, 'family_member', 'adult', 2, 0),
  ('4fd897da-094b-dd05-7131-02d66ffcd7f3', 'MOHAMED WARSAME', NULL, 'family_member', 'adult', 2, 1),
  ('2e21de34-cdf1-a739-0319-3b6e560e39cc', 'SUCAAD WARSAME', NULL, 'family_member', 'adult', 2, 2),
  ('f4d86202-1d73-b3b3-b47b-9bf986b8cab2', 'KHADRA WARSAME', NULL, 'family_member', 'adult', 2, 3),
  ('93106213-c302-4c7c-092b-c3e6b167566a', 'AHMED WARSAME', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- ── XALIIMO SHEEKH → children (father CABDI) ───────────────────────────────
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order) VALUES
  ('37052234-e714-7a88-94dd-299ba7cc3fce', 'DAYIB CABDI', NULL, 'family_member', 'adult', 2, 0),
  ('4b87a367-7dcb-44ed-31a1-5c87b66aad6d', 'AHMED CABDI', NULL, 'family_member', 'adult', 2, 1),
  ('586f87ba-5498-5f4f-efd3-38c115921e46', 'XUSEEN CABDI', NULL, 'family_member', 'adult', 2, 2),
  ('d4dff2b0-968b-4cb7-3339-d737fc865acc', 'IID CABDI', NULL, 'family_member', 'adult', 2, 3),
  ('9f952128-6b0b-c649-6630-f28f80059792', 'SAHRA CABDI', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- ── FOOSIYA SHEEKH → children (father JAAMAC) ──────────────────────────────
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order) VALUES
  ('d6fd8d5c-d443-4131-90f3-a579c2e83a5a', 'NUURADIIN JAAMAC', NULL, 'family_member', 'adult', 2, 0),
  ('e7bf71f3-5669-1d3b-7fd9-feaf0fec5d39', 'MUXIYADIIN JAAMAC', NULL, 'family_member', 'adult', 2, 1),
  ('2a458b49-9588-8bba-5a55-dade04f52655', 'XAMDA JAAMAC', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- ── FAYSA SHEEKH → child (external father unknown / blank) ───────────────────
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2bb664de-fd52-9761-cd78-1cb3a5b7dff7', 'C/RAHMAN', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- ── Lineage links ────────────────────────────────────────────────────────────
-- Daughters → Sheekh Yonis
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '2730e806-b3f4-5cec-fb5b-94ab382d3d98';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '5356252b-2fb7-69a2-d1a6-0facb6342f05';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '19af258a-e1f2-4e9e-0d27-41dfe9090a55';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '0bfdba67-fce9-305f-b7fd-9a7328233f8c';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'ee53f67f-4a84-b095-c283-a777470c6dee';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '701ee62d-7b49-3725-b120-55479200bf32';

-- Children → mother (tree parent link; external father is in full_name only)
UPDATE reer_sh_yoonis.profiles SET father_id = '2730e806-b3f4-5cec-fb5b-94ab382d3d98' WHERE id IN (
  '494bc07a-5cac-4097-c1e3-d112379628bb', '2b3d42ab-5cf0-aa3f-619a-c37a0760b88c',
  'c77f09b5-eb0e-6a80-eb86-c581934790d9', 'd3f87f75-f278-d573-b45a-ecbfbae2aaf0',
  '4aa9a804-e19c-9464-260f-60d9fbff5aaa', 'c4800595-5ed6-f950-bbd8-34673a9c3d67',
  '2a250cb3-d437-3b81-2175-3e1b1938cc90', 'a51807ec-6fb0-ef69-1bd6-ef15d8aa7515'
);
UPDATE reer_sh_yoonis.profiles SET father_id = '5356252b-2fb7-69a2-d1a6-0facb6342f05' WHERE id IN (
  '9ec1035f-46a2-472b-b881-350f4cb5d9da', '9fde50f9-d97f-ea2c-9761-10798e27fc1b',
  '921e25af-8c08-7c06-e268-a027787a3da8', 'a53d0a9b-2ada-d3cc-675b-d1d600b578f2',
  'a4e27674-52b9-7924-88a2-cf0bae4ac996', '25edc5fa-fbb5-c818-b1b8-aca570ad8b57',
  'a4de3d48-2571-29ea-1724-7a60e3d428c9', 'a3ebed01-65bf-d28e-d5f0-a7f44a528990'
);
UPDATE reer_sh_yoonis.profiles SET father_id = '19af258a-e1f2-4e9e-0d27-41dfe9090a55' WHERE id IN (
  'd592e4a1-47ea-7755-893a-b64f6db13562', '4fd897da-094b-dd05-7131-02d66ffcd7f3',
  '2e21de34-cdf1-a739-0319-3b6e560e39cc', 'f4d86202-1d73-b3b3-b47b-9bf986b8cab2',
  '93106213-c302-4c7c-092b-c3e6b167566a'
);
UPDATE reer_sh_yoonis.profiles SET father_id = '0bfdba67-fce9-305f-b7fd-9a7328233f8c' WHERE id IN (
  '37052234-e714-7a88-94dd-299ba7cc3fce', '4b87a367-7dcb-44ed-31a1-5c87b66aad6d',
  '586f87ba-5498-5f4f-efd3-38c115921e46', 'd4dff2b0-968b-4cb7-3339-d737fc865acc',
  '9f952128-6b0b-c649-6630-f28f80059792'
);
UPDATE reer_sh_yoonis.profiles SET father_id = 'ee53f67f-4a84-b095-c283-a777470c6dee' WHERE id IN (
  'd6fd8d5c-d443-4131-90f3-a579c2e83a5a', 'e7bf71f3-5669-1d3b-7fd9-feaf0fec5d39',
  '2a458b49-9588-8bba-5a55-dade04f52655'
);
UPDATE reer_sh_yoonis.profiles SET father_id = '701ee62d-7b49-3725-b120-55479200bf32' WHERE id = '2bb664de-fd52-9761-cd78-1cb3a5b7dff7';

SELECT set_config('reer_sh_yoonis.bypass_profile_guard', 'off', true);

COMMIT;
