import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'transactions_provider.dart';

/// Monthly expense totals for [SpendingChartWidget] (mock baseline + live txs).
final spendingChartDataProvider = Provider<List<(int, double)>>((ref) {
  final transactions = ref.watch(transactionsProvider);

  final monthly = <int, double>{0: 200, 1: 350, 2: 420, 3: 310, 4: 500, 5: 680};

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
