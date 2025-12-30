import 'package:flutter/material.dart';

import 'worker_home_dashboard_screen.dart';
import '../../../work_sessions/presentation/screens/work_type_select_screen.dart';
import '../../../work_sessions/presentation/screens/work_history_list_screen.dart';
import '../../../payments/presentation/screens/earnings_dashboard_screen.dart';
import 'worker_profile_screen.dart';
import '../../../../core/utils/navigation_utils.dart';

class WorkerShell extends StatefulWidget {
  const WorkerShell({super.key});

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  int _index = 0;

  // No const list -> works even if some screens are not const constructors
  late final List<Widget> _pages = [
    const WorkerHomeDashboardScreen(),
    const WorkTypeSelectScreen(),
    const WorkHistoryListScreen(),
    const EarningsDashboardScreen(),
    const WorkerProfileScreen(),
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
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_circle_rounded),
              label: 'Work',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Earnings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

