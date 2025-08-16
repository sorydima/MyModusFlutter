-- 004_create_web3_tables.sql

-- Web3 кошельки пользователей
CREATE TABLE IF NOT EXISTS user_wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  wallet_address TEXT NOT NULL UNIQUE,
  wallet_type TEXT DEFAULT 'ethereum', -- 'ethereum', 'polygon', 'bsc'
  is_primary BOOLEAN DEFAULT false,
  nonce TEXT,
  last_sync_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Смарт-контракты
CREATE TABLE IF NOT EXISTS smart_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contract_address TEXT NOT NULL UNIQUE,
  contract_type TEXT NOT NULL, -- 'nft', 'loyalty', 'escrow'
  network TEXT NOT NULL, -- 'ethereum', 'polygon', 'bsc', 'testnet'
  abi JSONB,
  is_verified BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  deployed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- NFT токены
CREATE TABLE IF NOT EXISTS nfts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  token_id TEXT NOT NULL,
  contract_id UUID NOT NULL REFERENCES smart_contracts(id),
  owner_wallet_id UUID NOT NULL REFERENCES user_wallets(id),
  token_uri TEXT,
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  attributes JSONB,
  metadata_ipfs_hash TEXT,
  is_minted BOOLEAN DEFAULT false,
  minted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(contract_id, token_id)
);

-- Токены лояльности
CREATE TABLE IF NOT EXISTS loyalty_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  contract_id UUID NOT NULL REFERENCES smart_contracts(id),
  balance TEXT NOT NULL DEFAULT '0',
  total_earned TEXT NOT NULL DEFAULT '0',
  last_claim_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- IPFS файлы и метаданные
CREATE TABLE IF NOT EXISTS ipfs_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ipfs_hash TEXT NOT NULL UNIQUE,
  file_name TEXT NOT NULL,
  file_size BIGINT,
  mime_type TEXT,
  file_type TEXT NOT NULL, -- 'image', 'video', 'document', 'metadata'
  metadata JSONB,
  is_pinned BOOLEAN DEFAULT false,
  pin_expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Транзакции в блокчейне
CREATE TABLE IF NOT EXISTS blockchain_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tx_hash TEXT NOT NULL UNIQUE,
  from_address TEXT NOT NULL,
  to_address TEXT NOT NULL,
  contract_address TEXT,
  value TEXT,
  gas_used BIGINT,
  gas_price TEXT,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'confirmed', 'failed'
  block_number BIGINT,
  block_timestamp TIMESTAMP WITH TIME ZONE,
  network TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_user_wallets_user ON user_wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_user_wallets_address ON user_wallets(wallet_address);
CREATE INDEX IF NOT EXISTS idx_user_wallets_primary ON user_wallets(is_primary);

CREATE INDEX IF NOT EXISTS idx_smart_contracts_address ON smart_contracts(contract_address);
CREATE INDEX IF NOT EXISTS idx_smart_contracts_type ON smart_contracts(contract_type);
CREATE INDEX IF NOT EXISTS idx_smart_contracts_network ON smart_contracts(network);

CREATE INDEX IF NOT EXISTS idx_nfts_contract_token ON nfts(contract_id, token_id);
CREATE INDEX IF NOT EXISTS idx_nfts_owner ON nfts(owner_wallet_id);
CREATE INDEX IF NOT EXISTS idx_nfts_minted ON nfts(is_minted);

CREATE INDEX IF NOT EXISTS idx_loyalty_tokens_user ON loyalty_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_tokens_contract ON loyalty_tokens(contract_id);

CREATE INDEX IF NOT EXISTS idx_ipfs_files_hash ON ipfs_files(ipfs_hash);
CREATE INDEX IF NOT EXISTS idx_ipfs_files_type ON ipfs_files(file_type);
CREATE INDEX IF NOT EXISTS idx_ipfs_files_pinned ON ipfs_files(is_pinned);

CREATE INDEX IF NOT EXISTS idx_blockchain_tx_hash ON blockchain_transactions(tx_hash);
CREATE INDEX IF NOT EXISTS idx_blockchain_from ON blockchain_transactions(from_address);
CREATE INDEX IF NOT EXISTS idx_blockchain_to ON blockchain_transactions(to_address);
CREATE INDEX IF NOT EXISTS idx_blockchain_status ON blockchain_transactions(status);
CREATE INDEX IF NOT EXISTS idx_blockchain_network ON blockchain_transactions(network);

-- Триггеры для автоматического обновления
CREATE TRIGGER update_user_wallets_updated_at BEFORE UPDATE ON user_wallets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_smart_contracts_updated_at BEFORE UPDATE ON smart_contracts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_nfts_updated_at BEFORE UPDATE ON nfts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_loyalty_tokens_updated_at BEFORE UPDATE ON loyalty_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_blockchain_transactions_updated_at BEFORE UPDATE ON blockchain_transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Триггер для автоматического обновления основного кошелька
CREATE OR REPLACE FUNCTION ensure_single_primary_wallet()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_primary = true THEN
        UPDATE user_wallets SET is_primary = false 
        WHERE user_id = NEW.user_id AND id != NEW.id;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_ensure_single_primary_wallet
    BEFORE INSERT OR UPDATE ON user_wallets
    FOR EACH ROW EXECUTE FUNCTION ensure_single_primary_wallet();
