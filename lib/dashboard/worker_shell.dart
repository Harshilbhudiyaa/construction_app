import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'worker_home_dashboard_screen.dart';
import 'package:construction_app/modules/work_sessions/work_type_select_screen.dart';
import 'package:construction_app/modules/work_sessions/work_history_list_screen.dart';
import 'package:construction_app/modules/payments/earnings_dashboard_screen.dart';
import 'package:construction_app/profiles/worker_profile_screen.dart';
import 'package:construction_app/utils/navigation_utils.dart';
import 'package:construction_app/shared/widgets/responsive_sidebar.dart';
import 'package:construction_app/shared/widgets/app_sidebar.dart';
import 'package:construction_app/services/mock_worker_service.dart';
import 'package:construction_app/profiles/worker_types.dart';

class WorkerShell extends StatefulWidget {
  final String workerId;

  const WorkerShell({
    super.key,
    required this.workerId,
  });

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<MockWorkerService>(
      builder: (context, service, _) {
        final worker = service.workers.firstWhere(
          (w) => w.id == widget.workerId,
          orElse: () => service.workers.first,
        );

        final permissions = worker.permissions;

        // Dynamic Menu Structure
        final List<Map<String, dynamic>> menuItems = [
          {
            'dest': const SidebarDestination(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
            ),
            'page': null, // Assigned below
            'id': 'Dashboard',
            'permitted': true,
          },
          {
            'dest': const SidebarDestination(
              icon: Icons.play_circle_rounded,
              label: 'Start Work',
            ),
            'page': const WorkTypeSelectScreen(),
            'id': 'StartWork',
            'permitted': permissions.workSessionLogging,
          },
          {
            'dest': const SidebarDestination(
              icon: Icons.history_rounded,
              label: 'History',
            ),
            'page': const WorkHistoryListScreen(),
            'id': 'History',
            'permitted': permissions.historyViewing,
          },
          {
            'dest': const SidebarDestination(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Earnings',
            ),
            'page': const EarningsDashboardScreen(),
            'id': 'Earnings',
            'permitted': permissions.earningsViewing,
          },
          {
            'dest': const SidebarDestination(
              icon: Icons.person_rounded,
              label: 'Profile',
            ),
            'page': const WorkerProfileScreen(),
            'id': 'Profile',
            'permitted': permissions.profileEditing,
          },
        ];

        // Assign dashboard after menuItems exists for callback context
        menuItems[0]['page'] = WorkerHomeDashboardScreen(
          worker: worker,
          onNavigateToTab: (originalLocalIndex) {
            String targetId = '';
            if (originalLocalIndex == 1) targetId = 'StartWork';
            if (originalLocalIndex == 2) targetId = 'History';
            if (originalLocalIndex == 3) targetId = 'Earnings';

            if (targetId.isNotEmpty) {
              final permitted = menuItems.where((item) => item['permitted'] as bool).toList();
              final idx = permitted.indexWhere((item) => item['id'] == targetId);
              if (idx != -1) setState(() => _index = idx);
            }
          },
        );

        final permittedItems = menuItems.where((item) => item['permitted'] as bool).toList();
        final destinations = permittedItems.map((item) => item['dest'] as SidebarDestination).toList();
        final pages = permittedItems.map((item) => item['page'] as Widget).toList();

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
            destinations: destinations,
            userName: worker.name,
            userRole: worker.assignedSite != null 
                ? '${worker.skill} • ${worker.assignedSite}' 
                : worker.skill,
            child: pages[_index],
          ),
        );
      },
    );
  }
}


