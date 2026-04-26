import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';

class SupportSection extends ConsumerWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(height: 8),
        _CardWrapper(
          children: [
            // ── Help Center & FAQ ────────────────────────────────────────
            ListTile(
              leading: _LeadingIcon(icon: Icons.help_outline_rounded, cs: cs),
              title: const Text('Help Center & FAQ'),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () {},
            ),
            _InternalDivider(),

            // ── Terms of Service & Privacy ────────────────────────────────
            ListTile(
              leading: _LeadingIcon(icon: Icons.description_outlined, cs: cs),
              title: const Text('Terms of Service & Privacy'),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Destructive actions in a separate card ─────────────────────────
        _CardWrapper(
          children: [
            // Log Out
            ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title: Text(
                'Log Out',
                style: tt.bodyLarge?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _confirmLogOut(context, ref),
            ),
            _InternalDivider(),

            // Delete Account
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: cs.error.withValues(alpha: 0.6),
              ),
              title: Text(
                'Delete Account',
                style: tt.bodyLarge?.copyWith(
                  color: cs.error.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () => _confirmDeleteAccount(context),
            ),
          ],
        ),

        // ── App version ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 32),
          child: Text(
            'v1.0.0 (Build 12)',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _confirmLogOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(authProvider.notifier).signOut();
              },
              style: TextButton.styleFrom(foregroundColor: cs.error),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'This action is permanent and cannot be undone. '
            'All your data will be erased.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: cs.error.withValues(alpha: 0.7),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
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
