import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wallets/presentation/providers/wallet_providers.dart';
import 'transactions_provider.dart';

// ---------------------------------------------------------------------------
// Home state (greeting + non–wallet-derived UI only)
// ---------------------------------------------------------------------------

/// Home-specific UI state. **Total balance** comes from [calculatedBalanceProvider]
/// (sum of [walletsProvider]); keep this model free of a duplicate balance field.
class HomeState {
  const HomeState({required this.userName});

  final String userName;

  HomeState copyWith({String? userName}) {
    return HomeState(userName: userName ?? this.userName);
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState(userName: 'User');
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

/// Net worth / total cash: sum of all [walletsProvider] rows (same as My Wallets).
///
/// Consumed by the home header so the top balance always matches **My Wallets**
/// and any updates from the add-entry flow or wallet edits.
// calculatedBalanceProvider lives in wallet_providers.dart

/// Approximate “vs total balance” percent for the home badge, derived from
/// **this calendar month’s** net cashflow in [transactionsProvider] so it moves
/// with Recent Transactions.
final homeNetChangePercentProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final txs = ref.watch(transactionsProvider);
  var monthNet = 0.0;
  for (final t in txs) {
    if (t.createdAt.year == now.year && t.createdAt.month == now.month) {
      monthNet += t.amount;
    }
  }
  final total = ref.watch(calculatedBalanceProvider);
  if (total.abs() < 0.01) {
    return 0.0;
  }
  return (monthNet / total.abs() * 100).clamp(-999.0, 999.0);
});

/// Derives monthly expense totals from [transactionsProvider].
///
/// Seeds with 6 months of historical mock data and overlays real transactions.
/// The result is a sorted list of (monthIndex 0–11, totalAmount) tuples
/// consumed directly by [SpendingChartWidget].
final spendingChartDataProvider = Provider<List<(int, double)>>((ref) {
  final transactions = ref.watch(transactionsProvider);

  // Historical mock baseline (month 0–5 = Jan–Jun).
  final monthly = <int, double>{0: 200, 1: 350, 2: 420, 3: 310, 4: 500, 5: 680};

  // Overlay real expense transactions grouped by month.
  for (final tx in transactions) {
    if (tx.amount < 0) {
      final idx = tx.createdAt.month - 1;
      monthly[idx] = (monthly[idx] ?? 0) + tx.amount.abs();
    }
  }

  final sorted = monthly.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return sorted.map((e) => (e.key, e.value)).toList();
});
