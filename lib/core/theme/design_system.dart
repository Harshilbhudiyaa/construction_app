import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';

/// Enterprise-Grade Construction ERP Design System 🏛️
class DesignSystem {
  // ---------------------------------------------------------------------------
  // 1. Color Palette (Mapped to AestheticTokens)
  // ---------------------------------------------------------------------------
  
  static const Color primary = bcNavy;
  static const Color accent = bcAmber;
  static const Color background = bcSurface;
  static const Color surface = bcCard;
  static const Color success = bcSuccess;
  static const Color error = bcDanger;
  static const Color warning = bcAmber;
  static const Color info = bcInfo;
  
  static const Color textPrimary = bcTextPrimary;
  static const Color textSecondary = bcTextSecondary;
  static const Color border = bcBorder;
  
  // Compatibility Tokens
  static const Color constructionYellow = accent;
  static const Color steelGrey = textSecondary;
  static const Color charcoalBlack = bcNavy;
  static const Color surfaceWhite = Colors.white;
  static const Color secondary = bcNavy;

  // Additional Compatibility Tokens
  static const Color deepNavy = bcNavy;
  static const Color primaryBlue = bcNavy;
  static const Color electricBlue = bcInfo;
  static const Color concreteGrey = Color(0xFF94A3B8);
  static const Color coolGrey = Color(0xFF64748B);

  // ---------------------------------------------------------------------------
  // Animation Tokens
  // ---------------------------------------------------------------------------
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 700);
  static const Duration animVerySlow = Duration(milliseconds: 1200);
  static const Curve animCurve = Curves.easeOutCubic;
  static const Curve animBounceCurve = Curves.elasticOut;
  static const Curve animSmoothCurve = Curves.easeInOutCubic;

  // ---------------------------------------------------------------------------
  // 2. Typography (Premium Enterprise Fonts)
  // ---------------------------------------------------------------------------

  static TextTheme _buildTextTheme() {
    return GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32, 
        fontWeight: FontWeight.w900, 
        color: textPrimary,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28, 
        fontWeight: FontWeight.w800, 
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24, 
        fontWeight: FontWeight.w700, 
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 20, 
        fontWeight: FontWeight.w700, 
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, 
        fontWeight: FontWeight.w600, 
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15, 
        fontWeight: FontWeight.w500, 
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14, 
        fontWeight: FontWeight.w400, 
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 13, 
        fontWeight: FontWeight.w700, 
        color: textPrimary,
        letterSpacing: 0.5,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Component Themes
  // ---------------------------------------------------------------------------

  static ThemeData buildTheme() {
    final baseTheme = ThemeData.light();

    return baseTheme.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      textTheme: _buildTextTheme(),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        color: surface,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(size: 22),
        titleTextStyle: TextStyle(
          color: primary, 
          fontSize: 20, 
          fontWeight: FontWeight.w800,
        ),
      ),
      
      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        disabledColor: const Color(0xFFE2E8F0),
        selectedColor: primary.withValues(alpha: 0.1),
        secondarySelectedColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.white,
      ),

      // Animation & Interaction
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
