-- Add deceased to marital/life status enum.

ALTER TYPE reer_sh_yoonis.marital_status ADD VALUE IF NOT EXISTS 'deceased';

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
  v_marital reer_sh_yoonis.marital_status;
  v_generations INT;
BEGIN
  SELECT demographic, billing_override, father_id, marital_status
    INTO v_demo, v_override, v_father_id, v_marital
  FROM reer_sh_yoonis.profiles
  WHERE id = p_profile_id;

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  IF v_override = 'exempt' THEN
    RETURN TRUE;
  END IF;
  IF v_override = 'billable' THEN
    RETURN FALSE;
  END IF;

  IF v_demo IN ('student', 'child') THEN
    RETURN TRUE;
  END IF;

  IF v_marital = 'deceased' THEN
    RETURN TRUE;
  END IF;

  v_generations := reer_sh_yoonis.generations_from_patriarch(p_profile_id);

  IF v_generations IS NOT NULL AND v_generations <= 1 THEN
    RETURN TRUE;
  END IF;

  IF v_father_id IS NOT NULL
     AND reer_sh_yoonis.is_patriarch_daughter(v_father_id) THEN
    RETURN TRUE;
  END IF;

  IF v_generations IS NOT NULL AND v_generations >= 3 THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END;
$$;

SELECT reer_sh_yoonis.purge_exempt_contributions();

NOTIFY pgrst, 'reload config';
