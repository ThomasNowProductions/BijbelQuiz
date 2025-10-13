require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

const app = express();
const port = process.env.PORT || 3000;

// Supabase configuration
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

app.use(bodyParser.json());
app.use(cors());

// --- Auth routes ---
app.post('/auth/signup', async (req, res) => {
  const { username, email, password } = req.body;

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        username,
      }
    }
  });

  if (error) {
    return res.status(400).json({ error: error.message });
  }

  res.status(201).json({ data });
});

app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    return res.status(400).json({ error: error.message });
  }

  res.json({ data });
});

// --- User data routes ---
app.get('/user/stats', async (req, res) => {
  const { user } = await supabase.auth.api.getUserByCookie(req);

  if (!user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const { data, error } = await supabase
    .from('user_stats')
    .select('*')
    .eq('user_id', user.id)
    .single();

  if (error) {
    return res.status(400).json({ error: error.message });
  }

  res.json({ data });
});

app.put('/user/stats', async (req, res) => {
  const { user } = await supabase.auth.api.getUserByCookie(req);

  if (!user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const { data, error } = await supabase
    .from('user_stats')
    .upsert({ user_id: user.id, ...req.body }, { onConflict: ['user_id'] });

  if (error) {
    return res.status(400).json({ error: error.message });
  }

  res.json({ data });
});

// --- Social routes ---
app.get('/social/users', async (req, res) => {
  const { q } = req.query;

  const { data, error } = await supabase
    .from('users')
    .select('id, username')
    .ilike('username', `%${q}%`);

  if (error) {
    return res.status(400).json({ error: error.message });
  }

  res.json({ data });
});

app.post('/social/follow/:userId', async (req, res) => {
  const { user } = await supabase.auth.api.getUserByCookie(req);

  if (!user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const { data, error } = await supabase
    .from('followers')
    .insert([{ follower_id: user.id, following_id: req.params.userId }]);

  if (error) {
    return res.status(400).json({ error: error.message });
  }

  res.status(201).json({ data });
});

app.delete('/social/unfollow/:userId', async (req, res) => {
  const { user } = await supabase.auth.api.getUserByCookie(req);

  if (!user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const { data, error } = await supabase
    .from('followers')
    .delete()
    .eq('follower_id', user.id)
    .eq('following_id', req.params.userId);

  if (error) {
    return res.status(400).json({ error: error.message });
  }

  res.json({ data });
});

// --- Settings routes ---
app.put('/settings/profile', async (req, res) => {
    const { user } = await supabase.auth.api.getUserByCookie(req);

    if (!user) {
        return res.status(401).json({ error: 'Unauthorized' });
    }

    const { data, error } = await supabase
        .from('users')
        .update({ profile_visibility: req.body.visibility })
        .eq('id', user.id);

    if (error) {
        return res.status(400).json({ error: error.message });
    }

    res.json({ data });
});

app.put('/settings/sync', async (req, res) => {
    const { user } = await supabase.auth.api.getUserByCookie(req);

    if (!user) {
        return res.status(401).json({ error: 'Unauthorized' });
    }

    const { data, error } = await supabase
        .from('users')
        .update({ real_time_sync_enabled: req.body.enabled })
        .eq('id', user.id);

    if (error) {
        return res.status(400).json({ error: error.message });
    }

    res.json({ data });
});


app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
