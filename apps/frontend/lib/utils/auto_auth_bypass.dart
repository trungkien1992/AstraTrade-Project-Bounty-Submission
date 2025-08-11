import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

/// Auto authentication bypass for localhost development
/// Uses credentials from .env file to automatically sign in user
class AutoAuthBypass {
  
  /// Automatically authenticate user with .env credentials
  static Future<void> performAutoAuth(WidgetRef ref) async {
    try {
      print('🔐 AUTO AUTH: Starting authentication bypass...');
      
      final demoMode = dotenv.env['DEMO_MODE']?.toLowerCase() == 'true';
      
      if (!demoMode) {
        print('⚠️ AUTO AUTH: Demo mode not enabled, skipping auto auth');
        return;
      }
      
      // Get credentials from .env
      final privateKey = dotenv.env['PRIVATE_KEY'] ?? '';
      final publicAddress = dotenv.env['PUBLIC_ADDRESS'] ?? '';
      final apiKey = dotenv.env['EXTENDED_EXCHANGE_API_KEY'] ?? '';
      
      if (privateKey.isEmpty || publicAddress.isEmpty || apiKey.isEmpty) {
        print('❌ AUTO AUTH: Missing credentials in .env file');
        return;
      }
      
      print('🔑 AUTO AUTH: Using credentials from .env');
      print('   Address: $publicAddress');
      print('   API Key: ${apiKey.substring(0, 8)}...');
      
      // Create authenticated user with real credentials
      final authenticatedUser = User(
        id: 'auto_auth_${DateTime.now().millisecondsSinceEpoch}',
        username: 'Auto Authenticated User',
        email: 'auto@astratrade.localhost',
        privateKey: privateKey,
        starknetAddress: publicAddress,
        extendedExchangeApiKey: apiKey,
        profilePicture: null,
        stellarShards: 1000,
        lumina: 500,
        xp: 2500,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      // Set user in auth provider
      ref.read(authProvider.notifier).setUser(authenticatedUser);
      
      print('✅ AUTO AUTH: User authenticated successfully');
      print('   Ready for trading with Extended Exchange API');
      
    } catch (e, stackTrace) {
      print('❌ AUTO AUTH: Failed - $e');
      print('Stack trace: $stackTrace');
    }
  }
  
  /// Check if auto auth should be performed
  static bool shouldPerformAutoAuth() {
    final demoMode = dotenv.env['DEMO_MODE']?.toLowerCase() == 'true';
    final hasCredentials = dotenv.env['PRIVATE_KEY']?.isNotEmpty == true &&
                          dotenv.env['PUBLIC_ADDRESS']?.isNotEmpty == true &&
                          dotenv.env['EXTENDED_EXCHANGE_API_KEY']?.isNotEmpty == true;
    
    return demoMode && hasCredentials;
  }
}