import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wallets/domain/models/wallet_entry_model.dart';
import '../../wallets/presentation/providers/wallet_providers.dart';

// ---------------------------------------------------------------------------
// Home state
// ---------------------------------------------------------------------------

/// Encapsulates all data displayed on the Home screen.
class HomeState {
  const HomeState({
    required this.balance,
    required this.balanceChangePercent,
    required this.isBalanceVisible,
    required this.spendingFlowData,
  });

  final double balance;

  /// Percentage change displayed next to the balance badge (e.g. 5.2).
  final double balanceChangePercent;

  /// Toggles visibility of the balance amount.
  final bool isBalanceVisible;

  /// Ordered list of (month-index, amount) pairs for the chart.
  final List<(int, double)> spendingFlowData;

  HomeState copyWith({
    double? balance,
    double? balanceChangePercent,
    bool? isBalanceVisible,
    List<(int, double)>? spendingFlowData,
  }) {
    return HomeState(
      balance: balance ?? this.balance,
      balanceChangePercent: balanceChangePercent ?? this.balanceChangePercent,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
      spendingFlowData: spendingFlowData ?? this.spendingFlowData,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class HomeNotifier extends Notifier<HomeState> {
  static const List<(int, double)> _defaultSpending = [
    (0, 200),
    (1, 350),
    (2, 420),
    (3, 310),
    (4, 500),
    (5, 680),
  ];

  /// Off–ledger adjustments (e.g. transactions without a linked wallet).
  double _unlinkedLedger = 0;

  bool _isBalanceVisible = true;

  @override
  HomeState build() {
    final wallets = ref.watch(walletsProvider);
    final mode = ref.watch(balanceViewModeProvider);
    final walletTotal = _sumForViewMode(wallets, mode);
    final displayBalance = walletTotal + _unlinkedLedger;

    return HomeState(
      balance: displayBalance,
      balanceChangePercent: 5.2,
      isBalanceVisible: _isBalanceVisible,
      spendingFlowData: _defaultSpending,
    );
  }

  double _sumForViewMode(List<WalletEntry> wallets, BalanceViewMode mode) {
    switch (mode) {
      case BalanceViewMode.netWorth:
        return wallets.fold<double>(
          0,
          (double s, WalletEntry w) => s + w.balance,
        );
      case BalanceViewMode.totalCash:
        return wallets
            .where((WalletEntry w) => w.balance > 0)
            .fold<double>(0, (double s, WalletEntry w) => s + w.balance);
    }
  }

  /// Toggles the balance visibility (eye icon tap).
  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    final wallets = ref.read(walletsProvider);
    final mode = ref.read(balanceViewModeProvider);
    final current = state;
    state = HomeState(
      balance: _sumForViewMode(wallets, mode) + _unlinkedLedger,
      balanceChangePercent: current.balanceChangePercent,
      isBalanceVisible: _isBalanceVisible,
      spendingFlowData: current.spendingFlowData,
    );
  }

  /// Applies a signed delta when a transaction has no linked wallet (legacy).
  void adjustBalance(double delta) {
    _unlinkedLedger += delta;
    final wallets = ref.read(walletsProvider);
    final mode = ref.read(balanceViewModeProvider);
    final current = state;
    state = HomeState(
      balance: _sumForViewMode(wallets, mode) + _unlinkedLedger,
      balanceChangePercent: current.balanceChangePercent,
      isBalanceVisible: current.isBalanceVisible,
      spendingFlowData: current.spendingFlowData,
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});
