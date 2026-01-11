import 'package:flutter/material.dart';

import 'contractor_dashboard_screen.dart';
import '../worker/workers_list_screen.dart';
import '../engineer/engineers_list_screen.dart';
import '../engineer/engineer_management_screen.dart';
import '../engineer/machine_management_screen.dart';
import '../engineer/tools_management_screen.dart';
import '../block_management/machines_list_screen.dart';
import '../inventory/inventory_master_list_screen.dart';
import '../inventory/inventory_detail_management_screen.dart';
import '../payments/payments_dashboard_screen.dart';
import '../analytics/analytics_dashboard_screen.dart';
import '../notifications/notifications_screen.dart';
import 'audit_log_list_screen.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../app/ui/widgets/app_sidebar.dart';
import '../../../../app/ui/widgets/responsive_sidebar.dart';

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
    const EngineerManagementScreen(), // Updated to new engineer management
    const MachineManagementScreen(), // Updated to new machine management
    const InventoryDetailManagementScreen(), // Updated to new inventory detail
    const ToolsManagementScreen(), // New tools management
    const PaymentsDashboardScreen(),
    const AnalyticsDashboardScreen(),
    const NotificationsScreen(),
    const AuditLogListScreen(),
  ];

  static const _destinations = [
    SidebarDestination(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    SidebarDestination(
      icon: Icons.groups_rounded,
      label: 'Workers',
    ),
    SidebarDestination(
      icon: Icons.engineering_rounded,
      label: 'Personnel',
    ),
    SidebarDestination(
      icon: Icons.precision_manufacturing_rounded,
      label: 'Machines',
    ),
    SidebarDestination(
      icon: Icons.inventory_2_rounded,
      label: 'Inventory',
    ),
    SidebarDestination(
      icon: Icons.build_rounded,
      label: 'Tools',
    ),
    SidebarDestination(
      icon: Icons.payments_rounded,
      label: 'Payments',
    ),
    SidebarDestination(
      icon: Icons.analytics_rounded,
      label: 'Analytics',
    ),
    SidebarDestination(
      icon: Icons.notifications_rounded,
      label: 'Notifications',
      badge: '3',
    ),
    SidebarDestination(
      icon: Icons.policy_rounded,
      label: 'Audit Log',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        if (_index != 0) {
          setState(() => _index = 0);
        } else {
          await NavigationUtils.showLogoutDialog(context);
        }
      },
      child: ResponsiveSidebar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: _destinations,
        userName: 'Contractor Admin',
        userRole: 'Administrator',
        child: _pages[_index],
      ),
    );
  }
}


