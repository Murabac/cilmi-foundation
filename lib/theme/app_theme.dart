import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colours from [design/DESIGN.md] (teal & gold Family Crown system).
class BrandColors {
  static const teal = Color(0xFF0F3D3E);
  static const tealMid = Color(0xFF1F6F6B);
  static const mint = Color(0xFFDCEBE7);
  static const gold = Color(0xFFC9A227);
  static const onGold = Color(0xFF1E1A0B);
  static const linen = Color(0xFFF4F1EA);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE3DDD0);
  static const ink = Color(0xFF16302F);
  static const muted = Color(0xFF56625F);
  static const onTealMuted = Color(0xFFC9DAD6);
  static const paid = Color(0xFF1E7A4C);
  static const pending = Color(0xFFB26A00);
  static const pendingInk = Color(0xFF9A5B00);
  static const pendingBg = Color(0xFFFBEFD9);
  static const urgent = Color(0xFFB42318);
  static const urgentBg = Color(0xFFFBE4E1);
}

class CareRatingTheme {
  static const List<int> values = [1, 2, 3];

  /// Maps legacy 4–5 ratings to level 3. Values 1–3 are already valid.
  static int normalize(int rating) => switch (rating) {
        4 || 5 => 3,
        >= 1 && <= 3 => rating,
        _ => 1,
      };

  /// 1 Deggan · 2 Cadaadis · 3 U baahan gargaar ([design/DESIGN.md]).
  static Color colorFor(int rating) => switch (normalize(rating)) {
        1 => BrandColors.paid,
        2 => BrandColors.pending,
        3 => BrandColors.urgent,
        _ => BrandColors.paid,
      };

  static String labelKey(int rating) => 'care_${normalize(rating)}';

  static bool isUrgent(int rating) => normalize(rating) == 3;
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: BrandColors.teal,
        onPrimary: Colors.white,
        secondary: BrandColors.gold,
        onSecondary: BrandColors.onGold,
        surface: BrandColors.surface,
        onSurface: BrandColors.ink,
        error: BrandColors.urgent,
        onError: Colors.white,
        outline: BrandColors.border,
      ),
      scaffoldBackgroundColor: BrandColors.linen,
    );

    final manrope = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: BrandColors.ink,
      displayColor: BrandColors.ink,
    );

    return base.copyWith(
      textTheme: manrope.copyWith(
        headlineLarge: manrope.headlineLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: BrandColors.ink,
        ),
        headlineMedium: manrope.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: BrandColors.ink,
        ),
        titleLarge: manrope.titleLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: BrandColors.ink,
        ),
        titleMedium: manrope.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: BrandColors.ink,
        ),
        bodyLarge: manrope.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: BrandColors.ink,
        ),
        bodyMedium: manrope.bodyMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: BrandColors.ink,
        ),
        bodySmall: manrope.bodySmall?.copyWith(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: BrandColors.muted,
        ),
        labelLarge: manrope.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: BrandColors.ink,
        ),
        labelMedium: manrope.labelMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.06 * 13,
          color: BrandColors.muted,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: BrandColors.teal,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
        titleTextStyle: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        toolbarTextStyle: GoogleFonts.manrope(
          color: BrandColors.onTealMuted,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: BrandColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: BrandColors.border),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BrandColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BrandColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BrandColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BrandColors.teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BrandColors.urgent),
        ),
        labelStyle: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: BrandColors.muted,
        ),
        hintStyle: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: BrandColors.muted,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BrandColors.teal,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.manrope(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BrandColors.teal,
          minimumSize: const Size(48, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.manrope(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          side: const BorderSide(color: BrandColors.teal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BrandColors.tealMid,
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          minimumSize: const Size(48, 48),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BrandColors.mint,
        selectedColor: BrandColors.mint,
        disabledColor: BrandColors.linen,
        labelStyle: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: BrandColors.teal,
        ),
        secondaryLabelStyle: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: BrandColors.ink,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
          side: BorderSide.none,
        ),
        side: BorderSide.none,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BrandColors.gold,
        foregroundColor: BrandColors.onGold,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(
        color: BrandColors.border,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BrandColors.teal,
        indicatorColor: BrandColors.gold,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? BrandColors.onGold : const Color(0xFFBFD9D4),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: active ? BrandColors.onGold : const Color(0xFFBFD9D4),
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: BrandColors.tealMid,
        linearTrackColor: BrandColors.mint,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BrandColors.ink,
        contentTextStyle: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
