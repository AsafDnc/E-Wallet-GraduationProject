import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/goals_provider.dart';
import '../../subscriptions/presentation/widgets/subscriptions_goals_add_sheets.dart';
import 'widgets/goal_card_widget.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key, required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      await ref.read(goalsProvider.notifier).loadGoals();
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _onDelete(String id) async {
    try {
      await ref.read(goalsProvider.notifier).deleteGoal(id);
      if (!mounted) return;
      HapticFeedback.heavyImpact();
    } catch (_) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final goals = ref.watch(goalsProvider.select((s) => s.goals));
    final savedTotal = goals.fold<int>(0, (s, g) => s + g.savedAmount);
    final targetTotal = goals.fold<int>(0, (s, g) => s + g.targetAmount);

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBackTap,
                    icon: Icon(Icons.arrow_back, color: cs.onSurface, size: 22),
                    splashRadius: 22,
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.savingGoalsTab,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: cs.surfaceContainerHighest,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => showAddSavingGoalSheet(context),
                      child: const SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(Icons.add, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$appCurrencySymbolSpaced${_fmt(savedTotal)} ',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: '/ $appCurrencySymbolSpaced${_fmt(targetTotal)}',
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return GoalCardWidget(
                    goal: goal,
                    onPin: () =>
                        ref.read(goalsProvider.notifier).pinGoal(goal.id),
                    onUnpin: () =>
                        ref.read(goalsProvider.notifier).unpinGoal(goal.id),
                    onDelete: () => _onDelete(goal.id),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(int v) {
    final raw = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buf.write(',');
      buf.write(raw[i]);
    }
    return buf.toString();
  }
}
