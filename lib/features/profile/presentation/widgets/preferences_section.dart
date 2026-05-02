import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/show_language_picker.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/profile_providers.dart';
import 'profile_section_title.dart';

class PreferencesSection extends ConsumerWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);
    final isNotificationsEnabled = ref.watch(notificationsProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionTitle(title: l10n.sectionPreferences),
        _CardWrapper(
          children: [
            ListTile(
              leading: _LeadingIcon(
                icon: Icons.currency_exchange_rounded,
                cs: cs,
              ),
              title: Text(
                l10n.preferencesCurrency,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: _TrailingValue(text: profile.currency, cs: cs, tt: tt),
              onTap: () {},
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(
                icon: isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                cs: cs,
              ),
              title: Text(
                l10n.preferencesAppearance,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                isDarkMode ? l10n.appearanceDark : l10n.appearanceLight,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                activeThumbColor: cs.primary,
              ),
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(icon: Icons.notifications_outlined, cs: cs),
              title: Text(
                l10n.preferencesNotifications,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                l10n.preferencesNotificationsSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
            ListTile(
              leading: _LeadingIcon(icon: Icons.language_rounded, cs: cs),
              title: Text(
                l10n.preferencesLanguage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: _TrailingValue(text: profile.language, cs: cs, tt: tt),
              onTap: () =>
                  showCupertinoLanguagePicker(context: context, ref: ref),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrailingValue extends StatelessWidget {
  const _TrailingValue({
    required this.text,
    required this.cs,
    required this.tt,
  });

  final String text;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                text,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
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
