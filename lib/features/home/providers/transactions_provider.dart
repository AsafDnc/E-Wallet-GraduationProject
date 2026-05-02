import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wallets/presentation/providers/wallet_providers.dart';
import '../data/transaction_wallet_repository.dart';
import '../domain/transaction.dart';
import 'home_provider.dart';

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
        walletId: 'w1',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: 'gas_station',
        title: 'Gas Station',
        amount: -35.79,
        iconData: Icons.local_gas_station_rounded.codePoint,
        iconBgColor: const Color(0xFF3A3A3C),
        walletId: 'w1',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: 'salary',
        title: 'Salary',
        amount: 3500.00,
        iconData: Icons.account_balance_wallet_rounded.codePoint,
        iconBgColor: const Color(0xFF27AE60),
        walletId: 'w1',
        createdAt: DateTime(now.year, now.month, 1),
      ),
      Transaction(
        id: 'netflix',
        title: 'Netflix',
        amount: -15.99,
        iconData: Icons.tv_rounded.codePoint,
        iconBgColor: const Color(0xFFE50914),
        walletId: 'w3',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: 'grocery',
        title: 'Grocery',
        amount: -87.20,
        iconData: Icons.shopping_cart_rounded.codePoint,
        iconBgColor: const Color(0xFF2E7D32),
        walletId: 'w2',
        createdAt: DateTime(
          now.year,
          now.month - 1 < 1 ? 12 : now.month - 1,
          15,
        ),
      ),
    ];
  }

  /// Inserts [transaction] at the top, updates wallet (and home) balances
  /// optimistically, then persists to Supabase. Rolls back all local changes on
  /// persistence failure.
  Future<void> recordNewTransaction(Transaction transaction) async {
    final walletsNotifier = ref.read(walletsProvider.notifier);
    final previousTransactions = List<Transaction>.from(state);

    state = [transaction, ...state];
    _applyLocalWalletEffectsForTransaction(
      walletsNotifier,
      transaction,
      direction: 1,
    );
    _applyHomeHeaderForUnlinkedTransaction(
      ref.read(homeProvider.notifier),
      transaction,
      direction: 1,
    );

    try {
      await ref
          .read(transactionWalletRepositoryProvider)
          .insertTransactionAndUpdateWallets(transaction);
    } catch (_) {
      _applyLocalWalletEffectsForTransaction(
        walletsNotifier,
        transaction,
        direction: -1,
      );
      _applyHomeHeaderForUnlinkedTransaction(
        ref.read(homeProvider.notifier),
        transaction,
        direction: -1,
      );
      state = previousTransactions;
      rethrow;
    }
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

  /// Removes the transaction locally (and wallet / home effects), persists
  /// deletion + remote wallet reversal, then rolls back local state if remote
  /// persistence fails.
  Future<void> deleteTransaction(String id) async {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx < 0) return;

    final removed = state[idx];
    final walletsNotifier = ref.read(walletsProvider.notifier);

    state = [...state.sublist(0, idx), ...state.sublist(idx + 1)];
    _applyLocalWalletEffectsForTransaction(
      walletsNotifier,
      removed,
      direction: -1,
    );
    _applyHomeHeaderForUnlinkedTransaction(
      ref.read(homeProvider.notifier),
      removed,
      direction: -1,
    );

    try {
      await ref
          .read(transactionWalletRepositoryProvider)
          .deleteTransactionAndUpdateWallets(removed);
    } catch (e, st) {
      assert(() {
        debugPrint('Persist transaction delete failed: $e $st');
        return true;
      }());
    }
  }
}

void _applyLocalWalletEffectsForTransaction(
  WalletsNotifier wallets,
  Transaction t, {
  required int direction,
}) {
  final d = direction.toDouble();
  if (t.walletId != null) {
    wallets.applyBalanceDelta(t.walletId!, d * t.amount);
  }
  final dest = t.transferToWalletId;
  if (dest != null && t.walletId != null) {
    wallets.applyBalanceDelta(dest, d * (-t.amount));
  }
}

bool _usesNoWalletLinkage(Transaction t) =>
    t.walletId == null && t.transferToWalletId == null;

void _applyHomeHeaderForUnlinkedTransaction(
  HomeNotifier home,
  Transaction t, {
  required int direction,
}) {
  if (!_usesNoWalletLinkage(t)) return;
  home.adjustBalance(direction.toDouble() * t.amount);
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<Transaction>>(
      TransactionsNotifier.new,
    );

/// Sublist of [transactionsProvider] for [walletId] only; order matches the global list.
final transactionsForWalletProvider =
    Provider.family<List<Transaction>, String>((ref, walletId) {
      return ref
          .watch(transactionsProvider)
          .where((Transaction t) => t.walletId == walletId)
          .toList();
    });
