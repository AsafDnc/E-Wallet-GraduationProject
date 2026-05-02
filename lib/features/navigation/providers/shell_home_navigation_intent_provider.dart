import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subscriptions/domain/subscriptions_goals_tab.dart';

/// One-shot intent: switch shell bottom index (e.g. open unified subs from Home).
class ShellHomeNavigationIntent {
  const ShellHomeNavigationIntent({
    required this.bottomNavIndex,
    this.unifiedInitialTab = SubscriptionsGoalsTab.subscriptions,
  });

  final int bottomNavIndex;
  final SubscriptionsGoalsTab unifiedInitialTab;
}

class ShellHomeNavigationIntentNotifier
    extends Notifier<ShellHomeNavigationIntent?> {
  @override
  ShellHomeNavigationIntent? build() => null;

  /// Opens shell tab 3 with the Subscriptions segment selected.
  void openUnifiedSubscriptionsFromHome() {
    state = const ShellHomeNavigationIntent(
      bottomNavIndex: 3,
      unifiedInitialTab: SubscriptionsGoalsTab.subscriptions,
    );
  }

  void clear() {
    state = null;
  }
}

final shellHomeNavigationIntentProvider =
    NotifierProvider<
      ShellHomeNavigationIntentNotifier,
      ShellHomeNavigationIntent?
    >(ShellHomeNavigationIntentNotifier.new);
