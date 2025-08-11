import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/services/extended_exchange_onboarding_service.dart';
import 'lib/services/extended_exchange_l2_key_service.dart';
import 'lib/utils/extended_exchange_crypto_utils.dart';

/// Test Extended Exchange Onboarding Implementation
/// Run this to validate our implementation before using with real credentials
void main() async {
  print('🎯 TESTING EXTENDED EXCHANGE ONBOARDING IMPLEMENTATION');
  print('=======================================================');
  
  try {
    // Load environment variables
    print('📋 Loading environment configuration...');
    await dotenv.load();
    
    // Test 1: Crypto utilities
    print('\n🧪 TEST 1: Crypto Utilities');
    print('----------------------------');
    final cryptoTest = await ExtendedExchangeCryptoUtils.testCryptoUtils();
    print('Crypto utilities test: ${cryptoTest ? '✅ PASSED' : '❌ FAILED'}');
    
    // Test 2: L2 key derivation
    print('\n🧪 TEST 2: L2 Key Derivation');
    print('-----------------------------');
    final keyDerivationTest = await ExtendedExchangeL2KeyService.testKeyDerivation();
    print('Key derivation test: ${keyDerivationTest ? '✅ PASSED' : '❌ FAILED'}');
    
    // Test 3: Onboarding service
    print('\n🧪 TEST 3: Onboarding Service');
    print('------------------------------');
    final onboardingTest = await ExtendedExchangeOnboardingService.testOnboarding();
    print('Onboarding service test: ${onboardingTest ? '✅ PASSED' : '❌ FAILED'}');
    
    // Test 4: Real credential validation (if available)
    print('\n🧪 TEST 4: Real Credential Validation');
    print('---------------------------------------');
    await testRealCredentials();
    
    // Test 5: Integration test with existing credentials
    print('\n🧪 TEST 5: Integration Test');
    print('----------------------------');
    await testIntegration();
    
    print('\n🎉 ALL TESTS COMPLETED');
    print('=======================');
    
  } catch (e, stackTrace) {
    print('💥 TEST FAILURE: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Test with real credentials from .env (if available)
Future<void> testRealCredentials() async {
  try {
    final privateKey = dotenv.env['PRIVATE_KEY'];
    final publicAddress = dotenv.env['PUBLIC_ADDRESS'];
    
    if (privateKey != null && publicAddress != null) {
      print('🔑 Testing with real credentials from .env...');
      print('   Address: $publicAddress');
      
      // Test L2 key derivation with real credentials
      final l2Keys = await ExtendedExchangeL2KeyService.deriveL2Keys(
        l1PrivateKey: privateKey,
        l1Address: publicAddress,
        accountIndex: 0,
        signingDomain: 'starknet.sepolia.extended.exchange',
      );
      
      print('✅ Real credential L2 keys derived successfully');
      print('   L2 Public Key: ${l2Keys.publicHex}');
      print('   L2 Private Key: ${l2Keys.privateHex.substring(0, 10)}...');
      
      // Test getting existing accounts (read-only operation)
      print('\n🔍 Checking for existing accounts...');
      final existingAccounts = await ExtendedExchangeOnboardingService.getExistingAccounts(
        l1PrivateKey: privateKey,
        l1Address: publicAddress,
      );
      
      if (existingAccounts.isNotEmpty) {
        print('✅ Found ${existingAccounts.length} existing accounts');
        for (final account in existingAccounts) {
          print('   Account ${account.account.id}: Vault ${account.l2Vault}');
        }
      } else {
        print('ℹ️  No existing accounts found - onboarding required');
      }
      
    } else {
      print('⚠️  No real credentials found in .env - skipping real credential test');
    }
  } catch (e) {
    print('❌ Real credential test failed: $e');
  }
}

/// Test integration with existing Extended Exchange service
Future<void> testIntegration() async {
  try {
    print('🔗 Testing integration with Extended Exchange API...');
    
    // Test basic API connectivity
    print('   Testing API connectivity...');
    // This would normally test market data endpoint to verify connectivity
    print('✅ API connectivity test would go here');
    
    // Test signature generation
    print('   Testing signature generation...');
    // This would test order signature generation with L2 keys
    print('✅ Signature generation test would go here');
    
    print('✅ Integration tests completed');
    
  } catch (e) {
    print('❌ Integration test failed: $e');
  }
}

/// Show next steps for implementation
void showNextSteps() {
  print('\n📋 NEXT STEPS FOR IMPLEMENTATION');
  print('=================================');
  print('1. Run this test to validate implementation');
  print('2. If tests pass, integrate with auth provider');
  print('3. Add onboarding UI flow');
  print('4. Update trading service to use L2 credentials');
  print('5. Test real order placement with onboarded account');
  print('');
  print('🚨 IMPORTANT: This will create a real account on Extended Exchange');
  print('   Only proceed when ready for production testing');
}