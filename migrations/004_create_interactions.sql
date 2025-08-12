-- 004_create_interactions.sql
CREATE TABLE IF NOT EXISTS interactions (
  id SERIAL PRIMARY KEY,
  post_id INTEGER REFERENCES feed_posts(id),
  user_id INTEGER REFERENCES users(id),
  type TEXT NOT NULL, -- like, save, comment
  content TEXT, -- for comment text
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_interactions_post ON interactions(post_id);
