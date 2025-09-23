const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');
const { mcpServer } = require('./mcp-server');
const { StreamableHTTPServerTransport } = require('@modelcontextprotocol/sdk/server/streamableHttp.js');
const { isInitializeRequest } = require('@modelcontextprotocol/sdk/types.js');

// In-memory storage for the emergency message
let emergencyMessage = null;

// How long the message should be valid (24 hours)
const MESSAGE_TTL = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

// Version information - in a real app, this might come from a database
const versions = {
  android: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes",
    downloadEndpoint: "/api/download?platform=android",
    platform: "android"
  },
  ios: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes",
    downloadEndpoint: "/api/download?platform=ios",
    platform: "ios"
  },
  windows: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes",
    downloadEndpoint: "/api/download?platform=windows",
    platform: "windows"
  },
  macos: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes",
    downloadEndpoint: "/api/download?platform=macos",
    platform: "macos"
  },
  linux: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes",
    downloadEndpoint: "/api/download?platform=linux",
    platform: "linux"
  },
  web: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes",
    downloadEndpoint: "/api/download?platform=web",
    platform: "web"
  }
};

// Test versions - used for local development testing
const testVersions = {
  android: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes\n• Nieuwe functies",
    downloadEndpoint: "/api/download?platform=android",
    platform: "android"
  },
  ios: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes\n• Nieuwe functies",
    downloadEndpoint: "/api/download?platform=ios",
    platform: "ios"
  },
  windows: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes\n• Nieuwe functies",
    downloadEndpoint: "/api/download?platform=windows",
    platform: "windows"
  },
  macos: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes\n• Nieuwe functies",
    downloadEndpoint: "/api/download?platform=macos",
    platform: "macos"
  },
  linux: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes\n• Nieuwe functies",
    downloadEndpoint: "/api/download?platform=linux",
    platform: "linux"
  },
  web: {
    version: "1.1.0",
    releaseNotes: "• Nieuwe vragen toegevoegd\n• Prestatieverbeteringen\n• Bug fixes\n• Nieuwe functies",
    downloadEndpoint: "/api/download?platform=web",
    platform: "web"
  }
};

// Map to store transports by session ID
const transports = new Map();

// Create HTTP server
const server = http.createServer(async (req, res) => {
  // Parse request body for POST requests
  if (req.method === 'POST') {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    await new Promise(resolve => {
      req.on('end', () => {
        try {
          req.body = JSON.parse(body);
        } catch (e) {
          req.body = {};
        }
        resolve();
      });
    });
  }

  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  const method = req.method;
  
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, Mcp-Session-Id');
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  
  // Handle OPTIONS method for CORS preflight
  if (method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Handle MCP protocol requests
  if (pathname === '/mcp') {
    // Check for existing session ID
    const sessionId = req.headers['mcp-session-id'];
    let transport;

    if (sessionId && transports.has(sessionId)) {
      // Reuse existing transport
      transport = transports.get(sessionId);
    } else if (!sessionId && isInitializeRequest(req.body)) {
      // New initialization request
      console.log('Creating new transport for initialization request');
      transport = new StreamableHTTPServerTransport({
        onsessioninitialized: (newSessionId) => {
          console.log('Session initialized with ID:', newSessionId);
          transports.set(newSessionId, transport);
          // Set the session ID in the response headers
          res.setHeader('Mcp-Session-Id', newSessionId);
        },
        enableDnsRebindingProtection: false, // Disabled for local development
      });

      // Clean up transport when closed
      transport.onclose = () => {
        if (transport.sessionId) {
          transports.delete(transport.sessionId);
        }
      };

      // Connect to the MCP server
      await mcpServer.connect(transport);
    } else {
      // Invalid request
      res.writeHead(400);
      res.end(JSON.stringify({
        jsonrpc: '2.0',
        error: {
          code: -32000,
          message: 'Bad Request: No valid session ID provided',
        },
        id: null,
      }));
      return;
    }

    // Handle the request
    try {
      await transport.handleRequest(req, res, req.body);
    } catch (error) {
      console.error('Error handling MCP request:', error);
      if (!res.headersSent) {
        res.writeHead(500);
        res.end(JSON.stringify({
          jsonrpc: '2.0',
          error: {
            code: -32603,
            message: 'Internal server error',
          },
          id: null,
        }));
      }
    }
    return;
  }

  // Handle /api/questions
  if (method === 'GET' && pathname === '/api/questions') {
    try {
      // Get the questions file path
      const questionsPath = path.join(__dirname, 'api', 'questions-nl-sv.json');
      
      // Check if file exists
      if (!fs.existsSync(questionsPath)) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Questions file not found' }));
        return;
      }
      
      // Read the questions file
      const questionsData = fs.readFileSync(questionsPath, 'utf8');
      
      // Return the JSON
      res.writeHead(200);
      res.end(questionsData);
    } catch (error) {
      console.error('Error serving questions:', error);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Internal server error' }));
    }
    return;
  }

  // Handle /api/version
  if (method === 'GET' && pathname === '/api/version') {
    try {
      const platform = parsedUrl.query.platform || 'android';
      // Check if we're in test mode (for local development)
      const testMode = parsedUrl.query.test === 'true' || req.headers.host?.includes('localhost');
      
      // Validate platform
      if (!versions.hasOwnProperty(platform)) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid platform' }));
        return;
      }
      
      // Get version info for the requested platform
      const baseVersionData = testMode ? testVersions[platform] : versions[platform];
      
      // Include platform and current version in response
      const currentVersion = parsedUrl.query.currentVersion || null;
      const versionData = {
        ...baseVersionData,
        platform: platform,
        currentVersion: currentVersion
      };
      
      res.writeHead(200);
      res.end(JSON.stringify(versionData));
    } catch (error) {
      console.error('Error handling GET request:', error);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Internal server error' }));
    }
    return;
  }

  // Handle /api/download
  if (method === 'GET' && pathname === '/api/download') {
    // Get query parameters for platform and version
    const { platform, currentVersion } = parsedUrl.query;

    // Build the download page URL with parameters
    const baseUrl = 'https://bijbelquiz.app/download.html';
    const params = new URLSearchParams();

    if (platform) params.append('platform', platform);
    if (currentVersion) params.append('current', currentVersion);

    const redirectUrl = params.toString() ? `${baseUrl}?${params.toString()}` : baseUrl;

    // Redirect to the unified download page
    res.setHeader('X-Deprecated', 'true');
    res.writeHead(302, { 'Location': redirectUrl });
    res.end();
    return;
  }

  // Handle /api/emergency GET requests
  if (method === 'GET' && pathname === '/api/emergency') {
    try {
      // If there's no message, return 204 No Content
      if (!emergencyMessage) {
        res.writeHead(204);
        res.end();
        return;
      }

      // If the message has expired, clear it and return 204
      const now = Date.now();
      if (now - emergencyMessage.timestamp > MESSAGE_TTL) {
        emergencyMessage = null;
        res.writeHead(204);
        res.end();
        return;
      }

      // Otherwise, return the message
      res.writeHead(200);
      res.end(JSON.stringify({
        message: emergencyMessage.message,
        isBlocking: emergencyMessage.isBlocking,
        expiresAt: emergencyMessage.timestamp + MESSAGE_TTL
      }));
    } catch (error) {
      console.error('Error handling GET request:', error);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Internal server error' }));
    }
    return;
  }

  // Handle /api/emergency POST requests
  if (method === 'POST' && pathname === '/api/emergency') {
    try {
      // Simple authentication - in production, use a proper auth system
      const authHeader = req.headers.authorization;
      const adminToken = process.env.ADMIN_TOKEN || '';
      
      if (!authHeader || authHeader !== `Bearer ${adminToken}`) {
        res.writeHead(401, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Unauthorized' }));
        return;
      }

      // Collect request body
      let body = '';
      req.on('data', chunk => {
        body += chunk.toString();
      });
      
      req.on('end', () => {
        try {
          const parsedBody = JSON.parse(body);
          const { message, isBlocking = false } = parsedBody;

          // Validate the request
          if (!message || typeof message !== 'string') {
            res.writeHead(400, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ 
              error: 'Message is required and must be a string' 
            }));
            return;
          }

          // Set the emergency message
          const timestamp = Date.now();
          emergencyMessage = {
            message: String(message),
            isBlocking: Boolean(isBlocking),
            timestamp
          };

          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ 
            success: true, 
            expiresAt: timestamp + MESSAGE_TTL 
          }));
        } catch (error) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Invalid JSON body' }));
        }
      });
    } catch (error) {
      console.error('Error handling POST request:', error);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Internal server error' }));
    }
    return;
  }

  // Handle /api/emergency DELETE requests
  if (method === 'DELETE' && pathname === '/api/emergency') {
    try {
      // Simple authentication
      const authHeader = req.headers.authorization;
      const adminToken = process.env.ADMIN_TOKEN || '';
      
      if (!authHeader || authHeader !== `Bearer ${adminToken}`) {
        res.writeHead(401, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Unauthorized' }));
        return;
      }

      emergencyMessage = null;
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true }));
    } catch (error) {
      console.error('Error handling DELETE request:', error);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Internal server error' }));
    }
    return;
  }

  // Serve static files for question-editor
  if (pathname.startsWith('/question-editor/')) {
    // Normalize the path to prevent directory traversal
    let normalizedPath = pathname;
    if (normalizedPath === '/question-editor/' || normalizedPath === '/question-editor') {
      normalizedPath = '/question-editor/index.html';
    }
    
    // Remove leading slash and join with __dirname
    const filePath = path.join(__dirname, normalizedPath);
    
    // Ensure the resolved path is within the question-editor directory
    const questionEditorDir = path.join(__dirname, 'question-editor');
    if (!filePath.startsWith(questionEditorDir)) {
      res.writeHead(403);
      res.end('Forbidden');
      return;
    }
    
    const extname = path.extname(filePath);
    let contentType = 'text/html';
    
    switch (extname) {
      case '.js':
        contentType = 'text/javascript';
        break;
      case '.css':
        contentType = 'text/css';
        break;
      case '.json':
        contentType = 'application/json';
        break;
      case '.png':
        contentType = 'image/png';
        break;
      case '.jpg':
        contentType = 'image/jpg';
        break;
    }
    
    fs.readFile(filePath, (error, content) => {
      if (error) {
        if (error.code === 'ENOENT') {
          res.writeHead(404);
          res.end('File not found');
        } else {
          console.error('Server Error:', error);
          res.writeHead(500);
          res.end('Server Error');
        }
      } else {
        res.writeHead(200, { 'Content-Type': contentType });
        res.end(content, 'utf-8');
      }
    });
    return;
  }

  // Serve index.html for root path
  if (pathname === '/') {
    const indexPath = path.join(__dirname, 'index.html');
    fs.readFile(indexPath, (error, content) => {
      if (error) {
        res.writeHead(500);
        res.end('Server Error');
      } else {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(content, 'utf-8');
      }
    });
    return;
  }

  // Return 404 for other routes
  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not found' }));
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});