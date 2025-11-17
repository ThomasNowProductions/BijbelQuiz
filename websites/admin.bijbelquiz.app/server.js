// server.js - Node.js server for Admin Dashboard API (for local development)
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
const slowDown = require('express-slow-down');
const xss = require('xss');
const validator = require('validator');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Trust proxy for proper IP detection behind reverse proxies (important for rate limiting)
app.set('trust proxy', 1);

// Initialize Supabase client
let supabase;
if (process.env.SUPABASE_URL && process.env.SUPABASE_SERVICE_ROLE_KEY) {
    supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
} else {
    console.error("Supabase configuration is missing. Please set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in your environment.");
}

// Serve static files from the current directory
app.use(express.static(__dirname));

// Force HTTPS in production
if (process.env.NODE_ENV === 'production') {
    app.use((req, res, next) => {
        if (req.header('x-forwarded-proto') !== 'https') {
            res.redirect(`https://${req.header('host')}${req.url}`);
        } else {
            next();
        }
    });
}

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://*.supabase.co"], // Supabase connection
    },
  },
  referrerPolicy: { policy: 'no-referrer' },
  hsts: {
    maxAge: 31536000, // 1 year
    includeSubDomains: true,
    preload: true
  }
}));

// CORS Configuration - only allow specific origins
const allowedOrigins = process.env.ALLOWED_ORIGINS ?
  process.env.ALLOWED_ORIGINS.split(',') :
  ['http://localhost:3000', 'http://127.0.0.1:3000', 'http://localhost:5500'];

app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);

    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  optionsSuccessStatus: 200 // Some legacy browsers choke on 204
}));

// Rate limiting for API endpoints
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

// Rate limiting for authentication endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // limit each IP to 5 login requests per windowMs
  message: {
    error: 'Too many login attempts from this IP, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Slow down middleware - gradually increase response time when request rate increases
const speedLimiter = slowDown({
  windowMs: 15 * 60 * 1000, // 15 minutes
  delayAfter: 25, // allow 25 requests per 15 minutes, then...
  delayMs: 500 // begin adding 500ms of delay per request above 25
});

app.use(express.json({ limit: '10mb' }));
app.use(speedLimiter);

// Apply rate limiting to API routes
app.use('/api/', apiLimiter);

// Sanitize input function
const sanitizeInput = (input) => {
  if (typeof input === 'string') {
    // Sanitize using xss library and validator
    return xss(input).trim();
  } else if (typeof input === 'object' && input !== null) {
    const sanitized = {};
    for (const [key, value] of Object.entries(input)) {
      sanitized[key] = sanitizeInput(value); // Recursively sanitize
    }
    return sanitized;
  }
  return input;
};

// In production, admin users should come from a database
// For demo purposes only, using a hardcoded admin user
// IMPORTANT: Change these credentials before deploying to production!
let adminUsers = [];

// Initialize admin user with proper password handling
const initializeAdminUser = async () => {
  // Check if we have a pre-hashed password in the environment
  if (process.env.ADMIN_PASSWORD_HASH) {
    adminUsers = [
      {
        id: 1,
        username: process.env.ADMIN_USERNAME || 'admin',
        password: process.env.ADMIN_PASSWORD_HASH
      }
    ];
  } else {
    // If no pre-hashed password, hash the plain text password from env
    const plainPassword = process.env.ADMIN_PASSWORD || 'admin123';
    const hashedPassword = bcrypt.hashSync(plainPassword, 10);
    adminUsers = [
      {
        id: 1,
        username: process.env.ADMIN_USERNAME || 'admin',
        password: hashedPassword
      }
    ];
  }
};

// Initialize admin user
initializeAdminUser();

// Verify token middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret_for_dev', (err, user) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(403).json({ error: 'Token expired' });
      } else if (err.name === 'JsonWebTokenError') {
        return res.status(403).json({ error: 'Invalid token' });
      }
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Validate and sanitize query parameters
const validateAndSanitizeQuery = (req, res, next) => {
  const { type, user, question, search } = req.query;
  
  // Sanitize all query parameters
  if (type) req.query.type = sanitizeInput(type);
  if (user) req.query.user = sanitizeInput(user);
  if (question) req.query.question = sanitizeInput(question);
  if (search) req.query.search = sanitizeInput(search);
  
  // Validate query parameters
  if (type && !validator.isAscii(type) && type.length > 50) {
    return res.status(400).json({ error: 'Invalid type parameter' });
  }
  
  if (user && (!validator.isAscii(user) || user.length > 100)) {
    return res.status(400).json({ error: 'Invalid user parameter' });
  }
  
  if (question && (!validator.isAscii(question) || question.length > 50)) {
    return res.status(400).json({ error: 'Invalid question parameter' });
  }
  
  if (search && (!validator.isAscii(search) || search.length > 100)) {
    return res.status(400).json({ error: 'Invalid search parameter' });
  }
  
  next();
};

// Validate and sanitize request body
const validateAndSanitizeBody = (req, res, next) => {
  if (req.body) {
    req.body = sanitizeInput(req.body);
    
    // Additional validation for specific endpoints can be added here
    next();
  } else {
    next();
  }
};

// Validate ID parameter
const validateIdParam = (req, res, next) => {
  const id = req.params.id;
  
  if (!id || !validator.isInt(id, { min: 1, max: 999999 })) {
    return res.status(400).json({ error: 'Invalid ID parameter' });
  }
  
  next();
};

// Login endpoint with rate limiting
app.post('/api/login', authLimiter, async (req, res) => {
  try {
    let { username, password } = req.body;

    // Validate and sanitize inputs
    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    // Sanitize inputs
    username = sanitizeInput(username);
    password = sanitizeInput(password);

    // Validate username format (alphanumeric and some special chars)
    if (!validator.isAlphanumeric(username.replace(/[_\-@.]/g, '')) || username.length > 50) {
      return res.status(400).json({ error: 'Invalid username format' });
    }

    // Validate password length
    if (password.length < 6 || password.length > 128) {
      return res.status(400).json({ error: 'Password must be between 6 and 128 characters' });
    }

    // Find user
    const user = adminUsers.find(u => u.username === username);
    if (!user) {
      // To prevent user enumeration, we still do a hash comparison
      await bcrypt.hash('dummy', 10); // Perform dummy hash to maintain timing consistency
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Verify password using bcrypt (compare plain text with hashed password)
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Create JWT token
    const token = jwt.sign(
      { 
        id: user.id, 
        username: user.username,
        iat: Math.floor(Date.now() / 1000), // issued at time
        exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60) // expires in 24 hours
      },
      process.env.JWT_SECRET || 'fallback_secret_for_dev'
    );

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Protected API routes
app.use('/api/', authenticateToken);

// Get tracking data
app.get('/api/tracking', validateAndSanitizeQuery, async (req, res) => {
  try {
    // Build query with filters
    let query = supabase.from('tracking_events').select('*').order('timestamp', { ascending: false });
    
    const { type, user, question, search } = req.query;
    
    // Apply filters
    if (type) query = query.eq('event_type', type);
    if (user) query = query.ilike('user_id', `%${user}%`);
    if (question) query = query.eq('question_id', question);
    if (search) query = query.or(`event_name.ilike.%${search}%,user_id.ilike.%${search}%`);
    
    const { data, error } = await query;
    
    if (error) {
      console.error('Error fetching tracking data:', error);
      return res.status(500).json({ error: 'Failed to fetch tracking data' });
    }
    
    res.json(data);
  } catch (error) {
    console.error('Error fetching tracking data:', error);
    res.status(500).json({ error: 'Failed to fetch tracking data' });
  }
});

// Get error reports
app.get('/api/errors', validateAndSanitizeQuery, async (req, res) => {
  try {
    // Build query with filters
    let query = supabase.from('error_reports').select('*').order('timestamp', { ascending: false });
    
    const { type, user, question, search } = req.query;
    
    // Apply filters
    if (type) query = query.eq('error_type', type);
    if (user) query = query.ilike('user_id', `%${user}%`);
    if (question) query = query.eq('question_id', question);
    if (search) query = query.or(`error_message.ilike.%${search}%,user_message.ilike.%${search}%`);
    
    const { data, error } = await query;
    
    if (error) {
      console.error('Error fetching error reports:', error);
      return res.status(500).json({ error: 'Failed to fetch error reports' });
    }
    
    res.json(data);
  } catch (error) {
    console.error('Error fetching error reports:', error);
    res.status(500).json({ error: 'Failed to fetch error reports' });
  }
});

// Get specific error report by ID
app.get('/api/errors/:id', validateIdParam, async (req, res) => {
  try {
    const errorId = req.params.id;
    
    const { data, error } = await supabase
      .from('error_reports')
      .select('*')
      .eq('id', errorId)
      .single();
    
    if (error) {
      console.error('Error fetching error report:', error);
      return res.status(500).json({ error: 'Failed to fetch error report' });
    }
    
    res.json(data);
  } catch (error) {
    console.error('Error fetching error report:', error);
    res.status(500).json({ error: 'Failed to fetch error report' });
  }
});

// Delete error report
app.delete('/api/errors/:id', validateIdParam, async (req, res) => {
  try {
    const errorId = req.params.id;
    
    const { data, error } = await supabase
      .from('error_reports')
      .delete()
      .eq('id', errorId);
    
    if (error) {
      console.error('Error deleting error report:', error);
      return res.status(500).json({ error: 'Failed to delete error report' });
    }
    
    res.json({ message: `Error report ${errorId} deleted successfully` });
  } catch (error) {
    console.error('Error deleting error report:', error);
    res.status(500).json({ error: 'Failed to delete error report' });
  }
});

// Get store items
app.get('/api/store', validateAndSanitizeQuery, async (req, res) => {
  try {
    // Build query with filters
    let query = supabase.from('store_items').select('*').order('item_name');
    
    const { type, search } = req.query;
    
    // Apply filters
    if (type) query = query.eq('item_type', type);
    if (search) query = query.ilike('item_name', `%${search}%`);
    
    const { data, error } = await query;
    
    if (error) {
      console.error('Error fetching store items:', error);
      return res.status(500).json({ error: 'Failed to fetch store items' });
    }
    
    res.json(data);
  } catch (error) {
    console.error('Error fetching store items:', error);
    res.status(500).json({ error: 'Failed to fetch store items' });
  }
});

// Get specific store item by ID
app.get('/api/store/:id', validateIdParam, async (req, res) => {
  try {
    const itemId = req.params.id;
    
    const { data, error } = await supabase
      .from('store_items')
      .select('*')
      .eq('id', itemId)
      .single();
    
    if (error) {
      console.error('Error fetching store item:', error);
      return res.status(500).json({ error: 'Failed to fetch store item' });
    }
    
    res.json(data);
  } catch (error) {
    console.error('Error fetching store item:', error);
    res.status(500).json({ error: 'Failed to fetch store item' });
  }
});

// Update store item
app.put('/api/store/:id', validateIdParam, validateAndSanitizeBody, async (req, res) => {
  try {
    const itemId = req.params.id;
    const updateData = req.body;
    
    // Validate updateData fields
    if (updateData.item_name && (updateData.item_name.length < 1 || updateData.item_name.length > 100)) {
      return res.status(400).json({ error: 'Item name must be between 1 and 100 characters' });
    }
    
    if (updateData.item_description && updateData.item_description.length > 500) {
      return res.status(400).json({ error: 'Item description must be less than 500 characters' });
    }
    
    if (updateData.base_price && (!Number.isInteger(updateData.base_price) || updateData.base_price < 0)) {
      return res.status(400).json({ error: 'Base price must be a non-negative integer' });
    }
    
    const { data, error } = await supabase
      .from('store_items')
      .update(updateData)
      .eq('id', itemId);
    
    if (error) {
      console.error('Error updating store item:', error);
      return res.status(500).json({ error: 'Failed to update store item' });
    }
    
    res.json({ message: `Store item ${itemId} updated successfully` });
  } catch (error) {
    console.error('Error updating store item:', error);
    res.status(500).json({ error: 'Failed to update store item' });
  }
});

// Delete store item
app.delete('/api/store/:id', validateIdParam, async (req, res) => {
  try {
    const itemId = req.params.id;
    
    const { data, error } = await supabase
      .from('store_items')
      .delete()
      .eq('id', itemId);
    
    if (error) {
      console.error('Error deleting store item:', error);
      return res.status(500).json({ error: 'Failed to delete store item' });
    }
    
    res.json({ message: `Store item ${itemId} deleted successfully` });
  } catch (error) {
    console.error('Error deleting store item:', error);
    res.status(500).json({ error: 'Failed to delete store item' });
  }
});

// Create new store item
app.post('/api/store', validateAndSanitizeBody, async (req, res) => {
  try {
    const newItem = req.body;
    
    // Validate required fields
    if (!newItem.item_key || newItem.item_key.length > 50) {
      return res.status(400).json({ error: 'Item key is required and must be less than 50 characters' });
    }
    
    if (!newItem.item_name || newItem.item_name.length < 1 || newItem.item_name.length > 100) {
      return res.status(400).json({ error: 'Item name is required and must be between 1 and 100 characters' });
    }
    
    if (newItem.item_description && newItem.item_description.length > 500) {
      return res.status(400).json({ error: 'Item description must be less than 500 characters' });
    }
    
    if (!newItem.item_type || !['powerup', 'theme', 'feature'].includes(newItem.item_type)) {
      return res.status(400).json({ error: 'Item type must be one of: powerup, theme, feature' });
    }
    
    if (typeof newItem.base_price !== 'number' || newItem.base_price < 0) {
      return res.status(400).json({ error: 'Base price must be a non-negative number' });
    }
    
    const { data, error } = await supabase
      .from('store_items')
      .insert([newItem])
      .select();
    
    if (error) {
      console.error('Error creating store item:', error);
      return res.status(500).json({ error: 'Failed to create store item' });
    }
    
    res.json({ message: 'Store item created successfully', id: data[0].id });
  } catch (error) {
    console.error('Error creating store item:', error);
    res.status(500).json({ error: 'Failed to create store item' });
  }
});

// Get messages
app.get('/api/messages', validateAndSanitizeQuery, async (req, res) => {
  try {
    // Build query with search filter
    let query = supabase.from('messages').select('*').order('created_at', { ascending: false });
    
    const { search } = req.query;
    
    // Apply search filter
    if (search) query = query.or(`title.ilike.%${search}%,content.ilike.%${search}%`);
    
    const { data, error } = await query;
    
    if (error) {
      console.error('Error fetching messages:', error);
      return res.status(500).json({ error: 'Failed to fetch messages' });
    }
    
    res.json(data);
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

// Update message
app.put('/api/messages/:id', validateIdParam, validateAndSanitizeBody, async (req, res) => {
  try {
    const messageId = req.params.id;
    const updateData = req.body;
    
    // Validate updateData fields
    if (updateData.title && (updateData.title.length < 1 || updateData.title.length > 200)) {
      return res.status(400).json({ error: 'Title must be between 1 and 200 characters' });
    }
    
    if (updateData.content && (updateData.content.length < 1 || updateData.content.length > 2000)) {
      return res.status(400).json({ error: 'Content must be between 1 and 2000 characters' });
    }
    
    if (updateData.expiration_date && !validator.isISO8601(updateData.expiration_date)) {
      return res.status(400).json({ error: 'Expiration date must be in ISO8601 format' });
    }
    
    const { data, error } = await supabase
      .from('messages')
      .update(updateData)
      .eq('id', messageId);
    
    if (error) {
      console.error('Error updating message:', error);
      return res.status(500).json({ error: 'Failed to update message' });
    }
    
    res.json({ message: `Message ${messageId} updated successfully` });
  } catch (error) {
    console.error('Error updating message:', error);
    res.status(500).json({ error: 'Failed to update message' });
  }
});

// Delete message
app.delete('/api/messages/:id', validateIdParam, async (req, res) => {
  try {
    const messageId = req.params.id;
    
    const { data, error } = await supabase
      .from('messages')
      .delete()
      .eq('id', messageId);
    
    if (error) {
      console.error('Error deleting message:', error);
      return res.status(500).json({ error: 'Failed to delete message' });
    }
    
    res.json({ message: `Message ${messageId} deleted successfully` });
  } catch (error) {
    console.error('Error deleting message:', error);
    res.status(500).json({ error: 'Failed to delete message' });
  }
});

// Create new message
app.post('/api/messages', validateAndSanitizeBody, async (req, res) => {
  try {
    const newMessage = req.body;
    
    // Validate required fields
    if (!newMessage.title || newMessage.title.length < 1 || newMessage.title.length > 200) {
      return res.status(400).json({ error: 'Title is required and must be between 1 and 200 characters' });
    }
    
    if (!newMessage.content || newMessage.content.length < 1 || newMessage.content.length > 2000) {
      return res.status(400).json({ error: 'Content is required and must be between 1 and 2000 characters' });
    }
    
    if (!newMessage.expiration_date || !validator.isISO8601(newMessage.expiration_date)) {
      return res.status(400).json({ error: 'Expiration date is required and must be in ISO8601 format' });
    }
    
    const { data, error } = await supabase
      .from('messages')
      .insert([newMessage])
      .select();
    
    if (error) {
      console.error('Error creating message:', error);
      return res.status(500).json({ error: 'Failed to create message' });
    }
    
    res.json({ message: 'Message created successfully', id: data[0].id });
  } catch (error) {
    console.error('Error creating message:', error);
    res.status(500).json({ error: 'Failed to create message' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// If this file is run directly (not imported), start the server
if (require.main === module) {
  const host = process.env.NODE_ENV === 'production' ? 'localhost' : '0.0.0.0';
  app.listen(PORT, host, () => {
    console.log(`Admin Dashboard Server running on ${host}:${PORT} (${process.env.NODE_ENV || 'development'} mode)`);
  });
}

module.exports = app; // Export for Vercel or testing