import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wallets/domain/models/wallet_entry_model.dart';
import '../../wallets/presentation/providers/wallet_providers.dart';

// ---------------------------------------------------------------------------
// Home state
// ---------------------------------------------------------------------------

/// Encapsulates all data displayed on the Home screen.
class HomeState {
  const HomeState({
    required this.userName,
    required this.balance,
    required this.balanceChangePercent,
    required this.isBalanceVisible,
    required this.spendingFlowData,
  });

  final String userName;
  final double balance;

  /// Percentage change displayed next to the balance badge (e.g. 5.2).
  final double balanceChangePercent;

  /// Toggles visibility of the balance amount.
  final bool isBalanceVisible;

  /// Ordered list of (month-index, amount) pairs for the chart.
  final List<(int, double)> spendingFlowData;

  HomeState copyWith({
    String? userName,
    double? balance,
    double? balanceChangePercent,
    bool? isBalanceVisible,
    List<(int, double)>? spendingFlowData,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
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
  @override
  HomeState build() {
    final initialSum = ref
        .read(walletsProvider)
        .fold<double>(0, (double s, WalletEntry w) => s + w.balance);

    ref.listen<List<WalletEntry>>(walletsProvider, (previous, next) {
      final nextSum = next.fold<double>(
        0,
        (double s, WalletEntry w) => s + w.balance,
      );
      state = state.copyWith(balance: nextSum);
    });

    return HomeState(
      userName: 'User',
      balance: initialSum,
      balanceChangePercent: 5.2,
      isBalanceVisible: true,
      spendingFlowData: const [
        (0, 200),
        (1, 350),
        (2, 420),
        (3, 310),
        (4, 500),
        (5, 680),
      ],
    );
  }

  /// Toggles the balance visibility (eye icon tap).
  void toggleBalanceVisibility() {
    state = state.copyWith(isBalanceVisible: !state.isBalanceVisible);
  }

  /// Applies a signed delta when a transaction has no linked wallet (legacy).
  void adjustBalance(double delta) {
    state = state.copyWith(balance: state.balance + delta);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});
