import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../domain/subscription_model.dart';

/// Full-width subscription row with swipe-to-delete only.
class SubscriptionCardWidget extends StatelessWidget {
  const SubscriptionCardWidget({
    super.key,
    required this.subscription,
    required this.onDelete,
  });

  final SubscriptionModel subscription;
  final VoidCallback onDelete;

  static const double _radius = 18;
  static const _tileRadius = BorderRadius.all(Radius.circular(_radius));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(subscription.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.24,
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: _tileRadius,
                child: SlidableAction(
                  onPressed: (_) => onDelete(),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline_rounded,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: isLight
                ? const [
                    BoxShadow(
                      color: Color(0x12222B33),
                      blurRadius: 18,
                      offset: Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: subscription.iconBgColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  IconData(subscription.iconData, fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.displayName,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: subscription.priceDollarsText,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: ' / mo',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _BillingRing(subscription: subscription),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillingRing extends StatelessWidget {
  const _BillingRing({required this.subscription});

  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context) {
    const size = 66.0;
    final progress = subscription.billingProgress.clamp(0.0, 1.0);
    final cs = Theme.of(context).colorScheme;
    final ringBg = cs.surfaceContainerHighest;
    // Match primary body text (dark charcoal in light mode), not brand blue.
    final ringFg = cs.onSurface;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              // Slightly thicker, premium feel.
              strokeWidth: 6,
              // Rounded ends for a softer, modern look.
              strokeCap: StrokeCap.round,
              backgroundColor: ringBg,
              valueColor: AlwaysStoppedAnimation<Color>(ringFg),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${subscription.daysUntilRenewal}',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              Text(
                'Days',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
