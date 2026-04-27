import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../goals/presentation/widgets/goal_card_widget.dart';
import '../../goals/providers/goals_provider.dart';
import '../domain/subscriptions_goals_tab.dart';
import '../providers/subscriptions_provider.dart';
import 'widgets/subscription_card_widget.dart';
import 'widgets/subscriptions_goals_add_sheets.dart';

extension _SubscriptionsGoalsTabX on SubscriptionsGoalsTab {
  String get label {
    switch (this) {
      case SubscriptionsGoalsTab.subscriptions:
        return 'Subscriptions';
      case SubscriptionsGoalsTab.goals:
        return 'Saving Goals';
    }
  }

  String get sectionTitle {
    switch (this) {
      case SubscriptionsGoalsTab.subscriptions:
        return 'Total Monthly Cost';
      case SubscriptionsGoalsTab.goals:
        return 'Saving Goals Cost';
    }
  }
}

// ─── Root screen ──────────────────────────────────────────────────────────────

class SubscriptionsGoalsScreen extends ConsumerStatefulWidget {
  const SubscriptionsGoalsScreen({
    super.key,
    this.initialTab = SubscriptionsGoalsTab.subscriptions,
  });

  final SubscriptionsGoalsTab initialTab;

  @override
  ConsumerState<SubscriptionsGoalsScreen> createState() =>
      _SubscriptionsGoalsScreenState();
}

class _SubscriptionsGoalsScreenState
    extends ConsumerState<SubscriptionsGoalsScreen> {
  late SubscriptionsGoalsTab _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void didUpdateWidget(SubscriptionsGoalsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() => _tab = widget.initialTab);
    }
  }

  void _switchTab(SubscriptionsGoalsTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildAmountSection(),
            const SizedBox(height: 18),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: _SlidingSegmentControl(tab: _tab, onChanged: _switchTab),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
            child: child,
          ),
          child: Text(
            _tab.sectionTitle,
            key: ValueKey(_tab.sectionTitle),
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
              child: child,
            ),
            child: _tab == SubscriptionsGoalsTab.subscriptions
                ? _SubsTotal(key: const ValueKey('sub_total'))
                : _GoalsTotal(key: const ValueKey('goal_total')),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      ),
      child: _tab == SubscriptionsGoalsTab.subscriptions
          ? _SubscriptionsList(
              key: const ValueKey('subs'),
              onAddTap: () => showAddSubscriptionSheet(context),
            )
          : _GoalsList(
              key: const ValueKey('goals'),
              onAddTap: () => showAddSavingGoalSheet(context),
            ),
    );
  }
}

// ─── Sliding segment control ──────────────────────────────────────────────────

class _SlidingSegmentControl extends StatelessWidget {
  const _SlidingSegmentControl({required this.tab, required this.onChanged});

  final SubscriptionsGoalsTab tab;
  final void Function(SubscriptionsGoalsTab) onChanged;

  static const _pillColor = Color(0xFF1E2330);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tabs = SubscriptionsGoalsTab.values;

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segW = constraints.maxWidth / tabs.length;

          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                left: segW * tabs.indexOf(tab),
                top: 0,
                bottom: 0,
                width: segW,
                child: Container(
                  decoration: BoxDecoration(
                    color: _pillColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: tabs
                    .map(
                      (t) => Expanded(
                        child: _SegTab(
                          label: t.label,
                          selected: t == tab,
                          selectedColor: Colors.white,
                          unselectedColor: cs.onSurfaceVariant,
                          onTap: () => onChanged(t),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegTab extends StatelessWidget {
  const _SegTab({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            color: selected ? selectedColor : unselectedColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 16,
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

// ─── Soft “+” footer button ───────────────────────────────────────────────────

class _ListSoftAddButton extends StatelessWidget {
  const _ListSoftAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade300
        : cs.outlineVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 120),
      child: Center(
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(56, 56),
            maximumSize: const Size(56, 56),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: cs.onSurface.withValues(alpha: 0.04),
            foregroundColor: cs.onSurface.withValues(alpha: 0.55),
            side: BorderSide(color: borderColor, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }
}

// ─── Amount widgets ───────────────────────────────────────────────────────────

class _SubsTotal extends ConsumerWidget {
  const _SubsTotal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(subscriptionsProvider);
    final total = items.fold<double>(0, (s, e) => s + e.monthlyPrice);
    final cs = Theme.of(context).colorScheme;

    return Align(
      child: Text(
        '\$${total.toStringAsFixed(2)}',
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -0.8,
        ),
      ),
    );
  }
}

class _GoalsTotal extends ConsumerWidget {
  const _GoalsTotal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider.select((s) => s.goals));
    final saved = goals.fold<int>(0, (s, g) => s + g.savedAmount);
    final target = goals.fold<int>(0, (s, g) => s + g.targetAmount);
    final cs = Theme.of(context).colorScheme;

    return Align(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '\$${_fmt(saved)} ',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 36,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -0.8,
              ),
            ),
            TextSpan(
              text: '/ \$${_fmt(target)}',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 17,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
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

// ─── Subscriptions list ───────────────────────────────────────────────────────

class _SubscriptionsList extends ConsumerWidget {
  const _SubscriptionsList({super.key, required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawItems = ref.watch(subscriptionsProvider);
    final items = [...rawItems]
      ..sort((a, b) => a.daysUntilRenewal.compareTo(b.daysUntilRenewal));

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        itemCount: items.length + 1,
        itemBuilder: (_, index) {
          if (index == items.length) {
            return _ListSoftAddButton(onPressed: onAddTap);
          }
          final sub = items[index];
          return SubscriptionCardWidget(
            subscription: sub,
            onDelete: () => ref
                .read(subscriptionsProvider.notifier)
                .removeSubscription(sub.id),
          );
        },
      ),
    );
  }
}

// ─── Goals list ───────────────────────────────────────────────────────────────

class _GoalsList extends ConsumerWidget {
  const _GoalsList({super.key, required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider.select((s) => s.goals));

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        itemCount: goals.length + 1,
        itemBuilder: (_, index) {
          if (index == goals.length) {
            return _ListSoftAddButton(onPressed: onAddTap);
          }
          final goal = goals[index];
          return GoalCardWidget(
            goal: goal,
            onPin: () => ref.read(goalsProvider.notifier).pinGoal(goal.id),
            onUnpin: () => ref.read(goalsProvider.notifier).unpinGoal(goal.id),
            onDelete: () =>
                ref.read(goalsProvider.notifier).deleteGoal(goal.id),
          );
        },
      ),
    );
  }
}
