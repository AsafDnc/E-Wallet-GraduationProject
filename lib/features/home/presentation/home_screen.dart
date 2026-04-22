import 'package:flutter/material.dart';

import '../../../shared/widgets/floating_bottom_nav.dart';
import 'widgets/ai_bot_card_widget.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/recent_transactions_widget.dart';
import 'widgets/spending_chart_widget.dart';
import 'widgets/upcoming_subs_widget.dart';

/// Root screen for the Home feature.
///
/// The [Stack] lets [FloatingBottomNav] overlay the scrollable content.
/// Horizontal padding is applied per-section so the full screen width is
/// available to widgets that need edge-to-edge layout.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  static const double _navBarHeight = 90;

  // Horizontal inset for sections that should not bleed to screen edges.
  static const double _hPad = 16;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, bottom: _navBarHeight + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepaintBoundary(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: _hPad),
                child: HomeHeaderWidget(),
              ),
            ),
            const SizedBox(height: 28),
            RepaintBoundary(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: _hPad),
                child: SpendingChartWidget(),
              ),
            ),
            const SizedBox(height: 28),
            RepaintBoundary(
              child: const UpcomingSubsWidget(horizontalPadding: _hPad),
            ),
            const SizedBox(height: 24),
            RepaintBoundary(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: _hPad),
                child: AiBotCardWidget(),
              ),
            ),
            const SizedBox(height: 28),
            RepaintBoundary(
              child: RecentTransactionsWidget(horizontalPadding: _hPad),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: showBottomNav
          ? Stack(
              children: [
                content,
                FloatingBottomNav(selectedIndex: 0, onIndexChanged: (_) {}),
              ],
            )
          : content,
    );
  }
}
