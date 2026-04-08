import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../subscriptions/domain/subscription_model.dart';
import '../../../subscriptions/providers/subscriptions_provider.dart';

/// Horizontally scrollable list of upcoming subscription cards.
///
/// [horizontalPadding] is applied to the section title so it aligns with the
/// rest of the page, while the card list itself scrolls edge-to-edge.
class UpcomingSubsWidget extends ConsumerWidget {
  const UpcomingSubsWidget({super.key, this.horizontalPadding = 16});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Text(
            'Upcoming Subs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
            itemBuilder: (context, index) =>
                _SubscriptionCard(subscription: subscriptions[index]),
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
    return Container(
      width: 148,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon row: brand icon left, renewal badge immediately to its right.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _BrandIcon(subscription: subscription),
              const SizedBox(width: 14),
              _RenewalBadge(days: subscription.daysUntilRenewal),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subscription.shortNameUppercase,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            subscription.homePriceLine,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ↑
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.alarm_rounded,
            color: Colors.black,
            size: 14,
          ), // ↑ from 12
          const SizedBox(width: 3),
          Text(
            days.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13, // ↑ from 11
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
