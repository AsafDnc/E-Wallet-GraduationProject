import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/transaction.dart';

/// Source of truth for the recent-transactions list (Home + add-entry flow).
class TransactionsNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() => List<Transaction>.from(_seed);

  static final List<Transaction> _seed = [
    Transaction(
      id: 'starbucks',
      title: 'Starbucks',
      amount: -5.99,
      iconData: Icons.local_cafe_rounded.codePoint,
      iconBgColor: const Color(0xFF00704A),
    ),
    Transaction(
      id: 'gas_station',
      title: 'Gas Station',
      amount: -35.79,
      iconData: Icons.local_gas_station_rounded.codePoint,
      iconBgColor: const Color(0xFF3A3A3C),
    ),
  ];

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
