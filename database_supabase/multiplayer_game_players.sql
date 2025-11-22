-- Multiplayer game players table
CREATE TABLE IF NOT EXISTS multiplayer_game_players (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    game_session_id UUID NOT NULL REFERENCES multiplayer_game_sessions(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    player_name VARCHAR(50) NOT NULL,
    is_organizer BOOLEAN NOT NULL DEFAULT FALSE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ DEFAULT NOW(),
    is_connected BOOLEAN NOT NULL DEFAULT TRUE,
    score INTEGER NOT NULL DEFAULT 0,
    current_answer TEXT,
    answer_time_seconds INTEGER,
    UNIQUE(game_session_id, player_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_multiplayer_game_players_game_session_id ON multiplayer_game_players(game_session_id);
CREATE INDEX IF NOT EXISTS idx_multiplayer_game_players_player_id ON multiplayer_game_players(player_id);
CREATE INDEX IF NOT EXISTS idx_multiplayer_game_players_is_connected ON multiplayer_game_players(is_connected);

-- RLS policies
ALTER TABLE multiplayer_game_players ENABLE ROW LEVEL SECURITY;

-- Allow players to read players in their game session
CREATE POLICY "Players can read players in their game session" ON multiplayer_game_players
    FOR SELECT USING (
        game_session_id IN (
            SELECT id FROM multiplayer_game_sessions
            WHERE organizer_id = auth.uid()
        ) OR
        player_id = auth.uid()
    );

-- Allow players to insert themselves into a game session
CREATE POLICY "Players can join game sessions" ON multiplayer_game_players
    FOR INSERT WITH CHECK (player_id = auth.uid());

-- Allow players to update their own record
CREATE POLICY "Players can update their own record" ON multiplayer_game_players
    FOR UPDATE USING (player_id = auth.uid());

-- Allow organizer to update all players in their game session
CREATE POLICY "Organizer can update all players in their game session" ON multiplayer_game_players
    FOR UPDATE USING (
        game_session_id IN (
            SELECT id FROM multiplayer_game_sessions
            WHERE organizer_id = auth.uid()
        )
    );

-- Allow organizer to delete players from their game session
CREATE POLICY "Organizer can delete players from their game session" ON multiplayer_game_players
    FOR DELETE USING (
        game_session_id IN (
            SELECT id FROM multiplayer_game_sessions
            WHERE organizer_id = auth.uid()
        )
    );

-- Function to update last_seen_at when player activity occurs
CREATE OR REPLACE FUNCTION update_player_last_seen()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_seen_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update last_seen_at
CREATE TRIGGER trigger_update_player_last_seen
    BEFORE UPDATE ON multiplayer_game_players
    FOR EACH ROW
    EXECUTE FUNCTION update_player_last_seen();