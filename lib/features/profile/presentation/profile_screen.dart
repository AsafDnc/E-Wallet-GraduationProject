import 'package:flutter/material.dart';

import 'widgets/core_features_section.dart';
import 'widgets/preferences_section.dart';
import 'widgets/security_section.dart';
import 'widgets/support_section.dart';
import 'widgets/user_header_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            centerTitle: false,
            title: Text(
              'Profile & Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildListDelegate([
              // Section 1 – User Header
              const UserHeaderSection(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: cs.outlineVariant, height: 1),
              ),

              // Section 2 – Core Features (Wallet & Finance)
              const CoreFeaturesSection(),

              // Section 3 – Security
              const SecuritySection(),

              // Section 4 – Preferences
              const PreferencesSection(),

              // Section 5 – Support & Destructive Actions
              const SupportSection(),
            ]),
          ),
        ],
      ),
    );
  }
}
