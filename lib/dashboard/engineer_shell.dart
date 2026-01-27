import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/mock_engineer_service.dart';

import 'engineer_dashboard_screen.dart';
import 'package:construction_app/governance/approvals/models/action_request.dart';
import 'package:construction_app/governance/approvals/approvals_queue_screen.dart';
import 'package:construction_app/profiles/workers_list_screen.dart';
import 'package:construction_app/modules/resources/tools_management_screen.dart';
import 'package:construction_app/modules/resources/machine_management_screen.dart';
import 'package:construction_app/modules/payments/payments_dashboard_screen.dart';
import 'package:construction_app/modules/inventory/material_list_screen.dart';
import 'package:construction_app/utils/navigation_utils.dart';
import 'package:construction_app/shared/widgets/app_sidebar.dart';
import 'package:construction_app/shared/widgets/responsive_sidebar.dart';
import 'package:construction_app/profiles/engineer_form_screen.dart';
import 'package:construction_app/notifications/notifications_screen.dart';
import 'package:construction_app/services/mock_notification_service.dart';
import 'package:construction_app/services/site_service.dart';
import 'package:construction_app/modules/inventory/inward_management_dashboard_screen.dart';
import 'package:construction_app/profiles/engineer_model.dart';
import 'package:construction_app/services/approval_service.dart';

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
  String? _activeSiteId;

  int getFilteredIndex(String id, List<Map<String, dynamic>> items) {
    final permitted = items.where((item) => item['permitted'] as bool).toList();
    return permitted.indexWhere((item) => item['id'] == id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MockEngineerService>(
      builder: (context, service, _) {
        final engineer = service.engineers.firstWhere(
            (e) => e.id == widget.engineerId,
            orElse: () => service.engineers.first
        );

        return Consumer<SiteService>(
          builder: (context, siteService, _) {
            final assignedSites = siteService.getSitesForEngineer(engineer.id);
            
            if (_activeSiteId != null && !assignedSites.any((s) => s.id == _activeSiteId)) {
              _activeSiteId = null;
            }
            _activeSiteId ??= assignedSites.isNotEmpty ? assignedSites.first.id : null;

            final permissions = _activeSiteId != null 
                ? siteService.getPermissionsForEngineer(engineer.id, engineer.role, _activeSiteId!)
                : const PermissionSet();

            return Consumer<ApprovalService>(
              builder: (context, approvalService, _) {
                final pendingApprovalsCount = approvalService.requests
                    .where((r) => r.siteId == _activeSiteId && r.status == ApprovalStatus.pending)
                    .length;

                final List<Map<String, dynamic>> menuItems = [
                  {
                    'dest': const SidebarDestination(icon: Icons.dashboard_rounded, label: 'Dashboard'),
                    'page': null, 
                    'id': 'Dashboard',
                    'permitted': true,
                  },
                  {
                    'dest': SidebarDestination(
                      icon: Icons.fact_check_rounded, 
                      label: 'Approvals', 
                      badge: (permissions.approvalVerification && pendingApprovalsCount > 0) ? pendingApprovalsCount.toString() : null
                    ),
                    'page': ApprovalsQueueScreen(activeSiteId: _activeSiteId),
                    'id': 'Approvals',
                    'permitted': engineer.role.requiredModuleIds.contains('Approvals') && (permissions.approvalVerification || permissions.siteManagement),
                  },
                  {
                    'dest': const SidebarDestination(icon: Icons.groups_rounded, label: 'Workers'),
                    'page': WorkersListScreen(activeSiteId: _activeSiteId),
                    'id': 'Workers',
                    'permitted': engineer.role.requiredModuleIds.contains('Workers') && permissions.workerManagement,
                  },
                  {
                    'dest': const SidebarDestination(icon: Icons.inventory_2_rounded, label: 'Inventory'),
                    'page': MaterialListScreen(isAdmin: false, activeSiteId: _activeSiteId),
                    'id': 'Inventory',
                    'permitted': engineer.role.requiredModuleIds.contains('Inventory') && permissions.inventoryManagement,
                  },
                  {
                    'dest': const SidebarDestination(icon: Icons.local_shipping_rounded, label: 'Inward Logs'),
                    'page': InwardManagementDashboardScreen(activeSiteId: _activeSiteId),
                    'id': 'Inward Logs',
                    'permitted': engineer.role.requiredModuleIds.contains('Inward Logs') && permissions.inventoryManagement,
                  },
                  {
                    'dest': const SidebarDestination(icon: Icons.build_rounded, label: 'Tools'),
                    'page': ToolsManagementScreen(activeSiteId: _activeSiteId),
                    'id': 'Tools',
                    'permitted': engineer.role.requiredModuleIds.contains('Tools') && permissions.toolMachineManagement,
                  },
                  {
                    'dest': const SidebarDestination(icon: Icons.precision_manufacturing_rounded, label: 'Machines'),
                    'page': MachineManagementScreen(activeSiteId: _activeSiteId),
                    'id': 'Machines',
                    'permitted': engineer.role.requiredModuleIds.contains('Machines') && permissions.toolMachineManagement,
                  },
                  {
                    'dest': const SidebarDestination(icon: Icons.payments_rounded, label: 'Financials'),
                    'page': PaymentsDashboardScreen(activeSiteId: _activeSiteId),
                    'id': 'Financials',
                    'permitted': engineer.role.requiredModuleIds.contains('Financials') && (permissions.siteManagement || permissions.reportViewing),
                  },
                ];

                menuItems[0]['page'] = EngineerDashboardScreen(
                  engineer: engineer,
                  permissions: permissions,
                  activeSiteId: _activeSiteId,
                  onNavigateToTab: (tabId, {siteId}) {
                     if (tabId.isNotEmpty) {
                       final idx = getFilteredIndex(tabId, menuItems);
                       if (idx != -1) setState(() => _index = idx);
                     }
                  }
                );

                final permittedItems = menuItems.where((item) => item['permitted'] as bool).toList();

                return Consumer<MockNotificationService>(
                  builder: (context, notificationService, _) {
                    final List<SidebarDestination> destinations = [
                      ...permittedItems.map((item) => item['dest'] as SidebarDestination),
                      SidebarDestination(
                        icon: Icons.notifications_rounded,
                        label: 'Notifications',
                        badge: notificationService.unreadCount > 0 ? notificationService.unreadCount.toString() : null,
                      ),
                      const SidebarDestination(
                        icon: Icons.person_rounded,
                        label: 'My Profile',
                      ),
                    ];

                    final List<Widget> pages = [
                      ...permittedItems.map((item) => item['page'] as Widget),
                      const NotificationsScreen(),
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
                        onDestinationSelected: (index) {
                          if (index == destinations.length - 1) {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => EngineerFormScreen(
                                engineer: engineer,
                                isSelfEdit: true,
                              ))
                            );
                          } else {
                            setState(() => _index = index);
                          }
                        },
                        destinations: destinations,
                        userName: engineer.name,
                        userRole: engineer.assignedSite != null 
                            ? '${engineer.role.displayName} • ${engineer.assignedSite}' 
                            : engineer.role.displayName,
                        child: pages[_index],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}


