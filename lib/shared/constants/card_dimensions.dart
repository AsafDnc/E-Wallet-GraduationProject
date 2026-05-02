import 'package:flutter/material.dart';

/// Shared card dimension constants used by both [SubscriptionCardWidget]
/// and [GoalCardWidget] to ensure identical card sizes across both lists.
const double kCardRadius = 18;
const EdgeInsets kCardPadding = EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 14,
);
const EdgeInsets kCardMargin = EdgeInsets.only(bottom: 10);
const BorderRadius kTileRadius = BorderRadius.all(Radius.circular(kCardRadius));
const List<BoxShadow> kCardShadow = [
  BoxShadow(color: Color(0x12222B33), blurRadius: 18, offset: Offset(0, 4)),
];
