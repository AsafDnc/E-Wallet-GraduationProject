import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/home_provider.dart';

/// Displays the top section of the Home screen:
///   - Greeting text ("Good Morning, User")
///   - Balance row: large dollar amount + percent badge + visibility toggle
///   - Trailing CircleAvatar for the user profile photo
class HomeHeaderWidget extends ConsumerWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final header = ref.watch(
      homeProvider.select(
        (s) =>
            (s.userName, s.balance, s.balanceChangePercent, s.isBalanceVisible),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingText(userName: header.$1),
              const SizedBox(height: 6),
              _BalanceRow(
                balance: header.$2,
                changePercent: header.$3,
                isVisible: header.$4,
                onToggleVisibility: () =>
                    ref.read(homeProvider.notifier).toggleBalanceVisibility(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _UserAvatar(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _GreetingText extends StatelessWidget {
  const _GreetingText({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Good Morning, $userName',
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _BalanceRow extends StatefulWidget {
  const _BalanceRow({
    required this.balance,
    required this.changePercent,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  final double balance;
  final double changePercent;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  @override
  State<_BalanceRow> createState() => _BalanceRowState();
}

class _BalanceRowState extends State<_BalanceRow> {
  String? _cachedWidthKey;
  double? _cachedVisibleWidth;

  String get _formattedBalance {
    final parts = widget.balance.toStringAsFixed(0).split('');
    final buffer = StringBuffer('\$');
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write(',');
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }

  /// Returns the digits-only portion of the balance (no $ or commas).
  String get _digitsOnly => widget.balance.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    // The SizedBox is always sized to the visible formatted balance so the
    // badge and eye icon never shift regardless of visibility state.
    final formatted = _formattedBalance;
    if (_cachedWidthKey != formatted) {
      _cachedWidthKey = formatted;
      _cachedVisibleWidth = _measureTextWidth(formatted, _balanceStyle);
    }
    final visibleWidth = _cachedVisibleWidth!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: visibleWidth,
          child: Stack(
            children: [
              // Invisible anchor text always holds the correct layout width.
              Opacity(
                opacity: 0.0,
                child: Text(
                  _formattedBalance,
                  style: _balanceStyle,
                  maxLines: 1,
                ),
              ),
              // Visible layer: real balance or masked version.
              Text(
                widget.isVisible
                    ? formatted
                    // Always keep the $ sign; mask only the digit characters.
                    : '\$${'*' * _digitsOnly.length}',
                style: _balanceStyle,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        _PercentBadge(percent: widget.changePercent),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: widget.onToggleVisibility,
          child: Icon(
            widget.isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.white38,
            size: 22,
          ),
        ),
      ],
    );
  }

  static const _balanceStyle = TextStyle(
    color: Colors.white,
    fontSize: 44,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  /// Measures the pixel width of [text] rendered with [style].
  double _measureTextWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }
}

class _PercentBadge extends StatelessWidget {
  const _PercentBadge({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF39D353),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '+%${percent.toStringAsFixed(1)}',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 28,
      backgroundColor: Color(0xFF2A2D32),
      child: Icon(Icons.person_rounded, color: Colors.white54, size: 30),
    );
  }
}
