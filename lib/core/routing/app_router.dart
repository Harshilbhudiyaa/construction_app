import 'package:flutter/material.dart';

// Auth
import 'package:construction_app/features/auth/splash_screen.dart';
import 'package:construction_app/features/auth/login_screen.dart';
import 'package:construction_app/features/auth/register_screen.dart';
import 'package:construction_app/features/auth/create_first_site_screen.dart';

// Shell
import 'package:construction_app/features/dashboard/contractor_shell.dart';
import 'package:construction_app/features/dashboard/site_management_screen.dart';

// Ledger / Payments
import 'package:construction_app/features/ledger/screens/payment_history_screen.dart';
import 'package:construction_app/features/ledger/screens/party_management_screen.dart';
import 'package:construction_app/features/ledger/screens/ledger_overview_screen.dart';

// Inventory (keep non-inward screens)
import 'package:construction_app/features/inventory/screens/stock_operations_screen.dart';
import 'package:construction_app/features/inventory/screens/material_master_screen.dart';
import 'package:construction_app/features/inventory/screens/add_edit_item_screen.dart';
import 'package:construction_app/features/inventory/screens/item_detail_screen.dart';
import 'package:construction_app/features/inventory/screens/stock_out_screen.dart';

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
  static const String splash          = '/';
  static const String login           = '/login';
  static const String register        = '/register';
  static const String createFirstSite = '/create-first-site';

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
  static const String stockOut         = '/stock-out';
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
    splash:          (_) => const SplashScreen(),
    login:           (_) => const LoginScreen(),
    register:        (_) => const RegisterScreen(),
    createFirstSite: (_) => const CreateFirstSiteScreen(),

    // Shell
    dashboard:      (_) => const ContractorShell(),
    siteManagement: (_) => const SiteManagementScreen(),

    // ── New screens ─────────────────────────────────────────────────────────────
    materialCatalog: (ctx) {
      final args = ModalRoute.of(ctx)!.settings.arguments;
      final showInStock = args is Map<String, dynamic> ? (args['inStock'] ?? false) : false;
      return MaterialCatalogScreen(initialInStockFilter: showInStock);
    },
    materialDetail: (ctx) {
      final id = ModalRoute.of(ctx)!.settings.arguments as String?;
      return MaterialDetailScreen(materialId: id ?? 'missing_id');
    },
    supplierList: (_) => const SupplierListScreen(),
    supplierDetail: (ctx) {
      final id = ModalRoute.of(ctx)!.settings.arguments as String?;
      return SupplierDetailScreen(supplierId: id ?? 'missing_id');
    },
    stockHub:      (_) => const StockHubScreen(),
    workerList:    (_) => const WorkerListScreen(),
    contractorList:(_) => const ContractorListScreen(),

    // ── Legacy inventory ────────────────────────────────────────────────────────
    paymentHistory:   (_) => const PaymentHistoryScreen(),
    inwardManagement: (_) => const _ComingSoonScreen(
      title: 'Inward Logistics',
      subtitle: 'Advanced inward tracking with photo proofs,\napproval workflows, and vehicle logs.',
      icon: Icons.local_shipping_rounded,
    ),
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
    stockOut: (_) => const StockOutScreen(),
    materialMaster: (_) => const MaterialMasterScreen(),
    suppliers:      (_) => const PartyManagementScreen(), // legacy alias
    reports:        (_) => const AdvancedReportsScreen(),
    inwardEntry: (_) => const _ComingSoonScreen(
      title: 'Inward Entry',
      subtitle: 'Record material arrivals with photo and GPS proofs.',
      icon: Icons.receipt_long_rounded,
    ),
    partyLedger:    (_) => const LedgerOverviewScreen(),
    milestones:     (_) => const ProjectMilestonesScreen(),
    financialSummary: (_) => const FinancialSummaryScreen(),
    addItem: (_) => const AddEditItemScreen(),
    editItem: (ctx) {
      final id = ModalRoute.of(ctx)!.settings.arguments as String?;
      return AddEditItemScreen(materialId: id);
    },
    itemDetail: (ctx) {
      final id = ModalRoute.of(ctx)!.settings.arguments as String?;
      return ItemDetailScreen(materialId: id ?? 'missing_id');
    },
    labourList: (_) => const LabourListScreen(),
    labourEntry: (ctx) {
      final args = ModalRoute.of(ctx)!.settings.arguments;
      return LabourEntryFormScreen(editingEntry: args as LabourEntryModel?);
    },
    labourDetail: (ctx) {
      final id = ModalRoute.of(ctx)!.settings.arguments as String?;
      return LabourDetailScreen(entryId: id ?? 'missing_id');
    },

    // ── Calculators (UNTOUCHED) ──────────────────────────────────────────────────
    calculatorHome: (_) => const UnifiedCalculatorScreen(),
    smartCalcWizard: (ctx) {
      final args = ModalRoute.of(ctx)!.settings.arguments;
      return SmartCalculatorWizard(initialType: args as CalculatorType?);
    },
  };
}

// ── Coming Soon Screen ─────────────────────────────────────────────────────────

class _ComingSoonScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _ComingSoonScreen({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48, color: const Color(0xFFF59E0B)),
                ),
                const SizedBox(height: 28),
                const Text('Coming Soon', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.6),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.construction_rounded, size: 14, color: Color(0xFFF59E0B)),
                    SizedBox(width: 8),
                    Text('Under Development', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w700, fontSize: 12)),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
