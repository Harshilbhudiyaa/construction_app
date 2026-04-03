import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/core/services/theme_service.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/core/services/reporting_service.dart';
import 'package:construction_app/core/theme/app_theme.dart';
import 'package:construction_app/core/routing/app_router.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/payment_repository.dart';
import 'package:construction_app/data/repositories/ledger_repository.dart';
import 'package:construction_app/data/repositories/milestone_repository.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/core/services/workflow_service.dart';
import 'package:construction_app/data/repositories/calculation_repository.dart';
import 'package:construction_app/data/repositories/labour_repository.dart';
// New repositories for redesigned modules
import 'package:construction_app/data/repositories/worker_repository.dart';
import 'package:construction_app/data/repositories/stock_entry_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthRepository()),
        ChangeNotifierProvider(create: (_) => InventoryRepository()..initDemoData()),
        ChangeNotifierProvider(create: (_) => SiteRepository()),
        ChangeNotifierProvider(create: (_) => PaymentRepository()),
        ChangeNotifierProvider(create: (_) => LedgerRepository()),
        ChangeNotifierProvider(create: (_) => PartyRepository()),
        ChangeNotifierProvider(create: (_) => MilestoneRepository()),
        ChangeNotifierProvider(create: (_) => CalculationRepository()),
        ChangeNotifierProvider(create: (_) => LabourRepository()),
        // New providers
        ChangeNotifierProvider(create: (_) => WorkerRepository()),
        ChangeNotifierProvider(create: (_) => StockEntryRepository()),
        ChangeNotifierProxyProvider5<InventoryRepository, LedgerRepository, PaymentRepository, SiteRepository, PartyRepository, WorkflowService>(
          create: (context) => WorkflowService(
            inventoryRepo: context.read<InventoryRepository>(),
            ledgerRepo: context.read<LedgerRepository>(),
            paymentRepo: context.read<PaymentRepository>(),
            siteRepo: context.read<SiteRepository>(),
            partyRepo: context.read<PartyRepository>(),
          ),
          update: (context, inv, led, pay, site, party, prev) => WorkflowService(
            inventoryRepo: inv,
            ledgerRepo: led,
            paymentRepo: pay,
            siteRepo: site,
            partyRepo: party,
          ),
        ),
        ChangeNotifierProxyProvider4<InventoryRepository, LabourRepository, LedgerRepository, SiteRepository, ReportingService>(
          create: (context) => ReportingService(
            context.read<InventoryRepository>(),
            labourRepo: context.read<LabourRepository>(),
            ledgerRepo: context.read<LedgerRepository>(),
            siteRepo: context.read<SiteRepository>(),
          ),
          update: (context, inventory, labour, ledger, site, previous) => ReportingService(
            inventory,
            labourRepo: labour,
            ledgerRepo: ledger,
            siteRepo: site,
          ),
        ),
      ],
      child: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartConstruction',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
