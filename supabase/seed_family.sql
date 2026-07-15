-- Reer Sh Yoonis family tree seed (from SHEEK YOONIS CSV)
-- Run after 001_initial_schema.sql and 016_profile_birth_order.sql
BEGIN;

-- Insert all profiles
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('8bffc1ca-5143-453f-7520-3ac411fb32d4', 'SHEEKH YONIS', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b46b1f9b-7564-6d6b-239a-11d95bc02099', 'CABDIQADIR', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3a6c4b11-1992-16bd-6d45-1d8f4a05a3cb', 'FADXIYA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('27285597-3166-f908-eb79-df40a47fa83d', 'XAMDA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('30ab04ce-d56c-1f07-6a3b-ea07784ddff7', 'MOHAMED', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e39b1fe9-aa72-e39b-8af9-01a76c79349a', 'CISMAAN', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9172d34a-c323-e233-43f7-d72b6c48d12e', 'C/QADIR', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a09146a4-0d4a-4a73-f880-7c5f909ab364', 'YOONIS', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3dccfdb3-2129-8c48-adb8-4e2676ff7f97', 'MARWA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b68c85f7-ee32-427e-bfc1-2627faccd141', 'MOHAMED', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e568b377-596c-911a-03ac-2c48c1fa165c', 'CABDALE', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d61e7998-4fcf-beff-b8a7-e19a31ade915', 'ANAS', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('597819d6-d7ae-ee36-bf9e-84c1ef7eb401', 'NUURA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fa478548-074f-dc76-6c69-6a78aa92d422', 'SIHAAM', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b4c7d30d-8610-9fb1-9194-206a531c1870', 'SAKARIYE', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6ca99335-a5ed-c9f0-ef61-370dd1537bbf', 'SICIID', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c6e8dbe3-2b27-7c5b-4d3f-9306630f5173', 'SAFA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('7e74c758-65d6-3081-8b54-0f9fd1a849ca', 'SUMAYA', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a3f8746e-e295-7c4e-9bc3-927009138724', 'SAKIYA', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3e3147e0-e128-f616-c5d9-f5a0aed2fe7d', 'SUWAYDA', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('29b0776d-3772-3c57-609f-f7387ca404e3', 'MARWA', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('aea54731-c707-6e02-7910-e6d0733a3fb7', 'CALI', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('497aed43-5e7d-aee3-9e85-b4850d7c4b22', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('acf88805-0539-8a77-604e-33444269c311', 'CABDILAAHI', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9d8ec945-6a04-e70f-e8d8-20df20a8d826', 'FAYSAL', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('da390d9f-c0ae-0093-3fda-6e47a2cd5f33', 'C/NAASIR', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('4989fc43-458e-4746-4f18-ef65cc1f8a93', 'NADIIRA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('365d78c8-ae83-fa42-675d-9b8be641288e', 'C/QANI', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3216b902-2908-5814-d812-6de0cb31fbdc', 'C/FATAH', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('bd77350d-16bd-bb66-de4f-8f670c837fc8', 'XAMDA', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e7fc954b-f0f0-5287-a60c-2fa58d3baebb', 'XAMSE', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a046dee0-bec6-09eb-4e50-a9ee30f1eba8', 'XANAAN', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e320e41b-56c3-8409-1966-964f3d49c3a3', 'NIMCO', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('5e66c081-18ee-51aa-e292-ad64022bac42', 'SAFA', NULL, 'family_member', 'adult', 2, 8)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f9dc98ef-9399-8161-c35c-6b5d3d97c8da', 'C/LAAHI', NULL, 'family_member', 'adult', 2, 9)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('46026503-519e-36a6-e2b2-68e99a4a5db5', 'MUMTAS', NULL, 'family_member', 'adult', 2, 10)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3ed22580-4b2b-8742-6be6-03ef9ebdb1b1', 'SAMIIRA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c3f8197a-b3f3-c56f-d8bd-f309cdbb5759', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('28996ccc-b9cf-d27b-3ba3-c9c7d93d712f', 'FILSAN', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('34561d7d-bb8b-8689-6db6-898f9e04db26', 'MUBARAK', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ce2b7264-acf1-112a-cb58-f32e729fc9d8', 'CAWO', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('7642f2b4-4d92-108e-63fc-45611d98723f', 'SUBEER', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e0b62f81-cbde-3b9b-2356-5175e212e28e', 'NASTEEXO', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('46a26395-f601-2ca0-4d83-3c0d8dfb1972', 'RAYAAN', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('17777882-ada6-9039-be64-d6869e0e5324', 'CUMAR', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9e62c76f-c2ef-1e65-da6b-2cd1878ea197', 'HANA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e270cb59-bae2-9903-8a52-87b598dfc2ac', 'AMIIN', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('8d50afa3-fb75-ec0d-3cba-e47e881646cb', 'C/LAAHI', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ac55d45e-3ff0-8436-daf0-65a85b55ca8a', 'HUDA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('99ff430a-fa66-6278-138e-5cb8a041f9b7', 'HADIYA', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b61e7fe2-131e-a307-ea6f-2e40ae19c2ac', 'C/RAHMAN', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e668f661-6c95-0b86-6699-76e1ae5b2656', 'C/RASHIID', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f2e55bbf-864b-0dea-966d-354a60c8a6bb', 'YAXYE', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('4f5753f7-36d9-1904-8971-f2328e8b6f9e', 'CAYDARUUS', NULL, 'family_member', 'adult', 2, 8)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('789dff60-bc8f-5987-e341-082ad0967818', 'SUBEER', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('242f6d5e-f08d-70ff-36c9-2cb3f8d19cfc', 'XAFSA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fcf8b87a-326d-4122-138f-b24a47a84989', 'MOHAMED', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a7411d4a-7e30-27df-be39-694a074783ed', 'KHALID', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9bc926ec-2cd7-0a1a-f447-5e6db4e81933', 'MUUSE', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0f786735-37b7-7e24-0392-9d9faa738f5a', 'SUHAYB', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3e1a75a6-8ced-85ae-b074-2e1c98e7e60a', 'SUMAYA', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('55102671-b386-a11c-0964-c53cd32db514', 'SALMAN', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a94f8eb9-ef6b-b55d-0e63-e460b7a046e6', 'SAFA', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('4c363e66-481e-5f09-d39b-dd6b24e88a50', 'SACAD', NULL, 'family_member', 'adult', 2, 8)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fbe3985e-240e-18e5-d2b0-2531d2e36f1b', 'C/RAHMAN', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2ba15c8c-b5ec-b1a4-5fa7-37a54de91b9e', 'MABSUUD', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1b57850f-2537-3a95-90e0-b6cf37a67bf1', 'MOHAMED', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3813f11f-4797-58da-7dee-d3c74ccaa1ce', 'MAARIYA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0abd86b3-d0e9-6244-11ee-a083861b1cda', 'MUSCAB', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1b6b2eea-cf51-8d2a-52ee-e805ee909d77', 'MARWA', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('896a25e4-b35e-b339-dd7b-ee2a520151ea', 'ROODA', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('af0d7f9c-c364-6812-63a8-a43971d3f1db', 'CIISE', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a27e6bf6-ac61-e2f4-1ee3-b50a43aca765', 'SICIID', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('98c98966-7832-e468-90ef-df0fa0e29090', 'MOHAMED', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('98c58a8d-197b-9002-61c5-9b75058978c3', 'ASMA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ab3f9a30-834a-bef7-7256-9341c7398bc6', 'ISRA', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a24dafe3-f67e-fcc0-3443-4601bb1e72a8', 'YUSRA', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('aba6e052-b4ef-3c64-f2b7-8cb1a3a2c07f', 'C/LAAHI', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d16bdf2a-75eb-25fb-626a-38a65ce33354', 'YOONIS', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1c13c4ff-52f8-3066-fbfc-cc7e517cc93e', 'NIMCO', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d0659e6b-8c12-2d50-8b6c-9545de5c9484', 'IBRAHIM', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('83d7118e-0537-50d6-8961-b69cd238a5c3', 'CABDIRASAQ', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('edd049c2-e6a8-eba6-40c2-71924beea630', 'SAFIYA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2cba07e5-e6d7-7fd8-7c86-15a09df7f9ac', 'GUULEED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae', 'SAHRA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c5d5c009-0502-1b15-0338-fdadc6f75a08', 'MUHA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d8a5b582-4da8-0349-022c-96295ffad813', 'XUSEEN', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9acb6996-d9f9-3378-ac98-186a7a45d320', 'MUHIIM', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b7ceaf0b-4d9b-eac8-b6f6-15ce9af883e5', 'MUNA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('725a5ba4-5efd-9a4f-6619-db6e191e9a82', 'MUMTAZ', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('4b7955f3-15e6-1dcd-e9de-d934e243cb02', 'C/RASAQ', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c420aafe-0819-64b6-60a9-2197826269c1', 'C/CASIIS', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3f028be8-56dc-4878-200f-ecd75f92f865', 'C/RAHIIM', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0f5fe588-0588-efd9-4427-99b7862e0100', 'NIMCO', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c36ec06a-8f98-ba2c-8ded-479348979b76', 'CAWA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d05111d0-f2e1-bd43-d84d-16bdf74f59c7', 'CUMAR', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3aeee5d3-91c8-b44f-c25b-356b719103e5', 'C/RASAQ', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6f695cf1-7918-6dde-2f0d-37bbb7d32a62', 'SAKARIYE', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2838f353-4e0a-dbc3-1802-975b9cc703dc', 'SAFIYA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d3967432-450b-0e0e-19a3-b0d43c1fd38d', 'SUMAYA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fc8762f4-a6cf-ee4e-19f7-905b89741389', 'MOHAMED', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1f7cad5c-4cae-23a4-0f42-b3e5da72b864', 'MARWA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c1f85d32-d461-19e8-2a3f-43e03ad71cb1', 'MAA''IIDA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('5e8e0f67-8fc8-68cf-e76c-795fee0dd561', 'BASRA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('8336650c-e6a2-ba85-0d82-c6967530f692', 'RAYAAN', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f01e7391-a3fd-a479-a18c-9bdf550c7288', 'CISMAAN', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d7d3bacc-7283-b026-3567-bab32fc37400', 'AYMAN', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6ce05e7f-376c-fc23-fadb-cfe62b6fd0b7', 'BUREEKA', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e990b703-b647-91d0-a53c-c6a69a9bee09', 'MUSTAFE', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('151c5c91-bc9a-6a34-5c30-1f9a446bb949', 'CABDIKARIM', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1b8a9934-f3c3-00b0-ddc1-6c632329cda2', 'ISMAACIIL', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c28d7067-9c43-3229-ed67-9db27b5dec51', 'IBRAHIM', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a7f04ca2-a5a1-3050-9c44-77f8fe386eac', 'MOHAMED', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('79f1cba5-d523-c242-7cfd-81249ecb3e23', 'SAAMIYA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6efa5283-cc89-a276-975e-600f12c55cf9', 'SUCAAD', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a213590e-2f81-c30e-2399-126a80471a3d', 'ROODA', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('8af390b5-c35f-f2c6-b26a-3e260a865376', 'CAASHA', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e349579f-c34b-aafd-6e51-c5649fa984c6', 'NUUR', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('293e35a6-32b5-c1e8-468e-ef6a9ae962a5', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('47356bab-2746-1001-b872-3eb04f1c00b8', 'NIMCO', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f08918b3-cb3a-fbdd-c789-7dd1dfb6d058', 'MIRE', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a523b95a-0bf7-5248-70f1-0127df9c8da2', 'HODAN', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('59c38ccd-a36a-475a-a838-8ff56f7981e2', 'AMIIN', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('881439b1-cf9a-ec5a-c94f-59ebdfe88f41', 'ASMA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3218e10f-6d68-b12f-0d58-09eeb141d2d0', 'MUSCAB', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d1b1d151-7217-f452-f25a-201b39aa27a5', 'AXMED', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('05fbc71a-3fdd-3722-4bff-fe668ae1520f', 'NIMCO', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a412fce5-f212-e5f7-3dd1-155b344a350c', 'AMIIRA', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('80b6a71d-f204-4fbc-4b46-a54235264e60', 'NAJAX', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ce0a15e7-9702-2879-8980-51926f07293b', 'SICIID', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0f64a18a-03b0-6fa9-dff6-8d04e6ca101a', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('51284264-7249-00e2-490b-2c5b061e7940', 'MUKHTAAR', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('7e1aa120-5154-9818-98f6-573992d82cea', 'AASIYA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1cd0e684-b258-435c-9b60-40bfe504150c', 'AMIIRA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('7df042cf-d2e2-c7d2-fb4e-57e30ae5f1d7', 'NIMCO', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('4b8dd3ab-8d57-be52-eda2-d890f64a369f', 'AXMED', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('cb3a6af5-d701-9072-c594-64daa6c8bae5', 'KHADIIJA', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c57838cf-9f6e-d8df-0202-49fa85ef6a59', 'NIMCO', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fe3e1e1d-ceb1-9f5c-36ec-aaff3e5c8b9e', 'HAFSA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9fd1ad7b-76e3-00f4-2d7b-56cf136cc72a', 'HAMDA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3e5dfcfc-1679-5526-fb8a-d4a81a237137', 'MOHAMED', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e1074b36-7350-ff8e-7029-b53ac4aff39e', 'C/RAHIM', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6e299527-3b94-26e1-3717-95d0d5fee21f', 'FARAH', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('680d0e23-6040-8d45-9091-69fcde8e63ec', 'FILSAN', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ef168e8c-1d06-4bd2-27f4-8f011b5915c0', 'FARHIYA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6df8669e-cc8a-deb7-a706-395502b5105a', 'FAHIIMA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9e4b8ffe-47f8-c353-9e1f-01d1adb786d5', 'MOHAMED', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b29be7eb-15e7-5093-b549-31d52368b294', 'SUHAYB', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ecc5d2c4-6d1f-7614-e38e-3b586e27ce48', 'AHMED', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('82975717-3bdf-2770-322c-e06e3272dd2f', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('85314f82-8f11-d09a-e9e4-ba99eb434430', 'C/RAHMAN', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('022daa5b-9313-a6fb-f623-6b1e9585ac3f', 'C/RASAQ', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fc940d88-9b2a-9997-cb61-49e38b6738c7', 'BUSHRA', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b75cd906-4383-b390-fd27-2b89231614ce', 'MOHAMED', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('28c2a15e-519e-7e13-736a-eb5db9d2a6bc', 'C/QANI', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('8aea2880-8d35-ea67-b3f1-1975e138c36f', 'C/RAHMAN', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('aa9e0ae6-fb00-7177-0ca8-138987d3cf05', 'MAHDIYA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('331f43f5-bf54-422d-3492-f3c3631016ca', 'ISMAIL', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b6bcbae6-a5ff-0dec-e07b-927ae73f928b', 'C/SHAKUUR', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a2c99eb0-1380-c908-a691-47e9fae8336f', 'YOONIS', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('cf27d852-d87d-2c75-a918-f33edb830d1f', 'C/RASAAQ', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f5697690-b315-fcf8-1c53-337078e391dc', 'HIBAAQ', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1589bb79-d475-3b34-31a2-835e9d679c95', 'HADIYA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('68d7d31b-97ad-0045-076f-59034b27b3af', 'AHMED', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f8cbea5d-73b2-a75f-1a06-beb14c7be7bf', 'MAHDIYA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('41ed0903-dd95-5b09-3ea2-3e904765e973', 'IIDO', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f203ef34-7225-b42e-b42b-65d1918d4b6e', 'ISTAAHIL', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b5dde88a-7237-a765-c08d-fbd04ef00eb8', 'MUNA', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('efefb257-4498-4aff-ff10-11b960351f8e', 'CAWO', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('30c45f60-bf3d-c128-c0a7-8a949a783422', 'AYAAN', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('41a01e50-1554-364e-f740-172d625ad2c1', 'NIMCAAN', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('10c208ee-e32d-e86a-905b-55a8ca822a48', 'MARWA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e235de2a-c309-7ccf-2712-1e20ac05b03e', 'SAFA', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('61cc5498-0b6f-6e0d-3bfd-d7ff9e804bb8', 'NIMCO', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('50cae6ea-ad04-fa6f-6398-7faefcb42224', 'NASRI', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('374033c1-4ff6-0230-5696-ff16b670a8e4', 'C/RASHIID', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e62227cc-3e5b-d3d2-8f43-f66c8f09b95b', 'HINDA', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('8a6b9be8-eb33-f982-1898-0d943f19aa51', 'CABDIRASHIID', NULL, 'family_member', 'adult', 2, 8)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f3899079-1d68-5c45-8255-1faff58aecf3', 'KAWSAR', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1642ed80-6065-95bb-c8b9-ed3c906201dd', 'FARDUUS', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0137267c-ccca-bb77-0ff6-ff30ebf0229e', 'NIMCO', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('57d60180-ac75-60dc-78a1-fde1a2af8582', 'BUSHRA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2848d442-1abe-c903-392c-41081e25d613', 'SAFA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('43239ec7-dfa4-54e1-b7e4-3bebd5b432d7', 'MARWA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('053f2b47-8906-ddb1-3cfb-0ef982d6050b', 'AMIIRA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6f3d9e76-8060-eece-fea2-151e42c2b9bb', 'DEEQA', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c7484172-b2b7-ffab-8a03-b4719560f8f9', 'MAA''IDA', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('46c00caf-7e3b-547d-477f-4feee3d229f4', 'MABSUUD', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d529d6a7-fc17-093d-6304-2ccfe5de3277', 'AHMED', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('21a3d99f-ea6a-b568-a593-99f12518bb54', 'RAYAAN', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2565f705-63b1-66c6-7744-dffb87e5999e', 'RAADIYA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ca240ce2-6515-0903-ec92-5e402e80cb9d', 'SHUKRI', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('cacccb84-ad87-de78-8962-247189bb3252', 'RAXIIMA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0c9523b7-cc68-c180-339f-0dd7cc6eb62d', 'MUSTAFE', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0ae39279-a131-7085-2961-689fc68e4a5e', 'C/CASIIS', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6a06fe52-1e3c-bee4-aab0-85c2de29a732', 'SAKRIYE', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('741d0ba8-fb58-3189-fb43-a9465feeba9f', 'AYAAN', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('97e7704c-5452-10bb-9a27-82446095b5d0', 'AFNAAN', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('26600952-210e-c3bc-f33b-558ad86964fc', 'ARWA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('13e0c128-3e0c-b115-5cbd-f4408c0b1f00', 'YUUSUF', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d5de7bf3-4a68-1fcd-1191-8fa990a713ba', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c66588fb-102d-cbdd-0577-dc3ec803b6f9', 'SAFIYA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e328b73b-e103-8d7c-8485-3cff6d25e668', 'MANAAL', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f6f9e2ab-640d-15ad-1a9c-09431ada83fb', 'RIDWAAN', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a027813a-9b14-bd24-7c73-20a446d1ca0f', 'KHALID', NULL, 'family_member', 'adult', 2, 8)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2f1d0fd3-a105-1097-470e-676eb58c7cb5', 'C/FATAH', NULL, 'family_member', 'adult', 2, 9)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('64d440db-d4d7-2a05-bd6a-ec6662056c3e', 'AYAAN', NULL, 'family_member', 'adult', 2, 10)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('5a3a3edc-5f35-8cd5-dcbd-806480e64fd3', 'MUNA', NULL, 'family_member', 'adult', 2, 11)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('107a1131-132f-97b0-81c4-f815d473db5d', 'SACDI', NULL, 'family_member', 'adult', 2, 9)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c3479fd8-a6b9-59e0-b1f9-7b68272b8d89', 'C/SHAKUUR', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2f0921e7-da61-ca19-aa35-33aa12b9fb6b', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f58c769b-6960-a605-d6dc-3601de0e65f3', 'MUBARAK', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('aba5f468-9cbc-63ef-d27f-33f670a9beed', 'XAMDA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('869b455f-925c-b5a9-7d7c-5a7a4d727fa4', 'XAMDA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c9ed2122-e1f2-997a-a671-57af8535f564', 'SACAADA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e25a92ed-713e-2dbc-f283-3e1b776ff360', 'CAWA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('628e86e7-5dbd-be52-f56c-f4de658fedc9', 'AHMED', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2e2aae27-5de8-0697-bf64-863ba7a4fb80', 'SUHUUR', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3dcf260d-5c29-e5a5-74bd-58f8f86fa3da', 'SAFA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('766125b7-b557-43c7-d824-a0c06951e240', 'MARWA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('99567860-2d50-dbcb-8157-bf5085878e0f', 'MABSUUD', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2bc659ae-fcb1-7ec4-d7bd-11b13441ee7f', 'SALMA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('38095d0f-d7fc-1ea7-2a28-4a47455b3031', 'MOHAMED', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('616bb12a-cf85-e221-8b43-65740bd8d4c5', 'AHMED', NULL, 'family_member', 'adult', 2, 10)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3048fdcb-330a-e3a1-eb96-d934393ad0a7', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6ccee8db-6771-26cf-b53d-eafa4f51fb93', 'AHMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('43a9f872-4f59-564d-f316-bf9afde006fc', 'HOODO', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('04f0a12f-d255-19ce-0d48-563658dbbbec', 'AFNAAN', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0260a03d-b669-b987-7f32-5f2c74fc4477', 'YUSUF', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b45efebc-3440-4ee6-e74e-34f193cdddf2', 'ASMA', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('feb3ecda-f353-7e5e-11e0-ba400b9284a7', 'BARWAAQO', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('77dd4b8e-3c56-efde-2407-785ff8b0ede6', 'XASAN', NULL, 'family_member', 'adult', 2, 11)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('8782bbef-bd67-ca86-2815-8a98878c3a04', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('8cd8738f-8970-f5cd-07b4-10075f3a56d4', 'CABDI', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('10fba5ac-fe34-52ff-5015-f9eb79cd76a5', 'IBRAHIM', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('098e48d4-d5cf-5f65-747d-8a0679eb5fc8', 'KHALID', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b182bcf3-764d-d0ff-038e-6ae1d3217470', 'YOONIS', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('bfdd6285-b193-acea-cde1-cdc04a959631', 'C/QANI', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a35ca3f5-e1ce-0536-e516-59ed805096a3', 'SAKI', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('97aa31e4-5db7-a707-90df-73cc8201edda', 'ASMA', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('238a0def-3ed0-49cf-609c-a397bcb0344c', 'BADRA', NULL, 'family_member', 'adult', 2, 8)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('68e9e265-a304-4c87-e3ac-a4e3fef643a2', 'HODAN', NULL, 'family_member', 'adult', 2, 9)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('711c7270-bb38-8ad8-a846-65e3a14f41e5', 'HOODO', NULL, 'family_member', 'adult', 2, 10)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1905020d-c42f-15c4-3bfe-6cb15f7bf552', 'SAFA', NULL, 'family_member', 'adult', 2, 11)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ee46f40a-8509-ae88-4dbf-b39b1ccee986', 'MARWA', NULL, 'family_member', 'adult', 2, 12)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d1052f8e-232e-af94-f993-78642032aa09', 'IKRAAN', NULL, 'family_member', 'adult', 2, 13)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('5b9372bf-a17a-5274-147f-7f45c1cabac2', 'MAHDI', NULL, 'family_member', 'adult', 2, 12)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('522154c1-a182-5f63-59d3-7901ae46e0a4', 'KHADAR', NULL, 'family_member', 'adult', 2, 13)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('89abcb2f-971d-de85-7f3f-5f626eaa1c07', 'SIHAAM', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0ecdc2c4-92f2-c6e8-e47a-4b2c5dbada92', 'SUHAYMA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('92501e82-5a17-4f0e-6d56-0e30db6f9de5', 'SAKARIYE', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d5f474e4-5fc8-bf08-a069-d8f4fc3ef43c', 'SUWAYDA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c69dc823-f930-baae-fc0b-386061eafdbf', 'SAFA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('37dce389-3355-b8e5-b884-ef4944d2227a', 'SIHAAM', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d2294d8d-f39a-fa44-cda5-f9d9224b85d1', 'SAKIYA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('bd8414a8-221b-8b96-4584-f9dc0c1b3774', 'C/RAHMAN', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('35bfcbce-e4fc-7773-dde5-bc87cda41f60', 'C/LADIIF', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('8a41bce6-460e-335d-d2b5-927143b9a99b', 'C/FATAH', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('61a00aad-57b7-7d49-c90e-a234d94cfb01', 'CUMAR', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9ed24d8d-8049-b936-e8ee-af3c021d6e76', 'C/RASAAQ', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3d2563be-5899-9cd5-b7b0-01641720eeee', 'MARWA', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- Link father_id (lineage) - re-run this file to fix broken tree connections
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099' WHERE id = '3a6c4b11-1992-16bd-6d45-1d8f4a05a3cb';
UPDATE reer_sh_yoonis.profiles SET father_id = '3a6c4b11-1992-16bd-6d45-1d8f4a05a3cb' WHERE id = '27285597-3166-f908-eb79-df40a47fa83d';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099' WHERE id = '30ab04ce-d56c-1f07-6a3b-ea07784ddff7';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099' WHERE id = 'e39b1fe9-aa72-e39b-8af9-01a76c79349a';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e39b1fe9-aa72-e39b-8af9-01a76c79349a' WHERE id = '9172d34a-c323-e233-43f7-d72b6c48d12e';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e39b1fe9-aa72-e39b-8af9-01a76c79349a' WHERE id = 'a09146a4-0d4a-4a73-f880-7c5f909ab364';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e39b1fe9-aa72-e39b-8af9-01a76c79349a' WHERE id = '3dccfdb3-2129-8c48-adb8-4e2676ff7f97';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e39b1fe9-aa72-e39b-8af9-01a76c79349a' WHERE id = 'b68c85f7-ee32-427e-bfc1-2627faccd141';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e39b1fe9-aa72-e39b-8af9-01a76c79349a' WHERE id = 'e568b377-596c-911a-03ac-2c48c1fa165c';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e39b1fe9-aa72-e39b-8af9-01a76c79349a' WHERE id = 'd61e7998-4fcf-beff-b8a7-e19a31ade915';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099' WHERE id = '597819d6-d7ae-ee36-bf9e-84c1ef7eb401';
UPDATE reer_sh_yoonis.profiles SET father_id = '597819d6-d7ae-ee36-bf9e-84c1ef7eb401' WHERE id = 'fa478548-074f-dc76-6c69-6a78aa92d422';
UPDATE reer_sh_yoonis.profiles SET father_id = '597819d6-d7ae-ee36-bf9e-84c1ef7eb401' WHERE id = 'b4c7d30d-8610-9fb1-9194-206a531c1870';
UPDATE reer_sh_yoonis.profiles SET father_id = '597819d6-d7ae-ee36-bf9e-84c1ef7eb401' WHERE id = '6ca99335-a5ed-c9f0-ef61-370dd1537bbf';
UPDATE reer_sh_yoonis.profiles SET father_id = '597819d6-d7ae-ee36-bf9e-84c1ef7eb401' WHERE id = 'c6e8dbe3-2b27-7c5b-4d3f-9306630f5173';
UPDATE reer_sh_yoonis.profiles SET father_id = '597819d6-d7ae-ee36-bf9e-84c1ef7eb401' WHERE id = '7e74c758-65d6-3081-8b54-0f9fd1a849ca';
UPDATE reer_sh_yoonis.profiles SET father_id = '597819d6-d7ae-ee36-bf9e-84c1ef7eb401' WHERE id = 'a3f8746e-e295-7c4e-9bc3-927009138724';
UPDATE reer_sh_yoonis.profiles SET father_id = '597819d6-d7ae-ee36-bf9e-84c1ef7eb401' WHERE id = '3e3147e0-e128-f616-c5d9-f5a0aed2fe7d';
UPDATE reer_sh_yoonis.profiles SET father_id = '597819d6-d7ae-ee36-bf9e-84c1ef7eb401' WHERE id = '29b0776d-3772-3c57-609f-f7387ca404e3';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099' WHERE id = 'aea54731-c707-6e02-7910-e6d0733a3fb7';
UPDATE reer_sh_yoonis.profiles SET father_id = 'aea54731-c707-6e02-7910-e6d0733a3fb7' WHERE id = '497aed43-5e7d-aee3-9e85-b4850d7c4b22';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'acf88805-0539-8a77-604e-33444269c311';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = 'da390d9f-c0ae-0093-3fda-6e47a2cd5f33';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = '4989fc43-458e-4746-4f18-ef65cc1f8a93';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = '365d78c8-ae83-fa42-675d-9b8be641288e';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = '3216b902-2908-5814-d812-6de0cb31fbdc';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = 'bd77350d-16bd-bb66-de4f-8f670c837fc8';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = 'e7fc954b-f0f0-5287-a60c-2fa58d3baebb';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = 'a046dee0-bec6-09eb-4e50-a9ee30f1eba8';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = 'e320e41b-56c3-8409-1966-964f3d49c3a3';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = '5e66c081-18ee-51aa-e292-ad64022bac42';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = 'f9dc98ef-9399-8161-c35c-6b5d3d97c8da';
UPDATE reer_sh_yoonis.profiles SET father_id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826' WHERE id = '46026503-519e-36a6-e2b2-68e99a4a5db5';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '3ed22580-4b2b-8742-6be6-03ef9ebdb1b1';
UPDATE reer_sh_yoonis.profiles SET father_id = '3ed22580-4b2b-8742-6be6-03ef9ebdb1b1' WHERE id = 'c3f8197a-b3f3-c56f-d8bd-f309cdbb5759';
UPDATE reer_sh_yoonis.profiles SET father_id = '3ed22580-4b2b-8742-6be6-03ef9ebdb1b1' WHERE id = '28996ccc-b9cf-d27b-3ba3-c9c7d93d712f';
UPDATE reer_sh_yoonis.profiles SET father_id = '3ed22580-4b2b-8742-6be6-03ef9ebdb1b1' WHERE id = '34561d7d-bb8b-8689-6db6-898f9e04db26';
UPDATE reer_sh_yoonis.profiles SET father_id = '3ed22580-4b2b-8742-6be6-03ef9ebdb1b1' WHERE id = 'ce2b7264-acf1-112a-cb58-f32e729fc9d8';
UPDATE reer_sh_yoonis.profiles SET father_id = '3ed22580-4b2b-8742-6be6-03ef9ebdb1b1' WHERE id = '7642f2b4-4d92-108e-63fc-45611d98723f';
UPDATE reer_sh_yoonis.profiles SET father_id = '3ed22580-4b2b-8742-6be6-03ef9ebdb1b1' WHERE id = 'e0b62f81-cbde-3b9b-2356-5175e212e28e';
UPDATE reer_sh_yoonis.profiles SET father_id = '3ed22580-4b2b-8742-6be6-03ef9ebdb1b1' WHERE id = '46a26395-f601-2ca0-4d83-3c0d8dfb1972';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '17777882-ada6-9039-be64-d6869e0e5324';
UPDATE reer_sh_yoonis.profiles SET father_id = '17777882-ada6-9039-be64-d6869e0e5324' WHERE id = '9e62c76f-c2ef-1e65-da6b-2cd1878ea197';
UPDATE reer_sh_yoonis.profiles SET father_id = '17777882-ada6-9039-be64-d6869e0e5324' WHERE id = 'e270cb59-bae2-9903-8a52-87b598dfc2ac';
UPDATE reer_sh_yoonis.profiles SET father_id = '17777882-ada6-9039-be64-d6869e0e5324' WHERE id = '8d50afa3-fb75-ec0d-3cba-e47e881646cb';
UPDATE reer_sh_yoonis.profiles SET father_id = '17777882-ada6-9039-be64-d6869e0e5324' WHERE id = 'ac55d45e-3ff0-8436-daf0-65a85b55ca8a';
UPDATE reer_sh_yoonis.profiles SET father_id = '17777882-ada6-9039-be64-d6869e0e5324' WHERE id = '99ff430a-fa66-6278-138e-5cb8a041f9b7';
UPDATE reer_sh_yoonis.profiles SET father_id = '17777882-ada6-9039-be64-d6869e0e5324' WHERE id = 'b61e7fe2-131e-a307-ea6f-2e40ae19c2ac';
UPDATE reer_sh_yoonis.profiles SET father_id = '17777882-ada6-9039-be64-d6869e0e5324' WHERE id = 'e668f661-6c95-0b86-6699-76e1ae5b2656';
UPDATE reer_sh_yoonis.profiles SET father_id = '17777882-ada6-9039-be64-d6869e0e5324' WHERE id = 'f2e55bbf-864b-0dea-966d-354a60c8a6bb';
UPDATE reer_sh_yoonis.profiles SET father_id = '17777882-ada6-9039-be64-d6869e0e5324' WHERE id = '4f5753f7-36d9-1904-8971-f2328e8b6f9e';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '789dff60-bc8f-5987-e341-082ad0967818';
UPDATE reer_sh_yoonis.profiles SET father_id = '789dff60-bc8f-5987-e341-082ad0967818' WHERE id = '242f6d5e-f08d-70ff-36c9-2cb3f8d19cfc';
UPDATE reer_sh_yoonis.profiles SET father_id = '789dff60-bc8f-5987-e341-082ad0967818' WHERE id = 'fcf8b87a-326d-4122-138f-b24a47a84989';
UPDATE reer_sh_yoonis.profiles SET father_id = '789dff60-bc8f-5987-e341-082ad0967818' WHERE id = 'a7411d4a-7e30-27df-be39-694a074783ed';
UPDATE reer_sh_yoonis.profiles SET father_id = '789dff60-bc8f-5987-e341-082ad0967818' WHERE id = '9bc926ec-2cd7-0a1a-f447-5e6db4e81933';
UPDATE reer_sh_yoonis.profiles SET father_id = '789dff60-bc8f-5987-e341-082ad0967818' WHERE id = '0f786735-37b7-7e24-0392-9d9faa738f5a';
UPDATE reer_sh_yoonis.profiles SET father_id = '789dff60-bc8f-5987-e341-082ad0967818' WHERE id = '3e1a75a6-8ced-85ae-b074-2e1c98e7e60a';
UPDATE reer_sh_yoonis.profiles SET father_id = '789dff60-bc8f-5987-e341-082ad0967818' WHERE id = '55102671-b386-a11c-0964-c53cd32db514';
UPDATE reer_sh_yoonis.profiles SET father_id = '789dff60-bc8f-5987-e341-082ad0967818' WHERE id = 'a94f8eb9-ef6b-b55d-0e63-e460b7a046e6';
UPDATE reer_sh_yoonis.profiles SET father_id = '789dff60-bc8f-5987-e341-082ad0967818' WHERE id = '4c363e66-481e-5f09-d39b-dd6b24e88a50';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = 'fbe3985e-240e-18e5-d2b0-2531d2e36f1b';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fbe3985e-240e-18e5-d2b0-2531d2e36f1b' WHERE id = '2ba15c8c-b5ec-b1a4-5fa7-37a54de91b9e';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fbe3985e-240e-18e5-d2b0-2531d2e36f1b' WHERE id = '1b57850f-2537-3a95-90e0-b6cf37a67bf1';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fbe3985e-240e-18e5-d2b0-2531d2e36f1b' WHERE id = '3813f11f-4797-58da-7dee-d3c74ccaa1ce';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fbe3985e-240e-18e5-d2b0-2531d2e36f1b' WHERE id = '0abd86b3-d0e9-6244-11ee-a083861b1cda';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fbe3985e-240e-18e5-d2b0-2531d2e36f1b' WHERE id = '1b6b2eea-cf51-8d2a-52ee-e805ee909d77';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '896a25e4-b35e-b339-dd7b-ee2a520151ea';
UPDATE reer_sh_yoonis.profiles SET father_id = '896a25e4-b35e-b339-dd7b-ee2a520151ea' WHERE id = 'af0d7f9c-c364-6812-63a8-a43971d3f1db';
UPDATE reer_sh_yoonis.profiles SET father_id = '896a25e4-b35e-b339-dd7b-ee2a520151ea' WHERE id = 'a27e6bf6-ac61-e2f4-1ee3-b50a43aca765';
UPDATE reer_sh_yoonis.profiles SET father_id = '896a25e4-b35e-b339-dd7b-ee2a520151ea' WHERE id = '98c98966-7832-e468-90ef-df0fa0e29090';
UPDATE reer_sh_yoonis.profiles SET father_id = '896a25e4-b35e-b339-dd7b-ee2a520151ea' WHERE id = '98c58a8d-197b-9002-61c5-9b75058978c3';
UPDATE reer_sh_yoonis.profiles SET father_id = '896a25e4-b35e-b339-dd7b-ee2a520151ea' WHERE id = 'ab3f9a30-834a-bef7-7256-9341c7398bc6';
UPDATE reer_sh_yoonis.profiles SET father_id = '896a25e4-b35e-b339-dd7b-ee2a520151ea' WHERE id = 'a24dafe3-f67e-fcc0-3443-4601bb1e72a8';
UPDATE reer_sh_yoonis.profiles SET father_id = '896a25e4-b35e-b339-dd7b-ee2a520151ea' WHERE id = 'aba6e052-b4ef-3c64-f2b7-8cb1a3a2c07f';
UPDATE reer_sh_yoonis.profiles SET father_id = '896a25e4-b35e-b339-dd7b-ee2a520151ea' WHERE id = 'd16bdf2a-75eb-25fb-626a-38a65ce33354';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '1c13c4ff-52f8-3066-fbfc-cc7e517cc93e';
UPDATE reer_sh_yoonis.profiles SET father_id = '1c13c4ff-52f8-3066-fbfc-cc7e517cc93e' WHERE id = 'd0659e6b-8c12-2d50-8b6c-9545de5c9484';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '83d7118e-0537-50d6-8961-b69cd238a5c3';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = 'edd049c2-e6a8-eba6-40c2-71924beea630';
UPDATE reer_sh_yoonis.profiles SET father_id = 'edd049c2-e6a8-eba6-40c2-71924beea630' WHERE id = '2cba07e5-e6d7-7fd8-7c86-15a09df7f9ac';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = '5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae';
UPDATE reer_sh_yoonis.profiles SET father_id = '5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae' WHERE id = 'c5d5c009-0502-1b15-0338-fdadc6f75a08';
UPDATE reer_sh_yoonis.profiles SET father_id = '5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae' WHERE id = 'd8a5b582-4da8-0349-022c-96295ffad813';
UPDATE reer_sh_yoonis.profiles SET father_id = '5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae' WHERE id = '9acb6996-d9f9-3378-ac98-186a7a45d320';
UPDATE reer_sh_yoonis.profiles SET father_id = '5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae' WHERE id = 'b7ceaf0b-4d9b-eac8-b6f6-15ce9af883e5';
UPDATE reer_sh_yoonis.profiles SET father_id = '5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae' WHERE id = '725a5ba4-5efd-9a4f-6619-db6e191e9a82';
UPDATE reer_sh_yoonis.profiles SET father_id = '5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae' WHERE id = '4b7955f3-15e6-1dcd-e9de-d934e243cb02';
UPDATE reer_sh_yoonis.profiles SET father_id = '5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae' WHERE id = 'c420aafe-0819-64b6-60a9-2197826269c1';
UPDATE reer_sh_yoonis.profiles SET father_id = '5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae' WHERE id = '3f028be8-56dc-4878-200f-ecd75f92f865';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = '0f5fe588-0588-efd9-4427-99b7862e0100';
UPDATE reer_sh_yoonis.profiles SET father_id = '0f5fe588-0588-efd9-4427-99b7862e0100' WHERE id = 'c36ec06a-8f98-ba2c-8ded-479348979b76';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = 'd05111d0-f2e1-bd43-d84d-16bdf74f59c7';
UPDATE reer_sh_yoonis.profiles SET father_id = 'd05111d0-f2e1-bd43-d84d-16bdf74f59c7' WHERE id = '3aeee5d3-91c8-b44f-c25b-356b719103e5';
UPDATE reer_sh_yoonis.profiles SET father_id = 'd05111d0-f2e1-bd43-d84d-16bdf74f59c7' WHERE id = '6f695cf1-7918-6dde-2f0d-37bbb7d32a62';
UPDATE reer_sh_yoonis.profiles SET father_id = 'd05111d0-f2e1-bd43-d84d-16bdf74f59c7' WHERE id = '2838f353-4e0a-dbc3-1802-975b9cc703dc';
UPDATE reer_sh_yoonis.profiles SET father_id = 'd05111d0-f2e1-bd43-d84d-16bdf74f59c7' WHERE id = 'd3967432-450b-0e0e-19a3-b0d43c1fd38d';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = 'fc8762f4-a6cf-ee4e-19f7-905b89741389';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fc8762f4-a6cf-ee4e-19f7-905b89741389' WHERE id = '1f7cad5c-4cae-23a4-0f42-b3e5da72b864';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fc8762f4-a6cf-ee4e-19f7-905b89741389' WHERE id = 'c1f85d32-d461-19e8-2a3f-43e03ad71cb1';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fc8762f4-a6cf-ee4e-19f7-905b89741389' WHERE id = '5e8e0f67-8fc8-68cf-e76c-795fee0dd561';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fc8762f4-a6cf-ee4e-19f7-905b89741389' WHERE id = '8336650c-e6a2-ba85-0d82-c6967530f692';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fc8762f4-a6cf-ee4e-19f7-905b89741389' WHERE id = 'f01e7391-a3fd-a479-a18c-9bdf550c7288';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fc8762f4-a6cf-ee4e-19f7-905b89741389' WHERE id = 'd7d3bacc-7283-b026-3567-bab32fc37400';
UPDATE reer_sh_yoonis.profiles SET father_id = 'fc8762f4-a6cf-ee4e-19f7-905b89741389' WHERE id = '6ce05e7f-376c-fc23-fadb-cfe62b6fd0b7';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = 'e990b703-b647-91d0-a53c-c6a69a9bee09';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = '1b8a9934-f3c3-00b0-ddc1-6c632329cda2';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = 'c28d7067-9c43-3229-ed67-9db27b5dec51';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = 'a7f04ca2-a5a1-3050-9c44-77f8fe386eac';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = '79f1cba5-d523-c242-7cfd-81249ecb3e23';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = '6efa5283-cc89-a276-975e-600f12c55cf9';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = 'a213590e-2f81-c30e-2399-126a80471a3d';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = '8af390b5-c35f-f2c6-b26a-3e260a865376';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'e349579f-c34b-aafd-6e51-c5649fa984c6';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e349579f-c34b-aafd-6e51-c5649fa984c6' WHERE id = '293e35a6-32b5-c1e8-468e-ef6a9ae962a5';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e349579f-c34b-aafd-6e51-c5649fa984c6' WHERE id = '47356bab-2746-1001-b872-3eb04f1c00b8';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'a523b95a-0bf7-5248-70f1-0127df9c8da2';
UPDATE reer_sh_yoonis.profiles SET father_id = 'a523b95a-0bf7-5248-70f1-0127df9c8da2' WHERE id = '59c38ccd-a36a-475a-a838-8ff56f7981e2';
UPDATE reer_sh_yoonis.profiles SET father_id = 'a523b95a-0bf7-5248-70f1-0127df9c8da2' WHERE id = '881439b1-cf9a-ec5a-c94f-59ebdfe88f41';
UPDATE reer_sh_yoonis.profiles SET father_id = 'a523b95a-0bf7-5248-70f1-0127df9c8da2' WHERE id = '3218e10f-6d68-b12f-0d58-09eeb141d2d0';
UPDATE reer_sh_yoonis.profiles SET father_id = 'a523b95a-0bf7-5248-70f1-0127df9c8da2' WHERE id = 'd1b1d151-7217-f452-f25a-201b39aa27a5';
UPDATE reer_sh_yoonis.profiles SET father_id = 'a523b95a-0bf7-5248-70f1-0127df9c8da2' WHERE id = '05fbc71a-3fdd-3722-4bff-fe668ae1520f';
UPDATE reer_sh_yoonis.profiles SET father_id = 'a523b95a-0bf7-5248-70f1-0127df9c8da2' WHERE id = 'a412fce5-f212-e5f7-3dd1-155b344a350c';
UPDATE reer_sh_yoonis.profiles SET father_id = 'a523b95a-0bf7-5248-70f1-0127df9c8da2' WHERE id = '80b6a71d-f204-4fbc-4b46-a54235264e60';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'ce0a15e7-9702-2879-8980-51926f07293b';
UPDATE reer_sh_yoonis.profiles SET father_id = 'ce0a15e7-9702-2879-8980-51926f07293b' WHERE id = '0f64a18a-03b0-6fa9-dff6-8d04e6ca101a';
UPDATE reer_sh_yoonis.profiles SET father_id = 'ce0a15e7-9702-2879-8980-51926f07293b' WHERE id = '51284264-7249-00e2-490b-2c5b061e7940';
UPDATE reer_sh_yoonis.profiles SET father_id = 'ce0a15e7-9702-2879-8980-51926f07293b' WHERE id = '7e1aa120-5154-9818-98f6-573992d82cea';
UPDATE reer_sh_yoonis.profiles SET father_id = 'ce0a15e7-9702-2879-8980-51926f07293b' WHERE id = '1cd0e684-b258-435c-9b60-40bfe504150c';
UPDATE reer_sh_yoonis.profiles SET father_id = 'ce0a15e7-9702-2879-8980-51926f07293b' WHERE id = '7df042cf-d2e2-c7d2-fb4e-57e30ae5f1d7';
UPDATE reer_sh_yoonis.profiles SET father_id = 'ce0a15e7-9702-2879-8980-51926f07293b' WHERE id = '4b8dd3ab-8d57-be52-eda2-d890f64a369f';
UPDATE reer_sh_yoonis.profiles SET father_id = 'ce0a15e7-9702-2879-8980-51926f07293b' WHERE id = 'cb3a6af5-d701-9072-c594-64daa6c8bae5';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'c57838cf-9f6e-d8df-0202-49fa85ef6a59';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c57838cf-9f6e-d8df-0202-49fa85ef6a59' WHERE id = 'fe3e1e1d-ceb1-9f5c-36ec-aaff3e5c8b9e';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c57838cf-9f6e-d8df-0202-49fa85ef6a59' WHERE id = '9fd1ad7b-76e3-00f4-2d7b-56cf136cc72a';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c57838cf-9f6e-d8df-0202-49fa85ef6a59' WHERE id = '3e5dfcfc-1679-5526-fb8a-d4a81a237137';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = '6e299527-3b94-26e1-3717-95d0d5fee21f';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = '680d0e23-6040-8d45-9091-69fcde8e63ec';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = 'ef168e8c-1d06-4bd2-27f4-8f011b5915c0';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = '6df8669e-cc8a-deb7-a706-395502b5105a';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = '9e4b8ffe-47f8-c353-9e1f-01d1adb786d5';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = 'b29be7eb-15e7-5093-b549-31d52368b294';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'ecc5d2c4-6d1f-7614-e38e-3b586e27ce48';
UPDATE reer_sh_yoonis.profiles SET father_id = 'ecc5d2c4-6d1f-7614-e38e-3b586e27ce48' WHERE id = '82975717-3bdf-2770-322c-e06e3272dd2f';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = '85314f82-8f11-d09a-e9e4-ba99eb434430';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = '022daa5b-9313-a6fb-f623-6b1e9585ac3f';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'fc940d88-9b2a-9997-cb61-49e38b6738c7';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'b75cd906-4383-b390-fd27-2b89231614ce';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b75cd906-4383-b390-fd27-2b89231614ce' WHERE id = '28c2a15e-519e-7e13-736a-eb5db9d2a6bc';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b75cd906-4383-b390-fd27-2b89231614ce' WHERE id = '8aea2880-8d35-ea67-b3f1-1975e138c36f';
UPDATE reer_sh_yoonis.profiles SET father_id = '8aea2880-8d35-ea67-b3f1-1975e138c36f' WHERE id = 'aa9e0ae6-fb00-7177-0ca8-138987d3cf05';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '331f43f5-bf54-422d-3492-f3c3631016ca';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'b6bcbae6-a5ff-0dec-e07b-927ae73f928b';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'a2c99eb0-1380-c908-a691-47e9fae8336f';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'cf27d852-d87d-2c75-a918-f33edb830d1f';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'f5697690-b315-fcf8-1c53-337078e391dc';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f5697690-b315-fcf8-1c53-337078e391dc' WHERE id = '1589bb79-d475-3b34-31a2-835e9d679c95';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f5697690-b315-fcf8-1c53-337078e391dc' WHERE id = '68d7d31b-97ad-0045-076f-59034b27b3af';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f5697690-b315-fcf8-1c53-337078e391dc' WHERE id = 'f8cbea5d-73b2-a75f-1a06-beb14c7be7bf';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = '41ed0903-dd95-5b09-3ea2-3e904765e973';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'f203ef34-7225-b42e-b42b-65d1918d4b6e';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'b5dde88a-7237-a765-c08d-fbd04ef00eb8';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b5dde88a-7237-a765-c08d-fbd04ef00eb8' WHERE id = 'efefb257-4498-4aff-ff10-11b960351f8e';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b5dde88a-7237-a765-c08d-fbd04ef00eb8' WHERE id = '30c45f60-bf3d-c128-c0a7-8a949a783422';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b5dde88a-7237-a765-c08d-fbd04ef00eb8' WHERE id = '41a01e50-1554-364e-f740-172d625ad2c1';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b5dde88a-7237-a765-c08d-fbd04ef00eb8' WHERE id = '10c208ee-e32d-e86a-905b-55a8ca822a48';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b5dde88a-7237-a765-c08d-fbd04ef00eb8' WHERE id = 'e235de2a-c309-7ccf-2712-1e20ac05b03e';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b5dde88a-7237-a765-c08d-fbd04ef00eb8' WHERE id = '61cc5498-0b6f-6e0d-3bfd-d7ff9e804bb8';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b5dde88a-7237-a765-c08d-fbd04ef00eb8' WHERE id = '50cae6ea-ad04-fa6f-6398-7faefcb42224';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b5dde88a-7237-a765-c08d-fbd04ef00eb8' WHERE id = '374033c1-4ff6-0230-5696-ff16b670a8e4';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'e62227cc-3e5b-d3d2-8f43-f66c8f09b95b';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '8a6b9be8-eb33-f982-1898-0d943f19aa51';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = 'f3899079-1d68-5c45-8255-1faff58aecf3';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = '1642ed80-6065-95bb-c8b9-ed3c906201dd';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = '0137267c-ccca-bb77-0ff6-ff30ebf0229e';
UPDATE reer_sh_yoonis.profiles SET father_id = '0137267c-ccca-bb77-0ff6-ff30ebf0229e' WHERE id = '57d60180-ac75-60dc-78a1-fde1a2af8582';
UPDATE reer_sh_yoonis.profiles SET father_id = '0137267c-ccca-bb77-0ff6-ff30ebf0229e' WHERE id = '2848d442-1abe-c903-392c-41081e25d613';
UPDATE reer_sh_yoonis.profiles SET father_id = '0137267c-ccca-bb77-0ff6-ff30ebf0229e' WHERE id = '43239ec7-dfa4-54e1-b7e4-3bebd5b432d7';
UPDATE reer_sh_yoonis.profiles SET father_id = '0137267c-ccca-bb77-0ff6-ff30ebf0229e' WHERE id = '053f2b47-8906-ddb1-3cfb-0ef982d6050b';
UPDATE reer_sh_yoonis.profiles SET father_id = '0137267c-ccca-bb77-0ff6-ff30ebf0229e' WHERE id = '6f3d9e76-8060-eece-fea2-151e42c2b9bb';
UPDATE reer_sh_yoonis.profiles SET father_id = '0137267c-ccca-bb77-0ff6-ff30ebf0229e' WHERE id = 'c7484172-b2b7-ffab-8a03-b4719560f8f9';
UPDATE reer_sh_yoonis.profiles SET father_id = '0137267c-ccca-bb77-0ff6-ff30ebf0229e' WHERE id = '46c00caf-7e3b-547d-477f-4feee3d229f4';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = 'd529d6a7-fc17-093d-6304-2ccfe5de3277';
UPDATE reer_sh_yoonis.profiles SET father_id = 'd529d6a7-fc17-093d-6304-2ccfe5de3277' WHERE id = '21a3d99f-ea6a-b568-a593-99f12518bb54';
UPDATE reer_sh_yoonis.profiles SET father_id = 'd529d6a7-fc17-093d-6304-2ccfe5de3277' WHERE id = '2565f705-63b1-66c6-7744-dffb87e5999e';
UPDATE reer_sh_yoonis.profiles SET father_id = 'd529d6a7-fc17-093d-6304-2ccfe5de3277' WHERE id = 'ca240ce2-6515-0903-ec92-5e402e80cb9d';
UPDATE reer_sh_yoonis.profiles SET father_id = 'd529d6a7-fc17-093d-6304-2ccfe5de3277' WHERE id = 'cacccb84-ad87-de78-8962-247189bb3252';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = '0c9523b7-cc68-c180-339f-0dd7cc6eb62d';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = '0ae39279-a131-7085-2961-689fc68e4a5e';
UPDATE reer_sh_yoonis.profiles SET father_id = '0ae39279-a131-7085-2961-689fc68e4a5e' WHERE id = '6a06fe52-1e3c-bee4-aab0-85c2de29a732';
UPDATE reer_sh_yoonis.profiles SET father_id = '0ae39279-a131-7085-2961-689fc68e4a5e' WHERE id = '741d0ba8-fb58-3189-fb43-a9465feeba9f';
UPDATE reer_sh_yoonis.profiles SET father_id = '0ae39279-a131-7085-2961-689fc68e4a5e' WHERE id = '97e7704c-5452-10bb-9a27-82446095b5d0';
UPDATE reer_sh_yoonis.profiles SET father_id = '0ae39279-a131-7085-2961-689fc68e4a5e' WHERE id = '26600952-210e-c3bc-f33b-558ad86964fc';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = '13e0c128-3e0c-b115-5cbd-f4408c0b1f00';
UPDATE reer_sh_yoonis.profiles SET father_id = '13e0c128-3e0c-b115-5cbd-f4408c0b1f00' WHERE id = 'd5de7bf3-4a68-1fcd-1191-8fa990a713ba';
UPDATE reer_sh_yoonis.profiles SET father_id = '13e0c128-3e0c-b115-5cbd-f4408c0b1f00' WHERE id = 'c66588fb-102d-cbdd-0577-dc3ec803b6f9';
UPDATE reer_sh_yoonis.profiles SET father_id = '13e0c128-3e0c-b115-5cbd-f4408c0b1f00' WHERE id = 'e328b73b-e103-8d7c-8485-3cff6d25e668';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = 'f6f9e2ab-640d-15ad-1a9c-09431ada83fb';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = 'a027813a-9b14-bd24-7c73-20a446d1ca0f';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = '2f1d0fd3-a105-1097-470e-676eb58c7cb5';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = '64d440db-d4d7-2a05-bd6a-ec6662056c3e';
UPDATE reer_sh_yoonis.profiles SET father_id = '8a6b9be8-eb33-f982-1898-0d943f19aa51' WHERE id = '5a3a3edc-5f35-8cd5-dcbd-806480e64fd3';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '107a1131-132f-97b0-81c4-f815d473db5d';
UPDATE reer_sh_yoonis.profiles SET father_id = '107a1131-132f-97b0-81c4-f815d473db5d' WHERE id = 'c3479fd8-a6b9-59e0-b1f9-7b68272b8d89';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c3479fd8-a6b9-59e0-b1f9-7b68272b8d89' WHERE id = '2f0921e7-da61-ca19-aa35-33aa12b9fb6b';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c3479fd8-a6b9-59e0-b1f9-7b68272b8d89' WHERE id = 'f58c769b-6960-a605-d6dc-3601de0e65f3';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c3479fd8-a6b9-59e0-b1f9-7b68272b8d89' WHERE id = 'aba5f468-9cbc-63ef-d27f-33f670a9beed';
UPDATE reer_sh_yoonis.profiles SET father_id = '107a1131-132f-97b0-81c4-f815d473db5d' WHERE id = '869b455f-925c-b5a9-7d7c-5a7a4d727fa4';
UPDATE reer_sh_yoonis.profiles SET father_id = '107a1131-132f-97b0-81c4-f815d473db5d' WHERE id = 'c9ed2122-e1f2-997a-a671-57af8535f564';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c9ed2122-e1f2-997a-a671-57af8535f564' WHERE id = 'e25a92ed-713e-2dbc-f283-3e1b776ff360';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c9ed2122-e1f2-997a-a671-57af8535f564' WHERE id = '628e86e7-5dbd-be52-f56c-f4de658fedc9';
UPDATE reer_sh_yoonis.profiles SET father_id = '107a1131-132f-97b0-81c4-f815d473db5d' WHERE id = '2e2aae27-5de8-0697-bf64-863ba7a4fb80';
UPDATE reer_sh_yoonis.profiles SET father_id = '2e2aae27-5de8-0697-bf64-863ba7a4fb80' WHERE id = '3dcf260d-5c29-e5a5-74bd-58f8f86fa3da';
UPDATE reer_sh_yoonis.profiles SET father_id = '2e2aae27-5de8-0697-bf64-863ba7a4fb80' WHERE id = '766125b7-b557-43c7-d824-a0c06951e240';
UPDATE reer_sh_yoonis.profiles SET father_id = '2e2aae27-5de8-0697-bf64-863ba7a4fb80' WHERE id = '99567860-2d50-dbcb-8157-bf5085878e0f';
UPDATE reer_sh_yoonis.profiles SET father_id = '2e2aae27-5de8-0697-bf64-863ba7a4fb80' WHERE id = '2bc659ae-fcb1-7ec4-d7bd-11b13441ee7f';
UPDATE reer_sh_yoonis.profiles SET father_id = '2e2aae27-5de8-0697-bf64-863ba7a4fb80' WHERE id = '38095d0f-d7fc-1ea7-2a28-4a47455b3031';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '616bb12a-cf85-e221-8b43-65740bd8d4c5';
UPDATE reer_sh_yoonis.profiles SET father_id = '616bb12a-cf85-e221-8b43-65740bd8d4c5' WHERE id = '3048fdcb-330a-e3a1-eb96-d934393ad0a7';
UPDATE reer_sh_yoonis.profiles SET father_id = '3048fdcb-330a-e3a1-eb96-d934393ad0a7' WHERE id = '6ccee8db-6771-26cf-b53d-eafa4f51fb93';
UPDATE reer_sh_yoonis.profiles SET father_id = '3048fdcb-330a-e3a1-eb96-d934393ad0a7' WHERE id = '43a9f872-4f59-564d-f316-bf9afde006fc';
UPDATE reer_sh_yoonis.profiles SET father_id = '3048fdcb-330a-e3a1-eb96-d934393ad0a7' WHERE id = '04f0a12f-d255-19ce-0d48-563658dbbbec';
UPDATE reer_sh_yoonis.profiles SET father_id = '3048fdcb-330a-e3a1-eb96-d934393ad0a7' WHERE id = '0260a03d-b669-b987-7f32-5f2c74fc4477';
UPDATE reer_sh_yoonis.profiles SET father_id = '3048fdcb-330a-e3a1-eb96-d934393ad0a7' WHERE id = 'b45efebc-3440-4ee6-e74e-34f193cdddf2';
UPDATE reer_sh_yoonis.profiles SET father_id = '3048fdcb-330a-e3a1-eb96-d934393ad0a7' WHERE id = 'feb3ecda-f353-7e5e-11e0-ba400b9284a7';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '8782bbef-bd67-ca86-2815-8a98878c3a04';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '8cd8738f-8970-f5cd-07b4-10075f3a56d4';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '10fba5ac-fe34-52ff-5015-f9eb79cd76a5';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '098e48d4-d5cf-5f65-747d-8a0679eb5fc8';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'b182bcf3-764d-d0ff-038e-6ae1d3217470';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'bfdd6285-b193-acea-cde1-cdc04a959631';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'a35ca3f5-e1ce-0536-e516-59ed805096a3';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '97aa31e4-5db7-a707-90df-73cc8201edda';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '238a0def-3ed0-49cf-609c-a397bcb0344c';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '68e9e265-a304-4c87-e3ac-a4e3fef643a2';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '711c7270-bb38-8ad8-a846-65e3a14f41e5';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '1905020d-c42f-15c4-3bfe-6cb15f7bf552';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'ee46f40a-8509-ae88-4dbf-b39b1ccee986';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'd1052f8e-232e-af94-f993-78642032aa09';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '5b9372bf-a17a-5274-147f-7f45c1cabac2';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '522154c1-a182-5f63-59d3-7901ae46e0a4';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = '89abcb2f-971d-de85-7f3f-5f626eaa1c07';
UPDATE reer_sh_yoonis.profiles SET father_id = '89abcb2f-971d-de85-7f3f-5f626eaa1c07' WHERE id = '0ecdc2c4-92f2-c6e8-e47a-4b2c5dbada92';
UPDATE reer_sh_yoonis.profiles SET father_id = '89abcb2f-971d-de85-7f3f-5f626eaa1c07' WHERE id = '92501e82-5a17-4f0e-6d56-0e30db6f9de5';
UPDATE reer_sh_yoonis.profiles SET father_id = '89abcb2f-971d-de85-7f3f-5f626eaa1c07' WHERE id = 'd5f474e4-5fc8-bf08-a069-d8f4fc3ef43c';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = 'c69dc823-f930-baae-fc0b-386061eafdbf';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c69dc823-f930-baae-fc0b-386061eafdbf' WHERE id = '37dce389-3355-b8e5-b884-ef4944d2227a';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c69dc823-f930-baae-fc0b-386061eafdbf' WHERE id = 'd2294d8d-f39a-fa44-cda5-f9d9224b85d1';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c69dc823-f930-baae-fc0b-386061eafdbf' WHERE id = 'bd8414a8-221b-8b96-4584-f9dc0c1b3774';
UPDATE reer_sh_yoonis.profiles SET father_id = 'c69dc823-f930-baae-fc0b-386061eafdbf' WHERE id = '35bfcbce-e4fc-7773-dde5-bc87cda41f60';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = '8a41bce6-460e-335d-d2b5-927143b9a99b';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = '61a00aad-57b7-7d49-c90e-a234d94cfb01';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = '9ed24d8d-8049-b936-e8ee-af3c021d6e76';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = '3d2563be-5899-9cd5-b7b0-01641720eeee';

-- Patriarch gets stable flourishing rating
UPDATE reer_sh_yoonis.profiles SET care_rating = 1 WHERE full_name ILIKE 'SHEEKH YONIS';

COMMIT;

-- Total profiles seeded: 261
