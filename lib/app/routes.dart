import 'package:flutter/material.dart';

// Auth
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/role_select_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';

// Role shells
import '../features/worker/presentation/screens/worker_shell.dart';
import '../features/engineer/presentation/screens/engineer_shell.dart';
import '../features/contractor/presentation/screens/contractor_shell.dart';

class AppRoutes {
  static const splash = '/splash';
  static const role = '/role';
  static const login = '/login';

  static const workerHome = '/worker/home';
  static const engineerHome = '/engineer/home';
  static const contractorHome = '/contractor/home';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    role: (_) => const RoleSelectScreen(),
    login: (_) => const LoginScreen(),

    workerHome: (_) => const WorkerShell(),
    engineerHome: (_) => const EngineerShell(),
    contractorHome: (_) => const ContractorShell(),
  };
}
