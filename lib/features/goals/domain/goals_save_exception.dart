/// Thrown when [GoalsNotifier.addGoal] cannot complete; map to app strings in the UI layer.
enum GoalsSaveFailure { notConnected, notSignedIn, persistFailed }

class GoalsSaveException implements Exception {
  const GoalsSaveException(this.failure);

  final GoalsSaveFailure failure;

  @override
  String toString() => 'GoalsSaveException($failure)';
}
