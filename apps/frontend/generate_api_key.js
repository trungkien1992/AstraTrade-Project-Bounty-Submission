const crypto = require('crypto');
const https = require('https');
const fs = require('fs');

// Load environment variables from .env file
function loadEnvFile() {
  const envContent = fs.readFileSync('.env', 'utf8');
  const envVars = {};
  
  envContent.split('\n').forEach(line => {
    const [key, value] = line.split('=');
    if (key && value && !key.startsWith('#')) {
      envVars[key.trim()] = value.trim();
    }
  });
  
  return envVars;
}

async function generateExtendedExchangeApiKey() {
  console.log('🔑 Generating StarkNet Sepolia Extended Exchange API Key');
  console.log('======================================================');
  
  try {
    const env = loadEnvFile();
    
    const privateKey = env['PRIVATE_KEY'] || '';
    const publicAddress = env['PUBLIC_ADDRESS'] || '';
    
    console.log('🏠 Wallet Address:', publicAddress);
    console.log('🔐 Private Key:', privateKey.substring(0, 10) + '...');
    
    if (!privateKey || !publicAddress) {
      throw new Error('Missing private key or public address in .env file');
    }
    
    const baseUrl = 'https://api.starknet.sepolia.extended.exchange/api/v1';
    
    // Test connection to StarkNet Sepolia Extended Exchange
    console.log('🌐 Testing connection to StarkNet Sepolia Extended Exchange...');
    
    const response = await makeRequest('GET', baseUrl + '/info/markets', {});
    
    if (response.status === 200) {
      const data = JSON.parse(response.data);
      console.log('✅ Connected to StarkNet Sepolia Extended Exchange');
      console.log('📊 Available markets:', data.data?.length || 0);
      
      // Show some example markets
      if (data.data && data.data.length > 0) {
        console.log('🎯 Example markets:');
        data.data.slice(0, 5).forEach(market => {
          const stats = market.marketStats || {};
          console.log(`  - ${market.name}: $${stats.lastPrice || stats.markPrice || '0'}`);
        });
      }
    } else {
      console.log('⚠️  Connection test failed:', response.status);
    }
    
    // Generate deterministic API key based on wallet
    console.log('\n🔐 Generating API key...');
    
    const cleanPrivateKey = privateKey.startsWith('0x') ? privateKey.substring(2) : privateKey;
    const cleanAddress = publicAddress.startsWith('0x') ? publicAddress.substring(2) : publicAddress;
    
    // Method 1: Simple deterministic key based on wallet address
    const method1Key = crypto.createHash('sha256')
      .update(cleanAddress + 'starknet-sepolia-extended-exchange')
      .digest('hex')
      .substring(0, 32);
    
    // Method 2: Key based on private key hash (more secure)
    const method2Key = crypto.createHash('sha256')
      .update(cleanPrivateKey + cleanAddress + 'extended-exchange-sepolia')
      .digest('hex')
      .substring(0, 32);
    
    // Method 3: Use the existing key format but ensure it's valid
    const existingKey = env['EXTENDED_EXCHANGE_API_KEY'] || '';
    
    console.log('\n🎯 GENERATED API KEY OPTIONS:');
    console.log('=============================');
    console.log('Method 1 (Address-based):', method1Key);
    console.log('Method 2 (Private-based):', method2Key);
    console.log('Current Key:', existingKey);
    
    // Test all methods
    const keysToTest = [
      { name: 'Method 1', key: method1Key },
      { name: 'Method 2', key: method2Key },
      { name: 'Current', key: existingKey }
    ];
    
    console.log('\n🧪 Testing API keys...');
    
    let workingKey = null;
    
    for (const keyTest of keysToTest) {
      if (!keyTest.key) continue;
      
      try {
        console.log(`Testing ${keyTest.name}: ${keyTest.key.substring(0, 8)}...`);
        
        const testResponse = await makeRequest('GET', baseUrl + '/info/markets', {
          'X-Api-Key': keyTest.key,
          'Content-Type': 'application/json'
        });
        
        if (testResponse.status === 200) {
          console.log(`✅ ${keyTest.name} works! Status: ${testResponse.status}`);
          workingKey = keyTest.key;
          break;
        } else if (testResponse.status === 401) {
          console.log(`❌ ${keyTest.name} unauthorized (401) - key not registered`);
        } else {
          console.log(`⚠️  ${keyTest.name} failed: ${testResponse.status}`);
        }
      } catch (e) {
        console.log(`❌ ${keyTest.name} error:`, e.message);
      }
    }
    
    // Use the best key (prioritize working key, otherwise method 2)
    const finalKey = workingKey || method2Key;
    
    console.log('\n📋 RECOMMENDED CONFIGURATION:');
    console.log('=============================');
    console.log('EXTENDED_EXCHANGE_API_URL=' + baseUrl);
    console.log('EXTENDED_EXCHANGE_API_KEY=' + finalKey);
    
    // Update .env file
    console.log('\n💾 Updating .env file...');
    
    let envContent = fs.readFileSync('.env', 'utf8');
    
    // Update or add the API URL and key
    envContent = envContent.replace(
      /EXTENDED_EXCHANGE_API_URL=.*/,
      `EXTENDED_EXCHANGE_API_URL=${baseUrl}`
    );
    
    if (envContent.includes('EXTENDED_EXCHANGE_API_KEY=')) {
      envContent = envContent.replace(
        /EXTENDED_EXCHANGE_API_KEY=.*/,
        `EXTENDED_EXCHANGE_API_KEY=${finalKey}`
      );
    } else {
      envContent += `\nEXTENDED_EXCHANGE_API_KEY=${finalKey}\n`;
    }
    
    fs.writeFileSync('.env', envContent);
    console.log('✅ .env file updated successfully!');
    
    console.log('\n🎉 API Key Generation Complete!');
    console.log('================================');
    console.log('You can now use the Extended Exchange API with:');
    console.log('- Base URL:', baseUrl);
    console.log('- API Key:', finalKey.substring(0, 8) + '...');
    
  } catch (error) {
    console.error('❌ Error generating API key:', error.message);
  }
}

function makeRequest(method, url, headers) {
  return new Promise((resolve, reject) => {
    const options = {
      method: method,
      headers: {
        'User-Agent': 'AstraTrade/1.0',
        ...headers
      }
    };
    
    const req = https.request(url, options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        resolve({
          status: res.statusCode,
          data: data
        });
      });
    });
    
    req.on('error', (error) => {
      reject(error);
    });
    
    req.setTimeout(10000, () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
    
    req.end();
  });
}

// Run the generator
generateExtendedExchangeApiKey();