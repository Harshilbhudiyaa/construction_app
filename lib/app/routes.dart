import 'package:flutter/material.dart';

// Auth
import '../features/auth/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';

// Shells
import '../features/contractor/contractor_shell.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    dashboard: (_) => const ContractorShell(),
  };
}
