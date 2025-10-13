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
const updateProfileSchema = Joi.object({
  displayName: Joi.string().min(1).max(100).optional(),
  avatarUrl: Joi.string().uri().optional()
});

// Get current user profile
router.get('/me', authenticateUser, async (req, res) => {
  try {
    const { data: profile, error } = await supabase
      .from('users')
      .select('id, email, username, display_name, avatar_url, created_at, last_seen')
      .eq('id', req.user.id)
      .single();

    if (error) {
      return res.status(500).json({ error: 'Failed to fetch profile' });
    }

    res.json({ user: profile });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update user profile
router.put('/me', authenticateUser, async (req, res) => {
  try {
    const { error: validationError, value } = updateProfileSchema.validate(req.body);
    if (validationError) {
      return res.status(400).json({ error: validationError.details[0].message });
    }

    const updateData = {};
    if (value.displayName) updateData.display_name = value.displayName;
    if (value.avatarUrl) updateData.avatar_url = value.avatarUrl;

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ error: 'No valid fields to update' });
    }

    const { data, error } = await supabase
      .from('users')
      .update(updateData)
      .eq('id', req.user.id)
      .select()
      .single();

    if (error) {
      return res.status(500).json({ error: 'Failed to update profile' });
    }

    res.json({ user: data });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user profile by username
router.get('/profile/:username', async (req, res) => {
  try {
    const { username } = req.params;

    const { data: profile, error } = await supabase
      .from('users')
      .select('id, username, display_name, avatar_url, created_at, last_seen')
      .eq('username', username)
      .eq('is_active', true)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'User not found' });
      }
      return res.status(500).json({ error: 'Failed to fetch profile' });
    }

    res.json({ user: profile });
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Search users by username
router.get('/search', async (req, res) => {
  try {
    const { q, limit = 10 } = req.query;

    if (!q || q.length < 2) {
      return res.status(400).json({ error: 'Search query must be at least 2 characters' });
    }

    const { data: users, error } = await supabase
      .from('users')
      .select('id, username, display_name, avatar_url')
      .ilike('username', `%${q}%`)
      .eq('is_active', true)
      .limit(parseInt(limit));

    if (error) {
      return res.status(500).json({ error: 'Failed to search users' });
    }

    res.json({ users });
  } catch (error) {
    console.error('Search users error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update last seen timestamp
router.post('/me/activity', authenticateUser, async (req, res) => {
  try {
    const { error } = await supabase
      .from('users')
      .update({ last_seen: new Date().toISOString() })
      .eq('id', req.user.id);

    if (error) {
      return res.status(500).json({ error: 'Failed to update activity' });
    }

    res.json({ message: 'Activity updated' });
  } catch (error) {
    console.error('Update activity error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete user account
router.delete('/me', authenticateUser, async (req, res) => {
  try {
    // First deactivate the user
    const { error: deactivateError } = await supabase
      .from('users')
      .update({ is_active: false })
      .eq('id', req.user.id);

    if (deactivateError) {
      return res.status(500).json({ error: 'Failed to deactivate account' });
    }

    // Then delete from auth (this will cascade delete related data)
    const { error: authError } = await supabase.auth.admin.deleteUser(req.user.id);
    if (authError) {
      console.error('Failed to delete auth user:', authError);
      // Don't fail the request since we already deactivated
    }

    res.json({ message: 'Account deleted successfully' });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;