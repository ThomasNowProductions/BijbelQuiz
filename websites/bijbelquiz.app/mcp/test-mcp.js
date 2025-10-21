const { spawn } = require('child_process');

// Test de BijbelQuiz-MCP server
async function testMCP() {
  console.log('🧪 Testing BijbelQuiz-MCP server...');

  // Start de MCP server
  const mcpProcess = spawn('node', ['dist/index.js'], {
    cwd: process.cwd(),
    stdio: ['pipe', 'pipe', 'pipe']
  });

  let output = '';
  let errorOutput = '';

  mcpProcess.stdout.on('data', (data) => {
    output += data.toString();
    console.log('📤 Server output:', data.toString().trim());
  });

  mcpProcess.stderr.on('data', (data) => {
    errorOutput += data.toString();
    console.log('⚠️ Server error:', data.toString().trim());
  });

  // Wacht tot server gestart is
  await new Promise(resolve => setTimeout(resolve, 2000));

  // Test initialize
  console.log('\n🔧 Testing initialize...');
  const initMessage = {
    jsonrpc: '2.0',
    id: 1,
    method: 'initialize',
    params: {
      protocolVersion: '2024-11-05',
      capabilities: { tools: {} },
      clientInfo: { name: 'test-client', version: '1.0.0' }
    }
  };

  mcpProcess.stdin.write(JSON.stringify(initMessage) + '\n');

  // Wacht op response
  await new Promise(resolve => setTimeout(resolve, 1000));

  // Test tools/list
  console.log('\n📋 Testing tools/list...');
  const toolsListMessage = {
    jsonrpc: '2.0',
    id: 2,
    method: 'tools/list',
    params: {}
  };

  mcpProcess.stdin.write(JSON.stringify(toolsListMessage) + '\n');

  // Wacht op response
  await new Promise(resolve => setTimeout(resolve, 1000));

  // Cleanup
  mcpProcess.kill();
  console.log('\n✅ Test voltooid!');
  console.log('📊 Output length:', output.length);
  console.log('⚠️ Error length:', errorOutput.length);

  if (output.includes('bijbelquiz-mcp')) {
    console.log('🎉 Server identificeert zichzelf correct!');
  }

  if (output.includes('speel-bijbelquiz')) {
    console.log('🎯 Tool is correct geregistreerd!');
  }
}

// Run test
testMCP().catch(console.error);