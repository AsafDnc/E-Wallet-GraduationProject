import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/goal_model.dart';

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

  static const double _radiusValue = 14;
  static const _tileRadius = BorderRadius.all(Radius.circular(_radiusValue));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Same fill tone as subscription “days left” ring (primary body text).
    final progressFill = cs.onSurface;
    final trackColor = cs.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(goal.id),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.24,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: _tileRadius,
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
                borderRadius: _tileRadius,
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
            borderRadius: BorderRadius.circular(_radiusValue),
            border: Border.all(color: cs.outlineVariant, width: 1),
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? const [
                    BoxShadow(
                      color: Color(0x12222B33),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row ──────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: goal.iconBackground,
                    child: Text(
                      goal.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 17,
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
              const SizedBox(height: 8),
              // ── Savings amounts (emphasised) + compact % ─────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      goal.savingsLabel,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 17,
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
              // ── Progress bar (fill matches subscription ring) ───────
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
