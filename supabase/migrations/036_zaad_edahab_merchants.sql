-- ZAAD + e-Dahab merchant numbers for member contributions.
ALTER TABLE reer_sh_yoonis.global_settings
  ADD COLUMN IF NOT EXISTS edahab_merchant_id VARCHAR(20) NOT NULL DEFAULT '764043',
  ADD COLUMN IF NOT EXISTS edahab_ussd_service_code VARCHAR(10) NOT NULL DEFAULT '789';

-- ZAAD (primary / existing columns)
UPDATE reer_sh_yoonis.global_settings
SET
  payment_merchant_id = '484594',
  ussd_service_code = '883',
  edahab_merchant_id = '764043',
  edahab_ussd_service_code = '789'
WHERE id = 1;

NOTIFY pgrst, 'reload config';
