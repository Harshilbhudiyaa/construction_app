import 'package:flutter/material.dart';

import 'contractor_dashboard_screen.dart';
import '../../../worker/presentation/screens/workers_list_screen.dart';
import '../../../engineer/presentation/screens/engineers_list_screen.dart';
import '../../../block_management/presentation/screens/machines_list_screen.dart';
import '../../../inventory/presentation/screens/inventory_master_list_screen.dart';
import '../../../payments/presentation/screens/payments_dashboard_screen.dart';
import '../../../reports/presentation/screens/reports_home_screen.dart';
import 'audit_log_list_screen.dart';

class ContractorShell extends StatefulWidget {
  const ContractorShell({super.key});

  @override
  State<ContractorShell> createState() => _ContractorShellState();
}

class _ContractorShellState extends State<ContractorShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  late final List<Widget> _pages = [
    ContractorDashboardScreen(onNavigateTo: _goTo),
    const WorkersListScreen(),
    const EngineersListScreen(),
    const MachinesListScreen(),
    const InventoryMasterListScreen(),
    const PaymentsDashboardScreen(),
    const ReportsHomeScreen(),
    const AuditLogListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_rounded),
            label: 'Workers',
          ),
          NavigationDestination(
            icon: Icon(Icons.engineering_rounded),
            label: 'Engineers',
          ),
          NavigationDestination(
            icon: Icon(Icons.precision_manufacturing_rounded),
            label: 'Machines',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_rounded),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_rounded),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.policy_rounded),
            label: 'Audit',
          ),
        ],
      ),
    );
  }
}
