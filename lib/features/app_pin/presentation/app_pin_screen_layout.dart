import 'package:flutter/material.dart';

/// Shared layout metrics so [CreatePinScreen] and [ConfirmPinScreen] align the
/// PIN underline row and typography identically.
abstract final class AppPinScreenLayout {
  static const Color darkBackground = Color(0xFF121417);

  static const double darkPanelTopRadius = 32;

  /// Horizontal inset for the 6 digit fields (both screens).
  static const double pinHorizontalPadding = 28;

  /// Space from the dark panel’s top edge to the PIN row (both screens).
  static const double pinTopSpacingInDarkPanel = 18;

  /// Digit style above underlines (both screens).
  static const double digitFontSize = 30;
  static const FontWeight digitFontWeight = FontWeight.w700;
  static const double digitLetterSpacing = 1.2;

  /// Underline stroke (both screens).
  static const double underlineBorderWidth = 2.5;

  /// [TextField] content padding tuning the digit baseline vs underline.
  static const EdgeInsets pinFieldContentPadding = EdgeInsets.only(
    top: 6,
    bottom: 8,
  );

  /// Horizontal gap between each digit column.
  static const double digitCellHorizontalPadding = 4;

  /// Gap between PIN row and content directly below it (instructions / errors).
  static const double belowPinSpacing = 18;
}
