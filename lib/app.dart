import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/mock_inventory_service.dart';
import 'package:construction_app/services/theme_service.dart';
import 'package:construction_app/services/auth_service.dart';
import 'package:construction_app/shared/theme/app_theme.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => MockInventoryService()..initDemoData()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            title: 'Smart Construction',
            debugShowCheckedModeBanner: false,
            theme: themeService.isDarkMode ? AppTheme.dark() : AppTheme.light(),
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
