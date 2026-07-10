-- Member business card fields, avatar storage, admin/manager profile editing

CREATE TYPE reer_sh_yoonis.marital_status AS ENUM ('single', 'married');

ALTER TABLE reer_sh_yoonis.profiles
  ADD COLUMN IF NOT EXISTS marital_status reer_sh_yoonis.marital_status,
  ADD COLUMN IF NOT EXISTS occupation VARCHAR(255),
  ADD COLUMN IF NOT EXISTS city VARCHAR(255),
  ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Managers and super admins can update member profile details
DROP POLICY IF EXISTS "rsy_admin_update_member_details" ON reer_sh_yoonis.profiles;
CREATE POLICY "rsy_admin_update_member_details"
  ON reer_sh_yoonis.profiles FOR UPDATE TO authenticated
  USING (reer_sh_yoonis.is_admin_or_manager())
  WITH CHECK (reer_sh_yoonis.is_admin_or_manager());

-- Avatar storage (public read for business cards)
INSERT INTO storage.buckets (id, name, public)
VALUES ('reer-sh-yoonis-avatars', 'reer-sh-yoonis-avatars', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "rsy_admin_upload_avatars" ON storage.objects;
CREATE POLICY "rsy_admin_upload_avatars"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'reer-sh-yoonis-avatars'
    AND reer_sh_yoonis.is_admin_or_manager()
  );

DROP POLICY IF EXISTS "rsy_admin_update_avatars" ON storage.objects;
CREATE POLICY "rsy_admin_update_avatars"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'reer-sh-yoonis-avatars'
    AND reer_sh_yoonis.is_admin_or_manager()
  );

DROP POLICY IF EXISTS "rsy_read_avatars" ON storage.objects;
CREATE POLICY "rsy_read_avatars"
  ON storage.objects FOR SELECT TO authenticated, anon
  USING (bucket_id = 'reer-sh-yoonis-avatars');

NOTIFY pgrst, 'reload config';
