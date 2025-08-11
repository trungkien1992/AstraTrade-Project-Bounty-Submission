import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Test real trade placement on StarkNet Sepolia Extended Exchange
void main() async {
  print('🔥 TESTING REAL TRADE PLACEMENT');
  print('================================');
  
  try {
    // Load .env file
    final envFile = File('.env');
    final envContent = await envFile.readAsString();
    
    String? apiKey;
    String? privateKey;
    String? publicAddress;
    
    for (final line in envContent.split('\n')) {
      if (line.startsWith('EXTENDED_EXCHANGE_API_KEY=')) {
        apiKey = line.split('=')[1].trim();
      } else if (line.startsWith('PRIVATE_KEY=')) {
        privateKey = line.split('=')[1].trim();
      } else if (line.startsWith('PUBLIC_ADDRESS=')) {
        publicAddress = line.split('=')[1].trim();
      }
    }
    
    print('🔑 API Key: ${apiKey?.substring(0, 8)}...');
    print('🏠 Address: $publicAddress');
    print('🔐 Private Key: ${privateKey?.substring(0, 10)}...');
    
    if (apiKey == null || privateKey == null || publicAddress == null) {
      throw Exception('Missing credentials in .env file');
    }
    
    final baseUrl = 'http://localhost:3001';
    
    // Test 1: Get markets to verify API access
    print('\n📊 Testing market data access...');
    final marketResponse = await http.get(
      Uri.parse('$baseUrl/info/markets'),
      headers: {
        'X-Api-Key': apiKey,
        'Content-Type': 'application/json',
      },
    );
    
    if (marketResponse.statusCode == 200) {
      final marketData = json.decode(marketResponse.body);
      final markets = marketData['data'] as List;
      print('✅ Market access successful: ${markets.length} markets');
      
      // Show available markets
      print('📈 Available markets:');
      for (final market in markets.take(5)) {
        final stats = market['marketStats'] ?? {};
        final name = market['name'] ?? 'Unknown';
        final price = stats['markPrice'] ?? stats['lastPrice'] ?? '0';
        print('  - $name: \$${price}');
      }
    } else {
      print('❌ Market access failed: ${marketResponse.statusCode}');
      print('Response: ${marketResponse.body}');
      return;
    }
    
    // Test 2: Try to place a small test order
    print('\n🎯 Testing trade placement...');
    
    final testOrder = {
      'market': 'ETH-USD',
      'side': 'buy',
      'size': '0.001', // Very small size
      'price': '4000', // Below market price
      'type': 'limit',
      'timeInForce': 'GTC',
      'clientOrderId': 'test_${DateTime.now().millisecondsSinceEpoch}',
      'signature': 'placeholder_signature', // Will need real signature
    };
    
    print('📋 Test order: ${json.encode(testOrder)}');
    
    final orderResponse = await http.post(
      Uri.parse('$baseUrl/user/order'),
      headers: {
        'X-Api-Key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode(testOrder),
    );
    
    print('🎯 Order response status: ${orderResponse.statusCode}');
    print('📄 Order response: ${orderResponse.body}');
    
    if (orderResponse.statusCode == 200 || orderResponse.statusCode == 201) {
      print('✅ ORDER PLACEMENT WORKS! Trade was accepted!');
    } else if (orderResponse.statusCode == 401) {
      print('🔐 Authentication required - need proper signature');
    } else if (orderResponse.statusCode == 403) {
      print('🚫 API key lacks trading permissions');
    } else if (orderResponse.statusCode == 400) {
      final errorData = json.decode(orderResponse.body);
      print('❌ Bad request: ${errorData['message'] ?? 'Unknown error'}');
    } else {
      print('⚠️ Unexpected response: ${orderResponse.statusCode}');
    }
    
    // Test 3: Check account info/positions
    print('\n👤 Testing account access...');
    
    final endpoints = [
      '/user/account',
      '/user/positions',
      '/user/orders',
      '/user/balance',
      '/account',
      '/positions'
    ];
    
    for (final endpoint in endpoints) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'X-Api-Key': apiKey,
            'Content-Type': 'application/json',
          },
        );
        
        print('🔍 $endpoint: ${response.statusCode}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('  ✅ Data: ${data.toString().substring(0, 100)}...');
        }
      } catch (e) {
        print('🔍 $endpoint: Error - $e');
      }
    }
    
    print('\n🏁 TRADE PLACEMENT TEST COMPLETE');
    print('=================================');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}