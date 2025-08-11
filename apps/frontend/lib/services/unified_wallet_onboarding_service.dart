import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/extended_exchange_onboarding_models.dart';
import 'unified_wallet_setup_service.dart';
import 'extended_exchange_onboarding_service.dart';
import 'secure_storage_service.dart';

/// Unified Wallet and Extended Exchange Onboarding Service
/// Combines wallet creation with Extended Exchange onboarding for seamless trading setup
class UnifiedWalletOnboardingService {
  
  /// Complete wallet setup with Extended Exchange onboarding
  /// This is the main method that should be called for new wallet creation
  static Future<User> setupWalletWithExtendedExchange({
    required String privateKey,
    required String starknetAddress,
    required String userId,
    required String username,
    required String email,
    String? profilePicture,
    String? referralCode,
  }) async {
    try {
      debugPrint('🚀 Setting up wallet with Extended Exchange onboarding...');
      debugPrint('   Address: ${starknetAddress.substring(0, 10)}...${starknetAddress.substring(starknetAddress.length - 8)}');
      
      // Step 1: First setup the basic wallet (without API key)
      final user = await UnifiedWalletSetupService.setupWalletWithTrading(
        privateKey: privateKey,
        starknetAddress: starknetAddress,
        userId: userId,
        username: username,
        email: email,
        profilePicture: profilePicture,
      );
      
      // Step 2: Perform Extended Exchange onboarding
      try {
        debugPrint('🔄 Starting Extended Exchange onboarding...');
        
        final onboardedAccount = await ExtendedExchangeOnboardingService.onboardAccount(
          l1PrivateKey: privateKey,
          l1Address: starknetAddress,
          referralCode: referralCode,
        );
        
        debugPrint('✅ Extended Exchange onboarding successful!');
        debugPrint('   Vault ID: ${onboardedAccount.l2Vault}');
        debugPrint('   API Key: ${onboardedAccount.tradingApiKey?.substring(0, 8)}...');
        
        // Step 3: Store the Extended Exchange credentials
        if (onboardedAccount.tradingApiKey != null) {
          await SecureStorageService.instance.storeTradingCredentials(
            apiKey: onboardedAccount.tradingApiKey!,
            apiSecret: '', // Extended Exchange doesn't use API secret
            passphrase: null,
          );
          
          // Store L2 keys for trading operations
          await SecureStorageService.instance.storeKey(
            'extended_l2_private_key',
            onboardedAccount.l2PrivateKey,
          );
          await SecureStorageService.instance.storeKey(
            'extended_l2_public_key',
            onboardedAccount.l2PublicKey,
          );
          await SecureStorageService.instance.storeKey(
            'extended_l2_vault_id',
            onboardedAccount.l2Vault.toString(),
          );
        }
        
        // Step 4: Return updated user with API key
        final updatedUser = user.copyWith(
          extendedExchangeApiKey: onboardedAccount.tradingApiKey,
        );
        
        // Store updated user data
        await _storeUserDataSecurely(updatedUser);
        
        return updatedUser;
        
      } catch (onboardingError) {
        debugPrint('⚠️ Extended Exchange onboarding failed: $onboardingError');
        debugPrint('💡 Continuing with wallet setup - user can onboard later');
        
        // Return user without API key - they can onboard later
        return user;
      }
      
    } catch (e) {
      debugPrint('❌ Wallet setup failed: $e');
      throw WalletSetupException('Failed to setup wallet: $e');
    }
  }
  
  /// Setup fresh wallet with Extended Exchange onboarding
  static Future<User> setupFreshWalletWithOnboarding({
    String? username,
    String? email,
    String? referralCode,
  }) async {
    try {
      debugPrint('🆕 Creating fresh wallet with Extended Exchange onboarding...');
      
      // First create the basic wallet
      final freshWallet = await UnifiedWalletSetupService.setupFreshWallet(
        username: username,
        email: email,
      );
      
      // Then perform Extended Exchange onboarding
      return await setupWalletWithExtendedExchange(
        privateKey: freshWallet.privateKey,
        starknetAddress: freshWallet.starknetAddress,
        userId: freshWallet.id,
        username: freshWallet.username,
        email: freshWallet.email,
        profilePicture: freshWallet.profilePicture,
        referralCode: referralCode,
      );
    } catch (e) {
      throw WalletSetupException('Fresh wallet creation with onboarding failed: $e');
    }
  }
  
  /// Check if user needs Extended Exchange onboarding
  static Future<bool> needsExtendedExchangeOnboarding() async {
    try {
      // Check if we have trading credentials
      final credentials = await SecureStorageService.instance.getTradingCredentials();
      if (credentials == null || credentials['api_key'] == null) {
        return true;
      }
      
      // Check if we have L2 keys
      final l2PrivateKey = await SecureStorageService.instance.getKey('extended_l2_private_key');
      final l2VaultId = await SecureStorageService.instance.getKey('extended_l2_vault_id');
      
      return l2PrivateKey == null || l2VaultId == null;
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
      return true;
    }
  }
  
  /// Perform Extended Exchange onboarding for existing wallet
  static Future<User> onboardExistingWallet(User existingUser, {String? referralCode}) async {
    try {
      debugPrint('📋 Onboarding existing wallet to Extended Exchange...');
      
      if (existingUser.extendedExchangeApiKey != null) {
        debugPrint('✅ User already has Extended Exchange API key');
        return existingUser;
      }
      
      // Perform Extended Exchange onboarding
      final onboardedAccount = await ExtendedExchangeOnboardingService.onboardAccount(
        l1PrivateKey: existingUser.privateKey,
        l1Address: existingUser.starknetAddress,
        referralCode: referralCode,
      );
      
      // Store credentials
      if (onboardedAccount.tradingApiKey != null) {
        await SecureStorageService.instance.storeTradingCredentials(
          apiKey: onboardedAccount.tradingApiKey!,
          apiSecret: '',
          passphrase: null,
        );
        
        // Store L2 keys
        await SecureStorageService.instance.storeKey(
          'extended_l2_private_key',
          onboardedAccount.l2PrivateKey,
        );
        await SecureStorageService.instance.storeKey(
          'extended_l2_public_key',
          onboardedAccount.l2PublicKey,
        );
        await SecureStorageService.instance.storeKey(
          'extended_l2_vault_id',
          onboardedAccount.l2Vault.toString(),
        );
      }
      
      // Return updated user
      final updatedUser = existingUser.copyWith(
        extendedExchangeApiKey: onboardedAccount.tradingApiKey,
      );
      
      await _storeUserDataSecurely(updatedUser);
      
      return updatedUser;
      
    } catch (e) {
      throw WalletSetupException('Extended Exchange onboarding failed: $e');
    }
  }
  
  /// Get stored Extended Exchange credentials
  static Future<ExtendedExchangeCredentials?> getStoredCredentials() async {
    try {
      final tradingCreds = await SecureStorageService.instance.getTradingCredentials();
      final l2PrivateKey = await SecureStorageService.instance.getKey('extended_l2_private_key');
      final l2PublicKey = await SecureStorageService.instance.getKey('extended_l2_public_key');
      final l2VaultId = await SecureStorageService.instance.getKey('extended_l2_vault_id');
      
      if (tradingCreds == null || l2PrivateKey == null || l2PublicKey == null || l2VaultId == null) {
        return null;
      }
      
      return ExtendedExchangeCredentials(
        apiKey: tradingCreds['api_key']!,
        l2PrivateKey: l2PrivateKey,
        l2PublicKey: l2PublicKey,
        l2VaultId: int.parse(l2VaultId),
      );
    } catch (e) {
      debugPrint('Error getting stored credentials: $e');
      return null;
    }
  }
  
  /// Store user data securely for session restoration
  static Future<void> _storeUserDataSecurely(User user) async {
    debugPrint('🔒 Storing user data with Extended Exchange credentials...');
    
    try {
      final userData = {
        'id': user.id,
        'email': user.email,
        'username': user.username,
        'profilePicture': user.profilePicture,
        'createdAt': user.createdAt.millisecondsSinceEpoch,
        'extendedExchangeApiKey': user.extendedExchangeApiKey,
        'stellarShards': user.stellarShards,
        'lumina': user.lumina,
        'xp': user.xp,
      };
      
      await SecureStorageService.instance.storeUserData(userData);
      debugPrint('✅ User data stored securely with Extended Exchange integration');
    } catch (e) {
      throw WalletSetupException('Failed to store user data securely: $e');
    }
  }
}

/// Extended Exchange Credentials model
class ExtendedExchangeCredentials {
  final String apiKey;
  final String l2PrivateKey;
  final String l2PublicKey;
  final int l2VaultId;
  
  ExtendedExchangeCredentials({
    required this.apiKey,
    required this.l2PrivateKey,
    required this.l2PublicKey,
    required this.l2VaultId,
  });
}

/// Wallet Setup Exception
class WalletSetupException implements Exception {
  final String message;
  
  WalletSetupException(this.message);
  
  @override
  String toString() => 'WalletSetupException: $message';
}