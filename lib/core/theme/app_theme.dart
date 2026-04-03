import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/design_system.dart';

class AppTheme {
  // We now only support one fixed professional theme
  static ThemeData light() {
    return DesignSystem.buildTheme();
  }

  // Deprecated: Dark mode is removed, creating alias to main theme for safety
  static ThemeData dark() {
    return DesignSystem.buildTheme();
  }
}
