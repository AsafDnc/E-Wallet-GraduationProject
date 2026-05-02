import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client_provider.dart';
import '../../../core/network/supabase_init.dart';
import '../domain/goal_model.dart';

class GoalsState {
  const GoalsState({required this.goals});

  final List<GoalModel> goals;

  GoalsState copyWith({List<GoalModel>? goals}) {
    return GoalsState(goals: goals ?? this.goals);
  }
}

class GoalsNotifier extends Notifier<GoalsState> {
  @override
  GoalsState build() => const GoalsState(goals: []);

  /// Loads all saving goals for the signed-in user (RLS applies).
  Future<void> loadGoals() async {
    if (!supabasePluginReady) return;
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;

    final response = await client
        .from('saving_goals')
        .select()
        .eq('user_id', user.id)
        .order('created_at');

    final rows = response as List<dynamic>;
    final list = rows
        .map(
          (row) => GoalModel.fromJson(
            Map<String, dynamic>.from(row as Map<dynamic, dynamic>),
          ),
        )
        .toList();
    state = GoalsState(goals: list);
  }

  /// Optimistic UI: appends [model] immediately, then persists. Rolls back on failure.
  Future<void> addGoal(GoalModel model) async {
    if (!supabasePluginReady) {
      throw Exception(
        'Unable to save: the app is not connected to the server yet.',
      );
    }
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to add a saving goal.');
    }

    final previous = GoalsState(goals: List<GoalModel>.from(state.goals));
    state = GoalsState(goals: [...state.goals, model]);

    try {
      final row = <String, dynamic>{...model.toJson(), 'user_id': user.id};
      await client.from('saving_goals').insert(row);
    } catch (e) {
      state = previous;
      throw Exception(e.toString());
    }
  }

  void pinGoal(String id) {
    final list = List<GoalModel>.from(state.goals);
    final idx = list.indexWhere((goal) => goal.id == id);
    if (idx < 0) return;
    if (idx == 0) {
      list[0] = list[0].copyWith(isPinned: true);
      state = state.copyWith(goals: list);
      return;
    }
    final pinned = list.removeAt(idx).copyWith(isPinned: true);
    list.insert(0, pinned);
    state = state.copyWith(goals: list);
  }

  void unpinGoal(String id) {
    final list = List<GoalModel>.from(state.goals);
    final idx = list.indexWhere((goal) => goal.id == id);
    if (idx < 0) return;
    final unpinned = list.removeAt(idx).copyWith(isPinned: false);
    final lastPinnedIdx = list.lastIndexWhere((goal) => goal.isPinned);
    list.insert(lastPinnedIdx + 1, unpinned);
    state = state.copyWith(goals: list);
  }

  Future<void> deleteGoal(String id) async {
    if (!supabasePluginReady) {
      state = state.copyWith(
        goals: state.goals.where((goal) => goal.id != id).toList(),
      );
      return;
    }
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) {
      state = state.copyWith(
        goals: state.goals.where((goal) => goal.id != id).toList(),
      );
      return;
    }

    try {
      await client
          .from('saving_goals')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
      state = state.copyWith(
        goals: state.goals.where((goal) => goal.id != id).toList(),
      );
    } catch (_) {
      rethrow;
    }
  }

  void contributeToGoal(String goalId, double amountDollars) {
    if (amountDollars <= 0) return;
    final addWhole = amountDollars.round();
    if (addWhole <= 0) return;

    final list = List<GoalModel>.from(state.goals);
    final i = list.indexWhere((goal) => goal.id == goalId);
    if (i < 0) return;

    final goal = list[i];
    final newSaved = goal.savedAmount + addWhole;
    final ratio = goal.targetAmount > 0
        ? (newSaved / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    list[i] = goal.copyWith(savedAmount: newSaved, progress: ratio);
    state = state.copyWith(goals: list);
  }
}

final goalsProvider = NotifierProvider<GoalsNotifier, GoalsState>(
  GoalsNotifier.new,
);
