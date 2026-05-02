import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../goals/domain/goal_model.dart';
import '../../goals/presentation/widgets/goal_card_widget.dart';
import '../../goals/providers/goals_provider.dart';
import '../domain/subscriptions_goals_tab.dart';
import '../providers/subscriptions_provider.dart';
import 'widgets/subscription_card_widget.dart';

// ─── Tab enum ─────────────────────────────────────────────────────────────────

enum ScreenTab { subscriptions, goals }

extension _ScreenTabX on ScreenTab {
  String get label {
    switch (this) {
      case ScreenTab.subscriptions:
        return 'Subscriptions';
      case ScreenTab.goals:
        return 'Saving Goals';
    }
  }

  String get sectionTitle {
    switch (this) {
      case ScreenTab.subscriptions:
        return 'Total Monthly Cost';
      case ScreenTab.goals:
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
  late ScreenTab _tab;

  static ScreenTab _toScreenTab(SubscriptionsGoalsTab t) {
    switch (t) {
      case SubscriptionsGoalsTab.subscriptions:
        return ScreenTab.subscriptions;
      case SubscriptionsGoalsTab.goals:
        return ScreenTab.goals;
    }
  }

  @override
  void initState() {
    super.initState();
    _tab = _toScreenTab(widget.initialTab);
  }

  @override
  void didUpdateWidget(SubscriptionsGoalsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() => _tab = _toScreenTab(widget.initialTab));
    }
  }

  void _switchTab(ScreenTab tab) {
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
            const SizedBox(height: 20),
            _buildAmountSection(),
            const SizedBox(height: 18),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ─── Header: centered segment control, no "+" button ──────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: _SlidingSegmentControl(tab: _tab, onChanged: _switchTab),
    );
  }

  // ─── Amount section: title label + animated large amount ──────────────────

  Widget _buildAmountSection() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Dynamic section title
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
              color: cs.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Fixed-height container keeps position static; only value fades
        SizedBox(
          height: 48,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
              child: child,
            ),
            child: _tab == ScreenTab.subscriptions
                ? _SubsTotal(key: const ValueKey('sub_total'))
                : _GoalsTotal(key: const ValueKey('goal_total')),
          ),
        ),
      ],
    );
  }

  // ─── Body: animated list switcher ─────────────────────────────────────────

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      ),
      child: _tab == ScreenTab.subscriptions
          ? const _SubscriptionsList(key: ValueKey('subs'))
          : const _GoalsList(key: ValueKey('goals')),
    );
  }
}

// ─── Sliding segment control ──────────────────────────────────────────────────

class _SlidingSegmentControl extends StatelessWidget {
  const _SlidingSegmentControl({required this.tab, required this.onChanged});

  final ScreenTab tab;
  final void Function(ScreenTab) onChanged;

  static const _pillColor = Color(0xFF1E2330);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tabs = ScreenTab.values;

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
              // ── Animated sliding pill ─────────────────────────────────
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
              // ── Labels ────────────────────────────────────────────────
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
            fontSize: 15,
          ),
          child: Text(label),
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
  const _SubscriptionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawItems = ref.watch(subscriptionsProvider);
    final items = [...rawItems]
      ..sort((a, b) => a.daysUntilRenewal.compareTo(b.daysUntilRenewal));

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
        itemCount: items.length,
        itemBuilder: (_, index) {
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

class _GoalsList extends ConsumerStatefulWidget {
  const _GoalsList({super.key});

  @override
  ConsumerState<_GoalsList> createState() => _GoalsListState();
}

class _GoalsListState extends ConsumerState<_GoalsList> {
  final _listKey = GlobalKey<AnimatedListState>();

  void _onPin(String id) {
    final notifier = ref.read(goalsProvider.notifier);
    final before = List<GoalModel>.from(ref.read(goalsProvider).goals);
    final fromIdx = before.indexWhere((g) => g.id == id);
    if (fromIdx < 0) return;
    if (fromIdx == 0) {
      notifier.pinGoal(id);
      return;
    }
    _listKey.currentState?.removeItem(
      fromIdx,
      (context, animation) => _tile(before[fromIdx], animation),
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
    final fromIdx = before.indexWhere((g) => g.id == id);
    if (fromIdx < 0) return;
    _listKey.currentState?.removeItem(
      fromIdx,
      (context, animation) => _tile(before[fromIdx], animation),
      duration: const Duration(milliseconds: 280),
    );
    notifier.unpinGoal(id);
    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      final next = ref.read(goalsProvider).goals;
      final newIdx = next.indexWhere((g) => g.id == id);
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
    final idx = before.indexWhere((g) => g.id == id);
    if (idx < 0) return;
    _listKey.currentState?.removeItem(
      idx,
      (context, animation) => _tile(before[idx], animation),
      duration: const Duration(milliseconds: 300),
    );
    notifier.deleteGoal(id);
  }

  Widget _tile(GoalModel goal, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: GoalCardWidget(
          goal: goal,
          onPin: () {},
          onUnpin: () {},
          onDelete: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider.select((s) => s.goals));

    return SlidableAutoCloseBehavior(
      child: AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
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
    );
  }
}
