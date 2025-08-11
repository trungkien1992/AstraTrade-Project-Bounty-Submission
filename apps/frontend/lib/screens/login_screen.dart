import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:astratrade_app/services/auth_service.dart';
import 'package:astratrade_app/providers/auth_provider.dart';
import 'package:astratrade_app/screens/import_wallet_screen.dart';
import 'package:astratrade_app/screens/learn_more_modal.dart';
// Removed gamified widgets - focus on core trading flow
import 'package:astratrade_app/models/user.dart';
import 'package:astratrade_app/services/secure_storage_service.dart';
import 'package:astratrade_app/services/unified_wallet_setup_service.dart';
import 'package:astratrade_app/services/unified_wallet_onboarding_service.dart';
import 'package:astratrade_app/main.dart';
import 'dart:math' as math;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = ref.read(authServiceProvider);
    final authNotifier = ref.read(authProvider.notifier);

    try {
      await authNotifier.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    // Apple sign-in not yet implemented - using Google as fallback
    _handleGoogleSignIn();
  }

  void _navigateToImportWallet() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImportWalletScreen(),
      ),
    );
  }

  void _showLearnMoreModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const LearnMoreModal(),
    );
  }

  Future<void> _createFreshWallet() async {
    try {
      print('🚀 Starting fresh wallet creation with Extended Exchange onboarding...');
      
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Creating wallet and setting up trading...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      
      // Use unified wallet onboarding service for complete setup
      final newUser = await UnifiedWalletOnboardingService.setupFreshWalletWithOnboarding(
        username: 'CosmicTrader',
        email: 'fresh-wallet@astratrade.app',
        referralCode: null, // Can be added from UI if needed
      );
      
      print('✅ Fresh wallet with Extended Exchange trading created successfully');

      // Debug the user object
      print('📋 User created: ${newUser.toString()}');
      print('🔑 User ID: ${newUser.id}');
      print('📧 User Email: ${newUser.email}');
      print('🏠 User Address: ${newUser.starknetAddress}');
      print('🔐 API Key: ${newUser.extendedExchangeApiKey?.substring(0, 8) ?? 'none'}...');
      
      // Dismiss loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Sign in with the new wallet
      print('🔄 Setting user in auth provider...');
      ref.read(authProvider.notifier).setUser(newUser);
      print('✅ User set in auth provider successfully');
      
      // Navigate directly to main hub screen
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/trade-entry',
          (route) => false,
        );
      }
      
      // Show success message
      if (mounted) {
        final hasApiKey = newUser.extendedExchangeApiKey != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasApiKey 
                ? '🎉 Wallet created with Extended Exchange trading!\nAddress: ${newUser.starknetAddress.substring(0, 6)}...${newUser.starknetAddress.substring(newUser.starknetAddress.length - 4)}'
                : '✅ Wallet created! Extended Exchange setup pending.\nAddress: ${newUser.starknetAddress.substring(0, 6)}...${newUser.starknetAddress.substring(newUser.starknetAddress.length - 4)}'
            ),
            backgroundColor: hasApiKey ? Colors.green[700] : Colors.orange[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stack) {
      print('💥 Wallet creation failed: $e');
      print('📍 Error type: ${e.runtimeType}');
      print('📍 Stack trace: $stack');
      
      // Dismiss loading dialog if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to create wallet: ${e.toString()}'),
            backgroundColor: Colors.red[800],
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _generateFreshPrivateKey() {
    try {
      // Generate cryptographically secure random bytes
      final random = math.Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      
      // Convert to hex string
      final hexString = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      
      // Ensure it's exactly 64 characters (32 bytes)
      final privateKey = '0x$hexString';
      
      print('Generated private key: ${privateKey.substring(0, 10)}...${privateKey.substring(privateKey.length - 8)}');
      return privateKey;
    } catch (e) {
      print('Error generating private key: $e');
      throw Exception('Failed to generate private key: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Back button (optional, can be removed if not needed)
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Logo and Title
                _buildModernLogo(),
                const SizedBox(height: 48),
                
                // Welcome Text
                _buildModernWelcomeText(),
                const SizedBox(height: 40),
                
                // Authentication Cards
                _buildModernAuthCards(authState),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLogo() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'AstraTrade',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Gateway to Smart Trading',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernWelcomeText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          const Text(
            'Get Started',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose how you\'d like to begin your trading journey',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernAuthCards(AsyncValue<User?> authState) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Primary CTA - Fresh Wallet Creation
          _buildModernCreateWalletCard(),
          const SizedBox(height: 16),
          
          // Secondary - Import Existing Wallet
          _buildModernImportWalletCard(),
          const SizedBox(height: 24),
          
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Tertiary - Social Login
          _buildModernSocialLoginCard(),
          
          // Learn More as subtle text link
          const SizedBox(height: 16),
          _buildModernLearnMoreLink(),
        ],
      ),
    );
  }

  Widget _buildModernCreateWalletCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: _createFreshWallet,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 28,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create New Wallet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Generate a new Starknet wallet instantly',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernImportWalletCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: _navigateToImportWallet,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.vpn_key,
                  size: 28,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Import Existing Wallet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Already have a Starknet wallet? Import it here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSocialLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _handleGoogleSignIn,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.g_mobiledata,
                  size: 24,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        minimumSize: const Size(0, 32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernLearnMoreLink() {
    return Center(
      child: TextButton(
        onPressed: _showLearnMoreModal,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          'Learn about Starknet & self-custody',
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}