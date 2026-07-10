-- Payment destination for USSD (*883*MERCHANT*amount#).
ALTER TABLE reer_sh_yoonis.global_settings
  ADD COLUMN IF NOT EXISTS payment_merchant_id VARCHAR(20) NOT NULL DEFAULT '123456',
  ADD COLUMN IF NOT EXISTS ussd_service_code VARCHAR(10) NOT NULL DEFAULT '883';
