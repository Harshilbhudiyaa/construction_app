import 'package:flutter/material.dart';

import 'engineer_dashboard_screen.dart';
import '../../../approvals/presentation/screens/approvals_queue_screen.dart';
import '../../../block_management/presentation/screens/block_overview_screen.dart';
import '../../../inventory/presentation/screens/inventory_dashboard_screen.dart';
import '../../../trucks/presentation/screens/truck_trips_list_screen.dart';
import '../../../../core/utils/navigation_utils.dart';

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
    EngineerDashboardScreen(onNavigateToTab: _goTo), // ✅ callback
    const ApprovalsQueueScreen(),
    const BlockOverviewScreen(),
    const InventoryDashboardScreen(),
    const TruckTripsListScreen(),
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
      child: Scaffold(
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
              icon: Icon(Icons.fact_check_rounded),
              label: 'Approvals',
            ),
            NavigationDestination(
              icon: Icon(Icons.precision_manufacturing_rounded),
              label: 'Blocks',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_rounded),
              label: 'Inventory',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_shipping_rounded),
              label: 'Trucks',
            ),
          ],
        ),
      ),
    );
  }
}

