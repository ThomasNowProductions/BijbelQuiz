const http = require('http');
const { McpServer } = require('@modelcontextprotocol/sdk/server/mcp.js');
const { StreamableHTTPServerTransport } = require('@modelcontextprotocol/sdk/server/streamableHttp.js');

// Create a simple test to check if we can get the session ID properly
async function testTransport() {
  const transport = new StreamableHTTPServerTransport({
    sessionIdGenerator: () => 'test-session-id',
    onsessioninitialized: (sessionId) => {
      console.log('Session initialized:', sessionId);
    }
  });
  
  console.log('Transport created');
  console.log('Session ID:', transport.sessionId);
}

testTransport();