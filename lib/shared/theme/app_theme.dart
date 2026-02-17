import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:construction_app/shared/theme/design_system.dart';

/// Professional Deep Blue Color Palette - Forwarding to DesignSystem
class ConstructionColors {
  // Primary Blue Colors
  static const deepOrange = DesignSystem.deepNavy;      // Deep Blue
  static const safetyYellow = DesignSystem.softBlue;    // Light Blue
  static const charcoalGray = DesignSystem.royalBlue;    // Blue variant
  static const steelGray = DesignSystem.electricBlue;       // Medium Blue
  static const concreteGray = Color(0xFF7986CB);    // Light Blue Gray
  static const darkGray = Color(0xFF283593);        // Dark Blue
  
  // Background Colors
  static const white = Color(0xFFFFFFFF);
  static const lightGray = Color(0xFFF5F7FA);
  static const blueprintBlue = Color(0xFFE8EAF6);   // Very light blue background
  
  // Text Colors - DARK for visibility on light backgrounds
  static const textPrimary = DesignSystem.deepNavy;     // Deep blue for headings
  static const textSecondary = Color(0xFF37474F);   // Dark gray for body
  static const textTertiary = Color(0xFF78909C);    // Medium gray for labels
  
  // Status Colors
  static const successGreen = DesignSystem.success;
  static const warningAmber = DesignSystem.warning;
  static const errorRed = DesignSystem.error;
  static const infoBlue = DesignSystem.info;
  
  // Gradients
  static const primaryGradient = DesignSystem.primaryGradient;
  
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
    return DesignSystem.buildTheme(false);
  }

  static ThemeData dark() {
    return DesignSystem.buildTheme(true);
  }
}
