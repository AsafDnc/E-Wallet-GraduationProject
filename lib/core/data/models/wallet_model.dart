/// Row shape for the Supabase `wallets` table (PostgREST / JSON).
///
/// Columns: `id`, `user_id`, `balance`, `currency`, `created_at`.
class WalletModel {
  const WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final double balance;
  final String currency;
  final DateTime createdAt;

  factory WalletModel.fromJson(Map<String, Object?> json) {
    return WalletModel(
      id: json['id']! as String,
      userId: json['user_id']! as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency']! as String,
      createdAt: DateTime.parse(json['created_at']! as String),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'user_id': userId,
      'balance': balance,
      'currency': currency,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  WalletModel copyWith({
    String? id,
    String? userId,
    double? balance,
    String? currency,
    DateTime? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
