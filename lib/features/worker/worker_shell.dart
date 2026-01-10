import 'package:flutter/material.dart';

import 'worker_home_dashboard_screen.dart';
import '../work_sessions/work_type_select_screen.dart';
import '../work_sessions/work_history_list_screen.dart';
import '../payments/earnings_dashboard_screen.dart';
import 'worker_profile_screen.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../app/ui/widgets/app_sidebar.dart';
import '../../../../app/ui/widgets/responsive_sidebar.dart';

class WorkerShell extends StatefulWidget {
  const WorkerShell({super.key});

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  int _index = 0;

  late final List<Widget> _pages = [
    const WorkerHomeDashboardScreen(),
    const WorkTypeSelectScreen(),
    const WorkHistoryListScreen(),
    const EarningsDashboardScreen(),
    const WorkerProfileScreen(),
  ];

  static const _destinations = [
    SidebarDestination(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    SidebarDestination(
      icon: Icons.play_circle_rounded,
      label: 'Start Work',
    ),
    SidebarDestination(
      icon: Icons.history_rounded,
      label: 'History',
    ),
    SidebarDestination(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Earnings',
    ),
    SidebarDestination(
      icon: Icons.person_rounded,
      label: 'Profile',
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
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations,
        userName: 'Ramesh Kumar',
        userRole: 'Mason',
        child: _pages[_index],
      ),
    );
  }
}


