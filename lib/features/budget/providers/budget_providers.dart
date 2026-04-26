import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/home/providers/transactions_provider.dart';
import '../domain/budget_settings.dart';

// ─── Settings notifier ────────────────────────────────────────────────────────

class BudgetSettingsNotifier extends Notifier<BudgetSettings> {
  @override
  BudgetSettings build() => const BudgetSettings();

  void setLimit(double limit) {
    if (limit <= 0) return;
    state = state.copyWith(monthlyLimit: limit);
  }

  void setAlertEnabled(bool enabled) =>
      state = state.copyWith(isAlertEnabled: enabled);

  void setThreshold(double threshold) =>
      state = state.copyWith(alertThreshold: threshold);
}

final budgetSettingsProvider =
    NotifierProvider<BudgetSettingsNotifier, BudgetSettings>(
      BudgetSettingsNotifier.new,
    );

// ─── Derived: current-month expense total ─────────────────────────────────────

final currentMonthSpendingProvider = Provider<double>((ref) {
  final txns = ref.watch(transactionsProvider);
  final now = DateTime.now();
  return txns
      .where(
        (t) =>
            t.amount < 0 &&
            t.createdAt.year == now.year &&
            t.createdAt.month == now.month,
      )
      .fold(0.0, (sum, t) => sum + t.amount.abs());
});

// ─── Derived: progress ratio (0.0 – 1.0+) ────────────────────────────────────

final budgetProgressProvider = Provider<double>((ref) {
  final settings = ref.watch(budgetSettingsProvider);
  final spent = ref.watch(currentMonthSpendingProvider);
  if (settings.monthlyLimit <= 0) return 0;
  return spent / settings.monthlyLimit;
});

// ─── Helper: should alert fire given a potential new expense? ─────────────────

final budgetAlertForAmountProvider = Provider.family<bool, double>((
  ref,
  newAmount,
) {
  final settings = ref.watch(budgetSettingsProvider);
  if (!settings.isAlertEnabled) return false;
  final spent = ref.watch(currentMonthSpendingProvider);
  return (spent + newAmount) >=
      (settings.monthlyLimit * settings.alertThreshold);
});
