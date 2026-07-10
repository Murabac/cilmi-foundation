import 'package:flutter/material.dart';

class CareRatingTheme {
  static Color colorFor(int rating) => switch (rating) {
        1 => const Color(0xFF059669),
        2 => const Color(0xFF34D399),
        3 => const Color(0xFFF59E0B),
        4 => const Color(0xFFEA580C),
        5 => const Color(0xFFDC2626),
        _ => const Color(0xFF34D399),
      };

  static String labelKey(int rating) => 'care_$rating';

  static bool isUrgent(int rating) => rating >= 4;
}

class AppTheme {
  static ThemeData light() {
    const seed = Color(0xFF1B4332);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
