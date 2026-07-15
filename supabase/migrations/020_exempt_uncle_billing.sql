-- Exempt Sheekh Yonis (patriarch) and his direct sons (uncles) from monthly billing.

CREATE OR REPLACE FUNCTION reer_sh_yoonis.generate_monthly_billing(
  p_month INT DEFAULT EXTRACT(MONTH FROM NOW())::INT,
  p_year INT DEFAULT EXTRACT(YEAR FROM NOW())::INT
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = reer_sh_yoonis
AS $$
DECLARE
  v_rate NUMERIC(10,2);
  v_count INT := 0;
  v_patriarch_id UUID;
BEGIN
  IF NOT reer_sh_yoonis.is_admin_or_manager() THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT current_adult_rate INTO v_rate FROM global_settings WHERE id = 1;

  SELECT id INTO v_patriarch_id
  FROM profiles
  WHERE full_name ILIKE '%SHEEKH YONIS%'
  ORDER BY CASE WHEN father_id IS NULL THEN 0 ELSE 1 END
  LIMIT 1;

  INSERT INTO contributions (user_id, billing_month, billing_year, amount_due, status)
  SELECT p.id, p_month, p_year, v_rate, 'pending'
  FROM profiles p
  WHERE p.demographic = 'adult'
    AND (v_patriarch_id IS NULL OR p.id IS DISTINCT FROM v_patriarch_id)
    AND (v_patriarch_id IS NULL OR p.father_id IS DISTINCT FROM v_patriarch_id)
  ON CONFLICT (user_id, billing_month, billing_year) DO NOTHING;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

-- Remove patriarch and uncle bills that may have been generated before this rule.
DELETE FROM reer_sh_yoonis.contributions c
USING reer_sh_yoonis.profiles p, reer_sh_yoonis.profiles patriarch
WHERE c.user_id = p.id
  AND patriarch.full_name ILIKE '%SHEEKH YONIS%'
  AND patriarch.father_id IS NULL
  AND (p.id = patriarch.id OR p.father_id = patriarch.id);
