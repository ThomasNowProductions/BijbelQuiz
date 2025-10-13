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
const createPurchaseSchema = Joi.object({
  itemType: Joi.string().valid('powerup', 'theme', 'feature', 'premium').required(),
  itemId: Joi.string().required(),
  itemName: Joi.string().required(),
  cost: Joi.number().integer().min(0).required(),
  metadata: Joi.object().optional()
});

// Get user's purchases
router.get('/me', authenticateUser, async (req, res) => {
  try {
    const { status, itemType, limit = 50, offset = 0 } = req.query;

    let query = supabase
      .from('purchases')
      .select('*')
      .eq('user_id', req.user.id)
      .order('purchased_at', { ascending: false })
      .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

    if (status) {
      query = query.eq('status', status);
    }

    if (itemType) {
      query = query.eq('item_type', itemType);
    }

    const { data: purchases, error } = await query;

    if (error) {
      return res.status(500).json({ error: 'Failed to fetch purchases' });
    }

    res.json({ purchases });
  } catch (error) {
    console.error('Get purchases error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create a new purchase
router.post('/', authenticateUser, async (req, res) => {
  try {
    const { error: validationError, value } = createPurchaseSchema.validate(req.body);
    if (validationError) {
      return res.status(400).json({ error: validationError.details[0].message });
    }

    const { itemType, itemId, itemName, cost, metadata } = value;

    // Check if user has enough points
    const { data: userStats, error: statsError } = await supabase
      .from('user_stats')
      .select('score')
      .eq('user_id', req.user.id)
      .single();

    if (statsError) {
      return res.status(500).json({ error: 'Failed to check user balance' });
    }

    if (!userStats || userStats.score < cost) {
      return res.status(400).json({ error: 'Insufficient points' });
    }

    // Check if item is already purchased (for non-consumable items)
    if (itemType !== 'powerup') {
      const { data: existingPurchase } = await supabase
        .from('purchases')
        .select('id')
        .eq('user_id', req.user.id)
        .eq('item_id', itemId)
        .eq('status', 'completed')
        .single();

      if (existingPurchase) {
        return res.status(409).json({ error: 'Item already purchased' });
      }
    }

    // Create purchase record
    const { data: purchase, error: purchaseError } = await supabase
      .from('purchases')
      .insert({
        user_id: req.user.id,
        item_type: itemType,
        item_id: itemId,
        item_name: itemName,
        cost,
        metadata: metadata || {}
      })
      .select()
      .single();

    if (purchaseError) {
      return res.status(500).json({ error: 'Failed to create purchase' });
    }

    // Deduct points from user's score
    const { error: deductError } = await supabase
      .from('user_stats')
      .update({
        score: userStats.score - cost
      })
      .eq('user_id', req.user.id);

    if (deductError) {
      // Rollback purchase if point deduction fails
      await supabase
        .from('purchases')
        .delete()
        .eq('id', purchase.id);
      
      return res.status(500).json({ error: 'Failed to process payment' });
    }

    res.status(201).json({ purchase });
  } catch (error) {
    console.error('Create purchase error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get purchase by ID
router.get('/:purchaseId', authenticateUser, async (req, res) => {
  try {
    const { purchaseId } = req.params;

    const { data: purchase, error } = await supabase
      .from('purchases')
      .select('*')
      .eq('id', purchaseId)
      .eq('user_id', req.user.id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'Purchase not found' });
      }
      return res.status(500).json({ error: 'Failed to fetch purchase' });
    }

    res.json({ purchase });
  } catch (error) {
    console.error('Get purchase error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Check if user owns a specific item
router.get('/check/:itemType/:itemId', authenticateUser, async (req, res) => {
  try {
    const { itemType, itemId } = req.params;

    const { data: purchase, error } = await supabase
      .from('purchases')
      .select('id, expires_at')
      .eq('user_id', req.user.id)
      .eq('item_type', itemType)
      .eq('item_id', itemId)
      .eq('status', 'completed')
      .single();

    if (error && error.code !== 'PGRST116') {
      return res.status(500).json({ error: 'Failed to check ownership' });
    }

    if (!purchase) {
      return res.json({ owned: false });
    }

    // Check if item has expired
    if (purchase.expires_at && new Date(purchase.expires_at) < new Date()) {
      return res.json({ owned: false, expired: true });
    }

    res.json({ owned: true, expiresAt: purchase.expires_at });
  } catch (error) {
    console.error('Check ownership error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get available items for purchase
router.get('/store/items', async (req, res) => {
  try {
    const { itemType, limit = 50 } = req.query;

    // This would typically come from a separate items table
    // For now, we'll return a static list of available items
    const availableItems = [
      {
        id: 'powerup_double_points',
        type: 'powerup',
        name: 'Double Points (5 Questions)',
        description: 'Earn double points for the next 5 questions',
        cost: 100,
        duration: 5, // questions
        metadata: { multiplier: 2, questions: 5 }
      },
      {
        id: 'powerup_triple_points',
        type: 'powerup',
        name: 'Triple Points (3 Questions)',
        description: 'Earn triple points for the next 3 questions',
        cost: 150,
        duration: 3,
        metadata: { multiplier: 3, questions: 3 }
      },
      {
        id: 'powerup_time_extension',
        type: 'powerup',
        name: 'Time Extension',
        description: 'Get 10 extra seconds per question for 10 questions',
        cost: 200,
        duration: 10,
        metadata: { timeExtension: 10, questions: 10 }
      },
      {
        id: 'theme_dark',
        type: 'theme',
        name: 'Dark Theme',
        description: 'Unlock the dark theme for the app',
        cost: 50,
        permanent: true,
        metadata: { themeId: 'dark' }
      },
      {
        id: 'theme_ocean',
        type: 'theme',
        name: 'Ocean Theme',
        description: 'Unlock the ocean theme for the app',
        cost: 75,
        permanent: true,
        metadata: { themeId: 'ocean' }
      },
      {
        id: 'feature_skip_question',
        type: 'feature',
        name: 'Skip Question',
        description: 'Skip a question you don\'t know',
        cost: 25,
        consumable: true,
        metadata: { action: 'skip_question' }
      },
      {
        id: 'feature_hint',
        type: 'feature',
        name: 'Hint',
        description: 'Get a hint for the current question',
        cost: 15,
        consumable: true,
        metadata: { action: 'hint' }
      }
    ];

    let filteredItems = availableItems;
    if (itemType) {
      filteredItems = availableItems.filter(item => item.type === itemType);
    }

    res.json({ 
      items: filteredItems.slice(0, parseInt(limit)),
      total: filteredItems.length
    });
  } catch (error) {
    console.error('Get store items error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Refund a purchase
router.post('/:purchaseId/refund', authenticateUser, async (req, res) => {
  try {
    const { purchaseId } = req.params;

    // Get the purchase
    const { data: purchase, error: purchaseError } = await supabase
      .from('purchases')
      .select('*')
      .eq('id', purchaseId)
      .eq('user_id', req.user.id)
      .eq('status', 'completed')
      .single();

    if (purchaseError || !purchase) {
      return res.status(404).json({ error: 'Purchase not found or not eligible for refund' });
    }

    // Check if refund is allowed (e.g., within 24 hours)
    const purchaseDate = new Date(purchase.purchased_at);
    const now = new Date();
    const hoursDiff = (now - purchaseDate) / (1000 * 60 * 60);

    if (hoursDiff > 24) {
      return res.status(400).json({ error: 'Refund period has expired' });
    }

    // Update purchase status
    const { error: updateError } = await supabase
      .from('purchases')
      .update({ status: 'refunded' })
      .eq('id', purchaseId);

    if (updateError) {
      return res.status(500).json({ error: 'Failed to process refund' });
    }

    // Refund points to user
    const { error: refundError } = await supabase
      .from('user_stats')
      .update({
        score: supabase.raw(`score + ${purchase.cost}`)
      })
      .eq('user_id', req.user.id);

    if (refundError) {
      // Rollback purchase status if refund fails
      await supabase
        .from('purchases')
        .update({ status: 'completed' })
        .eq('id', purchaseId);
      
      return res.status(500).json({ error: 'Failed to refund points' });
    }

    res.json({ message: 'Purchase refunded successfully' });
  } catch (error) {
    console.error('Refund purchase error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;