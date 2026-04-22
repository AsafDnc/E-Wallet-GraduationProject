/// Supabase `transactions` row: `id`, `wallet_id`, `amount`, `type`, `category`,
/// `description`, `created_at`.
///
/// The `type` column accepts only `'income'` or `'expense'` (see [WalletTransactionType]).
enum WalletTransactionType {
  income,
  expense;

  static WalletTransactionType parse(String value) {
    switch (value) {
      case 'income':
        return WalletTransactionType.income;
      case 'expense':
        return WalletTransactionType.expense;
      default:
        throw FormatException('Invalid transaction type: $value', value);
    }
  }

  /// Value stored in Supabase (`income` or `expense`).
  String toJson() => switch (this) {
    WalletTransactionType.income => 'income',
    WalletTransactionType.expense => 'expense',
  };
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.category,
    required this.createdAt,
    this.description,
  });

  final String id;
  final String walletId;
  final double amount;
  final WalletTransactionType type;
  final String category;
  final String? description;
  final DateTime createdAt;

  factory TransactionModel.fromJson(Map<String, Object?> json) {
    return TransactionModel(
      id: json['id']! as String,
      walletId: json['wallet_id']! as String,
      amount: (json['amount'] as num).toDouble(),
      type: WalletTransactionType.parse(json['type']! as String),
      category: json['category']! as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at']! as String),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'wallet_id': walletId,
      'amount': amount,
      'type': type.toJson(),
      'category': category,
      'description': description,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? walletId,
    double? amount,
    WalletTransactionType? type,
    String? category,
    String? description,
    DateTime? createdAt,
    bool clearDescription = false,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: clearDescription ? null : (description ?? this.description),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
