import 'package:flutter/material.dart';

enum WalletType { cash, bank, creditCard }

extension WalletTypeX on WalletType {
  String get label {
    switch (this) {
      case WalletType.cash:
        return 'Cash';
      case WalletType.bank:
        return 'Bank Account';
      case WalletType.creditCard:
        return 'Credit Card';
    }
  }

  IconData get icon {
    switch (this) {
      case WalletType.cash:
        return Icons.payments_outlined;
      case WalletType.bank:
        return Icons.account_balance_rounded;
      case WalletType.creditCard:
        return Icons.credit_card_rounded;
    }
  }
}

class WalletEntry {
  const WalletEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
    required this.iconCode,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final WalletType type;
  final double balance;
  final int color;
  final int iconCode;
  final bool isDefault;

  Color get displayColor => Color(color);
  IconData get displayIcon => IconData(iconCode, fontFamily: 'MaterialIcons');

  WalletEntry copyWith({
    String? id,
    String? name,
    WalletType? type,
    double? balance,
    int? color,
    int? iconCode,
    bool? isDefault,
  }) {
    return WalletEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      iconCode: iconCode ?? this.iconCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
