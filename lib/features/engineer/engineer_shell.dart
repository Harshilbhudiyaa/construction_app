import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/mock_engineer_service.dart';

import 'engineer_dashboard_screen.dart';
import '../approvals/approvals_queue_screen.dart';
import '../block_management/block_overview_screen.dart';
import '../inventory/inventory_dashboard_screen.dart';
import '../trucks/truck_trips_list_screen.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../app/ui/widgets/app_sidebar.dart';
import '../../../../app/ui/widgets/responsive_sidebar.dart';
import 'engineer_form_screen.dart';

class EngineerShell extends StatefulWidget {
  final String engineerId;

  const EngineerShell({
    super.key,
    required this.engineerId,
  });

  @override
  State<EngineerShell> createState() => _EngineerShellState();
}

class _EngineerShellState extends State<EngineerShell> {
  int _index = 0;

  void _goTo(int index) {
    setState(() => _index = index);
  }

  late final List<Widget> _pages = [
    // This will be constructed in build now to access engineer data
    const SizedBox(), 
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
  
  // Add Profile to destinations? SidebarDestination doesn't support action clicks usually,
  // but we can add a destination that when clicked opens a page or dialog.
  // Instead, let's assume the user clicks the "User Profile" area in the sidebar.
  // The ResponsiveSidebar might need a callback for user profile click.
  // For now, let's add a "My Profile" item at the bottom.

  @override
  Widget build(BuildContext context) {
    return Consumer<MockEngineerService>(
      builder: (context, service, _) {
        // Find current engineer
        final engineer = service.engineers.firstWhere(
            (e) => e.id == widget.engineerId,
            orElse: () => service.engineers.first // Fallback if not found (shouldn't happen)
        );

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
            onDestinationSelected: (index) {
              if (index == _destinations.length) {
                // Profile clicked (last simulated item)
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => EngineerFormScreen(
                    engineer: engineer,
                    isSelfEdit: true,
                  ))
                );
              } else {
                _goTo(index);
              }
            },
            destinations: [
              ..._destinations,
              const SidebarDestination(
                icon: Icons.person_rounded,
                label: 'My Profile',
              ),
            ],
            userName: engineer.name,
            userRole: engineer.assignedSite != null 
                ? '${engineer.role.displayName} • ${engineer.assignedSite}' 
                : engineer.role.displayName,
            child: _index == 0 
                ? EngineerDashboardScreen(engineer: engineer, onNavigateToTab: _goTo)
                : _pages[_index],
          ),
        );
      },
    );
  }
}


