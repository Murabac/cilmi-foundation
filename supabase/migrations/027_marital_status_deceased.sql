-- Add deceased to marital/life status enum ONLY.
-- Do not put function bodies that reference 'deceased' in this same file —
-- Postgres requires the new enum value to be committed first.
-- After this commits, run 034_payment_exempt_text_safe.sql (or 028+).

ALTER TYPE reer_sh_yoonis.marital_status ADD VALUE IF NOT EXISTS 'deceased';
