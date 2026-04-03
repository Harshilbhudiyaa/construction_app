import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  // Theme is now fixed to Professional Construction Theme
  // This service is kept for compatibility but enforces a single theme.
  
  bool get isDarkMode => false; // Always light/construction mode

  ThemeService() {
    // No-op: Transformation to single theme
  }

  Future<void> toggleTheme() async {
    // No-op: Theme is fixed
    notifyListeners();
  }
}
