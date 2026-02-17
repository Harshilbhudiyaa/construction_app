import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Design System 🎨
/// 
/// Core Philosophy: "Professional, Clean, & Efficient"
/// Combines deep professional blues with vibrant accents and glassmorphism.
class DesignSystem {
  // ---------------------------------------------------------------------------
  // 1. Color Palette 🌈
  // ---------------------------------------------------------------------------

  // Primary Colors (Brand)
  static const Color deepNavy = Color(0xFF1A237E);    // Primary Brand
  static const Color royalBlue = Color(0xFF283593);   // Secondary Brand
  static const Color electricBlue = Color(0xFF3949AB); // Interactive
  static const Color softBlue = Color(0xFF5C6BC0);    // Accents

  // Functional Colors
  static const Color success = Color(0xFF00C853);     // Green Accent
  static const Color warning = Color(0xFFFFAB00);     // Amber Accent
  static const Color error = Color(0xFFD50000);       // Red Accent
  static const Color info = Color(0xFF29B6F6);        // Light Blue
  static const Color coolGrey = Color(0xFF78909C);    // Neutral Text/Icons
  static const Color softGold = Color(0xFFFFD740);    // Warm Accents

  // Background Gradients
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF020617), Color(0xFF0F172A)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [deepNavy, royalBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism System
  static Color glassColor(bool isDark) => 
      isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.7);
  
  static Color glassBorder(bool isDark) => 
      isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.4);

  // ---------------------------------------------------------------------------
  // 2. Typography ✍️
  // ---------------------------------------------------------------------------

  static TextTheme _buildTextTheme(bool isDark) {
    final baseColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryColor = isDark ? Colors.white70 : const Color(0xFF475569);

    return GoogleFonts.interTextTheme().copyWith(
      displayMedium: TextStyle(
        fontSize: 24, 
        fontWeight: FontWeight.w900, 
        color: baseColor,
        letterSpacing: -0.5,
      ), // Dashboard Headers
      headlineMedium: TextStyle(
        fontSize: 20, 
        fontWeight: FontWeight.w700, 
        color: baseColor,
      ), // Page Titles
      titleLarge: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.w600, 
        color: baseColor,
      ), // Section Headers
      bodyLarge: TextStyle(
        fontSize: 14, 
        fontWeight: FontWeight.w500, 
        color: baseColor,
      ), // Primary Content
      bodyMedium: TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.w400, 
        color: secondaryColor,
      ), // Secondary Text
      labelSmall: TextStyle(
        fontSize: 10, 
        fontWeight: FontWeight.w700, 
        color: secondaryColor,
        letterSpacing: 0.5,
      ), // Captions/Tags
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Theme Data Building 🏗️
  // ---------------------------------------------------------------------------

  static ThemeData buildTheme(bool isDark) {
    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return baseTheme.copyWith(
      primaryColor: deepNavy,
      scaffoldBackgroundColor: Colors.transparent, // Handled by ProfessionalPage background
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: deepNavy,
        secondary: royalBlue,
        tertiary: electricBlue,
        error: error,
        surface: isDark ? const Color(0xFF0F172A) : Colors.white,
        onSurface: textColor,
      ),
      textTheme: _buildTextTheme(isDark),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: glassColor(isDark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: electricBlue, width: 2),
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
