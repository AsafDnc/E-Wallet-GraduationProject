import 'package:flutter/material.dart';

import '../../../core/data/models/transaction_model.dart';

/// Domain model representing a single financial transaction (UI + local state).
///
/// [walletId] maps to the Supabase `transactions.wallet_id` column (UUID / text
/// foreign key to your wallets table). Use [toSupabaseJson], [fromSupabaseJson],
/// or [toTransactionModel] / [fromTransactionModel] for API rows.
class Transaction {
  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.iconData,
    required this.iconBgColor,
    this.isPinned = false,
    this.walletId,
    this.transferToWalletId,
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

  /// Wallet this row belongs to; null for legacy rows or cross-wallet views.
  /// Persists as `wallet_id` in PostgREST / Supabase.
  final String? walletId;

  /// For transfer-out rows: receiving wallet (local + balance sync only).
  /// Not sent in [toSupabaseJson] unless your schema adds a column.
  final String? transferToWalletId;

  /// PostgREST / Supabase column name for [walletId].
  static const String supabaseWalletIdKey = 'wallet_id';

  /// Builds from a PostgREST row (`wallet_id`, `amount`, `type`, …).
  factory Transaction.fromSupabaseJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final walletRaw = json[supabaseWalletIdKey];
    final String? walletId = walletRaw is String
        ? walletRaw
        : walletRaw?.toString();

    final typeStr = json['type'] as String? ?? 'expense';
    final rawAmount = (json['amount'] as num?)?.toDouble() ?? 0;
    final signed = typeStr.toLowerCase() == 'expense'
        ? -rawAmount.abs()
        : rawAmount.abs();

    final category = json['category'] as String? ?? '';
    final description = json['description'] as String?;
    final title = (description != null && description.trim().isNotEmpty)
        ? description.trim()
        : category;

    final createdRaw = json['created_at'];
    final createdAt = createdRaw is String
        ? DateTime.tryParse(createdRaw) ?? DateTime.now()
        : DateTime.now();

    return Transaction(
      id: id,
      title: title,
      amount: signed,
      iconData: Icons.receipt_long_rounded.codePoint,
      iconBgColor: _colorForCategoryKey(category),
      isPinned: json['is_pinned'] as bool? ?? false,
      walletId: walletId,
      transferToWalletId: null,
      createdAt: createdAt,
    );
  }

  /// Insert / update payload keys aligned with [TransactionModel.toJson].
  ///
  /// [amount] is stored positive; [type] is derived from the sign of [amount].
  Map<String, Object?> toSupabaseJson() {
    final type = amount < 0
        ? WalletTransactionType.expense
        : WalletTransactionType.income;
    return <String, Object?>{
      'id': id,
      supabaseWalletIdKey: walletId,
      'amount': amount.abs(),
      'type': type.toJson(),
      'category': title,
      'description': title,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Converts to the core Supabase row model when [walletId] is set.
  TransactionModel? toTransactionModel() {
    final w = walletId;
    if (w == null) return null;
    final type = amount < 0
        ? WalletTransactionType.expense
        : WalletTransactionType.income;
    return TransactionModel(
      id: id,
      walletId: w,
      amount: amount.abs(),
      type: type,
      category: title,
      description: title,
      createdAt: createdAt,
    );
  }

  /// Hydrates UI fields from [model]; supply icons when you have UI metadata.
  factory Transaction.fromTransactionModel(
    TransactionModel model, {
    required int iconData,
    required Color iconBgColor,
    bool isPinned = false,
  }) {
    final signed = model.type == WalletTransactionType.expense
        ? -model.amount.abs()
        : model.amount.abs();
    final title =
        (model.description != null && model.description!.trim().isNotEmpty)
        ? model.description!.trim()
        : model.category;
    return Transaction(
      id: model.id,
      title: title,
      amount: signed,
      iconData: iconData,
      iconBgColor: iconBgColor,
      isPinned: isPinned,
      walletId: model.walletId,
      transferToWalletId: null,
      createdAt: model.createdAt,
    );
  }

  static Color _colorForCategoryKey(String category) {
    const palette = <Color>[
      Color(0xFF78909C),
      Color(0xFF1D75DD),
      Color(0xFF27AE60),
      Color(0xFFE74C3C),
      Color(0xFFA74CFF),
    ];
    var h = 0;
    for (final c in category.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return palette[h % palette.length];
  }

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    int? iconData,
    Color? iconBgColor,
    bool? isPinned,
    String? walletId,
    String? transferToWalletId,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      iconData: iconData ?? this.iconData,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      isPinned: isPinned ?? this.isPinned,
      walletId: walletId ?? this.walletId,
      transferToWalletId: transferToWalletId ?? this.transferToWalletId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Formats amount as "-₺5,99" or "+₺5,99".
  String get formattedAmount {
    final sign = amount < 0 ? '-' : '+';
    return '$sign₺${amount.abs().toStringAsFixed(2)}';
  }
}
