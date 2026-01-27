import 'package:flutter/material.dart';

import 'contractor_dashboard_screen.dart';
import 'package:construction_app/governance/sites/site_management_screen.dart';
import 'package:construction_app/profiles/workers_list_screen.dart';
import 'package:construction_app/profiles/engineer_management_screen.dart';
import 'package:construction_app/modules/resources/machine_management_screen.dart';
import 'package:construction_app/modules/resources/tools_management_screen.dart';
import 'package:construction_app/modules/inventory/material_list_screen.dart';
import 'package:construction_app/modules/payments/payments_dashboard_screen.dart';
import 'package:construction_app/notifications/notifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/utils/navigation_utils.dart';
import 'package:construction_app/shared/widgets/app_sidebar.dart';
import 'package:construction_app/shared/widgets/responsive_sidebar.dart';
import 'package:construction_app/services/mock_notification_service.dart';

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
    const GovernanceHubScreen(), // Unified Hub
    const EngineerManagementScreen(), // Global Directory
    const WorkersListScreen(),
    const MaterialListScreen(isAdmin: true),
    const ToolsManagementScreen(),
    const MachineManagementScreen(),
    const PaymentsDashboardScreen(),
    const NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MockNotificationService>(
      builder: (context, notificationService, child) {
        final List<SidebarDestination> destinations = [
          const SidebarDestination(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
          ),
          const SidebarDestination(
            icon: Icons.gavel_rounded,
            label: 'Governance Hub',
          ),
          const SidebarDestination(
            icon: Icons.engineering_rounded,
            label: 'Engineers',
          ),
          const SidebarDestination(
            icon: Icons.groups_rounded,
            label: 'Workers',
          ),
          const SidebarDestination(
            icon: Icons.inventory_2_rounded,
            label: 'Inventory',
          ),
          const SidebarDestination(
            icon: Icons.build_rounded,
            label: 'Tools',
          ),
          const SidebarDestination(
            icon: Icons.precision_manufacturing_rounded,
            label: 'Machines',
          ),
          const SidebarDestination(
            icon: Icons.payments_rounded,
            label: 'Payments',
          ),
          SidebarDestination(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            badge: notificationService.unreadCount > 0 
                ? notificationService.unreadCount.toString() 
                : null,
          ),
        ];

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
            destinations: destinations,
            userName: 'Contractor Admin',
            userRole: 'Administrator',
            child: _pages[_index],
          ),
        );
      },
    );
  }
}


