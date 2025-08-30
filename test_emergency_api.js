// Test script for emergency API
const fetch = require('node-fetch');

const API_URL = 'https://bijbelquiz.app/api/emergency';
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || 'your-admin-token-here';

async function testEmergencyApi() {
  try {
    // 1. Test GET with no message (should return 204)
    console.log('Testing GET with no message...');
    let response = await fetch(API_URL);
    console.log(`Status: ${response.status} (${response.statusText})`);
    
    if (response.status === 204) {
      console.log('✓ No emergency message (expected)');
    }
    
    // 2. Test setting an emergency message
    console.log('\nSetting emergency message...');
    response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ADMIN_TOKEN}`
      },
      body: JSON.stringify({
        message: 'This is a test emergency message. The app is currently in maintenance mode.',
        isBlocking: true
      })
    });
    
    console.log(`Status: ${response.status} (${response.statusText})`);
    const data = await response.json();
    console.log('Response:', data);
    
    if (response.ok) {
      console.log('✓ Emergency message set successfully');
      
      // 3. Test GET with the new message
      console.log('\nTesting GET with emergency message...');
      response = await fetch(API_URL);
      console.log(`Status: ${response.status} (${response.statusText})`);
      
      if (response.ok) {
        const messageData = await response.json();
        console.log('Emergency message:', messageData);
        console.log('✓ Successfully retrieved emergency message');
      }
      
      // 4. Test clearing the message (optional)
      console.log('\nClearing emergency message...');
      response = await fetch(API_URL, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${ADMIN_TOKEN}`
        }
      });
      
      console.log(`Status: ${response.status} (${response.statusText})`);
      if (response.ok) {
        console.log('✓ Emergency message cleared');
      }
    }
  } catch (error) {
    console.error('Error testing emergency API:', error);
  }
}

testEmergencyApi();
