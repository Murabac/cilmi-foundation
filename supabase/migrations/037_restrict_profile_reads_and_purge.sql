-- 037: Close two data-access gaps.
--   1. profiles were readable by ANY authenticated user (USING (true)), including
--      users of other apps in this shared Supabase project and anyone who signs
--      up with the public anon key. Now only approved family members (and staff)
--      can read full profiles. Unapproved sign-ups can read only their own row,
--      plus a masked lineage directory (names + tree links) via
--      lineage_directory() so they can still find and claim their name.
--   2. purge_exempt_contributions() had no role check, so any signed-in user
--      could delete contribution rows. Now admins/managers only.
-- Run once in the Supabase SQL Editor after 036. Safe to re-run.

-- ── 1a. Who counts as an approved member ────────────────────────────────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.is_approved_member()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles p
    WHERE p.auth_user_id = auth.uid()
      AND (
        p.role <> 'family_member'              -- staff (manager, treasury, super_admin)
        OR p.father_id IS NOT NULL             -- linked into the tree (claim approved)
        OR p.id = reer_sh_yoonis.patriarch_profile_id()
      )
  );
$$;

REVOKE ALL ON FUNCTION reer_sh_yoonis.is_approved_member() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.is_approved_member() TO authenticated, service_role;

-- ── 1b. Replace the open read policy ────────────────────────────────────────
DROP POLICY IF EXISTS "rsy_read_profiles" ON reer_sh_yoonis.profiles;
DROP POLICY IF EXISTS "rsy_anon_read_profiles" ON reer_sh_yoonis.profiles;
DROP POLICY IF EXISTS "rsy_members_read_profiles" ON reer_sh_yoonis.profiles;

CREATE POLICY "rsy_members_read_profiles"
  ON reer_sh_yoonis.profiles FOR SELECT TO authenticated
  USING (
    auth_user_id = auth.uid()
    OR reer_sh_yoonis.is_approved_member()
  );

REVOKE SELECT ON reer_sh_yoonis.profiles FROM anon;

-- ── 1c. Masked directory for the claim flow ─────────────────────────────────
-- Returns every profile row with contact and personal fields removed.
-- Callable only by signed-in users who have a profile in this app.
CREATE OR REPLACE FUNCTION reer_sh_yoonis.lineage_directory()
RETURNS SETOF reer_sh_yoonis.profiles
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  r reer_sh_yoonis.profiles%ROWTYPE;
  v_full BOOLEAN;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM profiles WHERE auth_user_id = auth.uid()) THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_full := reer_sh_yoonis.is_approved_member();

  FOR r IN SELECT * FROM profiles ORDER BY birth_order, full_name LOOP
    IF NOT v_full AND r.auth_user_id IS DISTINCT FROM auth.uid() THEN
      r.email            := NULL;
      r.phone_number     := NULL;
      r.occupation       := NULL;
      r.city             := NULL;
      r.avatar_url       := NULL;
      r.marital_status   := NULL;
      r.billing_override := NULL;
      r.care_rating      := 1;
      -- keep "claimed / unclaimed" without exposing other users' auth ids
      IF r.auth_user_id IS NOT NULL THEN
        r.auth_user_id := '00000000-0000-0000-0000-000000000000'::uuid;
      END IF;
    END IF;
    RETURN NEXT r;
  END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION reer_sh_yoonis.lineage_directory() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.lineage_directory() TO authenticated, service_role;

-- ── 2. purge_exempt_contributions: admins/managers only ─────────────────────
CREATE OR REPLACE FUNCTION reer_sh_yoonis.purge_exempt_contributions()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_count INT := 0;
BEGIN
  IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  DELETE FROM reer_sh_yoonis.contributions c
  WHERE reer_sh_yoonis.is_profile_payment_exempt(c.user_id);

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION reer_sh_yoonis.purge_exempt_contributions() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.purge_exempt_contributions() TO authenticated, service_role;

NOTIFY pgrst, 'reload config';
