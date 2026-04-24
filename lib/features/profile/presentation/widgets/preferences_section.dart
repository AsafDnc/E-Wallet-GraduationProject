import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../providers/profile_providers.dart';
import 'profile_section_title.dart';

class PreferencesSection extends ConsumerWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final profile = ref.watch(profileProvider);
    final isNotificationsEnabled = ref.watch(notificationsProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionTitle(title: 'Preferences'),
        _CardWrapper(
          children: [
            // ── Currency ───────────────────────────────────────────────────
            ListTile(
              leading: _LeadingIcon(
                icon: Icons.currency_exchange_rounded,
                cs: cs,
              ),
              title: const Text('Currency'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.currency,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
              onTap: () {},
            ),
            _InternalDivider(),

            // ── Appearance (dark mode toggle) ──────────────────────────────
            ListTile(
              leading: _LeadingIcon(
                icon: isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                cs: cs,
              ),
              title: const Text('Appearance'),
              subtitle: Text(
                isDarkMode ? 'Dark Mode' : 'Light Mode',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                activeThumbColor: cs.primary,
              ),
            ),
            _InternalDivider(),

            // ── Notifications ─────────────────────────────────────────────
            ListTile(
              leading: _LeadingIcon(icon: Icons.notifications_outlined, cs: cs),
              title: const Text('Notifications'),
              subtitle: Text(
                'Spending & budget alerts',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Switch(
                value: isNotificationsEnabled,
                onChanged: (_) =>
                    ref.read(notificationsProvider.notifier).toggle(),
                activeThumbColor: cs.primary,
              ),
            ),
            _InternalDivider(),

            // ── Language ──────────────────────────────────────────────────
            ListTile(
              leading: _LeadingIcon(icon: Icons.language_rounded, cs: cs),
              title: const Text('Language'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.language,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
              onTap: () {},
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
