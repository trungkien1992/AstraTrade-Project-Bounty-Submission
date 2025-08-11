import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/trade_entry_screen.dart';
import '../screens/login_screen.dart';
import '../onboarding/experience_level_screen.dart';

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final authState = ref.watch(authProvider);
    
    // Step 1: Show onboarding flow first for complete user experience
    if (!onboardingState.isCompleted) {
      return const ExperienceLevelScreen();
    }
    
    // Step 2: After onboarding, check authentication
    return authState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const LoginScreen(),
      data: (user) {
        // Step 3: If authenticated, show main app
        if (user != null) {
          return const TradeEntryScreen();
        }
        // Step 4: If not authenticated, show login
        return const LoginScreen();
      },
    );
  }
}