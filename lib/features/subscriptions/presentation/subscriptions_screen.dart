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
    final items = ref.watch(subscriptionsProvider);
    final total = items.fold<double>(0, (sum, item) => sum + item.monthlyPrice);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBackTap,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                    splashRadius: 22,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Total Monthly Cost',
                        style: TextStyle(
                          color: Color(0xFF9AA0AA),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2A2E37),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _formatTotal(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 18),
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
