const express = require('express');
const Joi = require('joi');
const { supabase } = require('../lib/supabase');

const router = express.Router();

// Middleware to verify authentication
const authenticateUser = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { data: { user }, error } = await supabase.auth.getUser(token);
    if (error || !user) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    req.user = user;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(401).json({ error: 'Authentication failed' });
  }
};

// Validation schemas
const updateStatsSchema = Joi.object({
  score: Joi.number().integer().min(0).optional(),
  currentStreak: Joi.number().integer().min(0).optional(),
  longestStreak: Joi.number().integer().min(0).optional(),
  incorrectAnswers: Joi.number().integer().min(0).optional(),
  totalQuestionsAnswered: Joi.number().integer().min(0).optional(),
  totalCorrectAnswers: Joi.number().integer().min(0).optional(),
  totalTimeSpent: Joi.number().integer().min(0).optional(),
  level: Joi.number().integer().min(1).optional(),
  experiencePoints: Joi.number().integer().min(0).optional()
});

// Get current user stats
router.get('/me', authenticateUser, async (req, res) => {
  try {
    const { data: stats, error } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', req.user.id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        // Create initial stats if they don't exist
        const { data: newStats, error: createError } = await supabase
          .from('user_stats')
          .insert({ user_id: req.user.id })
          .select()
          .single();

        if (createError) {
          return res.status(500).json({ error: 'Failed to create user stats' });
        }

        return res.json({ stats: newStats });
      }
      return res.status(500).json({ error: 'Failed to fetch stats' });
    }

    res.json({ stats });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update user stats
router.put('/me', authenticateUser, async (req, res) => {
  try {
    const { error: validationError, value } = updateStatsSchema.validate(req.body);
    if (validationError) {
      return res.status(400).json({ error: validationError.details[0].message });
    }

    // Check if stats exist
    const { data: existingStats } = await supabase
      .from('user_stats')
      .select('id')
      .eq('user_id', req.user.id)
      .single();

    let result;
    if (existingStats) {
      // Update existing stats
      const { data, error } = await supabase
        .from('user_stats')
        .update(value)
        .eq('user_id', req.user.id)
        .select()
        .single();

      if (error) {
        return res.status(500).json({ error: 'Failed to update stats' });
      }
      result = data;
    } else {
      // Create new stats
      const { data, error } = await supabase
        .from('user_stats')
        .insert({ user_id: req.user.id, ...value })
        .select()
        .single();

      if (error) {
        return res.status(500).json({ error: 'Failed to create stats' });
      }
      result = data;
    }

    res.json({ stats: result });
  } catch (error) {
    console.error('Update stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user stats by username
router.get('/user/:username', async (req, res) => {
  try {
    const { username } = req.params;

    // First get the user
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('id, username, display_name, avatar_url')
      .eq('username', username)
      .eq('is_active', true)
      .single();

    if (userError || !user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get user stats
    const { data: stats, error: statsError } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', user.id)
      .single();

    if (statsError) {
      return res.status(500).json({ error: 'Failed to fetch user stats' });
    }

    res.json({ 
      user: {
        id: user.id,
        username: user.username,
        displayName: user.display_name,
        avatarUrl: user.avatar_url
      },
      stats 
    });
  } catch (error) {
    console.error('Get user stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get leaderboard
router.get('/leaderboard', async (req, res) => {
  try {
    const { type = 'score', limit = 50 } = req.query;

    const validTypes = ['score', 'longest_streak', 'total_questions_answered', 'level'];
    if (!validTypes.includes(type)) {
      return res.status(400).json({ error: 'Invalid leaderboard type' });
    }

    const { data: leaderboard, error } = await supabase
      .from('user_stats')
      .select(`
        ${type},
        users!inner(id, username, display_name, avatar_url)
      `)
      .order(type, { ascending: false })
      .limit(parseInt(limit));

    if (error) {
      return res.status(500).json({ error: 'Failed to fetch leaderboard' });
    }

    // Transform the data to include user info
    const formattedLeaderboard = leaderboard.map((item, index) => ({
      rank: index + 1,
      value: item[type],
      user: {
        id: item.users.id,
        username: item.users.username,
        displayName: item.users.display_name,
        avatarUrl: item.users.avatar_url
      }
    }));

    res.json({ 
      leaderboard: formattedLeaderboard,
      type,
      total: leaderboard.length
    });
  } catch (error) {
    console.error('Get leaderboard error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Sync stats from local to server
router.post('/sync', authenticateUser, async (req, res) => {
  try {
    const { localStats } = req.body;

    if (!localStats) {
      return res.status(400).json({ error: 'Local stats required' });
    }

    // Get current server stats
    const { data: serverStats } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', req.user.id)
      .single();

    // Merge stats (server takes precedence for critical values, local for recent activity)
    const mergedStats = {
      ...localStats,
      // Keep server values for these fields to prevent cheating
      ...(serverStats && {
        score: Math.max(serverStats.score, localStats.score || 0),
        longestStreak: Math.max(serverStats.longest_streak, localStats.longestStreak || 0),
        level: Math.max(serverStats.level, localStats.level || 1),
        experiencePoints: Math.max(serverStats.experience_points, localStats.experiencePoints || 0)
      })
    };

    // Update server stats
    const { data: updatedStats, error } = await supabase
      .from('user_stats')
      .upsert({
        user_id: req.user.id,
        ...mergedStats
      })
      .select()
      .single();

    if (error) {
      return res.status(500).json({ error: 'Failed to sync stats' });
    }

    res.json({ 
      stats: updatedStats,
      synced: true
    });
  } catch (error) {
    console.error('Sync stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Reset user stats
router.post('/me/reset', authenticateUser, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('user_stats')
      .update({
        score: 0,
        current_streak: 0,
        longest_streak: 0,
        incorrect_answers: 0,
        total_questions_answered: 0,
        total_correct_answers: 0,
        total_time_spent: 0,
        level: 1,
        experience_points: 0
      })
      .eq('user_id', req.user.id)
      .select()
      .single();

    if (error) {
      return res.status(500).json({ error: 'Failed to reset stats' });
    }

    res.json({ stats: data });
  } catch (error) {
    console.error('Reset stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;