import 'package:flutter/material.dart';

/// Shared layout metrics so [CreatePinScreen] and [ConfirmPinScreen] align the
/// PIN underline row and typography identically.
abstract final class AppPinScreenLayout {
  static const Color darkBackground = Color(0xFF121417);

  static const double darkPanelTopRadius = 32;

  /// Horizontal inset for the 6 digit fields (both screens).
  static const double pinHorizontalPadding = 28;

  /// First gap inside the dark panel (below the white [AppBar]).
  static const double darkPanelInnerTopPadding = 18;

  /// Reserved vertical space for the instruction line(s) above the PIN row.
  /// [ConfirmPinScreen] uses the same height as an empty slot so the PIN row
  /// aligns with [CreatePinScreen].
  static const double instructionSlotHeight = 76;

  /// Gap between instruction slot and PIN row (both screens).
  static const double instructionToPinGap = 16;

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

  /// Gap between PIN row and the next block (bullets on create, error on confirm).
  static const double belowPinSpacing = 20;

  /// Reserved height for the confirm mismatch line (opacity 0 when hidden).
  static const double confirmMismatchSlotHeight = 24;

  // ─── Custom numpad (shared) ─────────────────────────────────────────────

  static const double numpadDigitFontSize = 34;
  static const FontWeight numpadDigitFontWeight = FontWeight.w700;

  /// Vertical padding inside the numpad tray (smaller top = keyboard sits higher).
  static const double numpadPaddingTop = 2;
  static const double numpadPaddingHorizontal = 12;
  static const double numpadPaddingBottom = 10;

  /// Space between numpad rows.
  static const double numpadRowGap = 8;

  /// Minimum tap target height per key.
  static const double numpadKeyHeight = 58;

  static const double numpadBackspaceIconSize = 28;
}
