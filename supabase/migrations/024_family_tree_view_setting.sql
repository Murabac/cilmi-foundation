-- Super admin chooses chart vs list layout for all users on the Family Tree tab.
ALTER TABLE reer_sh_yoonis.global_settings
  ADD COLUMN IF NOT EXISTS family_tree_view VARCHAR(10) NOT NULL DEFAULT 'chart'
  CHECK (family_tree_view IN ('chart', 'list'));
