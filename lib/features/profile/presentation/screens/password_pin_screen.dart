import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../providers/profile_providers.dart';

class PasswordPinScreen extends ConsumerWidget {
  const PasswordPinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final requirePin = ref.watch(requirePinProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.passwordPinTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── PIN section card ──────────────────────────────────────────
          _SectionCard(
            children: [
              _SectionHeader(
                icon: Icons.pin_outlined,
                title: l10n.passwordPinAppPin,
                cs: cs,
                tt: tt,
              ),

              // Change PIN tile
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: _TileIcon(
                  icon: Icons.dialpad_rounded,
                  cs: cs,
                  color: cs.primary,
                ),
                title: Text(
                  l10n.passwordChangePin,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  l10n.passwordChangePinSubtitle,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                ),
                onTap: () => context.push('/app-pin/create'),
              ),

              Divider(
                color: cs.outlineVariant,
                height: 1,
                indent: 4,
                endIndent: 4,
              ),

              // Require PIN on launch
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                secondary: _TileIcon(
                  icon: Icons.lock_clock_outlined,
                  cs: cs,
                  color: requirePin ? cs.primary : cs.onSurfaceVariant,
                ),
                title: Text(
                  l10n.passwordRequirePinOnLaunch,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  requirePin
                      ? l10n.passwordRequirePinProtected
                      : l10n.passwordRequirePinDisabled,
                  style: tt.bodySmall?.copyWith(
                    color: requirePin
                        ? const Color(0xFF27AE60)
                        : cs.onSurfaceVariant,
                  ),
                ),
                value: requirePin,
                onChanged: (newValue) =>
                    _handlePinToggle(context, ref, newValue),
                activeThumbColor: cs.primary,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Security tip card ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 20, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.passwordSecurityTipTitle,
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.passwordSecurityTipBody,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handlePinToggle(BuildContext context, WidgetRef ref, bool newValue) {
    // Turning ON is always safe — apply immediately.
    if (newValue) {
      ref.read(requirePinProvider.notifier).set(true);
      return;
    }

    // Turning OFF — show UX friction warning dialog.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          icon: Icon(Icons.security_rounded, color: cs.error, size: 36),
          title: Text(
            l10n.passwordDisableLockDialogTitle,
            textAlign: TextAlign.center,
          ),
          content: Text(
            l10n.passwordDisableLockDialogBody,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            // Safe action — keeps switch TRUE.
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.commonCancel),
            ),
            // Danger action — changes switch to FALSE.
            TextButton(
              style: TextButton.styleFrom(foregroundColor: cs.error),
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(requirePinProvider.notifier).set(false);
              },
              child: Text(
                l10n.passwordDisableAnyway,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.cs,
    required this.tt,
  });

  final IconData icon;
  final String title;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: tt.labelLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon, required this.cs, required this.color});

  final IconData icon;
  final ColorScheme cs;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
