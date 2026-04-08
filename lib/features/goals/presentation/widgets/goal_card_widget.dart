import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/goal_model.dart';

class GoalCardWidget extends StatelessWidget {
  const GoalCardWidget({
    super.key,
    required this.goal,
    required this.onPin,
    required this.onDelete,
  });

  final GoalModel goal;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  static const double _radiusValue = 18;
  static const _tileRadius = BorderRadius.all(Radius.circular(_radiusValue));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
                  onPressed: (_) => onPin(),
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  icon: Icons.push_pin_outlined,
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
            color: const Color(0xFF181B22),
            borderRadius: BorderRadius.circular(_radiusValue),
            border: Border.all(color: const Color(0xFF31353F), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: goal.iconBackground,
                    child: Text(
                      goal.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                  if (goal.isPinned)
                    SvgPicture.asset(
                      'assets/icons/Pinned.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFD8DCE4),
                        BlendMode.srcIn,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Middle row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      goal.savingsLabel,
                      style: const TextStyle(
                        color: Color(0xFFA3A8B3),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    goal.percentLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Bottom row
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 5,
                  backgroundColor: const Color(0xFF6A6F79),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
