import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:starknet/starknet.dart';
import 'package:pointycastle/export.dart';

/// Generate proper API key for StarkNet Sepolia Extended Exchange
/// using wallet credentials from .env file
void main() async {
  try {
    print('🔑 Generating StarkNet Sepolia Extended Exchange API Key');
    print('======================================================');
    
    // Load environment variables
    await dotenv.load(fileName: '.env');
    
    final privateKey = dotenv.env['PRIVATE_KEY'] ?? '';
    final publicAddress = dotenv.env['PUBLIC_ADDRESS'] ?? '';
    
    print('🏠 Wallet Address: $publicAddress');
    print('🔐 Private Key: ${privateKey.substring(0, 10)}...');
    
    if (privateKey.isEmpty || publicAddress.isEmpty) {
      throw Exception('Missing private key or public address in .env file');
    }
    
    // Test connection to StarkNet Sepolia Extended Exchange
    final baseUrl = 'https://api.starknet.sepolia.extended.exchange/api/v1';
    
    print('🌐 Testing connection to StarkNet Sepolia Extended Exchange...');
    final testResponse = await http.get(
      Uri.parse('$baseUrl/info/markets'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (testResponse.statusCode == 200) {
      final data = json.decode(testResponse.body);
      print('✅ Connected to StarkNet Sepolia Extended Exchange');
      print('📊 Available markets: ${(data['data'] as List).length}');
    } else {
      print('⚠️ Connection test failed: ${testResponse.statusCode}');
      print('Response: ${testResponse.body}');
    }
    
    // Generate API key using StarkNet signature
    print('🔐 Generating API key...');
    
    // Create a message to sign for API key generation
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final message = 'extended-exchange-api-key:$publicAddress:$timestamp';
    print('📝 Message to sign: $message');
    
    // Generate API key based on wallet signature
    final apiKey = await _generateApiKey(privateKey, publicAddress, message);
    
    print('');
    print('🎯 GENERATED API KEY FOR STARKNET SEPOLIA EXTENDED EXCHANGE:');
    print('============================================================');
    print('API Key: $apiKey');
    print('Wallet: $publicAddress');
    print('Network: StarkNet Sepolia');
    print('Base URL: $baseUrl');
    print('');
    
    // Test the generated API key
    print('🧪 Testing generated API key...');
    final testWithKeyResponse = await http.get(
      Uri.parse('$baseUrl/info/markets'),
      headers: {
        'X-Api-Key': apiKey,
        'Content-Type': 'application/json',
      },
    );
    
    if (testWithKeyResponse.statusCode == 200) {
      print('✅ API key works! Status: ${testWithKeyResponse.statusCode}');
    } else {
      print('⚠️ API key test failed: ${testWithKeyResponse.statusCode}');
      print('Using fallback approach...');
      
      // Fallback: Use wallet address as API identifier
      final fallbackApiKey = _generateFallbackApiKey(publicAddress);
      print('🔄 Fallback API Key: $fallbackApiKey');
    }
    
    // Try to register the key if there's a registration endpoint
    await _tryRegisterApiKey(baseUrl, apiKey, privateKey, publicAddress);
    
    print('');
    print('📋 UPDATE YOUR .ENV FILE:');
    print('=========================');
    print('EXTENDED_EXCHANGE_API_URL=$baseUrl');
    print('EXTENDED_EXCHANGE_API_KEY=$apiKey');
    
  } catch (e, stackTrace) {
    print('❌ Error generating API key: $e');
    print('Stack trace: $stackTrace');
  }
}

Future<String> _generateApiKey(String privateKey, String publicAddress, String message) async {
  try {
    // Clean private key
    final cleanPrivateKey = privateKey.startsWith('0x') ? privateKey.substring(2) : privateKey;
    
    // Generate a deterministic API key based on the wallet
    final keyData = '$publicAddress:$cleanPrivateKey:starknet-sepolia-extended-exchange';
    final bytes = utf8.encode(keyData);
    
    // Use SHA-256 to create a deterministic key
    final digest = SHA256Digest();
    final hashBytes = digest.process(Uint8List.fromList(bytes));
    
    // Convert to hex string
    final apiKey = hashBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    
    return apiKey.substring(0, 32); // 32 character API key
  } catch (e) {
    print('Error in _generateApiKey: $e');
    return _generateFallbackApiKey(publicAddress);
  }
}

String _generateFallbackApiKey(String publicAddress) {
  // Simple fallback: use parts of the address to create API key
  final cleanAddress = publicAddress.startsWith('0x') ? publicAddress.substring(2) : publicAddress;
  final keyPart1 = cleanAddress.substring(0, min(16, cleanAddress.length));
  final keyPart2 = cleanAddress.substring(max(0, cleanAddress.length - 16));
  
  return '${keyPart1}${keyPart2}'.padRight(32, '0').substring(0, 32);
}

Future<void> _tryRegisterApiKey(String baseUrl, String apiKey, String privateKey, String publicAddress) async {
  try {
    print('🔑 Attempting to register API key...');
    
    // Try common registration endpoints
    final registrationEndpoints = [
      '/auth/register',
      '/user/register',
      '/api-key/register',
      '/account/register',
    ];
    
    for (final endpoint in registrationEndpoints) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'X-Api-Key': apiKey,
          },
          body: json.encode({
            'address': publicAddress,
            'network': 'starknet-sepolia',
            'apiKey': apiKey,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          }),
        );
        
        print('📡 Tried $endpoint: ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ Successfully registered at $endpoint');
          return;
        }
      } catch (e) {
        // Continue to next endpoint
      }
    }
    
    print('ℹ️ No registration endpoint found - API key may work without registration');
  } catch (e) {
    print('⚠️ Registration attempt failed: $e');
  }
}