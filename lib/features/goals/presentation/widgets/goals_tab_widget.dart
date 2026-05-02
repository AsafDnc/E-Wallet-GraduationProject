import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class GoalsTabWidget extends StatelessWidget {
  const GoalsTabWidget({
    super.key,
    required this.isGoalsActive,
    required this.onChanged,
  });

  final bool isGoalsActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _TabItem(
            label: l10n.goalsTabGoals,
            active: isGoalsActive,
            onTap: () => onChanged(true),
          ),
          const SizedBox(width: 28),
          _TabItem(
            label: l10n.goalsTabAchieved,
            active: !isGoalsActive,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF858A95),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2.5,
            width: active ? 38 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }
}
