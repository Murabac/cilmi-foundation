-- Step 1 only: add the enum value.
-- Must be committed before any SQL that references 'treasury'.
-- Run this file alone first, then run 032_treasury_role_permissions.sql.

ALTER TYPE reer_sh_yoonis.user_role ADD VALUE IF NOT EXISTS 'treasury';
