-- Step 15: Somali is the default app language.
ALTER TABLE reer_sh_yoonis.global_settings
  ALTER COLUMN app_language SET DEFAULT 'so';

UPDATE reer_sh_yoonis.global_settings
SET app_language = 'so',
    updated_at = now()
WHERE id = 1
  AND (app_language IS NULL OR app_language = 'en');
