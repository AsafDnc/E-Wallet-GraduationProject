import 'package:flutter/material.dart';

class GoalModel {
  const GoalModel({
    required this.id,
    required this.title,
    required this.savedAmount,
    required this.targetAmount,
    required this.progress,
    required this.emoji,
    required this.iconBackground,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final int savedAmount;
  final int targetAmount;
  final double progress;
  final String emoji;
  final Color iconBackground;
  final bool isPinned;

  String get savingsLabel =>
      '\$${_formatNumber(savedAmount)} / \$${_formatNumber(targetAmount)}';
  String get currentAmountLabel => '\$${_formatNumber(savedAmount)}';
  String get targetAmountLabel => '/ \$${_formatNumber(targetAmount)}';
  String get percentLabel => '%${(progress * 100).round()}';

  static String _formatNumber(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buffer.write(',');
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }

  GoalModel copyWith({
    String? id,
    String? title,
    int? savedAmount,
    int? targetAmount,
    double? progress,
    String? emoji,
    Color? iconBackground,
    bool? isPinned,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      savedAmount: savedAmount ?? this.savedAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      progress: progress ?? this.progress,
      emoji: emoji ?? this.emoji,
      iconBackground: iconBackground ?? this.iconBackground,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
