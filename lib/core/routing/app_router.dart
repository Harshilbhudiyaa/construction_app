import 'package:flutter/material.dart';

// Auth
import 'package:construction_app/features/auth/splash_screen.dart';
import 'package:construction_app/features/auth/login_screen.dart';
import 'package:construction_app/features/auth/register_screen.dart';

// Shell
import 'package:construction_app/features/dashboard/contractor_shell.dart';
import 'package:construction_app/features/dashboard/site_management_screen.dart';

// Ledger / Payments
import 'package:construction_app/features/ledger/screens/payment_history_screen.dart';
import 'package:construction_app/features/ledger/screens/party_management_screen.dart';
import 'package:construction_app/features/ledger/screens/ledger_overview_screen.dart';

// Inventory (legacy — keep untouched so existing data still works)
import 'package:construction_app/features/inventory/screens/inward_management_dashboard_screen.dart';
import 'package:construction_app/features/inventory/screens/stock_operations_screen.dart';
import 'package:construction_app/features/inventory/screens/material_master_screen.dart';
import 'package:construction_app/features/inventory/screens/add_edit_item_screen.dart';
import 'package:construction_app/features/inventory/screens/item_detail_screen.dart';
import 'package:construction_app/features/inventory/screens/inward_entry_form_screen.dart';

// Reports
import 'package:construction_app/features/reports/screens/advanced_reports_screen.dart';
import 'package:construction_app/features/reports/screens/financial_summary_screen.dart';

// Milestones (legacy)
import 'package:construction_app/features/milestones/screens/project_milestones_screen.dart';

// Labour / Contractors (legacy screens reused by new shell)
import 'package:construction_app/features/labour/screens/labour_list_screen.dart';
import 'package:construction_app/features/labour/screens/labour_entry_form_screen.dart';
import 'package:construction_app/features/labour/screens/labour_detail_screen.dart';
import 'package:construction_app/data/models/labour_entry_model.dart';

// ── New ERP-lite screens ─────────────────────────────────────────────────────
import 'package:construction_app/features/materials/material_catalog_screen.dart';
import 'package:construction_app/features/materials/material_detail_screen.dart';
import 'package:construction_app/features/suppliers/supplier_list_screen.dart';
import 'package:construction_app/features/suppliers/supplier_detail_screen.dart';
import 'package:construction_app/features/stock/stock_hub_screen.dart';
import 'package:construction_app/features/workers/worker_list_screen.dart';
import 'package:construction_app/features/contractors/contractor_list_screen.dart';

// Calculators (UNTOUCHED)
import 'package:construction_app/features/calculators/screens/unified_calculator_screen.dart';
import 'package:construction_app/features/calculators/screens/smart_calculator_wizard.dart';

class AppRoutes {
  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String splash   = '/';
  static const String login    = '/login';
  static const String register = '/register';

  // ── Shell ────────────────────────────────────────────────────────────────────
  static const String dashboard      = '/dashboard';
  static const String siteManagement = '/site-management';

  // ── New ERP-lite routes ───────────────────────────────────────────────────────
  static const String materialCatalog = '/materials';
  static const String materialDetail  = '/material/detail';
  static const String supplierList    = '/suppliers';
  static const String supplierDetail  = '/supplier/detail';
  static const String stockHub        = '/stock/hub';
  static const String workerList      = '/workers';
  static const String contractorList  = '/contractors';

  // ── Legacy routes (kept for backward compatibility) ──────────────────────────
  static const String reports          = '/reports';
  static const String paymentHistory   = '/payment-history';
  static const String inwardManagement = '/inward-management';
  static const String stockOperations  = '/stock-operations';
  static const String materialMaster   = '/material-master';
  static const String inwardEntry      = '/inward-entry';
  static const String partyLedger      = '/party-ledger';
  static const String milestones       = '/milestones';
  static const String financialSummary = '/financial-summary';
  static const String addItem          = '/add-item';
  static const String editItem         = '/edit-item';
  static const String itemDetail       = '/item-detail';
  static const String labourList       = '/labour';
  static const String labourEntry      = '/labour-entry';
  static const String labourDetail     = '/labour-detail';
  // Legacy alias kept for any existing code that references suppliers via old route
  static const String suppliers        = '/suppliers-legacy';

  // ── Calculators (PROTECTED — no changes allowed) ──────────────────────────────
  static const String calculatorHome  = '/calculators';
  static const String smartCalcWizard = '/calc-wizard';

  // ── Route map ─────────────────────────────────────────────────────────────────
  static Map<String, WidgetBuilder> get routes => {
    // Auth
    splash:   (_) => const SplashScreen(),
    login:    (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),

    // Shell
    dashboard:      (_) => const ContractorShell(),
    siteManagement: (_) => const SiteManagementScreen(),

    // ── New screens ─────────────────────────────────────────────────────────────
    materialCatalog: (_) => const MaterialCatalogScreen(),
    materialDetail: (ctx) {
      final id = ModalRoute.of(ctx)!.settings.arguments as String;
      return MaterialDetailScreen(materialId: id);
    },
    supplierList: (_) => const SupplierListScreen(),
    supplierDetail: (ctx) {
      final id = ModalRoute.of(ctx)!.settings.arguments as String;
      return SupplierDetailScreen(supplierId: id);
    },
    stockHub:      (_) => const StockHubScreen(),
    workerList:    (_) => const WorkerListScreen(),
    contractorList:(_) => const ContractorListScreen(),

    // ── Legacy inventory ────────────────────────────────────────────────────────
    paymentHistory:   (_) => const PaymentHistoryScreen(),
    inwardManagement: (_) => const InwardManagementDashboardScreen(),
    stockOperations: (ctx) {
      final args = ModalRoute.of(ctx)!.settings.arguments;
      if (args is Map<String, dynamic>) {
        return StockOperationsScreen(
          initialQuantity: args['quantity'] as double?,
          initialPurpose: args['purpose'] as String?,
        );
      }
      return const StockOperationsScreen();
    },
    materialMaster: (_) => const MaterialMasterScreen(),
    suppliers:      (_) => const PartyManagementScreen(), // legacy alias
    reports:        (_) => const AdvancedReportsScreen(),
    inwardEntry:    (_) => const InwardEntryFormScreen(),
    partyLedger:    (_) => const LedgerOverviewScreen(),
    milestones:     (_) => const ProjectMilestonesScreen(),
    financialSummary: (_) => const FinancialSummaryScreen(),
    addItem: (_) => const AddEditItemScreen(),
    itemDetail: (ctx) {
      final id = ModalRoute.of(ctx)!.settings.arguments as String;
      return ItemDetailScreen(materialId: id);
    },
    labourList: (_) => const LabourListScreen(),
    labourEntry: (ctx) {
      final args = ModalRoute.of(ctx)!.settings.arguments;
      return LabourEntryFormScreen(editingEntry: args as LabourEntryModel?);
    },
    labourDetail: (ctx) {
      final id = ModalRoute.of(ctx)!.settings.arguments as String;
      return LabourDetailScreen(entryId: id);
    },

    // ── Calculators (UNTOUCHED) ──────────────────────────────────────────────────
    calculatorHome: (_) => const UnifiedCalculatorScreen(),
    smartCalcWizard: (ctx) {
      final args = ModalRoute.of(ctx)!.settings.arguments;
      return SmartCalculatorWizard(initialType: args as CalculatorType?);
    },
  };
}
