-- Reer Sh Yoonis family tree seed (from SHEEK YOONIS CSV)
-- Run after 001_initial_schema.sql
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
VALUES ('30ab04ce-d56c-1f07-6a3b-ea07784ddff7', 'MOHAMED', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e39b1fe9-aa72-e39b-8af9-01a76c79349a', 'CISMAAN', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('597819d6-d7ae-ee36-bf9e-84c1ef7eb401', 'NUURA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('aea54731-c707-6e02-7910-e6d0733a3fb7', 'CALI', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('acf88805-0539-8a77-604e-33444269c311', 'CABDILAAHI', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9d8ec945-6a04-e70f-e8d8-20df20a8d826', 'FAYSAL', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3ed22580-4b2b-8742-6be6-03ef9ebdb1b1', 'SAMIIRA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('17777882-ada6-9039-be64-d6869e0e5324', 'CUMAR', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('7642f2b4-4d92-108e-63fc-45611d98723f', 'SUBEER', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b61e7fe2-131e-a307-ea6f-2e40ae19c2ac', 'C/RAHMAN', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('896a25e4-b35e-b339-dd7b-ee2a520151ea', 'ROODA', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e320e41b-56c3-8409-1966-964f3d49c3a3', 'NIMCO', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('83d7118e-0537-50d6-8961-b69cd238a5c3', 'CABDIRASAQ', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('edd049c2-e6a8-eba6-40c2-71924beea630', 'SAFIYA', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae', 'SAHRA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1c13c4ff-52f8-3066-fbfc-cc7e517cc93e', 'NIMCO', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d05111d0-f2e1-bd43-d84d-16bdf74f59c7', 'CUMAR', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b68c85f7-ee32-427e-bfc1-2627faccd141', 'MOHAMED', NULL, 'family_member', 'adult', 2, 4)
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
VALUES ('d0659e6b-8c12-2d50-8b6c-9545de5c9484', 'IBRAHIM', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('497aed43-5e7d-aee3-9e85-b4850d7c4b22', 'MOHAMED', NULL, 'family_member', 'adult', 2, 2)
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
VALUES ('c3f8197a-b3f3-c56f-d8bd-f309cdbb5759', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0f5fe588-0588-efd9-4427-99b7862e0100', 'NIMCO', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f08918b3-cb3a-fbdd-c789-7dd1dfb6d058', 'MIRE', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a523b95a-0bf7-5248-70f1-0127df9c8da2', 'HODAN', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6ca99335-a5ed-c9f0-ef61-370dd1537bbf', 'SICIID', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('47356bab-2746-1001-b872-3eb04f1c00b8', 'NIMCO', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e1074b36-7350-ff8e-7029-b53ac4aff39e', 'C/RAHIM', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6e299527-3b94-26e1-3717-95d0d5fee21f', 'FARAH', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('28996ccc-b9cf-d27b-3ba3-c9c7d93d712f', 'FILSAN', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ef168e8c-1d06-4bd2-27f4-8f011b5915c0', 'FARHIYA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('6df8669e-cc8a-deb7-a706-395502b5105a', 'FAHIIMA', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fcf8b87a-326d-4122-138f-b24a47a84989', 'MOHAMED', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0f786735-37b7-7e24-0392-9d9faa738f5a', 'SUHAYB', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('ecc5d2c4-6d1f-7614-e38e-3b586e27ce48', 'AHMED', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fbe3985e-240e-18e5-d2b0-2531d2e36f1b', 'C/RAHMAN', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('4b7955f3-15e6-1dcd-e9de-d934e243cb02', 'C/RASAQ', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fc940d88-9b2a-9997-cb61-49e38b6738c7', 'BUSHRA', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1b57850f-2537-3a95-90e0-b6cf37a67bf1', 'MOHAMED', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('365d78c8-ae83-fa42-675d-9b8be641288e', 'C/QANI', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('85314f82-8f11-d09a-e9e4-ba99eb434430', 'C/RAHMAN', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('331f43f5-bf54-422d-3492-f3c3631016ca', 'ISMAIL', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b6bcbae6-a5ff-0dec-e07b-927ae73f928b', 'C/SHAKUUR', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a09146a4-0d4a-4a73-f880-7c5f909ab364', 'YOONIS', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('cf27d852-d87d-2c75-a918-f33edb830d1f', 'C/RASAAQ', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f5697690-b315-fcf8-1c53-337078e391dc', 'HIBAAQ', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('41ed0903-dd95-5b09-3ea2-3e904765e973', 'IIDO', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f203ef34-7225-b42e-b42b-65d1918d4b6e', 'ISTAAHIL', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b7ceaf0b-4d9b-eac8-b6f6-15ce9af883e5', 'MUNA', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('e62227cc-3e5b-d3d2-8f43-f66c8f09b95b', 'HINDA', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('5a8272b7-12d2-2841-b137-3a422129d4a2', 'CABDIRASHID', NULL, 'family_member', 'adult', 2, 8)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f3899079-1d68-5c45-8255-1faff58aecf3', 'KAWSAR', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('1642ed80-6065-95bb-c8b9-ed3c906201dd', 'FARDUUS', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('05fbc71a-3fdd-3722-4bff-fe668ae1520f', 'NIMCO', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('68d7d31b-97ad-0045-076f-59034b27b3af', 'AHMED', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('0c9523b7-cc68-c180-339f-0dd7cc6eb62d', 'MUSTAFE', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c420aafe-0819-64b6-60a9-2197826269c1', 'C/CASIIS', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('13e0c128-3e0c-b115-5cbd-f4408c0b1f00', 'YUUSUF', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('f6f9e2ab-640d-15ad-1a9c-09431ada83fb', 'RIDWAAN', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a7411d4a-7e30-27df-be39-694a074783ed', 'KHALID', NULL, 'family_member', 'adult', 2, 8)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3216b902-2908-5814-d812-6de0cb31fbdc', 'C/FATAH', NULL, 'family_member', 'adult', 2, 9)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('30c45f60-bf3d-c128-c0a7-8a949a783422', 'AYAAN', NULL, 'family_member', 'adult', 2, 10)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('b5dde88a-7237-a765-c08d-fbd04ef00eb8', 'MUNA', NULL, 'family_member', 'adult', 2, 11)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('107a1131-132f-97b0-81c4-f815d473db5d', 'SACDI', NULL, 'family_member', 'adult', 2, 9)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c3479fd8-a6b9-59e0-b1f9-7b68272b8d89', 'C/SHAKUUR', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('27285597-3166-f908-eb79-df40a47fa83d', 'XAMDA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c9ed2122-e1f2-997a-a671-57af8535f564', 'SACAADA', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2e2aae27-5de8-0697-bf64-863ba7a4fb80', 'SUHUUR', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d529d6a7-fc17-093d-6304-2ccfe5de3277', 'AHMED', NULL, 'family_member', 'adult', 2, 10)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('98c98966-7832-e468-90ef-df0fa0e29090', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('77dd4b8e-3c56-efde-2407-785ff8b0ede6', 'XASAN', NULL, 'family_member', 'adult', 2, 11)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('fc8762f4-a6cf-ee4e-19f7-905b89741389', 'MOHAMED', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('8cd8738f-8970-f5cd-07b4-10075f3a56d4', 'CABDI', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c28d7067-9c43-3229-ed67-9db27b5dec51', 'IBRAHIM', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a027813a-9b14-bd24-7c73-20a446d1ca0f', 'KHALID', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('d16bdf2a-75eb-25fb-626a-38a65ce33354', 'YOONIS', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('28c2a15e-519e-7e13-736a-eb5db9d2a6bc', 'C/QANI', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('a35ca3f5-e1ce-0536-e516-59ed805096a3', 'SAKI', NULL, 'family_member', 'adult', 2, 6)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('98c58a8d-197b-9002-61c5-9b75058978c3', 'ASMA', NULL, 'family_member', 'adult', 2, 7)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('238a0def-3ed0-49cf-609c-a397bcb0344c', 'BADRA', NULL, 'family_member', 'adult', 2, 8)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('68e9e265-a304-4c87-e3ac-a4e3fef643a2', 'HODAN', NULL, 'family_member', 'adult', 2, 9)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('43a9f872-4f59-564d-f316-bf9afde006fc', 'HOODO', NULL, 'family_member', 'adult', 2, 10)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('c6e8dbe3-2b27-7c5b-4d3f-9306630f5173', 'SAFA', NULL, 'family_member', 'adult', 2, 11)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('3dccfdb3-2129-8c48-adb8-4e2676ff7f97', 'MARWA', NULL, 'family_member', 'adult', 2, 12)
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
VALUES ('fa478548-074f-dc76-6c69-6a78aa92d422', 'SIHAAM', NULL, 'family_member', 'adult', 2, 0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('5e66c081-18ee-51aa-e292-ad64022bac42', 'SAFA', NULL, 'family_member', 'adult', 2, 1)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('2f1d0fd3-a105-1097-470e-676eb58c7cb5', 'C/FATAH', NULL, 'family_member', 'adult', 2, 2)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('61a00aad-57b7-7d49-c90e-a234d94cfb01', 'CUMAR', NULL, 'family_member', 'adult', 2, 3)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('9ed24d8d-8049-b936-e8ee-af3c021d6e76', 'C/RASAAQ', NULL, 'family_member', 'adult', 2, 4)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;
INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)
VALUES ('29b0776d-3772-3c57-609f-f7387ca404e3', 'MARWA', NULL, 'family_member', 'adult', 2, 5)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;

-- Link father_id (lineage)
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099' WHERE id = '3a6c4b11-1992-16bd-6d45-1d8f4a05a3cb';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099' WHERE id = '30ab04ce-d56c-1f07-6a3b-ea07784ddff7';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099' WHERE id = 'e39b1fe9-aa72-e39b-8af9-01a76c79349a';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099' WHERE id = '597819d6-d7ae-ee36-bf9e-84c1ef7eb401';
UPDATE reer_sh_yoonis.profiles SET father_id = 'b46b1f9b-7564-6d6b-239a-11d95bc02099' WHERE id = 'aea54731-c707-6e02-7910-e6d0733a3fb7';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'acf88805-0539-8a77-604e-33444269c311';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '9d8ec945-6a04-e70f-e8d8-20df20a8d826';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '3ed22580-4b2b-8742-6be6-03ef9ebdb1b1';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '17777882-ada6-9039-be64-d6869e0e5324';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '7642f2b4-4d92-108e-63fc-45611d98723f';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = 'b61e7fe2-131e-a307-ea6f-2e40ae19c2ac';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = '896a25e4-b35e-b339-dd7b-ee2a520151ea';
UPDATE reer_sh_yoonis.profiles SET father_id = 'acf88805-0539-8a77-604e-33444269c311' WHERE id = 'e320e41b-56c3-8409-1966-964f3d49c3a3';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '83d7118e-0537-50d6-8961-b69cd238a5c3';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = 'edd049c2-e6a8-eba6-40c2-71924beea630';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = '5d2b9ae4-ff5b-264f-5db9-c3c8424bb4ae';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = '1c13c4ff-52f8-3066-fbfc-cc7e517cc93e';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = 'd05111d0-f2e1-bd43-d84d-16bdf74f59c7';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = 'b68c85f7-ee32-427e-bfc1-2627faccd141';
UPDATE reer_sh_yoonis.profiles SET father_id = '83d7118e-0537-50d6-8961-b69cd238a5c3' WHERE id = 'e990b703-b647-91d0-a53c-c6a69a9bee09';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = '1b8a9934-f3c3-00b0-ddc1-6c632329cda2';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = 'd0659e6b-8c12-2d50-8b6c-9545de5c9484';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = '497aed43-5e7d-aee3-9e85-b4850d7c4b22';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = '79f1cba5-d523-c242-7cfd-81249ecb3e23';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = '6efa5283-cc89-a276-975e-600f12c55cf9';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = 'a213590e-2f81-c30e-2399-126a80471a3d';
UPDATE reer_sh_yoonis.profiles SET father_id = '151c5c91-bc9a-6a34-5c30-1f9a446bb949' WHERE id = '8af390b5-c35f-f2c6-b26a-3e260a865376';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'e349579f-c34b-aafd-6e51-c5649fa984c6';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e349579f-c34b-aafd-6e51-c5649fa984c6' WHERE id = 'c3f8197a-b3f3-c56f-d8bd-f309cdbb5759';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e349579f-c34b-aafd-6e51-c5649fa984c6' WHERE id = '0f5fe588-0588-efd9-4427-99b7862e0100';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'a523b95a-0bf7-5248-70f1-0127df9c8da2';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = '6ca99335-a5ed-c9f0-ef61-370dd1537bbf';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = '47356bab-2746-1001-b872-3eb04f1c00b8';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = '6e299527-3b94-26e1-3717-95d0d5fee21f';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = '28996ccc-b9cf-d27b-3ba3-c9c7d93d712f';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = 'ef168e8c-1d06-4bd2-27f4-8f011b5915c0';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = '6df8669e-cc8a-deb7-a706-395502b5105a';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = 'fcf8b87a-326d-4122-138f-b24a47a84989';
UPDATE reer_sh_yoonis.profiles SET father_id = 'e1074b36-7350-ff8e-7029-b53ac4aff39e' WHERE id = '0f786735-37b7-7e24-0392-9d9faa738f5a';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'ecc5d2c4-6d1f-7614-e38e-3b586e27ce48';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'fbe3985e-240e-18e5-d2b0-2531d2e36f1b';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = '4b7955f3-15e6-1dcd-e9de-d934e243cb02';
UPDATE reer_sh_yoonis.profiles SET father_id = 'f08918b3-cb3a-fbdd-c789-7dd1dfb6d058' WHERE id = 'fc940d88-9b2a-9997-cb61-49e38b6738c7';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '1b57850f-2537-3a95-90e0-b6cf37a67bf1';
UPDATE reer_sh_yoonis.profiles SET father_id = '1b57850f-2537-3a95-90e0-b6cf37a67bf1' WHERE id = '365d78c8-ae83-fa42-675d-9b8be641288e';
UPDATE reer_sh_yoonis.profiles SET father_id = '1b57850f-2537-3a95-90e0-b6cf37a67bf1' WHERE id = '85314f82-8f11-d09a-e9e4-ba99eb434430';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '331f43f5-bf54-422d-3492-f3c3631016ca';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'b6bcbae6-a5ff-0dec-e07b-927ae73f928b';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'a09146a4-0d4a-4a73-f880-7c5f909ab364';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'cf27d852-d87d-2c75-a918-f33edb830d1f';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'f5697690-b315-fcf8-1c53-337078e391dc';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = '41ed0903-dd95-5b09-3ea2-3e904765e973';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'f203ef34-7225-b42e-b42b-65d1918d4b6e';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'b7ceaf0b-4d9b-eac8-b6f6-15ce9af883e5';
UPDATE reer_sh_yoonis.profiles SET father_id = '331f43f5-bf54-422d-3492-f3c3631016ca' WHERE id = 'e62227cc-3e5b-d3d2-8f43-f66c8f09b95b';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '5a8272b7-12d2-2841-b137-3a422129d4a2';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = 'f3899079-1d68-5c45-8255-1faff58aecf3';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = '1642ed80-6065-95bb-c8b9-ed3c906201dd';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = '05fbc71a-3fdd-3722-4bff-fe668ae1520f';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = '68d7d31b-97ad-0045-076f-59034b27b3af';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = '0c9523b7-cc68-c180-339f-0dd7cc6eb62d';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = 'c420aafe-0819-64b6-60a9-2197826269c1';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = '13e0c128-3e0c-b115-5cbd-f4408c0b1f00';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = 'f6f9e2ab-640d-15ad-1a9c-09431ada83fb';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = 'a7411d4a-7e30-27df-be39-694a074783ed';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = '3216b902-2908-5814-d812-6de0cb31fbdc';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = '30c45f60-bf3d-c128-c0a7-8a949a783422';
UPDATE reer_sh_yoonis.profiles SET father_id = '5a8272b7-12d2-2841-b137-3a422129d4a2' WHERE id = 'b5dde88a-7237-a765-c08d-fbd04ef00eb8';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '107a1131-132f-97b0-81c4-f815d473db5d';
UPDATE reer_sh_yoonis.profiles SET father_id = '107a1131-132f-97b0-81c4-f815d473db5d' WHERE id = 'c3479fd8-a6b9-59e0-b1f9-7b68272b8d89';
UPDATE reer_sh_yoonis.profiles SET father_id = '107a1131-132f-97b0-81c4-f815d473db5d' WHERE id = '27285597-3166-f908-eb79-df40a47fa83d';
UPDATE reer_sh_yoonis.profiles SET father_id = '107a1131-132f-97b0-81c4-f815d473db5d' WHERE id = 'c9ed2122-e1f2-997a-a671-57af8535f564';
UPDATE reer_sh_yoonis.profiles SET father_id = '107a1131-132f-97b0-81c4-f815d473db5d' WHERE id = '2e2aae27-5de8-0697-bf64-863ba7a4fb80';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = 'd529d6a7-fc17-093d-6304-2ccfe5de3277';
UPDATE reer_sh_yoonis.profiles SET father_id = 'd529d6a7-fc17-093d-6304-2ccfe5de3277' WHERE id = '98c98966-7832-e468-90ef-df0fa0e29090';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'fc8762f4-a6cf-ee4e-19f7-905b89741389';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '8cd8738f-8970-f5cd-07b4-10075f3a56d4';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'c28d7067-9c43-3229-ed67-9db27b5dec51';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'a027813a-9b14-bd24-7c73-20a446d1ca0f';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'd16bdf2a-75eb-25fb-626a-38a65ce33354';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '28c2a15e-519e-7e13-736a-eb5db9d2a6bc';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'a35ca3f5-e1ce-0536-e516-59ed805096a3';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '98c58a8d-197b-9002-61c5-9b75058978c3';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '238a0def-3ed0-49cf-609c-a397bcb0344c';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '68e9e265-a304-4c87-e3ac-a4e3fef643a2';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '43a9f872-4f59-564d-f316-bf9afde006fc';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'c6e8dbe3-2b27-7c5b-4d3f-9306630f5173';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = '3dccfdb3-2129-8c48-adb8-4e2676ff7f97';
UPDATE reer_sh_yoonis.profiles SET father_id = '77dd4b8e-3c56-efde-2407-785ff8b0ede6' WHERE id = 'd1052f8e-232e-af94-f993-78642032aa09';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '5b9372bf-a17a-5274-147f-7f45c1cabac2';
UPDATE reer_sh_yoonis.profiles SET father_id = '8bffc1ca-5143-453f-7520-3ac411fb32d4' WHERE id = '522154c1-a182-5f63-59d3-7901ae46e0a4';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = 'fa478548-074f-dc76-6c69-6a78aa92d422';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = '5e66c081-18ee-51aa-e292-ad64022bac42';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = '2f1d0fd3-a105-1097-470e-676eb58c7cb5';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = '61a00aad-57b7-7d49-c90e-a234d94cfb01';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = '9ed24d8d-8049-b936-e8ee-af3c021d6e76';
UPDATE reer_sh_yoonis.profiles SET father_id = '522154c1-a182-5f63-59d3-7901ae46e0a4' WHERE id = '29b0776d-3772-3c57-609f-f7387ca404e3';

-- Patriarch gets stable flourishing rating
UPDATE reer_sh_yoonis.profiles SET care_rating = 1 WHERE full_name ILIKE 'SHEEKH YONIS';

COMMIT;

-- Total profiles seeded: 103
