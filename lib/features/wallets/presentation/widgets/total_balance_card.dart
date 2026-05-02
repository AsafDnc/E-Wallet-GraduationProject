import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../providers/wallet_providers.dart';

class TotalBalanceCard extends ConsumerWidget {
  const TotalBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final balance = ref.watch(calculatedBalanceProvider);
    final mode = ref.watch(balanceViewModeProvider);
    final isVisible = ref.watch(balanceVisibilityProvider);

    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: appCurrencySymbolSpaced,
      decimalDigits: 2,
    );

    final modeLabel = mode == BalanceViewMode.netWorth
        ? 'Net Worth'
        : 'Total Cash';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  modeLabel,
                  style: tt.labelLarge?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Toggle view mode
              _PillButton(
                label: mode == BalanceViewMode.netWorth
                    ? 'Total Cash'
                    : 'Net Worth',
                cs: cs,
                onTap: () =>
                    ref.read(balanceViewModeProvider.notifier).toggle(),
              ),
              const SizedBox(width: 8),
              // Visibility toggle
              GestureDetector(
                onTap: () =>
                    ref.read(balanceVisibilityProvider.notifier).toggle(),
                child: Icon(
                  isVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: cs.onPrimaryContainer,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Animated balance amount ──────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              key: ValueKey('$isVisible-$balance'),
              isVisible
                  ? formatter.format(balance)
                  : '$appCurrencySymbolSpaced••••••',
              style: tt.headlineLarge?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                fontSize: 36,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Subtitle ─────────────────────────────────────────────────
          Text(
            mode == BalanceViewMode.netWorth
                ? 'All accounts combined (debts included)'
                : 'Positive balances only',
            style: tt.bodySmall?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.cs,
    required this.onTap,
  });

  final String label;
  final ColorScheme cs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: cs.onPrimaryContainer.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: cs.onPrimaryContainer,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
