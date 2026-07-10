-- Link existing auth user (0634749276) to super_admin if registered before profile link.
-- Auth email format: {digits}@phone.reershyoonis.app  →  252634749276@phone.reershyoonis.app

UPDATE reer_sh_yoonis.profiles p
SET role = 'super_admin'
FROM auth.users u
WHERE p.auth_user_id = u.id
  AND (
    p.phone_number IN (
      '0634749276', '634749276', '+252634749276', '252634749276'
    )
    OR u.email = '252634749276@phone.reershyoonis.app'
    OR u.phone IN ('+252634749276', '252634749276')
  );

-- If no profile exists yet but auth user does, nothing to update until they complete lineage setup.
-- Re-run 007 after registration if needed.

NOTIFY pgrst, 'reload config';
