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
///
/// **Deferred paint:** On some physical iOS devices the first frame can crash
/// (EXC_BAD_ACCESS in the raster thread) when [SpendingChartWidget] (fl_chart)
/// paints immediately. We show the header first, then mount the chart and
/// the rest of the scroll content after a short delay.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// When true, heavy widgets (chart, lists with Slidable, etc.) are built.
  bool _heavyContentReady = false;

  static const double _navBarHeight = 90;
  static const double _hPad = 16;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Let the first frame + GPU settle before running fl_chart / Slidable.
      Future<void>.delayed(const Duration(milliseconds: 280), () {
        if (mounted) setState(() => _heavyContentReady = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final headerOnly = SafeArea(
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
            if (!_heavyContentReady) ...[
              const SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading…',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final fullContent = SafeArea(
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

    final body = _heavyContentReady ? fullContent : headerOnly;

    return Scaffold(
      backgroundColor: cs.surface,
      body: widget.showBottomNav
          ? Stack(
              children: [
                body,
                FloatingBottomNav(selectedIndex: 0, onIndexChanged: (_) {}),
              ],
            )
          : body,
    );
  }
}
