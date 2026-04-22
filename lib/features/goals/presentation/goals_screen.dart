import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/goal_model.dart';
import '../providers/goals_provider.dart';
import 'widgets/goal_card_widget.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key, required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final _listKey = GlobalKey<AnimatedListState>();

  void _onPin(String id) {
    final notifier = ref.read(goalsProvider.notifier);
    final before = List<GoalModel>.from(ref.read(goalsProvider).goals);
    final fromIdx = before.indexWhere((goal) => goal.id == id);
    if (fromIdx < 0) return;

    // Top item can still become pinned; no re-order animation needed.
    if (fromIdx == 0) {
      notifier.pinGoal(id);
      return;
    }

    _listKey.currentState?.removeItem(
      fromIdx,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: GoalCardWidget(
            goal: before[fromIdx],
            onPin: () {},
            onUnpin: () {},
            onDelete: () {},
          ),
        ),
      ),
      duration: const Duration(milliseconds: 280),
    );

    notifier.pinGoal(id);

    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 400),
      );
    });
  }

  void _onUnpin(String id) {
    final notifier = ref.read(goalsProvider.notifier);
    final before = List<GoalModel>.from(ref.read(goalsProvider).goals);
    final fromIdx = before.indexWhere((goal) => goal.id == id);
    if (fromIdx < 0) return;

    _listKey.currentState?.removeItem(
      fromIdx,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: GoalCardWidget(
            goal: before[fromIdx],
            onPin: () {},
            onUnpin: () {},
            onDelete: () {},
          ),
        ),
      ),
      duration: const Duration(milliseconds: 280),
    );

    notifier.unpinGoal(id);

    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      final next = ref.read(goalsProvider).goals;
      final newIdx = next.indexWhere((goal) => goal.id == id);
      if (newIdx >= 0) {
        _listKey.currentState?.insertItem(
          newIdx,
          duration: const Duration(milliseconds: 400),
        );
      }
    });
  }

  void _onDelete(String id) {
    final notifier = ref.read(goalsProvider.notifier);
    final before = List<GoalModel>.from(ref.read(goalsProvider).goals);
    final idx = before.indexWhere((goal) => goal.id == id);
    if (idx < 0) return;

    _listKey.currentState?.removeItem(
      idx,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: GoalCardWidget(
            goal: before[idx],
            onPin: () {},
            onUnpin: () {},
            onDelete: () {},
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );

    notifier.deleteGoal(id);
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider.select((s) => s.goals));

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
          child: Column(
            children: [
              // ── Shared header layout (mirrors SubscriptionsScreen) ───────
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBackTap,
                    icon: Icon(Icons.arrow_back, color: cs.onSurface, size: 22),
                    splashRadius: 22,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Saving Goals',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surfaceContainerHighest,
                    ),
                    child: Icon(Icons.add, color: cs.onSurface, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // ── Totals row: centered, compact (saved vs target) ───────────
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '\$12,155 ',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: '/ \$57,250',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 18),
              AnimatedList(
                key: _listKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: goals.length,
                itemBuilder: (context, index, animation) {
                  if (index >= goals.length) return const SizedBox.shrink();
                  final goal = goals[index];
                  return SizeTransition(
                    sizeFactor: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: GoalCardWidget(
                        goal: goal,
                        onPin: () => _onPin(goal.id),
                        onUnpin: () => _onUnpin(goal.id),
                        onDelete: () => _onDelete(goal.id),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
