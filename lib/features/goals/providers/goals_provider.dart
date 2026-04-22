import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  GoalsState build() {
    return GoalsState(
      goals: const [
        GoalModel(
          id: 'laptop',
          title: 'New Laptop',
          savedAmount: 2625,
          targetAmount: 3500,
          progress: 0.75,
          emoji: '💻',
          iconBackground: Color(0xFFA74CFF),
        ),
        GoalModel(
          id: 'car',
          title: 'New Car',
          savedAmount: 5250,
          targetAmount: 43750,
          progress: 0.12,
          emoji: '🚙',
          iconBackground: Color(0xFFFFD400),
        ),
        GoalModel(
          id: 'holiday',
          title: 'Holiday',
          savedAmount: 4280,
          targetAmount: 10000,
          progress: 0.42,
          emoji: '🏖️',
          iconBackground: Color(0xFFFF285A),
        ),
        GoalModel(
          id: 'winter_clothes',
          title: 'Winter Clothes Shopping',
          savedAmount: 1700,
          targetAmount: 2000,
          progress: 0.85,
          emoji: '🧥',
          iconBackground: Color(0xFF7BFF6A),
        ),
      ],
    );
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

  /// Clears pin and inserts after the last pinned goal (mirror of transactions unpin).
  void unpinGoal(String id) {
    final list = List<GoalModel>.from(state.goals);
    final idx = list.indexWhere((goal) => goal.id == id);
    if (idx < 0) return;
    final unpinned = list.removeAt(idx).copyWith(isPinned: false);
    final lastPinnedIdx = list.lastIndexWhere((goal) => goal.isPinned);
    list.insert(lastPinnedIdx + 1, unpinned);
    state = state.copyWith(goals: list);
  }

  void deleteGoal(String id) {
    state = state.copyWith(
      goals: state.goals.where((goal) => goal.id != id).toList(),
    );
  }

  /// Adds [amountDollars] to the goal's saved amount and recomputes [progress].
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

final goalsProvider = NotifierProvider<GoalsNotifier, GoalsState>(() {
  return GoalsNotifier();
});
