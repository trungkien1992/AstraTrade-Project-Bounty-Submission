import '../models/user.dart';

/// Authentication guards and utilities
class AuthGuards {
  /// Check if user is ready for trading (has required wallet info)
  static bool isUserReadyForTrading(User? user) {
    if (user == null) return false;
    
    return user.privateKey.isNotEmpty && 
           user.starknetAddress.isNotEmpty &&
           user.extendedExchangeApiKey != null &&
           user.extendedExchangeApiKey!.isNotEmpty;
  }
}