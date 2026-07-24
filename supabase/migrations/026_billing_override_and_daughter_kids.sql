-- Daughter-branch children are payment-exempt.
-- Admins can force exempt or billable via billing_override.

ALTER TABLE reer_sh_yoonis.profiles
  ADD COLUMN IF NOT EXISTS billing_override TEXT
  CHECK (billing_override IS NULL OR billing_override IN ('exempt', 'billable'));

COMMENT ON COLUMN reer_sh_yoonis.profiles.billing_override IS
  'NULL = automatic rules; exempt = never billed; billable = always billed.';

CREATE OR REPLACE FUNCTION reer_sh_yoonis.is_patriarch_daughter(p_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM reer_sh_yoonis.profiles p
    WHERE p.id = p_profile_id
      AND p.father_id = reer_sh_yoonis.patriarch_profile_id()
      AND upper(trim(p.full_name)) NOT LIKE '%SHEEKH YONIS%'
      AND (
        upper(trim(p.full_name)) LIKE '% SHEEKH'
        OR upper(trim(p.full_name)) LIKE '% SHEEK'
      )
  );
$$;

CREATE OR REPLACE FUNCTION reer_sh_yoonis.is_profile_payment_exempt(p_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_demo reer_sh_yoonis.demographic_type;
  v_override TEXT;
  v_father_id UUID;
  v_generations INT;
BEGIN
  SELECT demographic, billing_override, father_id
    INTO v_demo, v_override, v_father_id
  FROM reer_sh_yoonis.profiles
  WHERE id = p_profile_id;

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  -- Admin override wins over automatic rules.
  IF v_override = 'exempt' THEN
    RETURN TRUE;
  END IF;
  IF v_override = 'billable' THEN
    RETURN FALSE;
  END IF;

  IF v_demo IN ('student', 'child') THEN
    RETURN TRUE;
  END IF;

  v_generations := reer_sh_yoonis.generations_from_patriarch(p_profile_id);

  -- Patriarch + sons/daughters (depth 0–1).
  IF v_generations IS NOT NULL AND v_generations <= 1 THEN
    RETURN TRUE;
  END IF;

  -- Kids of Sheekh Yonis daughters (linked via mother as father_id).
  IF v_father_id IS NOT NULL
     AND reer_sh_yoonis.is_patriarch_daughter(v_father_id) THEN
    RETURN TRUE;
  END IF;

  -- Below grandchild generation.
  IF v_generations IS NOT NULL AND v_generations >= 3 THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END;
$$;

-- Only admins/managers may change billing_override.
CREATE OR REPLACE FUNCTION reer_sh_yoonis.protect_profile_sensitive_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_role reer_sh_yoonis.user_role;
BEGIN
  IF current_setting('reer_sh_yoonis.bypass_profile_guard', true) = 'on' THEN
    RETURN NEW;
  END IF;

  v_role := reer_sh_yoonis.current_user_role();

  IF TG_OP = 'INSERT' THEN
    IF v_role IS DISTINCT FROM 'super_admin' THEN
      NEW.role := 'family_member';
    END IF;

    IF v_role IS NULL OR v_role = 'family_member' THEN
      IF NEW.auth_user_id IS NOT NULL AND NEW.auth_user_id IS DISTINCT FROM auth.uid() THEN
        RAISE EXCEPTION 'cannot_set_auth_user_id';
      END IF;
      IF NEW.father_id IS NOT NULL THEN
        RAISE EXCEPTION 'cannot_set_lineage_fields';
      END IF;
      IF COALESCE(NEW.birth_order, 0) <> 0 THEN
        RAISE EXCEPTION 'cannot_set_lineage_fields';
      END IF;
      NEW.billing_override := NULL;
    END IF;

    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF v_role IS DISTINCT FROM 'super_admin' THEN
      IF NEW.role IS DISTINCT FROM OLD.role THEN
        RAISE EXCEPTION 'cannot_change_role';
      END IF;
      IF NEW.auth_user_id IS DISTINCT FROM OLD.auth_user_id THEN
        RAISE EXCEPTION 'cannot_change_auth_user_id';
      END IF;
    END IF;

    IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
      IF NEW.father_id IS DISTINCT FROM OLD.father_id THEN
        RAISE EXCEPTION 'cannot_change_lineage_fields';
      END IF;
      IF NEW.full_name IS DISTINCT FROM OLD.full_name THEN
        RAISE EXCEPTION 'cannot_change_lineage_fields';
      END IF;
      IF NEW.birth_order IS DISTINCT FROM OLD.birth_order THEN
        RAISE EXCEPTION 'cannot_change_lineage_fields';
      END IF;
      IF NEW.billing_override IS DISTINCT FROM OLD.billing_override THEN
        RAISE EXCEPTION 'cannot_change_billing_override';
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.is_patriarch_daughter(UUID)
  TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION reer_sh_yoonis.is_profile_payment_exempt(UUID)
  TO authenticated, service_role;

SELECT reer_sh_yoonis.purge_exempt_contributions();

NOTIFY pgrst, 'reload config';
