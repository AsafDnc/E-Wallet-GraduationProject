import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/wallet_entry_model.dart';

// ─── Mock seed data ────────────────────────────────────────────────────────

final _mockWallets = <WalletEntry>[
  WalletEntry(
    id: 'w1',
    name: 'Main Bank Account',
    type: WalletType.bank,
    balance: 5000,
    color: const Color(0xFF1D75DD).toARGB32(),
    iconCode: Icons.account_balance_rounded.codePoint,
    isDefault: true,
  ),
  WalletEntry(
    id: 'w2',
    name: 'Cash Wallet',
    type: WalletType.cash,
    balance: 250,
    color: const Color(0xFF27AE60).toARGB32(),
    iconCode: Icons.payments_outlined.codePoint,
  ),
  WalletEntry(
    id: 'w3',
    name: 'Credit Card',
    type: WalletType.creditCard,
    balance: -1200,
    color: const Color(0xFFE74C3C).toARGB32(),
    iconCode: Icons.credit_card_rounded.codePoint,
  ),
];

// ─── Wallets list provider ────────────────────────────────────────────────

class WalletsNotifier extends Notifier<List<WalletEntry>> {
  @override
  List<WalletEntry> build() => List.from(_mockWallets);

  void addWallet(WalletEntry wallet) {
    state = [...state, wallet];
  }

  void updateWallet(WalletEntry updated) {
    state = [
      for (final w in state)
        if (w.id == updated.id) updated else w,
    ];
  }

  void deleteWallet(String id) {
    state = state.where((w) => w.id != id).toList();
  }

  void setDefault(String id) {
    state = [for (final w in state) w.copyWith(isDefault: w.id == id)];
  }

  void adjustBalance(String id, double newBalance) {
    state = [
      for (final w in state)
        if (w.id == id) w.copyWith(balance: newBalance) else w,
    ];
  }
}

final walletsProvider = NotifierProvider<WalletsNotifier, List<WalletEntry>>(
  WalletsNotifier.new,
);

// ─── Balance view mode ────────────────────────────────────────────────────

enum BalanceViewMode { netWorth, totalCash }

class BalanceViewModeNotifier extends Notifier<BalanceViewMode> {
  @override
  BalanceViewMode build() => BalanceViewMode.netWorth;

  void toggle() {
    state = state == BalanceViewMode.netWorth
        ? BalanceViewMode.totalCash
        : BalanceViewMode.netWorth;
  }
}

final balanceViewModeProvider =
    NotifierProvider<BalanceViewModeNotifier, BalanceViewMode>(
      BalanceViewModeNotifier.new,
    );

// ─── Calculated balance ────────────────────────────────────────────────────

final calculatedBalanceProvider = Provider<double>((ref) {
  final wallets = ref.watch(walletsProvider);
  final mode = ref.watch(balanceViewModeProvider);

  switch (mode) {
    case BalanceViewMode.netWorth:
      return wallets.fold(0.0, (sum, w) => sum + w.balance);
    case BalanceViewMode.totalCash:
      return wallets
          .where((w) => w.balance > 0)
          .fold(0.0, (sum, w) => sum + w.balance);
  }
});

// ─── Balance visibility ────────────────────────────────────────────────────

class BalanceVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final balanceVisibilityProvider =
    NotifierProvider<BalanceVisibilityNotifier, bool>(
      BalanceVisibilityNotifier.new,
    );
