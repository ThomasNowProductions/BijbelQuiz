-- Multiplayer game sessions table
CREATE TABLE IF NOT EXISTS multiplayer_game_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    game_code VARCHAR(6) UNIQUE NOT NULL,
    organizer_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting', 'active', 'finished')),
    game_settings JSONB NOT NULL DEFAULT '{
        "num_questions": 10,
        "time_limit_minutes": null,
        "question_time_seconds": 20
    }',
    current_question_index INTEGER DEFAULT 0,
    current_question_start_time TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_multiplayer_game_sessions_game_code ON multiplayer_game_sessions(game_code);
CREATE INDEX IF NOT EXISTS idx_multiplayer_game_sessions_organizer_id ON multiplayer_game_sessions(organizer_id);
CREATE INDEX IF NOT EXISTS idx_multiplayer_game_sessions_status ON multiplayer_game_sessions(status);

-- RLS policies
ALTER TABLE multiplayer_game_sessions ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read game sessions (for joining)
CREATE POLICY "Anyone can read multiplayer game sessions" ON multiplayer_game_sessions
    FOR SELECT USING (true);

-- Only organizer can update their game session
CREATE POLICY "Organizer can update their game session" ON multiplayer_game_sessions
    FOR UPDATE USING (organizer_id = auth.uid());

-- Only organizer can insert their game session
CREATE POLICY "Organizer can insert their game session" ON multiplayer_game_sessions
    FOR INSERT WITH CHECK (organizer_id = auth.uid());

-- Only organizer can delete their game session
CREATE POLICY "Organizer can delete their game session" ON multiplayer_game_sessions
    FOR DELETE USING (organizer_id = auth.uid());

-- Function to generate unique 6-letter game codes
CREATE OR REPLACE FUNCTION generate_game_code()
RETURNS VARCHAR(6) AS $$
DECLARE
    code VARCHAR(6);
    exists_already BOOLEAN;
BEGIN
    LOOP
        -- Generate random 6-letter code using uppercase letters
        code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6));
        -- Check if code already exists
        SELECT EXISTS(SELECT 1 FROM multiplayer_game_sessions WHERE game_code = code) INTO exists_already;
        EXIT WHEN NOT exists_already;
    END LOOP;
    RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_multiplayer_game_sessions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER trigger_update_multiplayer_game_sessions_updated_at
    BEFORE UPDATE ON multiplayer_game_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_multiplayer_game_sessions_updated_at();