import 'package:flutter/material.dart';

import '../../entry/presentation/add_entry_bottom_sheet.dart';
import '../../entry/presentation/entry_selection_bottom_sheet.dart';
import '../../goals/presentation/goals_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../subscriptions/presentation/subscriptions_screen.dart';
import '../../../shared/widgets/floating_bottom_nav.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _currentIndex = 0;

  void _onBackToHome() {
    setState(() => _currentIndex = 0);
  }

  void _openEntrySelectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return EntrySelectionBottomSheet(
          onManualEntry: () {
            Navigator.of(sheetContext).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const AddEntryBottomSheet(),
              );
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
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
                child: GoalsScreen(onBackTap: _onBackToHome),
              ),
              TickerMode(
                enabled: _currentIndex == 2,
                child: const _ShellPlaceholder(),
              ),
              TickerMode(
                enabled: _currentIndex == 3,
                child: SubscriptionsScreen(onBackTap: _onBackToHome),
              ),
              TickerMode(
                enabled: _currentIndex == 4,
                child: const _ShellPlaceholder(),
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
                    _openEntrySelectionSheet();
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

/// Empty tab body for nav slots not yet implemented (Add, Wallet).
class _ShellPlaceholder extends StatelessWidget {
  const _ShellPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: Color(0xFF0B0D12));
  }
}
