import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Helper utilities for demo mode functionality
class DemoUserHelper {
  /// Check if demo mode is enabled in environment
  static bool isDemoModeEnabled() {
    final demoMode = dotenv.env['DEMO_MODE'] ?? 'false';
    return demoMode.toLowerCase() == 'true';
  }
}