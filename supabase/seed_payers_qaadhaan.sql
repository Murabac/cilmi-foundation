-- Load the monthly payers list from "QAADHAAN - MONTHLY" (Aug 2026, total $240).
-- Only these members pay. Everyone else becomes exempt (monthly_amount = NULL).
-- Run AFTER migration 038, in the Supabase SQL Editor.
--
-- Each payer is matched in the tree by (grandfather, father, name). Spelling is
-- normalised (C/ = Cabdi, doubled letters collapsed, Maxamed = Mohamed, etc.).
-- Rows with zero or several matches are NOT applied; they are listed at the end
-- so you can set them in the app (Maaree Xubnaha > member > Qaadhaanka billaha).

-- Reusable name normaliser (also handy for ad-hoc lookups).
CREATE OR REPLACE FUNCTION reer_sh_yoonis.norm_somali_name(p TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT regexp_replace(
           regexp_replace(
             regexp_replace(
               regexp_replace(
                 regexp_replace(
                   regexp_replace(lower(coalesce(p, '')), 'c\s*/\s*', 'cabdi', 'g'),
                 '[^a-z]', '', 'g'),
               '(.)\1+', '\1', 'g'),
             '^abd', 'cabd'),
           '^(maxamed|muhamed|mohamad|maxamad|mohamud)$', 'mohamed'),
         '^axmed$', 'ahmed');
$$;

BEGIN;

CREATE TEMP TABLE payer_seed (
  code TEXT, grandfather TEXT, father TEXT, name TEXT, amount NUMERIC(10,2)
);

INSERT INTO payer_seed VALUES
  -- 001 REER C/QAADIR SH. YOONIS
  ('001-1', 'SHEEKH YONIS', 'C/QAADIR', 'CISMAAN', 10),
  ('001-2', 'SHEEKH YONIS', 'C/QAADIR', 'CALI', 10),
  -- 002 REER C/LAAHI SH. YOONIS
  ('002-1', 'SHEEKH YONIS', 'C/LAAHI', 'FAYSAL', 5),
  ('002-2', 'SHEEKH YONIS', 'C/LAAHI', 'SUBEER', 5),
  ('002-3', 'SHEEKH YONIS', 'C/LAAHI', 'C/RAHMAN', 5),
  -- 003 REER C/RASAQ SH. YOONIS
  ('003-1', 'SHEEKH YONIS', 'C/RASAQ', 'CUMAR', 5),
  ('003-2', 'SHEEKH YONIS', 'C/RASAQ', 'MOHAMED', 10),
  ('003-3', 'SHEEKH YONIS', 'C/RASAQ', 'MUSTAFE', 5),
  -- 004 REER C/KARIIM SH. YOONIS
  ('004-1', 'SHEEKH YONIS', 'C/KARIIM', 'ISMAACIIL', 5),
  ('004-2', 'SHEEKH YONIS', 'C/KARIIM', 'IBRAHIM', 5),
  ('004-3', 'SHEEKH YONIS', 'C/KARIIM', 'MOHAMED', 5),
  -- 005 REER NUUR SH. YOONIS
  ('005-1', 'SHEEKH YONIS', 'NUUR', 'MOHAMED', 10),
  -- 006 REER MIRE SH. YOONIS
  ('006-1', 'SHEEKH YONIS', 'MIRE', 'SICIID', 10),
  ('006-2', 'SHEEKH YONIS', 'MIRE', 'C/RAHIIM', 10),
  ('006-3', 'SHEEKH YONIS', 'MIRE', 'C/RAHMAN', 5),
  ('006-4', 'SHEEKH YONIS', 'MIRE', 'C/RASAAQ', 5),
  -- 007 REER MOHAMED SH. YOONIS
  ('007-1', 'SHEEKH YONIS', 'MOHAMED', 'C/RAHMAN', 10),
  -- 008 REER ISMACIIL SH. YOONIS
  ('008-1', 'SHEEKH YONIS', 'ISMACIIL', 'C/SHAKUUR', 10),
  ('008-2', 'SHEEKH YONIS', 'ISMACIIL', 'YOONIS', 5),
  -- 009 REER C/RASHIID SH. YOONIS
  ('009-1', 'SHEEKH YONIS', 'C/RASHIID', 'AHMED', 10),
  ('009-2', 'SHEEKH YONIS', 'C/RASHIID', 'MUSTAFE', 10),
  ('009-3', 'SHEEKH YONIS', 'C/RASHIID', 'C/CASIIS', 10),
  ('009-4', 'SHEEKH YONIS', 'C/RASHIID', 'YUUSUF', 10),
  ('009-5', 'SHEEKH YONIS', 'C/RASHIID', 'KHALID', 5),
  ('009-6', 'SHEEKH YONIS', 'C/RASHIID', 'C/FATAH', 5),
  -- 010 REER AHMED SH. YOONIS
  ('010-1', 'SHEEKH YONIS', 'AHMED', 'MOHAMED', 10),
  -- 011 REER XASAN SH. YOONIS
  ('011-1', 'SHEEKH YONIS', 'XASAN', 'MOHAMED', 5),
  ('011-2', 'SHEEKH YONIS', 'XASAN', 'IBRAHIM', 5),
  ('011-3', 'SHEEKH YONIS', 'XASAN', 'KHALID', 5),
  ('011-4', 'SHEEKH YONIS', 'XASAN', 'SAKI', 5),
  -- 012 REER KHADAR SH. YOONIS
  ('012-1', 'SHEEKH YONIS', 'KHADAR', 'C/FATAH', 5),
  -- 013 REER MOHAMED ADAM (sub-group MAWLIID)
  ('013-1', 'MOHAMED', 'MAWLIID', 'C/NAASIR', 10),
  ('013-2', 'MOHAMED', 'MAWLIID', 'SAKI', 5),
  ('013-3', 'AADAN', 'MOHAMED', 'DAAHIR', 5);

CREATE TEMP TABLE payer_match AS
SELECT s.*, p.id AS profile_id, p.full_name AS matched_name
FROM payer_seed s
JOIN reer_sh_yoonis.profiles p
  ON reer_sh_yoonis.norm_somali_name(s.name) IN (
       reer_sh_yoonis.norm_somali_name(split_part(p.full_name, ' ', 1)),
       reer_sh_yoonis.norm_somali_name(p.full_name))
JOIN reer_sh_yoonis.profiles f
  ON f.id = p.father_id
 AND reer_sh_yoonis.norm_somali_name(s.father) IN (
       reer_sh_yoonis.norm_somali_name(split_part(f.full_name, ' ', 1)),
       reer_sh_yoonis.norm_somali_name(f.full_name))
JOIN reer_sh_yoonis.profiles g
  ON g.id = f.father_id
 AND (
   (s.grandfather = 'SHEEKH YONIS' AND g.id = reer_sh_yoonis.sheekh_yonis_profile_id())
   OR (s.grandfather <> 'SHEEKH YONIS'
       AND reer_sh_yoonis.norm_somali_name(split_part(g.full_name, ' ', 1))
           = reer_sh_yoonis.norm_somali_name(s.grandfather))
 );

CREATE TEMP TABLE payer_unique AS
SELECT code, min(profile_id::text)::uuid AS profile_id, max(amount) AS amount
FROM payer_match
GROUP BY code
HAVING count(*) = 1;

SELECT set_config('reer_sh_yoonis.bypass_profile_guard', 'on', true);

-- Everyone off the list first, then the matched payers on.
UPDATE reer_sh_yoonis.profiles SET monthly_amount = NULL WHERE monthly_amount IS NOT NULL;
UPDATE reer_sh_yoonis.profiles p
SET monthly_amount = u.amount
FROM payer_unique u
WHERE p.id = u.profile_id;

SELECT set_config('reer_sh_yoonis.bypass_profile_guard', 'off', true);

COMMIT;

-- Result (shown in the SQL Editor): one row per payer. status = 'set' | 'NOT FOUND' | 'AMBIGUOUS (n)'
SELECT s.code, s.father AS reer_of, s.name, s.amount,
       CASE
         WHEN count(m.profile_id) = 1 THEN 'set'
         WHEN count(m.profile_id) = 0 THEN 'NOT FOUND'
         ELSE 'AMBIGUOUS (' || count(m.profile_id) || ')'
       END AS status,
       string_agg(m.matched_name, ', ') AS matched
FROM payer_seed s
LEFT JOIN payer_match m ON m.code = s.code
GROUP BY s.code, s.father, s.name, s.amount
ORDER BY s.code;

-- Total check (should be 34 payers / 240 when every row above says 'set'):
-- SELECT count(*), sum(monthly_amount) FROM reer_sh_yoonis.profiles WHERE monthly_amount > 0;


