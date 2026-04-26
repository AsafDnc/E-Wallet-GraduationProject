import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/card_dimensions.dart';
import '../../domain/goal_model.dart';

// Clean, modern icon mapping per goal ID — matches app's category icon style.
const Map<String, IconData> _goalIconData = {
  'laptop': Icons.laptop_mac_rounded,
  'car': Icons.directions_car_rounded,
  'holiday': Icons.beach_access_rounded,
  'winter_clothes': Icons.checkroom_rounded,
};

IconData _iconForGoal(String id) => _goalIconData[id] ?? Icons.savings_rounded;

class GoalCardWidget extends StatelessWidget {
  const GoalCardWidget({
    super.key,
    required this.goal,
    required this.onPin,
    required this.onUnpin,
    required this.onDelete,
  });

  final GoalModel goal;
  final VoidCallback onPin;
  final VoidCallback onUnpin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final progressFill = cs.onSurface;
    final trackColor = cs.surfaceContainerHighest;

    return Padding(
      padding: kCardMargin,
      child: Slidable(
        key: ValueKey(goal.id),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.24,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: kTileRadius,
                child: SlidableAction(
                  onPressed: (_) => goal.isPinned ? onUnpin() : onPin(),
                  backgroundColor: AppTheme.pinSwipeBackground,
                  foregroundColor: Colors.white,
                  icon: goal.isPinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.24,
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: kTileRadius,
                child: SlidableAction(
                  onPressed: (_) => onDelete(),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline_rounded,
                ),
              ),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(kCardRadius),
            border: Border.all(color: cs.outlineVariant, width: 1),
            boxShadow: isLight ? kCardShadow : const [],
          ),
          padding: kCardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row ──────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _GoalIcon(goal: goal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (goal.isPinned)
                    SvgPicture.asset(
                      'assets/icons/Pinned.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        cs.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // ── Amounts + percentage ────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      goal.savingsLabel,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  Text(
                    goal.percentLabel,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // ── Progress bar ────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 4,
                  backgroundColor: trackColor,
                  valueColor: AlwaysStoppedAnimation<Color>(progressFill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Square-rounded icon — identical size and shape to subscription service icons.
class _GoalIcon extends StatelessWidget {
  const _GoalIcon({required this.goal});
  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: goal.iconBackground,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(_iconForGoal(goal.id), color: Colors.white, size: 26),
    );
  }
}
