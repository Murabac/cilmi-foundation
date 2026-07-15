-- Fix signup 500: migration 017's profile guard blocked handle_new_user from
-- setting auth_user_id during auth.users INSERT (auth.uid() is null there).
-- Run in Supabase SQL Editor after 017/018.

CREATE OR REPLACE FUNCTION reer_sh_yoonis.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
BEGIN
  IF COALESCE(NEW.raw_user_meta_data->>'app', '') = 'reer_sh_yoonis' THEN
    PERFORM set_config('reer_sh_yoonis.bypass_profile_guard', 'on', true);

    INSERT INTO profiles (auth_user_id, full_name, email, role, demographic)
    VALUES (
      NEW.id,
      COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
      NEW.email,
      'family_member',
      'adult'
    );

    PERFORM set_config('reer_sh_yoonis.bypass_profile_guard', 'off', true);
  END IF;

  RETURN NEW;
END;
$$;
