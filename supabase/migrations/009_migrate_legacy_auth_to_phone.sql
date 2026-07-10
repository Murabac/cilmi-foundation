-- Migrate existing auth users to phone-based login (synthetic auth email).
-- Run once in Supabase SQL Editor after switching the app to phone login.
--
-- Result: user 0634749276 signs in with phone → auth uses 252634749276@phone.reershyoonis.app

CREATE OR REPLACE FUNCTION reer_sh_yoonis.normalize_phone_digits(raw text)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  d text;
BEGIN
  IF raw IS NULL OR trim(raw) = '' THEN
    RETURN NULL;
  END IF;

  d := regexp_replace(raw, '\D', '', 'g');
  IF d = '' THEN
    RETURN NULL;
  END IF;

  IF d LIKE '252%' THEN
    RETURN d;
  END IF;

  IF d LIKE '0%' THEN
    RETURN '252' || substring(d from 2);
  END IF;

  RETURN '252' || d;
END;
$$;

-- 1) Auth users that already have a phone on auth.users
UPDATE auth.users u
SET email = reer_sh_yoonis.normalize_phone_digits(u.phone) || '@phone.reershyoonis.app'
WHERE u.phone IS NOT NULL
  AND trim(u.phone) <> ''
  AND reer_sh_yoonis.normalize_phone_digits(u.phone) IS NOT NULL
  AND u.email IS DISTINCT FROM (
    reer_sh_yoonis.normalize_phone_digits(u.phone) || '@phone.reershyoonis.app'
  );

-- 2) Auth users linked to a profile with phone_number (covers old email-only signups)
UPDATE auth.users u
SET email = reer_sh_yoonis.normalize_phone_digits(p.phone_number) || '@phone.reershyoonis.app'
FROM reer_sh_yoonis.profiles p
WHERE p.auth_user_id = u.id
  AND p.phone_number IS NOT NULL
  AND trim(p.phone_number) <> ''
  AND reer_sh_yoonis.normalize_phone_digits(p.phone_number) IS NOT NULL
  AND u.email IS DISTINCT FROM (
    reer_sh_yoonis.normalize_phone_digits(p.phone_number) || '@phone.reershyoonis.app'
  );

-- 3) Keep profile phone in sync with auth phone when missing
UPDATE reer_sh_yoonis.profiles p
SET phone_number = u.phone
FROM auth.users u
WHERE p.auth_user_id = u.id
  AND (p.phone_number IS NULL OR trim(p.phone_number) = '')
  AND u.phone IS NOT NULL
  AND trim(u.phone) <> '';

-- 4) Super admin for 0634749276 (safe to re-run)
UPDATE reer_sh_yoonis.profiles p
SET role = 'super_admin'
FROM auth.users u
WHERE p.auth_user_id = u.id
  AND (
    reer_sh_yoonis.normalize_phone_digits(p.phone_number) = '252634749276'
    OR reer_sh_yoonis.normalize_phone_digits(u.phone) = '252634749276'
    OR u.email = '252634749276@phone.reershyoonis.app'
  );

-- Review any accounts that still need a phone set manually:
-- SELECT u.id, u.email, u.phone, p.full_name, p.phone_number
-- FROM auth.users u
-- LEFT JOIN reer_sh_yoonis.profiles p ON p.auth_user_id = u.id
-- WHERE u.email NOT LIKE '%@phone.reershyoonis.app';

NOTIFY pgrst, 'reload config';
