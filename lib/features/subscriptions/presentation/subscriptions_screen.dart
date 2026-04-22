import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../providers/subscriptions_provider.dart';
import 'widgets/subscription_card_widget.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key, required this.onBackTap});

  final VoidCallback onBackTap;

  static String _formatTotal(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawItems = ref.watch(subscriptionsProvider);
    // Sort ascending by days until renewal (soonest first).
    final items = [...rawItems]
      ..sort((a, b) => a.daysUntilRenewal.compareTo(b.daysUntilRenewal));
    final total = items.fold<double>(0, (sum, item) => sum + item.monthlyPrice);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
          child: Column(
            children: [
              // ── Shared header layout (blueprint for GoalsScreen) ──────────
              Row(
                children: [
                  IconButton(
                    onPressed: onBackTap,
                    icon: Icon(Icons.arrow_back, color: cs.onSurface, size: 22),
                    splashRadius: 22,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Total Monthly Cost',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surfaceContainerHighest,
                    ),
                    child: Icon(Icons.add, color: cs.onSurface, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // ── Monthly total: centered, same scale as Goals totals ───────
              Center(
                child: Text(
                  _formatTotal(total),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SlidableAutoCloseBehavior(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final sub = items[index];
                    return SubscriptionCardWidget(
                      subscription: sub,
                      onDelete: () => ref
                          .read(subscriptionsProvider.notifier)
                          .removeSubscription(sub.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
