import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

/// Wallet / transactions entry point from Profile. Full experience is not built yet.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, this.onBackTap});

  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _WalletBackButton(onBackTap: onBackTap),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.walletScreenTitle,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.walletComingSoonTitle,
              style: tt.titleMedium?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.72),
                fontWeight: FontWeight.w500,
                letterSpacing: 2.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletBackButton extends StatelessWidget {
  const _WalletBackButton({this.onBackTap});

  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canGoBack = onBackTap != null || context.canPop();
    if (!canGoBack) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: cs.onSurface,
        size: 20,
      ),
      onPressed: () {
        final cb = onBackTap;
        if (cb != null) {
          cb();
        } else {
          context.pop();
        }
      },
    );
  }
}
