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

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBackTap,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                    splashRadius: 22,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Saving Goals',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2A2E37),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  children: const [
                    TextSpan(
                      text: '\$12,155 ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: '/ \$57,250',
                      style: TextStyle(
                        color: Color(0xFF9AA0AA),
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
