-- Promote user with mobile 0634749276 to super_admin
-- Matches local (0634749276), national (634749276), and E.164 (+252634749276) formats.

UPDATE reer_sh_yoonis.profiles
SET role = 'super_admin'
WHERE phone_number IN (
  '0634749276',
  '634749276',
  '+252634749276',
  '252634749276'
)
OR auth_user_id IN (
  SELECT id
  FROM auth.users
  WHERE phone IN ('+252634749276', '252634749276')
     OR phone LIKE '%634749276%'
);

NOTIFY pgrst, 'reload config';
