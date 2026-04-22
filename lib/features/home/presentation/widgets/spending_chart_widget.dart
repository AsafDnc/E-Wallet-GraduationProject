import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../providers/home_provider.dart';

/// Displays the "Spending Flow" card containing an fl_chart [LineChart].
///
/// The line is cyan/neon blue, curved, and has a gradient fill below it.
/// Axes show month abbreviations on the bottom and amount labels on the left.
/// Touch interaction shows a smooth vertical indicator with a clean tooltip.
class SpendingChartWidget extends ConsumerStatefulWidget {
  const SpendingChartWidget({super.key});

  @override
  ConsumerState<SpendingChartWidget> createState() =>
      _SpendingChartWidgetState();
}

class _SpendingChartWidgetState extends ConsumerState<SpendingChartWidget>
    with SingleTickerProviderStateMixin {
  static const _lineColor = Color(0xFF00C5A0);
  static const _gradientTop = Color(0x6000C5A0);
  static const _gradientBottom = Color(0x0000C5A0);
  static const _monthLabels = ['Jan', 'Feb', 'March', 'Apr', 'May', 'Jun'];

  // Tracks the currently touched spot index for the smooth indicator.
  int? _touchedIndex;

  // AnimationController drives the indicator fade-in/out.
  late final AnimationController _indicatorAnim;

  @override
  void initState() {
    super.initState();
    _indicatorAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _indicatorAnim.dispose();
    super.dispose();
  }

  void _onChartTouch(LineTouchResponse? response) {
    final spots = response?.lineBarSpots;
    if (spots == null || spots.isEmpty) {
      _indicatorAnim.reverse();
      setState(() => _touchedIndex = null);
    } else {
      final idx = spots.first.spotIndex;
      if (_touchedIndex != idx) {
        setState(() => _touchedIndex = idx);
        _indicatorAnim.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(homeProvider.select((s) => s.spendingFlowData));

    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Flow',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          RepaintBoundary(
            child: SizedBox(
              height: 180,
              child: FadeTransition(
                opacity: const AlwaysStoppedAnimation(1.0),
                child: LineChart(
                  _buildChartData(
                    data,
                    cs.outlineVariant,
                    cs.onSurfaceVariant,
                    cs.surfaceContainerHighest,
                  ),
                  duration: const Duration(milliseconds: 80),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(
    List<(int, double)> data,
    Color gridColor,
    Color labelColor,
    Color tooltipBgColor,
  ) {
    final spots = data
        .map((entry) => FlSpot(entry.$1.toDouble(), entry.$2))
        .toList();

    final labelStyle = TextStyle(color: labelColor, fontSize: 11);

    return LineChartData(
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 200,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: gridColor, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= _monthLabels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_monthLabels[index], style: labelStyle),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 200,
            reservedSize: 38,
            getTitlesWidget: (value, meta) =>
                Text(value.toInt().toString(), style: labelStyle),
          ),
        ),
      ),
      minX: 0,
      maxX: 5,
      minY: 0,
      maxY: 900,
      // ── Touch configuration ──────────────────────────────────────────────
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchCallback: (event, response) {
          // Only update on pointer-move / pointer-down events for smoothness.
          if (event is FlTapUpEvent ||
              event is FlPanEndEvent ||
              event is FlLongPressEnd) {
            _onChartTouch(null);
          } else {
            _onChartTouch(response);
          }
        },
        // Vertical indicator line
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              // Thin cyan vertical line
              FlLine(
                color: _lineColor.withValues(alpha: 0.6),
                strokeWidth: 1.5,
                dashArray: [4, 4],
              ),
              // Dot on the line at the touch point
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, idx) => FlDotCirclePainter(
                  radius: 5,
                  color: _lineColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
            );
          }).toList();
        },
        // Tooltip bubble
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => tooltipBgColor,
          tooltipBorderRadius: BorderRadius.circular(10),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '\$${spot.y.toStringAsFixed(0)}',
                const TextStyle(
                  color: _lineColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: _lineColor,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_gradientTop, _gradientBottom],
            ),
          ),
        ),
      ],
    );
  }
}
