import 'package:flutter/material.dart';

// Auth
import 'package:construction_app/auth/splash_screen.dart';
import 'package:construction_app/auth/login_screen.dart';
import 'package:construction_app/auth/register_screen.dart';

// Shells
import 'package:construction_app/dashboard/contractor_shell.dart';

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
