-- 002_web3_wallets.sql (or 003 depending on existing)
BEGIN;

CREATE TABLE IF NOT EXISTS wallets (
  id SERIAL PRIMARY KEY,
  user_id INT,
  address TEXT NOT NULL UNIQUE,
  kms_ref TEXT,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS orders_chain_log (
  id SERIAL PRIMARY KEY,
  order_id INT,
  user_id INT,
  order_hash TEXT,
  tx_hash TEXT,
  chain TEXT,
  status TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

COMMIT;
