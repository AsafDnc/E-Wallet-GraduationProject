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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
            color: const Color(0xFF181B22),
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: const Color(0xFF31353F)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: subscription.iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  IconData(subscription.iconData, fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: subscription.priceDollarsText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' / mo',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
    const size = 72.0;
    final progress = subscription.billingProgress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.12 * progress),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: const Color(0xFF3A3E47),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${subscription.daysUntilRenewal}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              Text(
                'Days',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
