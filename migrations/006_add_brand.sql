-- 006_add_brand.sql
ALTER TABLE items ADD COLUMN IF NOT EXISTS brand TEXT;
