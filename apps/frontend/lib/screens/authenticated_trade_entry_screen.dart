import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'trade_entry_screen.dart';

/// Simple authenticated trade entry screen that wraps TradeEntryScreen
class AuthenticatedTradeEntryScreen extends ConsumerWidget {
  const AuthenticatedTradeEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const TradeEntryScreen();
  }
}