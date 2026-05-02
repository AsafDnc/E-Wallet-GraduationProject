import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';

/// Saving goal shown in lists and charts.
///
/// Backed by Supabase table `saving_goals`:
/// `id`, `user_id`, `title`, `saved_amount`, `target_amount`, `created_at`.
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
      '$appCurrencySymbolSpaced${_formatNumber(savedAmount)} / $appCurrencySymbolSpaced${_formatNumber(targetAmount)}';
  String get currentAmountLabel =>
      '$appCurrencySymbolSpaced${_formatNumber(savedAmount)}';
  String get targetAmountLabel =>
      '/ $appCurrencySymbolSpaced${_formatNumber(targetAmount)}';
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

  /// Row from PostgREST / Supabase `saving_goals` select.
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final title = json['title'] as String? ?? '';
    final saved = _numToInt(json['saved_amount']);
    final target = _numToInt(json['target_amount']);
    final ratio = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;

    return GoalModel(
      id: id,
      title: title,
      savedAmount: saved,
      targetAmount: target,
      progress: ratio,
      emoji: emojiForTitle(title),
      iconBackground: colorForId(id),
      isPinned: false,
    );
  }

  /// Insert payload (include `user_id` from auth at call site).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'saved_amount': savedAmount,
      'target_amount': targetAmount,
    };
  }

  static int _numToInt(Object? value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return double.tryParse(value)?.round() ?? 0;
    return 0;
  }

  static String emojiForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('car')) return '🚙';
    if (lower.contains('laptop') || lower.contains('pc')) return '💻';
    if (lower.contains('holiday') || lower.contains('vacation')) return '🏖️';
    if (lower.contains('clothes') || lower.contains('winter')) return '🧥';
    return '🎯';
  }

  static Color colorForId(String id) {
    const palette = <Color>[
      Color(0xFFA74CFF),
      Color(0xFFFFD400),
      Color(0xFFFF285A),
      Color(0xFF7BFF6A),
      Color(0xFF1D75DD),
      Color(0xFFFF6B6B),
    ];
    var h = 0;
    for (final c in id.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return palette[h % palette.length];
  }
}
