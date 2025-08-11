import 'dart:developer';
import 'dart:js' as js;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class Web3AuthWebService {
  static bool get isSupported => kIsWeb;

  /// Initialize Web3Auth for web platform
  static Future<void> initialize() async {
    if (!kIsWeb) return;
    
    try {
      // Wait for Web3Auth to be ready
      await _waitForWeb3Auth();
      log('Web3Auth web service initialized');
    } catch (e) {
      log('Web3Auth web initialization failed: $e');
      rethrow;
    }
  }

  /// Wait for Web3Auth to be ready
  static Future<void> _waitForWeb3Auth() async {
    int attempts = 0;
    while (attempts < 50) { // Wait up to 5 seconds
      if (js.context['web3AuthReady'] == true) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    throw Exception('Web3Auth initialization timeout');
  }

  /// Sign in with Google using Web3Auth
  static Future<User> signInWithGoogle() async {
    if (!kIsWeb) {
      throw UnsupportedError('Web3Auth web service only supports web platform');
    }

    try {
      log('Starting Web3Auth Google sign-in...');
      
      // Call the JavaScript function
      final result = await js.context.callMethod('web3AuthLogin');
      final resultMap = _jsObjectToMap(result);
      
      if (resultMap['success'] != true) {
        throw Exception(resultMap['error'] ?? 'Login failed');
      }
      
      final userInfo = _jsObjectToMap(resultMap['user']);
      final privateKey = resultMap['privateKey'] as String?;
      
      if (privateKey == null || privateKey.isEmpty) {
        throw Exception('Failed to get private key from Web3Auth');
      }
      
      log('Web3Auth login successful');
      
      // Create user from Web3Auth response
      return User(
        id: userInfo['verifierId'] ?? 'web3auth_${DateTime.now().millisecondsSinceEpoch}',
        email: userInfo['email'] ?? 'web3auth@astratrade.app',
        username: userInfo['name'] ?? 'Web3Auth User',
        profilePicture: userInfo['profileImage'],
        starknetAddress: _deriveStarknetAddress(privateKey),
        privateKey: privateKey,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        extendedExchangeApiKey: null, // Will be generated on-demand
      );
    } catch (e) {
      log('Web3Auth Google sign-in failed: $e');
      rethrow;
    }
  }

  /// Sign out from Web3Auth
  static Future<void> signOut() async {
    if (!kIsWeb) return;
    
    try {
      final result = await js.context.callMethod('web3AuthLogout');
      final resultMap = _jsObjectToMap(result);
      
      if (resultMap['success'] != true) {
        log('Web3Auth logout warning: ${resultMap['error']}');
        // Don't throw - logout should always succeed from user perspective
      }
      
      log('Web3Auth logout successful');
    } catch (e) {
      log('Web3Auth logout failed: $e');
      // Don't throw - logout should always succeed from user perspective
    }
  }

  /// Convert JS object to Dart Map
  static Map<String, dynamic> _jsObjectToMap(dynamic jsObject) {
    if (jsObject == null) return {};
    
    try {
      // Convert JS object to JSON string then parse
      final jsonString = js.context['JSON'].callMethod('stringify', [jsObject]);
      return json.decode(jsonString);
    } catch (e) {
      log('Failed to convert JS object to map: $e');
      return {};
    }
  }

  /// Derive Starknet address from private key
  static String _deriveStarknetAddress(String privateKey) {
    // For demo purposes, use the same deployed address
    // In production, this would derive the actual address from the private key
    return '0x05715B600c38f3BFA539281865Cf8d7B9fE998D79a2CF181c70eFFCb182752F7';
  }
}