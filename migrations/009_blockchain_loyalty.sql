-- Migration: Blockchain Loyalty System
-- Description: Creates tables for blockchain-based loyalty program with crypto rewards

-- Users loyalty profiles
CREATE TABLE IF NOT EXISTS user_loyalty_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    wallet_address VARCHAR(255) UNIQUE,
    loyalty_points DECIMAL(20,8) DEFAULT 0,
    loyalty_tier VARCHAR(50) DEFAULT 'bronze',
    total_spent DECIMAL(10,2) DEFAULT 0,
    total_rewards_earned DECIMAL(20,8) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Loyalty tiers configuration
CREATE TABLE IF NOT EXISTS loyalty_tiers (
    id SERIAL PRIMARY KEY,
    tier_name VARCHAR(50) UNIQUE NOT NULL,
    min_points INTEGER NOT NULL,
    min_spent DECIMAL(10,2) NOT NULL,
    reward_multiplier DECIMAL(5,4) DEFAULT 1.0,
    benefits JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Loyalty transactions
CREATE TABLE IF NOT EXISTS loyalty_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_type VARCHAR(50) NOT NULL, -- 'earn', 'spend', 'bonus', 'referral'
    points_amount DECIMAL(20,8) NOT NULL,
    crypto_amount DECIMAL(20,8),
    description TEXT,
    metadata JSONB,
    blockchain_tx_hash VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'confirmed', 'failed'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP
);

-- Crypto rewards configuration
CREATE TABLE IF NOT EXISTS crypto_rewards (
    id SERIAL PRIMARY KEY,
    reward_type VARCHAR(50) NOT NULL, -- 'purchase', 'referral', 'daily_login', 'achievement'
    points_required INTEGER NOT NULL,
    crypto_amount DECIMAL(20,8) NOT NULL,
    token_symbol VARCHAR(10) DEFAULT 'MODUS',
    is_active BOOLEAN DEFAULT true,
    max_daily_claims INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User achievements
CREATE TABLE IF NOT EXISTS user_achievements (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_type VARCHAR(50) NOT NULL,
    achievement_name VARCHAR(100) NOT NULL,
    description TEXT,
    points_rewarded INTEGER NOT NULL,
    crypto_rewarded DECIMAL(20,8),
    achieved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- Referral system
CREATE TABLE IF NOT EXISTS user_referrals (
    id SERIAL PRIMARY KEY,
    referrer_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    referred_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    referral_code VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'completed', 'expired'
    points_rewarded INTEGER DEFAULT 0,
    crypto_rewarded DECIMAL(20,8) DEFAULT 0,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(referred_id)
);

-- Daily login rewards
CREATE TABLE IF NOT EXISTS daily_login_rewards (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    login_date DATE NOT NULL,
    points_earned INTEGER NOT NULL,
    crypto_earned DECIMAL(20,8),
    streak_days INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, login_date)
);

-- Insert default loyalty tiers
INSERT INTO loyalty_tiers (tier_name, min_points, min_spent, reward_multiplier, benefits) VALUES
('bronze', 0, 0, 1.0, '{"discount": 0, "free_shipping": false, "priority_support": false}'),
('silver', 1000, 1000, 1.2, '{"discount": 5, "free_shipping": false, "priority_support": false}'),
('gold', 5000, 5000, 1.5, '{"discount": 10, "free_shipping": true, "priority_support": false}'),
('platinum', 15000, 15000, 2.0, '{"discount": 15, "free_shipping": true, "priority_support": true}'),
('diamond', 50000, 50000, 3.0, '{"discount": 20, "free_shipping": true, "priority_support": true, "exclusive_offers": true}');

-- Insert default crypto rewards
INSERT INTO crypto_rewards (reward_type, points_required, crypto_amount, token_symbol) VALUES
('purchase', 100, 0.1, 'MODUS'),
('referral', 500, 0.5, 'MODUS'),
('daily_login', 50, 0.05, 'MODUS'),
('achievement', 1000, 1.0, 'MODUS'),
('tier_upgrade', 2000, 2.0, 'MODUS');

-- Create indexes for better performance
CREATE INDEX idx_user_loyalty_profiles_user_id ON user_loyalty_profiles(user_id);
CREATE INDEX idx_user_loyalty_profiles_wallet ON user_loyalty_profiles(wallet_address);
CREATE INDEX idx_loyalty_transactions_user_id ON loyalty_transactions(user_id);
CREATE INDEX idx_loyalty_transactions_type ON loyalty_transactions(transaction_type);
CREATE INDEX idx_loyalty_transactions_status ON loyalty_transactions(status);
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_user_referrals_referrer_id ON user_referrals(referrer_id);
CREATE INDEX idx_user_referrals_referred_id ON user_referrals(referred_id);
CREATE INDEX idx_daily_login_rewards_user_date ON daily_login_rewards(user_id, login_date);
