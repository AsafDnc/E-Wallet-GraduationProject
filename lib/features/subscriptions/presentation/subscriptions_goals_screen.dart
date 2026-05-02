import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../goals/presentation/widgets/goal_card_widget.dart';
import '../../goals/providers/goals_provider.dart';
import '../domain/subscriptions_goals_tab.dart';
import '../providers/subscriptions_provider.dart';
import 'widgets/subscription_card_widget.dart';
import 'widgets/subscriptions_goals_add_sheets.dart';

// ─── Tab enum ─────────────────────────────────────────────────────────────────

enum ScreenTab { subscriptions, goals }

extension _ScreenTabX on ScreenTab {
  String localizedTitle(AppLocalizations l10n) {
    switch (this) {
      case ScreenTab.subscriptions:
        return l10n.subscriptionsTab;
      case ScreenTab.goals:
        return l10n.savingGoalsTab;
    }
  }

  String localizedAmountHeading(AppLocalizations l10n) {
    switch (this) {
      case ScreenTab.subscriptions:
        return l10n.subscriptionsTotalMonthlyCost;
      case ScreenTab.goals:
        return l10n.savingGoalsCostTitle;
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(l10n),
            const SizedBox(height: 20),
            _buildAmountSection(l10n),
            const SizedBox(height: 18),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ─── Header: centered segment control, no "+" button ──────────────────────

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: _SlidingSegmentControl(
        tab: _tab,
        l10n: l10n,
        onChanged: _switchTab,
      ),
    );
  }

  // ─── Amount section: title label + animated large amount ──────────────────

  Widget _buildAmountSection(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final heading = _tab.localizedAmountHeading(l10n);

    return Column(
      children: [
        // Dynamic section title
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
            child: child,
          ),
          child: Padding(
            key: ValueKey<String>(heading),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                heading,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
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

// ─── Premium minimalist “+” — white bg, soft gray shadow, gray icon ────────

class _PremiumCircularAddButton extends StatelessWidget {
  const _PremiumCircularAddButton({required this.onPressed});

  final VoidCallback onPressed;

  static const _bg = Color(0xFFFFFFFF);
  static const _icon = Color(0xFF5A5F6A);
  static const _border = Color(0xFFE8EAED);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.addButtonLabel,
      child: Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: const Color(0x0A5A5F6A),
          highlightColor: const Color(0x055A5F6A),
          child: Ink(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bg,
              border: Border.all(color: _border, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(0, 6),
                ),
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  spreadRadius: -2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: _icon, size: 28),
          ),
        ),
      ),
    );
  }
}

// ─── Sliding segment control ──────────────────────────────────────────────────

class _SlidingSegmentControl extends StatelessWidget {
  const _SlidingSegmentControl({
    required this.tab,
    required this.l10n,
    required this.onChanged,
  });

  final ScreenTab tab;
  final AppLocalizations l10n;
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
                          label: t.localizedTitle(l10n),
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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              color: selected ? selectedColor : unselectedColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          total.toAppCurrency(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.8,
          ),
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$appCurrencySymbolSpaced${_fmt(saved)} ',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.8,
                ),
              ),
              TextSpan(
                text: '/ $appCurrencySymbolSpaced${_fmt(target)}',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
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

// ─── Subscriptions list + animated “+” (top when empty, bottom when filled) ───

class _SubscriptionsList extends ConsumerWidget {
  const _SubscriptionsList({super.key});

  static const _alignDuration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawItems = ref.watch(subscriptionsProvider);
    final items = [...rawItems]
      ..sort((a, b) => a.daysUntilRenewal.compareTo(b.daysUntilRenewal));
    final isEmpty = items.isEmpty;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: isEmpty
              ? const SizedBox.expand()
              : SlidableAutoCloseBehavior(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 140),
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
                ),
        ),
        AnimatedAlign(
          duration: _alignDuration,
          curve: Curves.easeInOutCubic,
          alignment: isEmpty ? Alignment.topCenter : Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              top: isEmpty ? 6 : 0,
              bottom: isEmpty ? 0 : 100,
            ),
            child: _PremiumCircularAddButton(
              onPressed: () => showAddSubscriptionSheet(context),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Goals list + same animated “+” pattern ────────────────────────────────────

class _GoalsList extends ConsumerWidget {
  const _GoalsList({super.key});

  static const _alignDuration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider.select((s) => s.goals));
    final isEmpty = goals.isEmpty;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: isEmpty
              ? const SizedBox.expand()
              : SlidableAutoCloseBehavior(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 140),
                    itemCount: goals.length,
                    itemBuilder: (_, index) {
                      final goal = goals[index];
                      return GoalCardWidget(
                        goal: goal,
                        onPin: () =>
                            ref.read(goalsProvider.notifier).pinGoal(goal.id),
                        onUnpin: () =>
                            ref.read(goalsProvider.notifier).unpinGoal(goal.id),
                        onDelete: () => ref
                            .read(goalsProvider.notifier)
                            .deleteGoal(goal.id),
                      );
                    },
                  ),
                ),
        ),
        AnimatedAlign(
          duration: _alignDuration,
          curve: Curves.easeInOutCubic,
          alignment: isEmpty ? Alignment.topCenter : Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              top: isEmpty ? 6 : 0,
              bottom: isEmpty ? 0 : 100,
            ),
            child: _PremiumCircularAddButton(
              onPressed: () => showAddSavingGoalSheet(context),
            ),
          ),
        ),
      ],
    );
  }
}
