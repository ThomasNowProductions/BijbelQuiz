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
const followUserSchema = Joi.object({
  username: Joi.string().alphanum().min(3).max(30).required()
});

// Follow a user
router.post('/follow', authenticateUser, async (req, res) => {
  try {
    const { error: validationError, value } = followUserSchema.validate(req.body);
    if (validationError) {
      return res.status(400).json({ error: validationError.details[0].message });
    }

    const { username } = value;

    // Can't follow yourself
    if (username === req.user.user_metadata?.username) {
      return res.status(400).json({ error: 'Cannot follow yourself' });
    }

    // Get the user to follow
    const { data: userToFollow, error: userError } = await supabase
      .from('users')
      .select('id, username, display_name, avatar_url')
      .eq('username', username)
      .eq('is_active', true)
      .single();

    if (userError || !userToFollow) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if already following
    const { data: existingFollow } = await supabase
      .from('follows')
      .select('id')
      .eq('follower_id', req.user.id)
      .eq('following_id', userToFollow.id)
      .single();

    if (existingFollow) {
      return res.status(409).json({ error: 'Already following this user' });
    }

    // Create follow relationship
    const { data: follow, error: followError } = await supabase
      .from('follows')
      .insert({
        follower_id: req.user.id,
        following_id: userToFollow.id
      })
      .select()
      .single();

    if (followError) {
      return res.status(500).json({ error: 'Failed to follow user' });
    }

    res.status(201).json({ 
      message: 'Successfully followed user',
      user: userToFollow
    });
  } catch (error) {
    console.error('Follow user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Unfollow a user
router.delete('/follow/:username', authenticateUser, async (req, res) => {
  try {
    const { username } = req.params;

    // Get the user to unfollow
    const { data: userToUnfollow, error: userError } = await supabase
      .from('users')
      .select('id')
      .eq('username', username)
      .single();

    if (userError || !userToUnfollow) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Remove follow relationship
    const { error: unfollowError } = await supabase
      .from('follows')
      .delete()
      .eq('follower_id', req.user.id)
      .eq('following_id', userToUnfollow.id);

    if (unfollowError) {
      return res.status(500).json({ error: 'Failed to unfollow user' });
    }

    res.json({ message: 'Successfully unfollowed user' });
  } catch (error) {
    console.error('Unfollow user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get users that the current user follows
router.get('/following', authenticateUser, async (req, res) => {
  try {
    const { limit = 50, offset = 0 } = req.query;

    const { data: following, error } = await supabase
      .from('follows')
      .select(`
        created_at,
        users!follows_following_id_fkey(id, username, display_name, avatar_url, last_seen)
      `)
      .eq('follower_id', req.user.id)
      .eq('status', 'active')
      .order('created_at', { ascending: false })
      .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

    if (error) {
      return res.status(500).json({ error: 'Failed to fetch following' });
    }

    const formattedFollowing = following.map(item => ({
      followedAt: item.created_at,
      user: item.users
    }));

    res.json({ following: formattedFollowing });
  } catch (error) {
    console.error('Get following error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get users that follow the current user
router.get('/followers', authenticateUser, async (req, res) => {
  try {
    const { limit = 50, offset = 0 } = req.query;

    const { data: followers, error } = await supabase
      .from('follows')
      .select(`
        created_at,
        users!follows_follower_id_fkey(id, username, display_name, avatar_url, last_seen)
      `)
      .eq('following_id', req.user.id)
      .eq('status', 'active')
      .order('created_at', { ascending: false })
      .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

    if (error) {
      return res.status(500).json({ error: 'Failed to fetch followers' });
    }

    const formattedFollowers = followers.map(item => ({
      followedAt: item.created_at,
      user: item.users
    }));

    res.json({ followers: formattedFollowers });
  } catch (error) {
    console.error('Get followers error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Check if following a specific user
router.get('/following/:username', authenticateUser, async (req, res) => {
  try {
    const { username } = req.params;

    const { data: follow, error } = await supabase
      .from('follows')
      .select(`
        id,
        users!follows_following_id_fkey(username)
      `)
      .eq('follower_id', req.user.id)
      .eq('users.username', username)
      .eq('status', 'active')
      .single();

    if (error && error.code !== 'PGRST116') {
      return res.status(500).json({ error: 'Failed to check follow status' });
    }

    res.json({ isFollowing: !!follow });
  } catch (error) {
    console.error('Check following error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get feed of followed users' activity
router.get('/feed', authenticateUser, async (req, res) => {
  try {
    const { limit = 20, offset = 0 } = req.query;

    // Get recent stats updates from followed users
    const { data: feed, error } = await supabase
      .from('user_stats')
      .select(`
        updated_at,
        score,
        longest_streak,
        level,
        users!inner(
          id,
          username,
          display_name,
          avatar_url,
          follows!follows_follower_id_fkey(id)
        )
      `)
      .eq('users.follows.follower_id', req.user.id)
      .eq('users.follows.status', 'active')
      .order('updated_at', { ascending: false })
      .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

    if (error) {
      return res.status(500).json({ error: 'Failed to fetch feed' });
    }

    const formattedFeed = feed.map(item => ({
      type: 'stats_update',
      timestamp: item.updated_at,
      user: {
        id: item.users.id,
        username: item.users.username,
        displayName: item.users.display_name,
        avatarUrl: item.users.avatar_url
      },
      data: {
        score: item.score,
        longestStreak: item.longest_streak,
        level: item.level
      }
    }));

    res.json({ feed: formattedFeed });
  } catch (error) {
    console.error('Get feed error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user's social stats
router.get('/stats/:username', async (req, res) => {
  try {
    const { username } = req.params;

    // Get user info
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('id, username, display_name, avatar_url, created_at')
      .eq('username', username)
      .eq('is_active', true)
      .single();

    if (userError || !user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get follower count
    const { count: followerCount, error: followerError } = await supabase
      .from('follows')
      .select('*', { count: 'exact', head: true })
      .eq('following_id', user.id)
      .eq('status', 'active');

    if (followerError) {
      return res.status(500).json({ error: 'Failed to fetch follower count' });
    }

    // Get following count
    const { count: followingCount, error: followingError } = await supabase
      .from('follows')
      .select('*', { count: 'exact', head: true })
      .eq('follower_id', user.id)
      .eq('status', 'active');

    if (followingError) {
      return res.status(500).json({ error: 'Failed to fetch following count' });
    }

    // Get user stats
    const { data: stats, error: statsError } = await supabase
      .from('user_stats')
      .select('score, longest_streak, level, total_questions_answered')
      .eq('user_id', user.id)
      .single();

    res.json({
      user: {
        id: user.id,
        username: user.username,
        displayName: user.display_name,
        avatarUrl: user.avatar_url,
        joinedAt: user.created_at
      },
      socialStats: {
        followers: followerCount || 0,
        following: followingCount || 0
      },
      gameStats: stats || {
        score: 0,
        longestStreak: 0,
        level: 1,
        totalQuestionsAnswered: 0
      }
    });
  } catch (error) {
    console.error('Get social stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;