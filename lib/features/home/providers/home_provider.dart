import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  HomeState build() => _mockState();

  /// Toggles the balance visibility (eye icon tap).
  void toggleBalanceVisibility() {
    state = state.copyWith(isBalanceVisible: !state.isBalanceVisible);
  }

  /// Applies a signed delta to the wallet balance (expense negative, income positive).
  void adjustBalance(double delta) {
    state = state.copyWith(balance: state.balance + delta);
  }

  // Stub: replace with real Supabase fetch in the data layer.
  HomeState _mockState() {
    return const HomeState(
      userName: 'User',
      balance: 4723,
      balanceChangePercent: 5.2,
      isBalanceVisible: true,
      spendingFlowData: [
        (0, 200),
        (1, 350),
        (2, 420),
        (3, 310),
        (4, 500),
        (5, 680),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});
