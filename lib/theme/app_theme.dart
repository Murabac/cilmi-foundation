import 'package:flutter/material.dart';

/// Brand colors sampled from [assets/logo.png] (CILMI FOUNDATION).
class BrandColors {
  static const navy = Color(0xFF102850);
  static const gold = Color(0xFFB89020);
  static const cream = Color(0xFFF1EBD9);
  static const softNavy = Color(0xFF284060);
}

class CareRatingTheme {
  static const List<int> values = [1, 2, 3];

  /// Maps legacy 4–5 ratings to level 3. Values 1–3 are already valid.
  static int normalize(int rating) => switch (rating) {
        4 || 5 => 3,
        >= 1 && <= 3 => rating,
        _ => 1,
      };

  static Color colorFor(int rating) => switch (normalize(rating)) {
        1 => const Color(0xFF059669),
        2 => const Color(0xFFF59E0B),
        3 => const Color(0xFFDC2626),
        _ => const Color(0xFF059669),
      };

  static String labelKey(int rating) => 'care_${normalize(rating)}';

  static bool isUrgent(int rating) => normalize(rating) == 3;
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BrandColors.navy,
      primary: BrandColors.navy,
      secondary: BrandColors.gold,
      surface: BrandColors.cream,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BrandColors.cream,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: BrandColors.navy,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BrandColors.navy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BrandColors.gold,
        foregroundColor: BrandColors.navy,
      ),
    );
  }
}
