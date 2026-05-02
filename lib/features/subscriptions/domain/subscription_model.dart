import 'package:flutter/material.dart';

/// Single subscription row for list and home widgets.
///
/// Backed by Supabase table `subscriptions`:
/// `id`, `user_id`, `name`, `monthly_price`, `billing_cycle`, `renewal_day`, `created_at`.
class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.displayName,
    required this.shortNameUppercase,
    required this.monthlyPrice,
    required this.daysUntilRenewal,
    required this.billingCycleDays,
    required this.iconData,
    required this.iconBgColor,
    required this.renewalDayOfMonth,
  });

  final String id;

  /// Full name on the subscriptions list (e.g. "Netflix Premium").
  final String displayName;

  /// Compact uppercase label for the home horizontal cards.
  final String shortNameUppercase;

  /// Monthly charge in USD.
  final double monthlyPrice;

  /// Days until the next billing date (derived for UI).
  final int daysUntilRenewal;

  /// Length of the billing cycle in days (used for ring progress).
  final int billingCycleDays;

  final int iconData;
  final Color iconBgColor;

  /// Calendar day of month (1–31) stored in `renewal_day`.
  final int renewalDayOfMonth;

  /// Ring fill: approaches 1.0 as renewal gets closer.
  double get billingProgress {
    if (billingCycleDays <= 0) return 1;
    final remaining = daysUntilRenewal.clamp(0, billingCycleDays);
    return 1 - (remaining / billingCycleDays);
  }

  String get priceDollarsText => '\$${monthlyPrice.toStringAsFixed(2)}';

  String get homePriceLine => '$priceDollarsText/mo';

  SubscriptionModel copyWith({
    String? id,
    String? displayName,
    String? shortNameUppercase,
    double? monthlyPrice,
    int? daysUntilRenewal,
    int? billingCycleDays,
    int? iconData,
    Color? iconBgColor,
    int? renewalDayOfMonth,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      shortNameUppercase: shortNameUppercase ?? this.shortNameUppercase,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      daysUntilRenewal: daysUntilRenewal ?? this.daysUntilRenewal,
      billingCycleDays: billingCycleDays ?? this.billingCycleDays,
      iconData: iconData ?? this.iconData,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      renewalDayOfMonth: renewalDayOfMonth ?? this.renewalDayOfMonth,
    );
  }

  /// Row from PostgREST / Supabase `subscriptions` select.
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final id = json['id'] as String? ?? '';
    final monthlyPrice = _parseDouble(json['monthly_price']);
    final billingCycle = json['billing_cycle'] as String? ?? 'monthly';
    final renewalDay = _parseInt(
      json['renewal_day'],
      fallback: DateTime.now().day,
    ).clamp(1, 31);
    final cycleDays = billingCycleDaysFromDbLabel(billingCycle);

    return SubscriptionModel(
      id: id,
      displayName: name,
      shortNameUppercase: shortNameFromDisplay(name),
      monthlyPrice: monthlyPrice,
      daysUntilRenewal: daysUntilFromRenewalDay(renewalDay, cycleDays),
      billingCycleDays: cycleDays,
      iconData: defaultIconCodePointForName(name),
      iconBgColor: colorForName(name),
      renewalDayOfMonth: renewalDay,
    );
  }

  /// Insert payload (caller adds `user_id`).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': displayName,
      'monthly_price': monthlyPrice,
      'billing_cycle': billingCycleLabelFromDays(billingCycleDays),
      'renewal_day': renewalDayOfMonth.clamp(1, 31),
    };
  }

  static double _parseDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _parseInt(Object? value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static String shortNameFromDisplay(String name) {
    final trimmed = name.trim().toUpperCase();
    if (trimmed.isEmpty) return 'SUB';
    if (trimmed.length <= 14) return trimmed;
    return '${trimmed.substring(0, 13)}…';
  }

  static int billingCycleDaysFromDbLabel(String label) {
    switch (label.toLowerCase()) {
      case 'yearly':
      case 'annual':
        return 365;
      case 'weekly':
        return 7;
      case 'monthly':
      default:
        return 30;
    }
  }

  static String billingCycleLabelFromDays(int days) {
    if (days >= 300) return 'yearly';
    if (days <= 10) return 'weekly';
    return 'monthly';
  }

  /// Next occurrence of [renewalDay] (1–31) from today; returns days until that date.
  static int daysUntilFromRenewalDay(int renewalDay, int billingCycleDays) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = nextRenewalDate(today, renewalDay.clamp(1, 31));
    var diff = next.difference(today).inDays;
    if (diff < 0) diff = 0;
    if (billingCycleDays > 0 && diff > billingCycleDays) {
      diff = diff % billingCycleDays;
    }
    return diff;
  }

  static DateTime nextRenewalDate(DateTime fromDay, int desiredDayOfMonth) {
    var y = fromDay.year;
    var m = fromDay.month;
    var lastDay = DateTime(y, m + 1, 0).day;
    var day = desiredDayOfMonth > lastDay ? lastDay : desiredDayOfMonth;
    var candidate = DateTime(y, m, day);
    if (!candidate.isAfter(fromDay)) {
      if (m == 12) {
        y += 1;
        m = 1;
      } else {
        m += 1;
      }
      lastDay = DateTime(y, m + 1, 0).day;
      day = desiredDayOfMonth > lastDay ? lastDay : desiredDayOfMonth;
      candidate = DateTime(y, m, day);
    }
    return candidate;
  }

  static int defaultIconCodePointForName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('netflix')) {
      return Icons.play_circle_fill_rounded.codePoint;
    }
    if (lower.contains('music') || lower.contains('spotify')) {
      return Icons.music_note_rounded.codePoint;
    }
    if (lower.contains('prime') || lower.contains('video')) {
      return Icons.video_library_rounded.codePoint;
    }
    return Icons.subscriptions_rounded.codePoint;
  }

  static Color colorForName(String name) {
    const palette = <Color>[
      Color(0xFFE50914),
      Color(0xFF00A8E1),
      Color(0xFFFC3C44),
      Color(0xFF00C4CC),
      Color(0xFFFF0000),
      Color(0xFF1D75DD),
      Color(0xFF27AE60),
      Color(0xFFA74CFF),
    ];
    var h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return palette[h % palette.length];
  }
}
