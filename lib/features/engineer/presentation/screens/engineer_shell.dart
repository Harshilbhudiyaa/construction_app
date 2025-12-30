import 'package:flutter/material.dart';

import 'engineer_dashboard_screen.dart';
import 'approvals_queue_screen.dart';
import 'block_overview_screen.dart';
import 'inventory_dashboard_screen.dart';
import 'truck_trips_list_screen.dart';

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
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.fact_check_rounded), label: 'Approvals'),
          NavigationDestination(icon: Icon(Icons.precision_manufacturing_rounded), label: 'Blocks'),
          NavigationDestination(icon: Icon(Icons.inventory_2_rounded), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.local_shipping_rounded), label: 'Trucks'),
        ],
      ),
    );
  }
}
