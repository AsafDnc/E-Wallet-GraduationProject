import 'package:flutter/material.dart';

/// Single subscription row for [SubscriptionsScreen] and [UpcomingSubsWidget].
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
  });

  final String id;

  /// Full name on the subscriptions list (e.g. "Netflix Premium").
  final String displayName;

  /// Compact uppercase label for the home horizontal cards.
  final String shortNameUppercase;

  /// Monthly charge in USD.
  final double monthlyPrice;

  /// Days until the next billing date.
  final int daysUntilRenewal;

  /// Length of the billing cycle in days (used for ring progress).
  final int billingCycleDays;

  final int iconData;
  final Color iconBgColor;

  /// Ring fill: approaches 1.0 as renewal gets closer.
  double get billingProgress {
    if (billingCycleDays <= 0) return 1;
    final remaining = daysUntilRenewal.clamp(0, billingCycleDays);
    return 1 - (remaining / billingCycleDays);
  }

  String get priceDollarsText => '\$${monthlyPrice.toStringAsFixed(2)}';

  String get homePriceLine => '$priceDollarsText/mo';
}
