import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional Deep Blue Color Palette
class ConstructionColors {
  // Primary Blue Colors
  static const deepOrange = Color(0xFF1A237E);      // Deep Blue
  static const safetyYellow = Color(0xFF5C6BC0);    // Light Blue
  static const charcoalGray = Color(0xFF1E2B8F);    // Blue variant
  static const steelGray = Color(0xFF3949AB);       // Medium Blue
  static const concreteGray = Color(0xFF7986CB);    // Light Blue Gray
  static const darkGray = Color(0xFF283593);        // Dark Blue
  
  // Background Colors
  static const white = Color(0xFFFFFFFF);
  static const lightGray = Color(0xFFF5F7FA);
  static const blueprintBlue = Color(0xFFE8EAF6);   // Very light blue background
  
  // Text Colors - DARK for visibility on light backgrounds
  static const textPrimary = Color(0xFF1A237E);     // Deep blue for headings
  static const textSecondary = Color(0xFF37474F);   // Dark gray for body
  static const textTertiary = Color(0xFF78909C);    // Medium gray for labels
  
  // Status Colors
  static const successGreen = Color(0xFF4CAF50);
  static const warningAmber = Color(0xFFFFA726);
  static const errorRed = Color(0xFFE53935);
  static const infoBlue = Color(0xFF29B6F6);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const darkGradient = LinearGradient(
    colors: [Color(0xFF1E2B8F), Color(0xFF283593)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Spacing scale for consistent layouts
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

/// Animation durations and curves
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve bounceOut = Curves.easeOutBack;
  static const Curve smooth = Curves.easeOut;
}

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF1A237E),
      onPrimary: Colors.white,
      secondary: const Color(0xFF3949AB),
      onSecondary: Colors.white,
      error: ConstructionColors.errorRed,
      onError: Colors.white,
      background: const Color(0xFFF1F5F9), // Slate 100
      onBackground: Colors.black87,
      surface: Colors.white,
      onSurface: const Color(0xFF0F172A), // Slate 900
      surfaceVariant: const Color(0xFFE2E8F0), // Slate 200
      onSurfaceVariant: const Color(0xFF1E293B), // Slate 800
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF818CF8), // Indigo 400
      onPrimary: const Color(0xFF0F172A),
      secondary: const Color(0xFF94A3B8),
      onSecondary: const Color(0xFF0F172A),
      error: const Color(0xFFFB7185), // Rose 400
      onError: Colors.white,
      background: const Color(0xFF020617), // Slate 950
      onBackground: Colors.white,
      surface: const Color(0xFF0F172A), // Slate 900
      onSurface: Colors.white,
      surfaceVariant: const Color(0xFF1E293B), // Slate 800
      onSurfaceVariant: const Color(0xFFCBD5E1), // Slate 300
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    bool isDark = colorScheme.brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: isDark ? const Color(0xFFB0BEC5) : ConstructionColors.textSecondary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: isDark ? const Color(0xFFB0BEC5) : ConstructionColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: isDark ? const Color(0xFF78909C) : ConstructionColors.textTertiary,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withOpacity(isDark ? 0 : 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark ? BorderSide(color: colorScheme.onSurface.withOpacity(0.08)) : BorderSide.none,
        ),
        color: colorScheme.surface,
      ),
      
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colorScheme.surface.withOpacity(0.5) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF37474F) : const Color(0xFFBDBDBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF37474F) : const Color(0xFFBDBDBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: isDark ? const Color(0xFF78909C) : ConstructionColors.textTertiary),
        hintStyle: TextStyle(color: (isDark ? const Color(0xFF78909C) : ConstructionColors.textTertiary).withOpacity(0.6)),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.primary, width: 2),
          foregroundColor: colorScheme.primary,
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? colorScheme.surface : ConstructionColors.lightGray,
        selectedColor: colorScheme.primary.withOpacity(0.2),
        side: BorderSide(color: isDark ? const Color(0xFF37474F) : const Color(0xFFBDBDBD)),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: colorScheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      iconTheme: IconThemeData(
        color: isDark ? const Color(0xFF78909C) : ConstructionColors.textTertiary,
      ),
      
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
