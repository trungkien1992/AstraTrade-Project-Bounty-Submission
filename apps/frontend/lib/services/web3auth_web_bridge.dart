import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional imports for web-specific functionality
import 'dart:js_interop' if (dart.library.io) 'dart:typed_data';
import 'dart:js_interop_unsafe' if (dart.library.io) 'dart:typed_data';
import 'package:web/web.dart' as web if (dart.library.io) 'dart:typed_data';

import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import '../utils/constants.dart';

/// Web3Auth JavaScript bridge for Flutter web platform
/// Interfaces with Web3Auth Modal SDK loaded via HTML script tags
class Web3AuthWebBridge {
  static Web3AuthWebBridge? _instance;
  static Web3AuthWebBridge get instance => _instance ??= Web3AuthWebBridge._();
  
  Web3AuthWebBridge._();
  
  bool _isInitialized = false;
  
  /// Check if running on web platform with Web3Auth SDK available
  bool get isSupported {
    if (!kIsWeb) return false;
    return _checkWeb3AuthSDK();
  }
  
  /// Initialize Web3Auth on web platform
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (!isSupported) {
      throw Exception('Web3Auth SDK not available on this platform');
    }
    
    try {
      log('🌐 Initializing Web3Auth for web platform');
      
      final config = _createWeb3AuthConfig();
      await _initializeWeb3Auth(config);
      
      _isInitialized = true;
      log('✅ Web3Auth web bridge initialized successfully');
    } catch (e) {
      log('💥 Web3Auth web initialization failed: $e');
      rethrow;
    }
  }
  
  /// Login with Google provider
  Future<Map<String, dynamic>> loginWithGoogle() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      log('🚀 Starting Google authentication via Web3Auth web...');
      
      // Call Web3Auth login with Google provider
      final result = await _loginWithProvider('google');
      
      if (result == null) {
        throw Exception('Login failed - no result returned');
      }
      
      log('✅ Google authentication successful');
      return result;
    } catch (e) {
      log('💥 Google login failed: $e');
      rethrow;
    }
  }
  
  /// Get user information
  Future<Map<String, dynamic>?> getUserInfo() async {
    if (!_isInitialized) return null;
    
    try {
      final userInfo = await _getUserInfo();
      return userInfo;
    } catch (e) {
      log('⚠️  Failed to get user info: $e');
      return null;
    }
  }
  
  /// Get private key
  Future<String?> getPrivateKey() async {
    if (!_isInitialized) return null;
    
    try {
      final privateKey = await _getPrivateKey();
      return privateKey;
    } catch (e) {
      log('⚠️  Failed to get private key: $e');
      return null;
    }
  }
  
  /// Logout
  Future<void> logout() async {
    if (!_isInitialized) return;
    
    try {
      await _logout();
      log('✅ Logged out successfully');
    } catch (e) {
      log('⚠️  Logout failed: $e');
    }
  }
  
  /// Check if Web3Auth SDK is loaded
  bool _checkWeb3AuthSDK() {
    if (!kIsWeb) return false;
    
    try {
      // Check if Web3Auth SDK is loaded in the browser
      return web.window.hasProperty('initWeb3Auth'.toJS).toDart;
    } catch (e) {
      return false;
    }
  }
  
  /// Create Web3Auth configuration
  Map<String, dynamic> _createWeb3AuthConfig() {
    return {
      'clientId': AppConstants.web3AuthClientId,
      'web3AuthNetwork': 'sapphire_mainnet',
      'chainConfig': {
        'chainNamespace': 'other',
        'chainId': 'starknet:SN_SEPOLIA',
        'rpcTarget': 'https://starknet-sepolia.public.blastapi.io/rpc/v0_7',
        'displayName': 'Starknet Sepolia',
        'blockExplorer': 'https://sepolia.voyager.online',
        'ticker': 'ETH',
        'tickerName': 'Ethereum',
      },
      'uiConfig': {
        'appName': AppConstants.appName,
        'mode': 'dark',
        'logoLight': 'https://web3auth.io/docs/contents/logo-light.png',
        'logoDark': 'https://web3auth.io/docs/contents/logo-dark.png',
        'defaultLanguage': 'en',
        'theme': {
          'primary': '#7B2CBF',
        }
      }
    };
  }
  
  /// Initialize Web3Auth instance
  Future<void> _initializeWeb3Auth(Map<String, dynamic> config) async {
    try {
      log('🌐 Calling JavaScript initWeb3Auth...');
      
      // Call the JavaScript function we defined in index.html
      final result = await _callJavaScriptFunction('initWeb3Auth', [config]);
      
      if (result != true) {
        throw Exception('Web3Auth initialization returned false');
      }
      
      log('✅ Web3Auth web bridge initialized successfully');
    } catch (e) {
      log('💥 Web3Auth initialization error: $e');
      rethrow;
    }
  }
  
  /// Login with specified provider
  Future<Map<String, dynamic>?> _loginWithProvider(String provider) async {
    try {
      log('🌐 Starting Web3Auth $provider login...');
      
      // Call the JavaScript function to show the Web3Auth popup
      final result = await _callJavaScriptFunction('loginWithGoogle', []);
      
      if (result != true) {
        throw Exception('User cancelled Google authentication');
      }
      
      // Return a basic success indicator - user info will be fetched separately
      return {'success': true};
    } catch (e) {
      log('💥 Provider login error: $e');
      rethrow;
    }
  }
  
  /// Get user information from Web3Auth
  Future<Map<String, dynamic>?> _getUserInfo() async {
    try {
      log('📋 Getting user info from Web3Auth...');
      
      // Call the JavaScript function to get user info
      final userInfo = await _callJavaScriptFunction('getWeb3AuthUserInfo', []);
      
      if (userInfo is Map) {
        return Map<String, dynamic>.from(userInfo as Map);
      }
      
      return userInfo as Map<String, dynamic>?;
    } catch (e) {
      log('💥 Get user info error: $e');
      rethrow;
    }
  }
  
  /// Get private key from Web3Auth
  Future<String?> _getPrivateKey() async {
    try {
      log('🔑 Getting private key from Web3Auth...');
      
      // Call the JavaScript function to get private key
      final privateKey = await _callJavaScriptFunction('getWeb3AuthPrivateKey', []);
      
      return privateKey as String?;
    } catch (e) {
      log('💥 Get private key error: $e');
      rethrow;
    }
  }
  
  /// Logout from Web3Auth
  Future<void> _logout() async {
    try {
      log('🌐 Logging out from Web3Auth...');
      
      // Call the JavaScript function to logout
      await _callJavaScriptFunction('logoutWeb3Auth', []);
    } catch (e) {
      log('💥 Logout error: $e');
      rethrow;
    }
  }
  
  /// Call a JavaScript function using dart:js_interop
  Future<dynamic> _callJavaScriptFunction(String functionName, List<dynamic> args) async {
    try {
      log('🔍 DIAGNOSTIC: Starting JavaScript function call: $functionName');
      log('🔍 DIAGNOSTIC: Function arguments: $args');
      
      // DIAGNOSTIC: Check if we're actually on web platform
      log('🔍 DIAGNOSTIC: kIsWeb = $kIsWeb');
      
      // DIAGNOSTIC: Check if window object exists (web only)
      if (kIsWeb) {
        try {
          final hasWindow = web.window != null;
          log('🔍 DIAGNOSTIC: window object exists: $hasWindow');
        } catch (e) {
          log('🔍 DIAGNOSTIC: Error accessing window: $e');
        }
        
        // DIAGNOSTIC: Check if Web3Auth functions exist in window
        try {
          final hasInitFunction = web.window.hasProperty('initWeb3Auth'.toJS).toDart;
          final hasLoginFunction = web.window.hasProperty('loginWithGoogle'.toJS).toDart;
          final hasUserInfoFunction = web.window.hasProperty('getWeb3AuthUserInfo'.toJS).toDart;
          log('🔍 DIAGNOSTIC: initWeb3Auth exists: $hasInitFunction');
          log('🔍 DIAGNOSTIC: loginWithGoogle exists: $hasLoginFunction');
          log('🔍 DIAGNOSTIC: getWeb3AuthUserInfo exists: $hasUserInfoFunction');
        } catch (e) {
          log('🔍 DIAGNOSTIC: Error checking window properties: $e');
        }
        
        // DIAGNOSTIC: Check if Web3Auth SDK objects are loaded
        try {
          final hasWeb3Auth = web.window.hasProperty('Web3auth'.toJS).toDart;
          final hasOpenloginAdapter = web.window.hasProperty('OpenloginAdapter'.toJS).toDart;
          log('🔍 DIAGNOSTIC: Web3auth SDK loaded: $hasWeb3Auth');
          log('🔍 DIAGNOSTIC: OpenloginAdapter SDK loaded: $hasOpenloginAdapter');
        } catch (e) {
          log('🔍 DIAGNOSTIC: Error checking SDK objects: $e');
        }
      } else {
        log('🔍 DIAGNOSTIC: Running on non-web platform, skipping window checks');
      }
      
      // For the login function, now try to actually call it instead of throwing
      if (functionName == 'loginWithGoogle' && kIsWeb) {
        log('🚀 DIAGNOSTIC: Attempting REAL Web3Auth Google login...');
        
        try {
          // Check if the JavaScript function exists before calling
          final hasFunction = web.window.hasProperty('loginWithGoogle'.toJS).toDart;
          if (!hasFunction) {
            log('❌ DIAGNOSTIC: loginWithGoogle function not found in window');
            throw Exception('Web3Auth loginWithGoogle function not loaded');
          }
          
          log('✅ DIAGNOSTIC: loginWithGoogle function found, attempting call...');
          
          // TODO: Actually call the JavaScript function here
          // For now, still simulate failure but with better diagnostics
          log('⚠️ DIAGNOSTIC: Real JavaScript call not yet implemented');
          throw Exception('Real Web3Auth integration not yet implemented - diagnostic phase');
          
        } catch (e) {
          log('💥 DIAGNOSTIC: Login function call failed: $e');
          rethrow;
        }
      }
      
      // For other functions, return appropriate responses with diagnostics
      switch (functionName) {
        case 'initWeb3Auth':
          log('✅ DIAGNOSTIC: Web3Auth initialization mock called');
          return true;
        case 'getWeb3AuthUserInfo':
          log('📋 DIAGNOSTIC: Returning mock user info');
          return {
            'email': 'web3auth.user@gmail.com',
            'name': 'Web3Auth User',
            'profileImage': null,
            'verifierId': 'google_web3auth_user',
          };
        case 'getWeb3AuthPrivateKey':
          log('🔑 DIAGNOSTIC: Returning mock private key');
          return '0x1234567890abcdef1234567890abcdef12345678';
        case 'logoutWeb3Auth':
          log('🚪 DIAGNOSTIC: Mock logout called');
          return true;
        default:
          log('❓ DIAGNOSTIC: Unknown function called: $functionName');
          return null;
      }
    } catch (e) {
      log('💥 DIAGNOSTIC: JavaScript function call failed with error: $e');
      log('💥 DIAGNOSTIC: Error type: ${e.runtimeType}');
      rethrow;
    }
  }
}