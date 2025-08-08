import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'starknet_service.dart';

/// Web-safe wrapper for StarknetService that handles browser limitations
class WebSafeStarknetService {
  final StarknetService _service;
  static const int _webTimeout = 30; // Increased timeout for better reliability

  WebSafeStarknetService({bool useMainnet = false})
    : _service = StarknetService(useMainnet: useMainnet);

  /// Get ETH balance with web-specific optimizations and retry logic
  Future<double> getEthBalance(String address) async {
    if (kIsWeb) {
      // Try with multiple retry attempts
      return await _executeWithRetry(() => _service.getEthBalance(address));
    } else {
      // Native app - use full functionality
      return await _service.getEthBalance(address);
    }
  }

  /// Get STRK balance with web-specific optimizations and retry logic
  Future<double> getStrkBalance(String address) async {
    if (kIsWeb) {
      // Try with multiple retry attempts
      return await _executeWithRetry(() => _service.getStrkBalance(address));
    } else {
      // Native app - use full functionality
      return await _service.getStrkBalance(address);
    }
  }

  /// Mock ETH balance based on address for consistent demo experience
  double _getMockEthBalance(String address) {
    final hash = address.hashCode;
    final random = Random(hash);
    return 0.001 + (random.nextDouble() * 0.01); // 0.001 - 0.011 ETH
  }

  /// Mock STRK balance based on address for consistent demo experience
  double _getMockStrkBalance(String address) {
    final hash = address.hashCode;
    final random = Random(hash);
    return 100 + (random.nextDouble() * 100); // 100 - 200 STRK
  }

  /// Execute with retry logic and progressive fallback
  Future<double> _executeWithRetry(Future<double> Function() operation) async {
    const maxRetries = 3;
    const baseDelayMs = 1000;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final result = await operation().timeout(
          Duration(seconds: _webTimeout),
        );
        if (kDebugMode) {
          print('Balance loaded successfully on attempt $attempt');
        }
        return result;
      } catch (e) {
        if (kDebugMode) {
          print('Balance loading attempt $attempt failed: $e');
        }

        if (attempt == maxRetries) {
          // Last attempt failed - log warning and use mock data
          if (kDebugMode) {
            print(
              'All balance loading attempts failed, using mock data as fallback',
            );
          }
          // Return 0.0 to indicate network failure - more honest than mock data
          return 0.0;
        }

        // Wait before next retry with exponential backoff
        await Future.delayed(Duration(milliseconds: baseDelayMs * attempt));
      }
    }

    // This should never be reached, but included for safety
    return 0.0;
  }
}
