import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            centerTitle: false,
            title: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.profileAndSettings,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const UserHeaderSection(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: cs.outlineVariant, height: 1),
              ),
              const CoreFeaturesSection(),
              const SecuritySection(),
              const PreferencesSection(),
              const SupportSection(),
            ]),
          ),
        ],
      ),
    );
  }
}
