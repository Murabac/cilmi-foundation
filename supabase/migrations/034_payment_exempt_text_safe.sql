-- Step 2: payment-exempt helper must not cast the literal 'deceased' into the
-- enum (that blows up if the enum value is missing or not yet committed).
-- Run after 033 has committed (or even if 033 was skipped — text compare is safe).

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
  v_marital_text TEXT;
  v_generations INT;
  v_sheekh_id UUID;
  v_sheekh_depth INT;
BEGIN
  SELECT demographic, billing_override, father_id, marital_status::text
    INTO v_demo, v_override, v_father_id, v_marital_text
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

  IF v_marital_text = 'deceased' THEN
    RETURN TRUE;
  END IF;

  v_generations := reer_sh_yoonis.generations_from_patriarch(p_profile_id);
  v_sheekh_id := reer_sh_yoonis.sheekh_yonis_profile_id();
  IF v_sheekh_id IS NULL THEN
    v_sheekh_depth := 0;
  ELSE
    v_sheekh_depth := COALESCE(
      reer_sh_yoonis.generations_from_patriarch(v_sheekh_id),
      0
    );
  END IF;

  -- Patriarch + first generation under foundation root stay exempt.
  IF v_generations IS NOT NULL AND v_generations <= 1 THEN
    RETURN TRUE;
  END IF;

  -- Children of Sheekh Yonis daughters (linked via father_id) stay exempt.
  IF v_father_id IS NOT NULL
     AND reer_sh_yoonis.is_patriarch_daughter(v_father_id) THEN
    RETURN TRUE;
  END IF;

  -- Youngest generations relative to Sheekh stay exempt.
  IF v_generations IS NOT NULL
     AND v_generations >= v_sheekh_depth + 3 THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END;
$$;

GRANT EXECUTE ON FUNCTION reer_sh_yoonis.is_profile_payment_exempt(UUID)
  TO authenticated, service_role;

NOTIFY pgrst, 'reload config';
