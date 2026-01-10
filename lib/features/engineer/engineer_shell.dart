import 'package:flutter/material.dart';

import 'engineer_dashboard_screen.dart';
import '../approvals/approvals_queue_screen.dart';
import '../block_management/block_overview_screen.dart';
import '../inventory/inventory_dashboard_screen.dart';
import '../trucks/truck_trips_list_screen.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../app/ui/widgets/app_sidebar.dart';
import '../../../../app/ui/widgets/responsive_sidebar.dart';

class EngineerShell extends StatefulWidget {
  const EngineerShell({super.key});

  @override
  State<EngineerShell> createState() => _EngineerShellState();
}

class _EngineerShellState extends State<EngineerShell> {
  int _index = 0;

  void _goTo(int index) {
    setState(() => _index = index);
  }

  late final List<Widget> _pages = [
    EngineerDashboardScreen(onNavigateToTab: _goTo),
    const ApprovalsQueueScreen(),
    const BlockOverviewScreen(),
    const InventoryDashboardScreen(),
    const TruckTripsListScreen(),
  ];

  static const _destinations = [
    SidebarDestination(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    SidebarDestination(
      icon: Icons.fact_check_rounded,
      label: 'Approvals',
      badge: '5',
    ),
    SidebarDestination(
      icon: Icons.precision_manufacturing_rounded,
      label: 'Blocks',
    ),
    SidebarDestination(
      icon: Icons.inventory_2_rounded,
      label: 'Inventory',
      badge: '3',
    ),
    SidebarDestination(
      icon: Icons.local_shipping_rounded,
      label: 'Trucks',
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
        userName: 'Engineer A',
        userRole: 'Site Engineer',
        child: _pages[_index],
      ),
    );
  }
}


