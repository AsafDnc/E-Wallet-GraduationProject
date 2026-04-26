import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/profile_providers.dart';
import 'profile_section_title.dart';

class SecuritySection extends ConsumerWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isBiometricEnabled = ref.watch(biometricProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionTitle(title: 'Security'),
        _CardWrapper(
          children: [
            ListTile(
              leading: _LeadingIcon(icon: Icons.person_outline_rounded, cs: cs),
              title: const Text('Personal Info'),
              subtitle: Text(
                'Name, phone, country/city',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => context.push('/security/personal-info'),
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(icon: Icons.lock_outline_rounded, cs: cs),
              title: const Text('Password & PIN'),
              subtitle: Text(
                'Update app lock & transaction PIN',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => context.push('/security/password-pin'),
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(icon: Icons.fingerprint_rounded, cs: cs),
              title: const Text('Biometric Login'),
              subtitle: Text(
                'FaceID / TouchID',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Switch(
                value: isBiometricEnabled,
                onChanged: (_) => ref.read(biometricProvider.notifier).toggle(),
                activeThumbColor: cs.primary,
              ),
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(icon: Icons.verified_user_outlined, cs: cs),
              title: const Text('Two-Factor Authentication (2FA)'),
              subtitle: Text(
                'SMS or Authenticator app',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => context.push('/security/2fa'),
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(
                icon: Icons.notifications_active_outlined,
                cs: cs,
              ),
              title: const Text('Daily Transaction Limits'),
              subtitle: Text(
                'Set max daily spend to trigger dynamic alerts',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => context.push('/security/daily-limits'),
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
