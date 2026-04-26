import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/transaction.dart';

/// Source of truth for the recent-transactions list (Home + add-entry flow).
class TransactionsNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() => _buildSeed();

  static List<Transaction> _buildSeed() {
    final now = DateTime.now();
    return [
      Transaction(
        id: 'starbucks',
        title: 'Starbucks',
        amount: -5.99,
        iconData: Icons.local_cafe_rounded.codePoint,
        iconBgColor: const Color(0xFF00704A),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: 'gas_station',
        title: 'Gas Station',
        amount: -35.79,
        iconData: Icons.local_gas_station_rounded.codePoint,
        iconBgColor: const Color(0xFF3A3A3C),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: 'salary',
        title: 'Salary',
        amount: 3500.00,
        iconData: Icons.account_balance_wallet_rounded.codePoint,
        iconBgColor: const Color(0xFF27AE60),
        createdAt: DateTime(now.year, now.month, 1),
      ),
      Transaction(
        id: 'netflix',
        title: 'Netflix',
        amount: -15.99,
        iconData: Icons.tv_rounded.codePoint,
        iconBgColor: const Color(0xFFE50914),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: 'grocery',
        title: 'Grocery',
        amount: -87.20,
        iconData: Icons.shopping_cart_rounded.codePoint,
        iconBgColor: const Color(0xFF2E7D32),
        createdAt: DateTime(
          now.year,
          now.month - 1 < 1 ? 12 : now.month - 1,
          15,
        ),
      ),
    ];
  }

  void addAtTop(Transaction transaction) {
    state = [transaction, ...state];
  }

  void pinTransaction(String id) {
    final list = List<Transaction>.from(state);
    final idx = list.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    if (idx == 0) {
      list[0] = list[0].copyWith(isPinned: true);
      state = list;
      return;
    }
    final pinned = list.removeAt(idx).copyWith(isPinned: true);
    list.insert(0, pinned);
    state = list;
  }

  void unpinTransaction(String id) {
    final list = List<Transaction>.from(state);
    final idx = list.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    final unpinned = list.removeAt(idx).copyWith(isPinned: false);
    final lastPinnedIdx = list.lastIndexWhere((t) => t.isPinned);
    list.insert(lastPinnedIdx + 1, unpinned);
    state = list;
  }

  void deleteTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<Transaction>>(
      TransactionsNotifier.new,
    );
