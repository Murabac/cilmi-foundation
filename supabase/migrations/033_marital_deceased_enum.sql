-- Step 1 only: add deceased to marital_status.
-- Run alone and let it commit before 034.
-- Fixes: invalid input value for enum marital_status: "deceased"

ALTER TYPE reer_sh_yoonis.marital_status ADD VALUE IF NOT EXISTS 'deceased';
