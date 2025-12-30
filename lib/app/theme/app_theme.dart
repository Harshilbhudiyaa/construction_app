import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF4F46E5), // modern indigo
      brightness: Brightness.light,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
      ),
    );
  }
}
