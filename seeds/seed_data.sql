-- seeds/seed_data.sql
INSERT INTO users (email, password_hash) VALUES ('demo@example.com', 'noop') ON CONFLICT DO NOTHING;
