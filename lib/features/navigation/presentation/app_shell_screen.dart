import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entry/presentation/add_entry_bottom_sheet.dart';
import '../../home/presentation/home_screen.dart';
import '../../subscriptions/domain/subscriptions_goals_tab.dart';
import '../../subscriptions/presentation/subscriptions_goals_screen.dart';
import '../../wallets/presentation/screens/my_wallets_screen.dart';
import '../providers/shell_home_navigation_intent_provider.dart';
import '../../../shared/widgets/floating_bottom_nav.dart';

/// Shell uses [StatefulWidget] + nested [Consumer] for navigation intents.
/// Avoid [ConsumerState] at the shell root: `ConsumerState.ref` relies on
/// `context as WidgetRef`, which requires a [ConsumerStatefulElement]; mixing
/// that with some navigator/index stacks has caused runtime cast failures.
class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _currentIndex = 0;
  int _unifiedScreenKey = 0;
  SubscriptionsGoalsTab _unifiedInitialTab =
      SubscriptionsGoalsTab.subscriptions;

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
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<ShellHomeNavigationIntent?>(
          shellHomeNavigationIntentProvider,
          (previous, next) {
            if (next == null) return;
            setState(() {
              _currentIndex = next.bottomNavIndex;
              _unifiedInitialTab = next.unifiedInitialTab;
              _unifiedScreenKey++;
            });
            ref.read(shellHomeNavigationIntentProvider.notifier).clear();
          },
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: [
                  TickerMode(
                    enabled: _currentIndex == 0,
                    child: const HomeScreen(showBottomNav: false),
                  ),
                  TickerMode(
                    enabled: _currentIndex == 1,
                    child: const _ComingSoonScreen(),
                  ),
                  const _ShellPlaceholder(),
                  TickerMode(
                    enabled: _currentIndex == 3,
                    child: SubscriptionsGoalsScreen(
                      key: ValueKey<int>(_unifiedScreenKey),
                      initialTab: _unifiedInitialTab,
                    ),
                  ),
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
      },
    );
  }
}

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

class _ShellPlaceholder extends StatelessWidget {
  const _ShellPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Theme.of(context).colorScheme.surface);
  }
}
