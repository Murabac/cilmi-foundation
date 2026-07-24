-- Collapse care_rating from 5 levels to 3 selectable options.
-- Old 1–2 → 1 (Stable), 3 → 2 (Under Pressure), 4–5 → 3 (Needs Support).

UPDATE reer_sh_yoonis.profiles
SET care_rating = CASE
  WHEN care_rating <= 2 THEN 1
  WHEN care_rating = 3 THEN 2
  ELSE 3
END;

ALTER TABLE reer_sh_yoonis.profiles
  DROP CONSTRAINT IF EXISTS profiles_care_rating_check;

ALTER TABLE reer_sh_yoonis.profiles
  ADD CONSTRAINT profiles_care_rating_check
  CHECK (care_rating BETWEEN 1 AND 3);

ALTER TABLE reer_sh_yoonis.profiles
  ALTER COLUMN care_rating SET DEFAULT 1;
