-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  profile_visibility TEXT NOT NULL DEFAULT 'private', -- private, mutual, public
  real_time_sync_enabled BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- User stats table
CREATE TABLE user_stats (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  progress JSONB,
  purchased_items JSONB,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Followers table (social graph)
CREATE TABLE followers (
  follower_id UUID REFERENCES users(id),
  following_id UUID REFERENCES users(id),
  PRIMARY KEY (follower_id, following_id)
);
