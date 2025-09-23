const http = require('http');

function makeRequest(options, data) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => {
        body += chunk;
      });
      res.on('end', () => {
        resolve({ statusCode: res.statusCode, headers: res.headers, body });
      });
    });
    
    req.on('error', (error) => {
      reject(error);
    });
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

async function testMcpServer() {
  try {
    // Initialize the session
    const initResponse = await makeRequest({
      hostname: 'localhost',
      port: 3001,
      path: '/mcp',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream'
      }
    }, {
      jsonrpc: '2.0',
      method: 'initialize',
      params: {
        protocolVersion: '2024-11-05',
        capabilities: {},
        clientInfo: {
          name: 'test-client',
          version: '1.0.0'
        }
      },
      id: 1
    });
    
    // Parse the SSE response to extract session ID
    const sessionId = initResponse.headers['mcp-session-id'];
    console.log('Session ID from headers:', sessionId);
    
    if (!sessionId) {
      console.log('Response body:', initResponse.body);
      return;
    }
    
    // Wait a moment for the transport to be fully initialized
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // List tools
    const toolsResponse = await makeRequest({
      hostname: 'localhost',
      port: 3001,
      path: '/mcp',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
        'Mcp-Session-Id': sessionId
      }
    }, {
      jsonrpc: '2.0',
      method: 'tools/list',
      params: {},
      id: 2
    });
    
    console.log('Tools response:', toolsResponse.body);
    
    // Test get_random_question tool
    const randomQuestionResponse = await makeRequest({
      hostname: 'localhost',
      port: 3001,
      path: '/mcp',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
        'Mcp-Session-Id': sessionId
      }
    }, {
      jsonrpc: '2.0',
      method: 'tools/call',
      params: {
        name: 'get_random_question',
        arguments: { type: 'mc', difficulty: 3 }
      },
      id: 3
    });
    
    console.log('Random question response:', randomQuestionResponse.body);
    
    // Test list_questions tool
    const listQuestionsResponse = await makeRequest({
      hostname: 'localhost',
      port: 3001,
      path: '/mcp',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
        'Mcp-Session-Id': sessionId
      }
    }, {
      jsonrpc: '2.0',
      method: 'tools/call',
      params: {
        name: 'list_questions',
        arguments: { limit: 3, type: 'tf' }
      },
      id: 4
    });
    
    console.log('List questions response:', listQuestionsResponse.body);
    
  } catch (error) {
    console.error('Error testing MCP server:', error);
  }
}

testMcpServer();