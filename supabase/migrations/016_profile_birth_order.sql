-- Sibling age order from family_tree.csv (oldest first within each father).
ALTER TABLE reer_sh_yoonis.profiles
  ADD COLUMN IF NOT EXISTS birth_order INT NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_rsy_profiles_father_birth_order
  ON reer_sh_yoonis.profiles(father_id, birth_order);

NOTIFY pgrst, 'reload config';

-- After this migration, re-run supabase/seed_family.sql to backfill birth_order values.
