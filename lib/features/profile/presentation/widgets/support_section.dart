import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/providers/auth_provider.dart';

class SupportSection extends ConsumerWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 8),
        _CardWrapper(
          children: [
            ListTile(
              leading: _LeadingIcon(icon: Icons.help_outline_rounded, cs: cs),
              title: Text(
                l10n.supportHelp,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () {},
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(icon: Icons.description_outlined, cs: cs),
              title: Text(
                l10n.supportTerms,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        _CardWrapper(
          children: [
            ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title: Text(
                l10n.supportLogOut,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodyLarge?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _confirmLogOut(context, ref, l10n),
            ),
            _InternalDivider(),
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: cs.error.withValues(alpha: 0.6),
              ),
              title: Text(
                l10n.supportDeleteAccount,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.bodyLarge?.copyWith(
                  color: cs.error.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () => _confirmDeleteAccount(context, l10n),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 32),
          child: Text(
            l10n.supportVersion,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmLogOut(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(
            l10n.supportLogOutConfirmTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: Text(
            l10n.supportLogOutConfirmMessage,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(authProvider.notifier).signOut();
              },
              style: TextButton.styleFrom(foregroundColor: cs.error),
              child: Text(l10n.supportLogOut),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(
            l10n.supportDeleteConfirmTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: Text(
            l10n.supportDeleteConfirmMessage,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: cs.error.withValues(alpha: 0.7),
              ),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
  }
}

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
