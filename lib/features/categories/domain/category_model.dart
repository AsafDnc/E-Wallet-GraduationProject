import 'package:flutter/material.dart';

enum CategoryType { income, expense }

extension CategoryTypeX on CategoryType {
  String get label => this == CategoryType.income ? 'Income' : 'Expense';
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.type,
  });

  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  final CategoryType type;

  Color get displayColor => Color(colorValue);
  IconData get displayIcon => IconData(iconCode, fontFamily: 'MaterialIcons');

  Category copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorValue,
    CategoryType? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
    );
  }
}

// ─── Seed data ────────────────────────────────────────────────────────────────
// Non-const because IconData.codePoint is not a compile-time constant.

final kSeedExpenseCategories = <Category>[
  Category(
    id: 'food',
    name: 'Food',
    iconCode: Icons.restaurant_rounded.codePoint,
    colorValue: const Color(0xFFE57373).toARGB32(),
    type: CategoryType.expense,
  ),
  Category(
    id: 'transport',
    name: 'Transport',
    iconCode: Icons.directions_car_rounded.codePoint,
    colorValue: const Color(0xFF64B5F6).toARGB32(),
    type: CategoryType.expense,
  ),
  Category(
    id: 'shopping',
    name: 'Shopping',
    iconCode: Icons.shopping_bag_rounded.codePoint,
    colorValue: const Color(0xFFBA68C8).toARGB32(),
    type: CategoryType.expense,
  ),
  Category(
    id: 'bills',
    name: 'Bills',
    iconCode: Icons.receipt_long_rounded.codePoint,
    colorValue: const Color(0xFFFFB74D).toARGB32(),
    type: CategoryType.expense,
  ),
  Category(
    id: 'subscription',
    name: 'Subscription',
    iconCode: Icons.subscriptions_rounded.codePoint,
    colorValue: const Color(0xFF4FC3F7).toARGB32(),
    type: CategoryType.expense,
  ),
  Category(
    id: 'entertainment',
    name: 'Entertainment',
    iconCode: Icons.movie_rounded.codePoint,
    colorValue: const Color(0xFFF06292).toARGB32(),
    type: CategoryType.expense,
  ),
  Category(
    id: 'health',
    name: 'Healthcare',
    iconCode: Icons.local_hospital_rounded.codePoint,
    colorValue: const Color(0xFF81C784).toARGB32(),
    type: CategoryType.expense,
  ),
  Category(
    id: 'other_exp',
    name: 'Other',
    iconCode: Icons.more_horiz_rounded.codePoint,
    colorValue: const Color(0xFF78909C).toARGB32(),
    type: CategoryType.expense,
  ),
];

final kSeedIncomeCategories = <Category>[
  Category(
    id: 'salary',
    name: 'Salary',
    iconCode: Icons.account_balance_wallet_rounded.codePoint,
    colorValue: const Color(0xFF81C784).toARGB32(),
    type: CategoryType.income,
  ),
  Category(
    id: 'freelance',
    name: 'Freelance',
    iconCode: Icons.work_rounded.codePoint,
    colorValue: const Color(0xFF4FC3F7).toARGB32(),
    type: CategoryType.income,
  ),
  Category(
    id: 'investment',
    name: 'Investment',
    iconCode: Icons.trending_up_rounded.codePoint,
    colorValue: const Color(0xFFFFD54F).toARGB32(),
    type: CategoryType.income,
  ),
  Category(
    id: 'gift',
    name: 'Gift',
    iconCode: Icons.card_giftcard_rounded.codePoint,
    colorValue: const Color(0xFFF06292).toARGB32(),
    type: CategoryType.income,
  ),
  Category(
    id: 'rental',
    name: 'Rental',
    iconCode: Icons.home_rounded.codePoint,
    colorValue: const Color(0xFFAED581).toARGB32(),
    type: CategoryType.income,
  ),
  Category(
    id: 'other_inc',
    name: 'Other',
    iconCode: Icons.more_horiz_rounded.codePoint,
    colorValue: const Color(0xFF90A4AE).toARGB32(),
    type: CategoryType.income,
  ),
];
