const express = require('express');
const Joi = require('joi');
const { supabase, supabaseAdmin } = require('../lib/supabase');
const { v4: uuidv4 } = require('uuid');

const router = express.Router();

// Enhanced validation schemas with security measures
const signupSchema = Joi.object({
  email: Joi.string()
    .email({ tlds: { allow: false } })
    .max(254)
    .required()
    .messages({
      'string.email': 'Please provide a valid email address',
      'string.max': 'Email address is too long',
      'any.required': 'Email is required'
    }),
  password: Joi.string()
    .min(8)
    .max(128)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .required()
    .messages({
      'string.min': 'Password must be at least 8 characters long',
      'string.max': 'Password is too long',
      'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
      'any.required': 'Password is required'
    }),
  username: Joi.string()
    .alphanum()
    .min(3)
    .max(30)
    .required()
    .messages({
      'string.alphanum': 'Username can only contain letters and numbers',
      'string.min': 'Username must be at least 3 characters long',
      'string.max': 'Username is too long',
      'any.required': 'Username is required'
    }),
  displayName: Joi.string()
    .min(1)
    .max(100)
    .pattern(/^[a-zA-Z0-9\s\-_.,!?]+$/)
    .required()
    .messages({
      'string.min': 'Display name is required',
      'string.max': 'Display name is too long',
      'string.pattern.base': 'Display name contains invalid characters',
      'any.required': 'Display name is required'
    })
});

const loginSchema = Joi.object({
  email: Joi.string()
    .email({ tlds: { allow: false } })
    .max(254)
    .required()
    .messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    }),
  password: Joi.string()
    .min(1)
    .max(128)
    .required()
    .messages({
      'any.required': 'Password is required'
    })
});

const usernameLoginSchema = Joi.object({
  username: Joi.string()
    .alphanum()
    .min(3)
    .max(30)
    .required()
    .messages({
      'string.alphanum': 'Username can only contain letters and numbers',
      'any.required': 'Username is required'
    }),
  password: Joi.string()
    .min(1)
    .max(128)
    .required()
    .messages({
      'any.required': 'Password is required'
    })
});

// Input sanitization function
const sanitizeInput = (input) => {
  if (typeof input !== 'string') return input;
  return input
    .trim()
    .replace(/[<>]/g, '') // Remove potential HTML tags
    .replace(/javascript:/gi, '') // Remove javascript: protocol
    .replace(/on\w+=/gi, ''); // Remove event handlers
};

// Sign up endpoint
router.post('/signup', async (req, res) => {
  try {
    // Sanitize input before validation
    const sanitizedBody = {
      email: sanitizeInput(req.body.email),
      password: req.body.password, // Don't sanitize password
      username: sanitizeInput(req.body.username),
      displayName: sanitizeInput(req.body.displayName)
    };

    const { error, value } = signupSchema.validate(sanitizedBody);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { email, password, username, displayName } = value;

    // Check if username already exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('id')
      .eq('username', username)
      .single();

    if (existingUser) {
      return res.status(409).json({ error: 'Username already taken' });
    }

    // Create user with Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          username,
          display_name: displayName
        }
      }
    });

    if (authError) {
      return res.status(400).json({ error: authError.message });
    }

    if (!authData.user) {
      return res.status(400).json({ error: 'Failed to create user' });
    }

    // Create user profile
    const { error: profileError } = await supabase
      .from('users')
      .insert({
        id: authData.user.id,
        email,
        username,
        display_name: displayName
      });

    if (profileError) {
      // If profile creation fails, we should clean up the auth user
      await supabaseAdmin?.auth.admin.deleteUser(authData.user.id);
      return res.status(500).json({ error: 'Failed to create user profile' });
    }

    // Create initial user stats
    const { error: statsError } = await supabase
      .from('user_stats')
      .insert({
        user_id: authData.user.id
      });

    if (statsError) {
      console.error('Failed to create user stats:', statsError);
      // Don't fail the signup for this
    }

    res.status(201).json({
      user: {
        id: authData.user.id,
        email: authData.user.email,
        username,
        displayName
      },
      session: authData.session
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Login endpoint
router.post('/login', async (req, res) => {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { email, password } = value;

    const { data, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (authError) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    if (!data.user) {
      return res.status(401).json({ error: 'Authentication failed' });
    }

    // Get user profile
    const { data: profile, error: profileError } = await supabase
      .from('users')
      .select('username, display_name, avatar_url, created_at')
      .eq('id', data.user.id)
      .single();

    if (profileError) {
      return res.status(500).json({ error: 'Failed to fetch user profile' });
    }

    res.json({
      user: {
        id: data.user.id,
        email: data.user.email,
        ...profile
      },
      session: data.session
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Login with username endpoint
router.post('/login-username', async (req, res) => {
  try {
    const { error, value } = usernameLoginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { username, password } = value;

    // First get the email for this username
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('email')
      .eq('username', username)
      .single();

    if (userError || !userData) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Now login with email
    const { data, error: authError } = await supabase.auth.signInWithPassword({
      email: userData.email,
      password
    });

    if (authError) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    if (!data.user) {
      return res.status(401).json({ error: 'Authentication failed' });
    }

    // Get user profile
    const { data: profile, error: profileError } = await supabase
      .from('users')
      .select('username, display_name, avatar_url, created_at')
      .eq('id', data.user.id)
      .single();

    if (profileError) {
      return res.status(500).json({ error: 'Failed to fetch user profile' });
    }

    res.json({
      user: {
        id: data.user.id,
        email: data.user.email,
        ...profile
      },
      session: data.session
    });
  } catch (error) {
    console.error('Username login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Logout endpoint
router.post('/logout', async (req, res) => {
  try {
    const { error } = await supabase.auth.signOut();
    if (error) {
      return res.status(400).json({ error: error.message });
    }
    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Refresh token endpoint
router.post('/refresh', async (req, res) => {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) {
      return res.status(400).json({ error: 'Refresh token required' });
    }

    const { data, error } = await supabase.auth.refreshSession({
      refresh_token
    });

    if (error) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    res.json({ session: data.session });
  } catch (error) {
    console.error('Refresh error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Check username availability
router.get('/check-username/:username', async (req, res) => {
  try {
    const { username } = req.params;
    
    if (!username || username.length < 3 || username.length > 30) {
      return res.status(400).json({ error: 'Username must be 3-30 characters' });
    }

    const { data, error } = await supabase
      .from('users')
      .select('id')
      .eq('username', username)
      .single();

    if (error && error.code !== 'PGRST116') { // PGRST116 = no rows returned
      return res.status(500).json({ error: 'Database error' });
    }

    res.json({ available: !data });
  } catch (error) {
    console.error('Username check error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;