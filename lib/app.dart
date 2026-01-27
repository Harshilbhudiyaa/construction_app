import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/mock_engineer_service.dart';
import 'routes.dart';
import 'package:construction_app/shared/theme/app_theme.dart';

import 'package:construction_app/services/auth_service.dart';
import 'package:construction_app/services/mock_machine_service.dart';
import 'package:construction_app/services/mock_notification_service.dart';
import 'package:construction_app/services/mock_tool_service.dart';
import 'package:construction_app/services/mock_worker_service.dart';
import 'package:construction_app/services/payment_service.dart';
import 'package:construction_app/services/site_service.dart';
import 'package:construction_app/services/theme_service.dart';
import 'package:construction_app/services/inventory_service.dart';
import 'package:construction_app/services/approval_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => MockEngineerService()..initDemoData()),
        ChangeNotifierProvider(create: (_) => MockWorkerService()..initDemoData()),
        ChangeNotifierProvider(create: (_) => SiteService()),
        ChangeNotifierProvider(create: (_) => MockNotificationService()),
        ChangeNotifierProvider(create: (_) => MockMachineService()),
        ChangeNotifierProvider(create: (_) => MockToolService()),
        ChangeNotifierProvider(create: (_) => PaymentService()),
        Provider(create: (_) => InventoryService()),
        ChangeNotifierProvider(create: (_) => ApprovalService()),
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
