import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const seed = Color(0xFF2563EB);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.grey.shade50,
      textTheme: Typography.blackMountainView.apply(
        bodyColor: Colors.black.withOpacity(0.9),
        displayColor: Colors.black.withOpacity(0.9),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        selectedColor: colorScheme.primary.withOpacity(0.1),
        backgroundColor: Colors.grey.shade200,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
