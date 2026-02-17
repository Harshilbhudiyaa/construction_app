import 'package:flutter/material.dart';

import 'contractor_dashboard_screen.dart';
import 'settings_screen.dart';

import 'package:construction_app/modules/inventory/materials/screens/material_list_screen.dart';
import 'package:construction_app/modules/inventory/inward/screens/inward_management_dashboard_screen.dart';
import 'package:construction_app/modules/inventory/stock/screens/stock_operations_screen.dart';
import 'package:construction_app/modules/inventory/parties/screens/party_management_screen.dart';
import 'package:construction_app/modules/inventory/core/reports_dashboard_screen.dart';
import 'package:construction_app/modules/inventory/approvals/approval_dashboard_screen.dart';

import 'package:construction_app/utils/navigation_utils.dart';
import 'package:construction_app/shared/widgets/app_sidebar.dart';
import 'package:construction_app/shared/widgets/responsive_sidebar.dart';


class ContractorShell extends StatefulWidget {
  const ContractorShell({super.key});

  @override
  State<ContractorShell> createState() => _ContractorShellState();
}

class _ContractorShellState extends State<ContractorShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    // Top-level Navigation Pages
    final List<Widget> pages = [
      ContractorDashboardScreen(onNavigateTo: _goTo),
      const MaterialListScreen(isAdmin: true),     // Inventory (Materials)
      const InwardManagementDashboardScreen(),     // Inward
      const StockOperationsScreen(),               // Stock Ops
      const ApprovalDashboardScreen(),             // Approvals
      const PartyManagementScreen(),               // Suppliers
      const ReportsDashboardScreen(),              // Reports
      const SettingsScreen(),                      // Settings
    ];

    final List<SidebarDestination> destinations = [
      const SidebarDestination(
        icon: Icons.dashboard_rounded,
        label: 'Dashboard',
        index: 0,
      ),
      const SidebarDestination(
        icon: Icons.inventory_2_rounded,
        label: 'Inventory',
        index: 1, // Clicking "Inventory" itself goes to Materials
        children: [
          SidebarDestination(
            icon: Icons.move_to_inbox_rounded,
            label: 'Inward',
            index: 2,
          ),
          SidebarDestination(
            icon: Icons.compare_arrows_rounded,
            label: 'Stock Ops',
            index: 3,
          ),
          SidebarDestination(
            icon: Icons.approval_rounded,
            label: 'Approvals',
            index: 4,
          ),
          SidebarDestination(
            icon: Icons.people_alt_rounded,
            label: 'Suppliers',
            index: 5,
          ),
          SidebarDestination(
            icon: Icons.analytics_rounded,
            label: 'Reports',
            index: 6,
          ),
           SidebarDestination(
            icon: Icons.settings_rounded,
            label: 'Settings',
            index: 7,
          ),
        ]
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        await NavigationUtils.showLogoutDialog(context);
      },
      child: ResponsiveSidebar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: destinations,
        userName: 'Inventory Admin',
        userRole: 'Administrator',
        child: pages[_index], // Directly use index since pages match destinations
      ),
    );
  }
}
