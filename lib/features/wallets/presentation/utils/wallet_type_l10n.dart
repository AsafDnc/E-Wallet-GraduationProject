import '../../../../l10n/app_localizations.dart';
import '../../domain/models/wallet_entry_model.dart';

String walletTypeDisplayName(AppLocalizations l10n, WalletType type) {
  switch (type) {
    case WalletType.cash:
      return l10n.walletTypeCash;
    case WalletType.bank:
      return l10n.walletTypeBank;
    case WalletType.creditCard:
      return l10n.walletTypeCreditCard;
  }
}
