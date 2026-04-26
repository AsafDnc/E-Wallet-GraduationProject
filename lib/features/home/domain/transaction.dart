import 'package:flutter/material.dart';

/// Domain model representing a single financial transaction.
class Transaction {
  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.iconData,
    required this.iconBgColor,
    this.isPinned = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;

  /// Negative value means debit (expense), positive means credit.
  final double amount;

  /// Icon displayed inside the leading circle.
  final int iconData;

  /// Background color of the leading circle.
  final Color iconBgColor;

  /// Whether this transaction is pinned to the top of the list.
  final bool isPinned;

  /// When the transaction was recorded (used for charts and monthly totals).
  final DateTime createdAt;

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    int? iconData,
    Color? iconBgColor,
    bool? isPinned,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      iconData: iconData ?? this.iconData,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Formats amount as "-₺5,99" or "+₺5,99".
  String get formattedAmount {
    final sign = amount < 0 ? '-' : '+';
    return '$sign₺${amount.abs().toStringAsFixed(2)}';
  }
}
