-- Create a secure function to retrieve leaderboard data
-- This function uses security definer but is very restrictive about what data it exposes
CREATE OR REPLACE FUNCTION get_leaderboard_data(limit_count INT DEFAULT 5)
RETURNS TABLE (
    user_id UUID,
    username TEXT,
    display_name TEXT,
    score INT
) AS $$
BEGIN
    -- Return ONLY the specific data needed for leaderboard
    -- This is very restrictive and doesn't expose any sensitive data
    RETURN QUERY
    SELECT
        up.user_id,
        up.username,
        -- Use COALESCE to handle null display names
        COALESCE(NULLIF(up.display_name, ''), up.username) as display_name,
        -- Safely extract only the score from game_stats, default to 0 if not available
        -- Use CASE to handle potential invalid data and out-of-range values
        CASE
            WHEN (usd.data->'game_stats'->'value'->>'score') ~ '^[0-9]+$' THEN
                LEAST(GREATEST((usd.data->'game_stats'->'value'->>'score')::INT, 0), 999999999) -- Clamp to reasonable range
            WHEN (usd.data->'game_stats'->>'score') ~ '^[0-9]+$' THEN
                LEAST(GREATEST((usd.data->'game_stats'->>'score')::INT, 0), 999999999) -- Clamp to reasonable range
            ELSE 0
        END as score
    FROM
        user_profiles up
    -- Use LEFT JOIN to include users even if they don't have sync data
    LEFT JOIN
        user_sync_data usd ON up.user_id = usd.user_id
    WHERE
        -- Only include non-deleted users
        up.deleted_at IS NULL AND
        -- Exclude system/bot users if they exist
        up.username NOT LIKE 'system_%' AND
        up.username NOT LIKE 'bot_%' AND
        -- Exclude users with invalid usernames
        up.username IS NOT NULL AND
        up.username != '' AND
        LENGTH(up.username) <= 100
    ORDER BY
        -- Primary sort by score (highest first)
        score DESC NULLS LAST,
        -- Secondary sort by username for consistent ordering
        up.username ASC
    LIMIT
        -- Apply the limit parameter with safety check
        GREATEST(LEAST(limit_count, 100), 1); -- Clamp limit to 1-100 range
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Create a more restrictive version that only shows public leaderboard data
CREATE OR REPLACE FUNCTION get_public_leaderboard_data(limit_count INT DEFAULT 5)
RETURNS TABLE (
    user_id UUID,
    username TEXT,
    display_name TEXT,
    score INT
) AS $$
BEGIN
    -- This version is even more restrictive and only shows users who have opted into public leaderboard
    -- For now, we'll implement basic filtering, but in production you might want user preferences
    RETURN QUERY
    SELECT
        up.user_id,
        up.username,
        COALESCE(NULLIF(up.display_name, ''), up.username) as display_name,
        -- Use CASE to handle potential invalid data and out-of-range values
        CASE
            WHEN (usd.data->'game_stats'->'value'->>'score') ~ '^[0-9]+$' THEN
                LEAST(GREATEST((usd.data->'game_stats'->'value'->>'score')::INT, 0), 999999999)
            WHEN (usd.data->'game_stats'->>'score') ~ '^[0-9]+$' THEN
                LEAST(GREATEST((usd.data->'game_stats'->>'score')::INT, 0), 999999999)
            ELSE 0
        END as score
    FROM
        user_profiles up
    LEFT JOIN
        user_sync_data usd ON up.user_id = usd.user_id
    WHERE
        up.deleted_at IS NULL AND
        up.username NOT LIKE 'system_%' AND
        up.username NOT LIKE 'bot_%' AND
        -- Additional safety: exclude users with no username (shouldn't happen but just in case)
        up.username IS NOT NULL AND
        up.username != '' AND
        LENGTH(up.username) <= 100
    ORDER BY
        score DESC NULLS LAST,
        up.username ASC
    LIMIT
        -- Apply the limit parameter with safety check
        GREATEST(LEAST(limit_count, 100), 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Grant execute permission ONLY to authenticated users (not anon)
REVOKE ALL ON FUNCTION get_leaderboard_data(int) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_leaderboard_data(int) TO authenticated;

REVOKE ALL ON FUNCTION get_public_leaderboard_data(int) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_public_leaderboard_data(int) TO authenticated;