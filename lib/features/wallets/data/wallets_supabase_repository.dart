import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client_provider.dart';
import '../../../core/network/supabase_init.dart';
import '../domain/models/wallet_entry_model.dart';

final walletsSupabaseRepositoryProvider = Provider<WalletsSupabaseRepository>((
  ref,
) {
  return WalletsSupabaseRepository(ref.watch(supabaseClientProvider));
});

/// Supabase persistence for user wallets (`wallets` table).
class WalletsSupabaseRepository {
  WalletsSupabaseRepository(this._client);

  final SupabaseClient _client;

  bool get _canUseRemote => supabasePluginReady;

  String? get _userId {
    try {
      return _client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  String _typeColumnValue(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return 'cash';
      case WalletType.bank:
        return 'bank';
      case WalletType.creditCard:
        return 'credit_card';
    }
  }

  /// Updates name, balance, type, presentation fields, and default flag.
  Future<void> updateWallet(WalletEntry wallet) async {
    if (!_canUseRemote) {
      debugPrint(
        'WalletsSupabaseRepository.updateWallet: Supabase not initialized.',
      );
      return;
    }
    final userId = _userId;
    if (userId == null) {
      debugPrint('WalletsSupabaseRepository.updateWallet: no signed-in user.');
      return;
    }

    try {
      await _client
          .from('wallets')
          .update(<String, dynamic>{
            'name': wallet.name,
            'balance': wallet.balance,
            'type': _typeColumnValue(wallet.type),
            'color': wallet.color,
            'icon_code': wallet.iconCode,
            'is_default': wallet.isDefault,
          })
          .eq('id', wallet.id)
          .eq('user_id', userId);
    } catch (e, st) {
      debugPrint('WalletsSupabaseRepository.updateWallet failed: $e\n$st');
      rethrow;
    }
  }

  /// Deletes a wallet row owned by the current user.
  Future<void> deleteWallet(String walletId) async {
    if (!_canUseRemote) {
      debugPrint(
        'WalletsSupabaseRepository.deleteWallet: Supabase not initialized.',
      );
      return;
    }
    final userId = _userId;
    if (userId == null) {
      debugPrint('WalletsSupabaseRepository.deleteWallet: no signed-in user.');
      return;
    }

    try {
      await _client
          .from('wallets')
          .delete()
          .eq('id', walletId)
          .eq('user_id', userId);
    } catch (e, st) {
      debugPrint('WalletsSupabaseRepository.deleteWallet failed: $e\n$st');
      rethrow;
    }
  }

  /// Clears default on all wallets for the user, then sets [walletId] default.
  Future<void> setDefaultWallet(String walletId) async {
    if (!_canUseRemote) {
      debugPrint(
        'WalletsSupabaseRepository.setDefaultWallet: Supabase not initialized.',
      );
      return;
    }
    final userId = _userId;
    if (userId == null) {
      debugPrint(
        'WalletsSupabaseRepository.setDefaultWallet: no signed-in user.',
      );
      return;
    }

    try {
      await _client
          .from('wallets')
          .update(<String, dynamic>{'is_default': false})
          .eq('user_id', userId);

      await _client
          .from('wallets')
          .update(<String, dynamic>{'is_default': true})
          .eq('id', walletId)
          .eq('user_id', userId);
    } catch (e, st) {
      debugPrint('WalletsSupabaseRepository.setDefaultWallet failed: $e\n$st');
      rethrow;
    }
  }
}
