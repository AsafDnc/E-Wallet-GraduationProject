import 'package:flutter/material.dart';

import '../../entry/presentation/add_entry_bottom_sheet.dart';
import '../../home/presentation/home_screen.dart';
import '../../subscriptions/presentation/subscriptions_goals_screen.dart';
import '../../wallets/presentation/screens/my_wallets_screen.dart';
import '../../../shared/widgets/floating_bottom_nav.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _currentIndex = 0;

  void _openTransactionSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              // 0 — Home
              TickerMode(
                enabled: _currentIndex == 0,
                child: const HomeScreen(showBottomNav: false),
              ),
              // 1 — Chart (reserved for future use)
              TickerMode(
                enabled: _currentIndex == 1,
                child: const _ComingSoonScreen(),
              ),
              // 2 — Add (handled as modal; placeholder keeps IndexedStack stable)
              const _ShellPlaceholder(),
              // 3 — Subscriptions & Saving Goals (unified)
              TickerMode(
                enabled: _currentIndex == 3,
                child: const SubscriptionsGoalsScreen(),
              ),
              // 4 — My Wallets
              TickerMode(
                enabled: _currentIndex == 4,
                child: const MyWalletsScreen(),
              ),
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: RepaintBoundary(
              child: FloatingBottomNav(
                selectedIndex: _currentIndex,
                onIndexChanged: (index) {
                  if (index == 2) {
                    _openTransactionSheet();
                    return;
                  }
                  if (index == _currentIndex) return;
                  setState(() => _currentIndex = index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Coming Soon placeholder (Chart tab) ─────────────────────────────────────

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Empty placeholder (keeps IndexedStack slot stable) ──────────────────────

class _ShellPlaceholder extends StatelessWidget {
  const _ShellPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Theme.of(context).colorScheme.surface);
  }
}
