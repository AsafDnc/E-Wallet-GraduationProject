import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralised theme definitions for the E-Wallet app.
///
/// Palette (Light):
///   Background  → #F3F7FD
///   Primary     → #1D75DD
///   Dark text   → #222B33
///   Card bg     → #FFFFFF  (separated from bg by soft shadow)
///   Subtitle    → #7B8794
///
/// Palette (Dark):
///   Background  → #0D0E12
///   Primary     → #1D75DD
///   Card bg     → #1A1C20
///   Subtitle    → rgba(255,255,255,.54)
abstract final class AppTheme {
  // ─── Brand palette ────────────────────────────────────────────────────────
  static const primary = Color(0xFF1D75DD);

  /// Swipe-to-pin [SlidableAction] background (RGB 0, 122, 255).
  static const pinSwipeBackground = Color.fromRGBO(0, 122, 255, 1);

  // Light
  static const _bgLight = Color(0xFFF3F7FD);
  static const _textLight = Color(0xFF222B33);
  static const _cardLight = Color(0xFFFFFFFF);
  static const _subtitleLight = Color(0xFF7B8794);
  static const _dividerLight = Color(0xFFDDE3EE);
  static const _surfaceHighLight = Color(0xFFEBF0F8);

  // Dark
  static const _bgDark = Color(0xFF0D0E12);
  static const _cardDark = Color(0xFF1A1C20);
  static const _cardHighDark = Color(0xFF2A2D32);

  // ─── Soft card shadow (light mode only) ───────────────────────────────────
  /// Returns a subtle, highly-dispersed shadow for cards in light mode.
  /// Returns an empty list in dark mode (no shadow needed).
  static List<BoxShadow> cardShadow(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) return const [];
    return const [
      BoxShadow(
        color: Color(0x12222B33),
        blurRadius: 24,
        spreadRadius: 0,
        offset: Offset(0, 6),
      ),
    ];
  }

  /// Convenience: white card in light / dark card in dark, with shadow.
  static BoxDecoration cardDecoration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      boxShadow: cardShadow(context),
    );
  }

  // ─── Light theme ──────────────────────────────────────────────────────────
  static ThemeData get light {
    final cs = ColorScheme(
      brightness: Brightness.light,
      // Primary
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD6E8FB),
      onPrimaryContainer: const Color(0xFF003A70),
      // Secondary
      secondary: const Color(0xFF5E6B7A),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFDDE7F0),
      onSecondaryContainer: _textLight,
      // Tertiary
      tertiary: const Color(0xFF3E7FA7),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFCDE5F5),
      onTertiaryContainer: _textLight,
      // Error
      error: const Color(0xFFE53935),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      // Surface
      surface: _bgLight,
      onSurface: _textLight,
      surfaceContainerLowest: const Color(0xFFFAFCFF),
      surfaceContainerLow: const Color(0xFFF5F8FD),
      surfaceContainer: _cardLight,
      surfaceContainerHigh: const Color(0xFFF0F4FA),
      surfaceContainerHighest: _surfaceHighLight,
      onSurfaceVariant: _subtitleLight,
      outline: const Color(0xFFBDC7D4),
      outlineVariant: _dividerLight,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: _textLight,
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFF9DCBFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: _bgLight,
      fontFamily: 'SF Pro',
      appBarTheme: AppBarTheme(
        backgroundColor: _bgLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textLight),
        titleTextStyle: const TextStyle(
          color: _textLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'SF Pro',
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _dividerLight,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: _subtitleLight),
      cardTheme: const CardThemeData(
        color: _cardLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // ─── Dark theme ───────────────────────────────────────────────────────────
  static ThemeData get dark {
    final cs = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF003A70),
      onPrimaryContainer: const Color(0xFFD6E8FB),
      secondary: const Color(0xFF9AAAB8),
      onSecondary: _bgDark,
      secondaryContainer: const Color(0xFF3A3F47),
      onSecondaryContainer: Colors.white,
      tertiary: const Color(0xFF7BBDE4),
      onTertiary: _bgDark,
      tertiaryContainer: const Color(0xFF2D5F7A),
      onTertiaryContainer: Colors.white,
      error: const Color(0xFFFF6B6B),
      onError: Colors.black,
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: _bgDark,
      onSurface: Colors.white,
      surfaceContainerLowest: const Color(0xFF0A0C10),
      surfaceContainerLow: const Color(0xFF111318),
      surfaceContainer: _cardDark,
      surfaceContainerHigh: const Color(0xFF1F2228),
      surfaceContainerHighest: _cardHighDark,
      onSurfaceVariant: Colors.white54,
      outline: const Color(0xFF3C4048),
      outlineVariant: const Color(0xFF2A2D32),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: _bgDark,
      inversePrimary: primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: _bgDark,
      fontFamily: 'SF Pro',
      appBarTheme: const AppBarTheme(
        backgroundColor: _bgDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'SF Pro',
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2D32),
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: Colors.white54),
      cardTheme: const CardThemeData(
        color: _cardDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
