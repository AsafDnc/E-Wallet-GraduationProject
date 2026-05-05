import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/greeting_utils.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../profile/providers/profile_providers.dart';
import '../../providers/home_provider.dart';

/// Displays the top section of the Home screen:
///   - Greeting text (time-based + first name from [profileProvider])
///   - Balance row: large dollar amount + percent badge + visibility toggle
///   - Trailing CircleAvatar for the user profile photo
class HomeHeaderWidget extends ConsumerWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullName = ref.watch(profileProvider.select((p) => p.fullName));
    final header = ref.watch(
      homeProvider.select(
        (s) => (s.balance, s.balanceChangePercent, s.isBalanceVisible),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingText(fullName: fullName),
              const SizedBox(height: 6),
              _BalanceRow(
                balance: header.$1,
                changePercent: header.$2,
                isVisible: header.$3,
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
  const _GreetingText({required this.fullName});

  /// Reactive [ProfileState.fullName] from [profileProvider] (trimmed upstream).
  final String fullName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phrase = localizedGreetingPhrase(l10n);
    final first = firstNameFromFullName(fullName, l10n.defaultUserFirstName);
    return Text(
      '$phrase, $first',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final themedBalanceStyle = _balanceStyle.copyWith(color: textColor);
    final formatted = widget.balance.formattedCompact;
    final masked =
        '$appCurrencySymbolSpaced${'*' * widget.balance.abs().toStringAsFixed(0).length}';

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.isVisible ? formatted : masked,
            style: themedBalanceStyle,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          const SizedBox(width: 8),
          _PercentBadge(percent: widget.changePercent),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onToggleVisibility,
            child: Icon(
              widget.isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  static const _balanceStyle = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
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
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: cs.surfaceContainerHighest,
        child: Icon(Icons.person_rounded, color: cs.onSurfaceVariant, size: 30),
      ),
    );
  }
}
