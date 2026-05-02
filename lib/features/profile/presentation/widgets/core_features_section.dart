import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import 'profile_section_title.dart';

class CoreFeaturesSection extends StatelessWidget {
  const CoreFeaturesSection({super.key});

  static void _soon(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.comingSoonSnack),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionTitle(title: l10n.sectionWalletFinance),
        _CardWrapper(
          children: [
            ListTile(
              leading: _LeadingIcon(
                icon: Icons.account_balance_wallet_rounded,
                cs: cs,
              ),
              title: Text(
                l10n.coreMyWallets,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                l10n.coreMyWalletsSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.coreAdjustBalance,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
              title: Text(
                l10n.coreBudget,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                l10n.coreBudgetSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => context.push('/budget'),
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(icon: Icons.category_rounded, cs: cs),
              title: Text(
                l10n.coreCategories,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                l10n.coreCategoriesSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => context.push('/categories'),
            ),
            _InternalDivider(),
            ListTile(
              leading: _LeadingIcon(icon: Icons.upload_file_rounded, cs: cs),
              title: Text(
                l10n.coreExport,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                l10n.coreExportSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
