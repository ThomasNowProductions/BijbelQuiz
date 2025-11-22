-- Multiplayer game answers table
CREATE TABLE IF NOT EXISTS multiplayer_game_answers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    game_session_id UUID NOT NULL REFERENCES multiplayer_game_sessions(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    question_index INTEGER NOT NULL,
    answer TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL,
    answer_time_seconds INTEGER,
    points_earned INTEGER NOT NULL DEFAULT 0,
    answered_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(game_session_id, player_id, question_index)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_multiplayer_game_answers_game_session_id ON multiplayer_game_answers(game_session_id);
CREATE INDEX IF NOT EXISTS idx_multiplayer_game_answers_player_id ON multiplayer_game_answers(player_id);
CREATE INDEX IF NOT EXISTS idx_multiplayer_game_answers_question_index ON multiplayer_game_answers(question_index);

-- RLS policies
ALTER TABLE multiplayer_game_answers ENABLE ROW LEVEL SECURITY;

-- Allow players to read answers in their game session
CREATE POLICY "Players can read answers in their game session" ON multiplayer_game_answers
    FOR SELECT USING (
        game_session_id IN (
            SELECT id FROM multiplayer_game_sessions
            WHERE organizer_id = auth.uid()
        ) OR
        player_id = auth.uid()
    );

-- Allow players to insert their own answers
CREATE POLICY "Players can insert their own answers" ON multiplayer_game_answers
    FOR INSERT WITH CHECK (player_id = auth.uid());

-- Allow organizer to read all answers in their game session
CREATE POLICY "Organizer can read all answers in their game session" ON multiplayer_game_answers
    FOR SELECT USING (
        game_session_id IN (
            SELECT id FROM multiplayer_game_sessions
            WHERE organizer_id = auth.uid()
        )
    );

-- Function to calculate points based on correctness and speed
CREATE OR REPLACE FUNCTION calculate_answer_points(
    is_correct BOOLEAN,
    answer_time_seconds INTEGER,
    question_time_limit INTEGER DEFAULT 20
) RETURNS INTEGER AS $$
BEGIN
    IF NOT is_correct THEN
        RETURN 0;
    END IF;

    -- Base points for correct answer
    -- Bonus points for speed: faster answers get more points
    -- Max bonus: 50 points for answering in 2 seconds or less
    -- Min bonus: 0 points for answering in time limit or more
    IF answer_time_seconds <= 2 THEN
        RETURN 100 + 50; -- 150 points
    ELSIF answer_time_seconds >= question_time_limit THEN
        RETURN 100; -- 100 points
    ELSE
        -- Linear interpolation between 2 seconds (150 points) and time limit (100 points)
        DECLARE
            time_ratio NUMERIC := (answer_time_seconds - 2.0) / (question_time_limit - 2.0);
            bonus_points INTEGER := 50 - (time_ratio * 50)::INTEGER;
        BEGIN
            RETURN 100 + GREATEST(0, bonus_points);
        END;
    END IF;
END;
$$ LANGUAGE plpgsql;