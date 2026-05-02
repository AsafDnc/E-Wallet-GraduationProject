import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/wallet_entry_model.dart';
import '../utils/wallet_type_l10n.dart';

class WalletListItem extends StatelessWidget {
  const WalletListItem({super.key, required this.wallet, required this.onTap});

  final WalletEntry wallet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: appCurrencySymbolSpaced,
      decimalDigits: 2,
    );

    final isNegative =
        wallet.type == WalletType.creditCard && wallet.balance < 0;
    final balanceColor = isNegative ? cs.error : cs.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Wallet icon ───────────────────────────────────────
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: wallet.displayColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    wallet.type.icon,
                    color: wallet.displayColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                // ── Name + type ───────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              wallet.name,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (wallet.isDefault) ...[
                            const SizedBox(width: 6),
                            _PrimaryBadge(l10n: l10n, cs: cs),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        walletTypeDisplayName(l10n, wallet.type),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Balance ───────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatter.format(wallet.balance),
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: balanceColor,
                      ),
                    ),
                    if (isNegative)
                      Text(
                        l10n.walletDebtLabel,
                        style: tt.labelSmall?.copyWith(color: cs.error),
                      ),
                  ],
                ),

                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryBadge extends StatelessWidget {
  const _PrimaryBadge({required this.l10n, required this.cs});

  final AppLocalizations l10n;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          l10n.walletBadgePrimary,
          style: TextStyle(
            color: cs.onPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
