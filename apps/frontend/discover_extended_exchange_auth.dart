import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Discover Extended Exchange authentication requirements
void main() async {
  print('🔍 DISCOVERING EXTENDED EXCHANGE AUTHENTICATION');
  print('==============================================');
  
  try {
    final config = await loadEnvConfig();
    final apiKey = config['EXTENDED_EXCHANGE_API_KEY']!;
    final publicAddress = config['PUBLIC_ADDRESS']!;
    
    // Test 1: Check if there's a registration/onboarding process
    print('\n📝 TESTING REGISTRATION/ONBOARDING...');
    await testRegistration(apiKey, publicAddress);
    
    // Test 2: Check documentation endpoints
    print('\n📚 CHECKING DOCUMENTATION ENDPOINTS...');
    await checkDocumentation();
    
    // Test 3: Test different authentication headers
    print('\n🔐 TESTING AUTHENTICATION METHODS...');
    await testAuthMethods(apiKey, publicAddress);
    
    // Test 4: Check if we need to create account first
    print('\n👤 TESTING ACCOUNT CREATION...');
    await testAccountCreation(apiKey, publicAddress);
    
    // Test 5: Check error responses for clues
    print('\n❌ ANALYZING ERROR RESPONSES...');
    await analyzeErrors(apiKey);
    
  } catch (e, stackTrace) {
    print('❌ Discovery failed: $e');
    print('Stack trace: $stackTrace');
  }
}

Future<Map<String, String>> loadEnvConfig() async {
  final envFile = File('.env');
  final envContent = await envFile.readAsString();
  
  final config = <String, String>{};
  for (final line in envContent.split('\n')) {
    if (line.contains('=') && !line.trim().startsWith('#')) {
      final parts = line.split('=');
      if (parts.length >= 2) {
        config[parts[0].trim()] = parts.sublist(1).join('=').trim();
      }
    }
  }
  return config;
}

Future<void> testRegistration(String apiKey, String publicAddress) async {
  final registrationEndpoints = [
    '/auth/register',
    '/user/register', 
    '/register',
    '/onboard',
    '/auth/connect',
    '/connect-wallet',
  ];
  
  for (final endpoint in registrationEndpoints) {
    try {
      // Test GET first
      var response = await http.get(
        Uri.parse('http://localhost:3001$endpoint'),
        headers: {'X-Api-Key': apiKey},
      );
      print('GET $endpoint: ${response.statusCode}');
      
      if (response.statusCode != 404 && response.statusCode != 405) {
        print('  Response: ${response.body}');
      }
      
      // Test POST
      response = await http.post(
        Uri.parse('http://localhost:3001$endpoint'),
        headers: {
          'X-Api-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'address': publicAddress,
          'network': 'starknet-sepolia',
        }),
      );
      print('POST $endpoint: ${response.statusCode}');
      
      if (response.statusCode != 404 && response.statusCode != 405) {
        print('  Response: ${response.body}');
      }
      
    } catch (e) {
      print('$endpoint: Error - $e');
    }
  }
}

Future<void> checkDocumentation() async {
  final docEndpoints = [
    '/docs',
    '/api-docs', 
    '/swagger',
    '/openapi',
    '/info',
    '/help',
    '/auth/help',
  ];
  
  for (final endpoint in docEndpoints) {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3001$endpoint'),
        headers: {'Accept': 'application/json, text/html'},
      );
      
      print('$endpoint: ${response.statusCode}');
      if (response.statusCode == 200) {
        final body = response.body;
        if (body.length > 100) {
          print('  Found documentation! Length: ${body.length}');
          print('  Preview: ${body.substring(0, 200)}...');
        } else {
          print('  Response: $body');
        }
      }
    } catch (e) {
      print('$endpoint: Error - $e');
    }
  }
}

Future<void> testAuthMethods(String apiKey, String publicAddress) async {
  final authMethods = [
    {'X-Api-Key': apiKey},
    {'Authorization': 'Bearer $apiKey'},
    {'Authorization': 'ApiKey $apiKey'},
    {'X-Api-Key': apiKey, 'X-Address': publicAddress},
    {'X-Api-Key': apiKey, 'X-Wallet-Address': publicAddress},
    {'API-Key': apiKey},
    {'api-key': apiKey},
  ];
  
  for (int i = 0; i < authMethods.length; i++) {
    try {
      final headers = Map<String, String>.from(authMethods[i]);
      headers['Content-Type'] = 'application/json';
      
      final response = await http.get(
        Uri.parse('http://localhost:3001/info/markets'),
        headers: headers,
      );
      
      print('Auth method ${i + 1}: ${response.statusCode} (${headers.keys.join(', ')})');
      
      // If this works differently, note it
      if (response.statusCode != 200) {
        print('  Different response: ${response.statusCode}');
      }
      
    } catch (e) {
      print('Auth method ${i + 1}: Error - $e');
    }
  }
}

Future<void> testAccountCreation(String apiKey, String publicAddress) async {
  try {
    // Try to create/initialize account
    final accountData = {
      'address': publicAddress,
      'publicKey': publicAddress,
      'network': 'starknet-sepolia',
      'chain': 'starknet',
      'apiKey': apiKey,
    };
    
    final response = await http.post(
      Uri.parse('http://localhost:3001/user/account'),
      headers: {
        'X-Api-Key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode(accountData),
    );
    
    print('Account creation: ${response.statusCode}');
    print('Response: ${response.body}');
    
    if (response.statusCode == 404) {
      // Try PUT method
      final putResponse = await http.put(
        Uri.parse('http://localhost:3001/user/account'),
        headers: {
          'X-Api-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(accountData),
      );
      
      print('Account PUT: ${putResponse.statusCode}');
      print('PUT Response: ${putResponse.body}');
    }
    
  } catch (e) {
    print('Account creation error: $e');
  }
}

Future<void> analyzeErrors(String apiKey) async {
  try {
    // Try different endpoints to see error patterns
    final testEndpoints = [
      '/user/orders',
      '/user/positions', 
      '/user/balance',
      '/orders',
      '/trading/order',
      '/api/order',
    ];
    
    for (final endpoint in testEndpoints) {
      try {
        final response = await http.get(
          Uri.parse('http://localhost:3001$endpoint'),
          headers: {
            'X-Api-Key': apiKey,
            'Content-Type': 'application/json',
          },
        );
        
        print('$endpoint: ${response.statusCode}');
        
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            print('  Error details: ${errorData['message'] ?? errorData['error'] ?? 'No message'}');
            
            // Look for authentication hints
            if (errorData.toString().toLowerCase().contains('auth') ||
                errorData.toString().toLowerCase().contains('sign') ||
                errorData.toString().toLowerCase().contains('key')) {
              print('  🔍 AUTHENTICATION HINT: $errorData');
            }
          } catch (e) {
            print('  Raw error: ${response.body}');
          }
        }
        
      } catch (e) {
        print('$endpoint: Request error - $e');
      }
    }
    
  } catch (e) {
    print('Error analysis failed: $e');
  }
}