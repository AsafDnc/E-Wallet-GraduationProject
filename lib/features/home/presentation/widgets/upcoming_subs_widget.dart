import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../subscriptions/domain/subscription_model.dart';
import '../../../subscriptions/providers/subscriptions_provider.dart';
import '../../../subscriptions/presentation/subscriptions_screen.dart';

/// Horizontally scrollable list of upcoming subscription cards.
///
/// [horizontalPadding] is applied to the section title so it aligns with the
/// rest of the page, while the card list itself scrolls edge-to-edge.
class UpcomingSubsWidget extends ConsumerWidget {
  const UpcomingSubsWidget({super.key, this.horizontalPadding = 16});

  final double horizontalPadding;

  void _goToSubs(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SubscriptionsScreen(onBackTap: () => Navigator.of(context).pop()),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Upcoming Subs',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _goToSubs(context),
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // First card starts at the same inset as the title.
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: subscriptions.length,
            separatorBuilder: (context, i) => const SizedBox(width: 12),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _goToSubs(context),
              child: _SubscriptionCard(subscription: subscriptions[index]),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual card
// ---------------------------------------------------------------------------

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.subscription});

  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 148,
      padding: const EdgeInsets.all(11),
      decoration: AppTheme.cardDecoration(
        context,
      ).copyWith(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _BrandIcon(subscription: subscription),
              const Spacer(),
              _RenewalBadge(days: subscription.daysUntilRenewal),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subscription.shortNameUppercase,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            subscription.homePriceLine,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon({required this.subscription});

  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: subscription.iconBgColor,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(
        IconData(subscription.iconData, fontFamily: 'MaterialIcons'),
        color: Colors.white,
        size: 21,
      ),
    );
  }
}

class _RenewalBadge extends StatelessWidget {
  const _RenewalBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Distinct mini-surface so the reminder sits apart from the card body.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? const [
                BoxShadow(
                  color: Color(0x0D222B33),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : const [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alarm_rounded, color: cs.primary, size: 15),
          const SizedBox(width: 5),
          Text(
            days.toString(),
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
