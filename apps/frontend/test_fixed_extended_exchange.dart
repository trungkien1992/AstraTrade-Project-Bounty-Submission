#!/usr/bin/env dart

/// Test script to verify the fixed Extended Exchange integration
/// Tests the new StarkNet signature generation and order placement

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'lib/services/extended_exchange_signature_service.dart';

Future<void> main() async {
  print('🧪 Testing Fixed Extended Exchange Integration');
  print('=' * 50);
  
  // Test 1: Verify StarkNet signature generation
  await testSignatureGeneration();
  
  // Test 2: Verify market data retrieval
  await testMarketDataRetrieval();
  
  // Test 3: Test order placement with new signatures
  await testOrderPlacement();
  
  print('\n🎯 Testing Complete!');
}

Future<void> testSignatureGeneration() async {
  print('\n1️⃣ Testing StarkNet Signature Generation');
  print('-' * 30);
  
  try {
    final signature = ExtendedExchangeSignatureService.generateOrderSignature(
      privateKey: '0x1234567890abcdef1234567890abcdef12345678',
      market: 'ETH-USD',
      side: 'buy',
      quantity: '1.0',
      price: '3800.0',
      vaultId: 101420,
      nonce: DateTime.now().millisecondsSinceEpoch,
      expiry: DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
    );
    
    print('✅ Signature generated successfully!');
    print('   Message Hash: ${signature['message_hash']}');
    print('   Signature R: ${signature['signature']['r']}');
    print('   Signature S: ${signature['signature']['s']}');
    print('   Public Key: ${signature['public_key']}');
    print('   StarkNet Crypto Used: ${signature['starknet_signature_used']}');
    print('   Pedersen Hash Used: ${signature['pedersen_hash_used']}');
    
  } catch (e) {
    print('❌ Signature generation failed: $e');
  }
}

Future<void> testMarketDataRetrieval() async {
  print('\n2️⃣ Testing Market Data Retrieval');
  print('-' * 30);
  
  try {
    final response = await http.get(
      Uri.parse('http://localhost:3001/info/markets'),
      headers: {
        'X-Api-Key': '6aa86ecc5df765eba5714d375d5ceef0',
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final markets = data['data'] as List?;
      print('✅ Market data retrieved successfully!');
      print('   Status: ${data['status']}');
      print('   Markets count: ${markets?.length ?? 0}');
      
      // Show first few markets
      if (markets != null && markets.isNotEmpty) {
        print('   Sample markets:');
        for (int i = 0; i < (markets.length > 3 ? 3 : markets.length); i++) {
          final market = markets[i];
          print('     - ${market['name']}: ${market['marketStats']?['lastPrice'] ?? 'N/A'}');
        }
      }
    } else {
      print('❌ Market data request failed: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Market data test failed: $e');
  }
}

Future<void> testOrderPlacement() async {
  print('\n3️⃣ Testing Order Placement with Fixed Format');
  print('-' * 30);
  
  try {
    // Generate signature for test order
    final signatureData = ExtendedExchangeSignatureService.generateOrderSignature(
      privateKey: '0x1234567890abcdef1234567890abcdef12345678',
      market: 'ETH-USD',
      side: 'buy',
      quantity: '0.1',
      price: '3800.0',
      vaultId: 101420,
      nonce: DateTime.now().millisecondsSinceEpoch,
      expiry: DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
    );
    
    // Create order with exact API format
    final orderData = {
      'id': 'test_${DateTime.now().millisecondsSinceEpoch}',
      'market': 'ETH-USD',
      'type': 'limit',
      'side': 'buy',
      'qty': '0.1',
      'price': '3800.0',
      'timeInForce': 'GTT',
      'expiryEpochMillis': DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
      'fee': (0.1 * 3800.0 * 0.00025).toStringAsFixed(8),
      'nonce': DateTime.now().millisecondsSinceEpoch.toString(),
      'settlement': {
        'signature': {
          'r': signatureData['signature']['r'],
          's': signatureData['signature']['s'],
        },
        'starkKey': signatureData['public_key'],
        'collateralPosition': int.parse(signatureData['vault_id']),
      },
      'reduceOnly': false,
      'postOnly': false,
      'selfTradeProtectionLevel': 'account',
    };

    print('📋 Order payload prepared:');
    print('   Order ID: ${orderData['id']}');
    print('   Market: ${orderData['market']}');
    print('   Side: ${orderData['side']}');
    print('   Quantity: ${orderData['qty']}');
    print('   Price: ${orderData['price']}');
    print('   Fee: ${orderData['fee']}');
    final settlement = orderData['settlement'] as Map<String, dynamic>;
    print('   StarkKey: ${settlement['starkKey']}');
    
    final response = await http.post(
      Uri.parse('http://localhost:3001/user/order'),
      headers: {
        'X-Api-Key': '6aa86ecc5df765eba5714d375d5ceef0',
        'Content-Type': 'application/json',
        'User-Agent': 'AstraTrade-Test/1.0.0',
      },
      body: json.encode(orderData),
    ).timeout(Duration(seconds: 15));

    print('\n📨 Order Response:');
    print('   Status Code: ${response.statusCode}');
    print('   Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'OK') {
        print('✅ Order placed successfully!');
        print('   Order ID: ${responseData['data']?['orderId']}');
      } else {
        print('⚠️  Order response received but status not OK');
        print('   Status: ${responseData['status']}');
        print('   Message: ${responseData['message']}');
      }
    } else {
      print('❌ Order placement failed');
      if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        print('   Error: ${errorData['message'] ?? 'Bad Request'}');
      } else if (response.statusCode == 401) {
        print('   Error: Authentication failed - check API key');
      } else if (response.statusCode == 405) {
        print('   Error: Method not allowed - check endpoint');
      }
    }
    
  } catch (e) {
    print('❌ Order placement test failed: $e');
  }
}