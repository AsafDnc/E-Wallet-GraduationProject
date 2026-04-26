import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'profile_section_title.dart';

class CoreFeaturesSection extends StatelessWidget {
  const CoreFeaturesSection({super.key});

  static void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionTitle(title: 'Wallet & Finance'),
        _CardWrapper(
          children: [
            ListTile(
              leading: _LeadingIcon(
                icon: Icons.account_balance_wallet_rounded,
                cs: cs,
              ),
              title: const Text('My Wallets / Accounts'),
              subtitle: Text(
                'Manage cash, credit cards...',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Adjust Balance',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
              onTap: () => context.push('/wallets'),
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(icon: Icons.bar_chart_rounded, cs: cs),
              title: const Text('Monthly Budget Limit'),
              subtitle: Text(
                'Set overall spending limits',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => context.push('/budget'),
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(icon: Icons.category_rounded, cs: cs),
              title: const Text('Categories'),
              subtitle: Text(
                'Manage income/expense categories',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => context.push('/categories'),
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(icon: Icons.upload_file_rounded, cs: cs),
              title: const Text('Export Data'),
              subtitle: Text(
                'Download history as CSV/PDF',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Icon(
                Icons.download_rounded,
                color: cs.onSurfaceVariant,
              ),
              onTap: () => _soon(context),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _CardWrapper extends StatelessWidget {
  const _CardWrapper({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(children: children),
      ),
    );
  }
}

class _InternalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon, required this.cs});

  final IconData icon;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: cs.onPrimaryContainer, size: 20),
    );
  }
}
