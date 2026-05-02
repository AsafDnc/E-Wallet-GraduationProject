import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client_provider.dart';
import '../../../core/network/supabase_init.dart';
import '../domain/transaction.dart';

final transactionWalletRepositoryProvider =
    Provider<TransactionWalletRepository>((ref) {
      return TransactionWalletRepository(ref.watch(supabaseClientProvider));
    });

/// Persists transactions and keeps `wallets.balance` aligned in Supabase.
class TransactionWalletRepository {
  TransactionWalletRepository(this._client);

  final SupabaseClient _client;

  /// Inserts the transaction row, then updates affected wallet balances.
  ///
  /// When Supabase is unavailable or the user is not signed in, returns
  /// without throwing so [TransactionsNotifier] can keep optimistic local UI.
  ///
  /// Remote insert / balance failures are logged but do not roll back local
  /// state (avoids "cannot add transaction" when mock wallet IDs or schema
  /// mismatch remote `wallets` rows).
  Future<void> insertTransactionAndUpdateWallets(Transaction tx) async {
    if (!supabasePluginReady) {
      debugPrint(
        'TransactionWalletRepository.insertTransactionAndUpdateWallets: '
        'Supabase not initialized — keeping local transaction only.',
      );
      return;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint(
        'TransactionWalletRepository.insertTransactionAndUpdateWallets: '
        'no authenticated user — keeping local transaction only.',
      );
      return;
    }

    final model = tx.toTransactionModel();
    if (model == null) {
      debugPrint(
        'TransactionWalletRepository.insertTransactionAndUpdateWallets: '
        'missing wallet_id on transaction id=${tx.id}.',
      );
      throw StateError(
        'Transaction requires a valid wallet_id for persistence.',
      );
    }

    try {
      final row = <String, dynamic>{...model.toJson(), 'user_id': user.id};
      await _client.from('transactions').insert(row);
    } catch (e, st) {
      debugPrint(
        'TransactionWalletRepository: remote insert failed '
        '(local list already updated): $e\n$st',
      );
      return;
    }

    try {
      await _applySignedBalanceDeltaRemote(user.id, tx.walletId!, tx.amount);
      final dest = tx.transferToWalletId;
      if (dest != null) {
        await _applySignedBalanceDeltaRemote(user.id, dest, -tx.amount);
      }
    } catch (e, st) {
      debugPrint(
        'TransactionWalletRepository: remote wallet balance update failed '
        '(transaction row may still exist on server): $e\n$st',
      );
    }
  }

  /// Reverses wallet balances, then deletes the transaction row.
  Future<void> deleteTransactionAndUpdateWallets(Transaction tx) async {
    if (!supabasePluginReady) {
      debugPrint(
        'TransactionWalletRepository.deleteTransactionAndUpdateWallets: '
        'Supabase not initialized.',
      );
      return;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint(
        'TransactionWalletRepository.deleteTransactionAndUpdateWallets: '
        'no authenticated user.',
      );
      return;
    }

    final model = tx.toTransactionModel();
    if (model == null) {
      await _client
          .from('transactions')
          .delete()
          .eq('id', tx.id)
          .eq('user_id', user.id);
      return;
    }

    try {
      await _applySignedBalanceDeltaRemote(user.id, tx.walletId!, -tx.amount);
      final dest = tx.transferToWalletId;
      if (dest != null) {
        await _applySignedBalanceDeltaRemote(user.id, dest, tx.amount);
      }
      await _client
          .from('transactions')
          .delete()
          .eq('id', tx.id)
          .eq('user_id', user.id);
    } catch (e, st) {
      debugPrint('deleteTransactionAndUpdateWallets failed: $e $st');
      rethrow;
    }
  }

  Future<void> _applySignedBalanceDeltaRemote(
    String userId,
    String walletId,
    double signedDelta,
  ) async {
    final row = await _client
        .from('wallets')
        .select('balance')
        .eq('id', walletId)
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) {
      debugPrint(
        'TransactionWalletRepository: wallet id=$walletId not found '
        'for user_id=$userId — skipping remote balance delta.',
      );
      return;
    }

    final current = (row['balance'] as num).toDouble();
    final next = current + signedDelta;

    await _client
        .from('wallets')
        .update(<String, dynamic>{'balance': next})
        .eq('id', walletId)
        .eq('user_id', userId);
  }
}
