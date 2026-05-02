import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../shared/constants/card_dimensions.dart';
import '../../domain/subscription_model.dart';

/// Full-width subscription row with swipe-to-delete.
class SubscriptionCardWidget extends StatelessWidget {
  const SubscriptionCardWidget({
    super.key,
    required this.subscription,
    required this.onDelete,
  });

  final SubscriptionModel subscription;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: kCardMargin,
      child: Slidable(
        key: ValueKey(subscription.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.24,
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: kTileRadius,
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
            borderRadius: BorderRadius.circular(kCardRadius),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: isLight ? kCardShadow : const [],
          ),
          padding: kCardPadding,
          child: Row(
            children: [
              _ServiceIcon(subscription: subscription),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      subscription.displayName,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: subscription.formattedMonthlyPrice,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({required this.subscription});
  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _BillingRing extends StatelessWidget {
  const _BillingRing({required this.subscription});
  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context) {
    const size = 62.0;
    final progress = subscription.billingProgress.clamp(0.0, 1.0);
    final cs = Theme.of(context).colorScheme;

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
              strokeWidth: 5.5,
              strokeCap: StrokeCap.round,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cs.onSurface),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${subscription.daysUntilRenewal}',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
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
