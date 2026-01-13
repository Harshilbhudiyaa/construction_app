import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/mock_engineer_service.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MockEngineerService()..initDemoData(),
      child: MaterialApp(
        title: 'Smart Construction',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
