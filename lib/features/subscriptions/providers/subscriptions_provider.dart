import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client_provider.dart';
import '../../../core/network/supabase_init.dart';
import '../domain/subscription_model.dart';

class SubscriptionsNotifier extends Notifier<List<SubscriptionModel>> {
  @override
  List<SubscriptionModel> build() => const [];

  /// Loads all subscriptions for the signed-in user (RLS applies).
  Future<void> loadSubscriptions() async {
    if (!supabasePluginReady) return;
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;

    final response = await client
        .from('subscriptions')
        .select()
        .eq('user_id', user.id)
        .order('renewal_day');

    final rows = response as List<dynamic>;
    final list = rows
        .map(
          (row) => SubscriptionModel.fromJson(
            Map<String, dynamic>.from(row as Map<dynamic, dynamic>),
          ),
        )
        .toList();
    state = list;
  }

  /// Optimistic UI: appends [model] immediately, then persists. Rolls back on failure.
  Future<void> addSubscription(SubscriptionModel model) async {
    if (!supabasePluginReady) {
      throw Exception(
        'Unable to save: the app is not connected to the server yet.',
      );
    }
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to add a subscription.');
    }

    final previous = List<SubscriptionModel>.from(state);
    state = [...state, model];

    try {
      final row = <String, dynamic>{...model.toJson(), 'user_id': user.id};
      await client.from('subscriptions').insert(row);
    } catch (e) {
      state = previous;
      throw Exception(e.toString());
    }
  }

  Future<void> removeSubscription(String id) async {
    if (!supabasePluginReady) {
      state = state.where((s) => s.id != id).toList();
      return;
    }
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) {
      state = state.where((s) => s.id != id).toList();
      return;
    }

    try {
      await client
          .from('subscriptions')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
      state = state.where((s) => s.id != id).toList();
    } catch (_) {
      rethrow;
    }
  }
}

final subscriptionsProvider =
    NotifierProvider<SubscriptionsNotifier, List<SubscriptionModel>>(
      SubscriptionsNotifier.new,
    );
