import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/utils/navigation_utils.dart';

import 'package:construction_app/profiles/engineer_model.dart';
import 'package:construction_app/modules/inventory/models/material_model.dart';
import 'package:construction_app/modules/inventory/material_list_screen.dart';
import 'package:construction_app/modules/inventory/material_form_screen.dart';
import 'package:construction_app/services/inventory_service.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/mock_notification_service.dart';
import 'package:construction_app/notifications/notifications_screen.dart';
import 'package:construction_app/shared/widgets/responsive_sidebar.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/services/mock_machine_service.dart';
import 'package:construction_app/services/mock_tool_service.dart';
import 'package:construction_app/services/approval_service.dart';
import 'package:construction_app/services/mock_worker_service.dart';
import 'package:construction_app/services/payment_service.dart';
import 'package:construction_app/modules/resources/machine_model.dart';
import 'package:construction_app/modules/resources/tool_model.dart';
import 'package:construction_app/governance/approvals/models/action_request.dart';
import 'package:construction_app/profiles/worker_types.dart';
import 'package:construction_app/modules/payments/widgets/payment_form_sheet.dart';
import 'package:construction_app/profiles/workers_list_screen.dart';


class EngineerDashboardScreen extends StatefulWidget {
  final EngineerModel engineer;
  final PermissionSet permissions; // Dynamic permissions from Governance
  final String? activeSiteId;
  final Function(String, {String? siteId}) onNavigateToTab;

  const EngineerDashboardScreen({
    super.key, 
    required this.engineer,
    required this.permissions,
    this.activeSiteId,
    required this.onNavigateToTab,
  });

  @override
  State<EngineerDashboardScreen> createState() => _EngineerDashboardScreenState();
}

class _EngineerDashboardScreenState extends State<EngineerDashboardScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fabController;
  bool _fabExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _fabExpanded = !_fabExpanded;
      if (_fabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = SidebarProvider.of(context)?.isMobile ?? false;
    return Scaffold(
      body: ProfessionalPage(
        title: 'Engineer Console',
        actions: [
          Consumer<MockNotificationService>(
            builder: (context, service, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                  icon: const Icon(Icons.notifications_rounded),
                ),
                if (service.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${service.unreadCount}',
                        style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => NavigationUtils.showLogoutDialog(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
        children: [
          _buildGreeting(),

          // Quick Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildQuickSearch(),
          ),

          // Hero Profile Card
          StaggeredAnimation(
            index: 0,
            child: _buildHeroProfile(),
          ),
          
          StreamBuilder<List<ConstructionMaterial>>(
            stream: context.read<InventoryService>().getMaterialsStream(siteId: widget.activeSiteId),
            builder: (context, materialSnapshot) {
              final materials = materialSnapshot.data ?? [];
              final lowStock = materials.where((m) => m.currentStock < 10 && m.isActive).length;
              final inactiveItemsCount = materials.where((i) => !i.isActive).length;

              final machineService = context.watch<MockMachineService>();
              final toolService = context.watch<MockToolService>();
              final approvalService = context.watch<ApprovalService>();
              final workerService = context.watch<MockWorkerService>();
              final paymentService = context.watch<PaymentService>();

              final machines = machineService.machines.where((m) => m.assignedSiteId == widget.activeSiteId).toList();
              final tools = toolService.tools.where((t) => t.assignedSiteId == widget.activeSiteId).toList();
              final siteWorkers = workerService.workers.where((w) => w.siteId == widget.activeSiteId).toList();
              final siteApprovals = approvalService.requests.where((r) => r.siteId == widget.activeSiteId && r.status == ApprovalStatus.pending).toList();
              final totalPayments = paymentService.allPayments
                  .where((p) => p.siteId == widget.activeSiteId)
                  .fold(0.0, (sum, p) => sum + p.amount);

              return Column(
                children: [
                  // Priority Alerts - Permission-Based
                  if ((lowStock > 0 || inactiveItemsCount > 0) && widget.permissions.inventoryManagement)
                    _buildPriorityAlerts(lowStock, inactiveItemsCount),

                  const ProfessionalSectionHeader(
                    title: 'Strategic Overview',
                    subtitle: 'Real-time site & resource metrics',
                  ),

                  // KPI Grid - Permission-Based Filtering
                  StaggeredAnimation(
                    index: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Builder(
                        builder: (context) {
                          final permissions = widget.permissions;
                          final role = widget.engineer.role;
                          final tiles = <Widget>[];

                          if (role.requiredModuleIds.contains('Machines') && permissions.toolMachineManagement) {
                            tiles.add(_KpiTile(
                              title: 'Machines',
                              value: '${machines.length}',
                              icon: Icons.precision_manufacturing_rounded,
                              color: Colors.blueAccent,
                              trend: '${machines.where((m) => m.status == MachineStatus.inUse).length} Active',
                              isPositive: true,
                              status: 'Approved Assets',
                              onTap: () => widget.onNavigateToTab('Machines'),
                            ));
                          }

                          if (role.requiredModuleIds.contains('Tools') && permissions.toolMachineManagement) {
                            tiles.add(_KpiTile(
                              title: 'Tools Live',
                              value: '${tools.length}',
                              icon: Icons.build_rounded,
                              color: Colors.purpleAccent,
                              trend: 'All Good',
                              isPositive: true,
                              status: 'Site Inventory',
                              onTap: () => widget.onNavigateToTab('Tools', siteId: widget.activeSiteId),
                            ));
                          }

                          if (role.requiredModuleIds.contains('Inventory') && permissions.inventoryManagement) {
                            tiles.add(_KpiTile(
                              title: 'Inventory',
                              value: '${materials.length}',
                              icon: Icons.inventory_2_rounded,
                              color: Colors.orangeAccent,
                              trend: lowStock > 0 ? '$lowStock Low' : 'Stable',
                              isPositive: lowStock == 0,
                              status: 'Stock Levels',
                              onTap: () => widget.onNavigateToTab('Inventory', siteId: widget.activeSiteId),
                            ));
                          }

                          if (role.requiredModuleIds.contains('Financials') && (permissions.siteManagement || permissions.reportViewing)) {
                            final formatter = NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN');
                            tiles.add(_KpiTile(
                              title: 'Financials',
                              value: formatter.format(totalPayments),
                              icon: Icons.payments_rounded,
                              color: Colors.greenAccent,
                              trend: 'Total Spend',
                              isPositive: true,
                              status: 'Site Expenses',
                              onTap: () => widget.onNavigateToTab('Financials', siteId: widget.activeSiteId),
                            ));
                          }

                          if (role.requiredModuleIds.contains('Workers') && permissions.workerManagement) {
                            tiles.add(_KpiTile(
                              title: 'Attendance',
                              value: siteWorkers.isEmpty ? '0' : '${siteWorkers.length}',
                              icon: Icons.groups_rounded,
                              color: Colors.tealAccent,
                              trend: '${siteWorkers.where((w) => w.status == WorkerStatus.active).length} Active',
                              isPositive: true,
                              status: 'On-site Workforce',
                              onTap: () => widget.onNavigateToTab('Workers'),
                            ));
                          }

                          if (role.requiredModuleIds.contains('Approvals') && (permissions.approvalVerification || permissions.siteManagement)) {
                            tiles.add(_KpiTile(
                              title: 'Approvals',
                              value: '${siteApprovals.length}',
                              icon: Icons.approval_rounded,
                              color: Colors.cyanAccent,
                              trend: siteApprovals.isNotEmpty ? 'Review Now' : 'Up to date',
                              isPositive: siteApprovals.isEmpty,
                              onTap: () => widget.onNavigateToTab('Approvals', siteId: widget.activeSiteId),
                            ));
                          }

                          // If no permissions, show a message
                          if (tiles.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.lock_outline_rounded,
                                      size: 48,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Accessible Features',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Contact your administrator for access',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Dynamic grid based on tile count
                          final crossAxisCount = isMobile 
                            ? (tiles.length == 1 ? 1 : 2)
                            : (tiles.length <= 3 ? tiles.length : 3);

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: isMobile ? 1.05 : 1.3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: tiles,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const ProfessionalSectionHeader(
            title: 'Tactical Control',
            subtitle: 'Direct operational management',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Builder(
              builder: (context) {
                final permissions = widget.permissions;
                final actionTiles = <Widget>[];

                // Financials & Resources Section
                if (permissions.siteManagement || permissions.reportViewing || permissions.toolMachineManagement) {
                  actionTiles.add(const ProfessionalSectionHeader(
                    title: 'Financials & Resources',
                    subtitle: 'Spend analysis and asset tracking',
                  ));
                  
                  actionTiles.add(_CompactActionGroup(
                    title: 'Financials & Resources',
                    children: [
                      if (permissions.siteManagement || permissions.reportViewing)
                        _CompactActionTile(
                          icon: Icons.payments_rounded,
                          title: 'Financials',
                          subtitle: 'Spend analysis',
                          onTap: () => widget.onNavigateToTab('Financials'),
                        ),
                      if (permissions.toolMachineManagement) ...[
                        _CompactActionTile(
                          icon: Icons.precision_manufacturing_rounded,
                          title: 'Machines',
                          subtitle: 'Active assets',
                          onTap: () => widget.onNavigateToTab('Machines', siteId: widget.activeSiteId), // Financials (New index)
                        ),
                        _CompactActionTile(
                          icon: Icons.build_rounded,
                          title: 'Tools',
                          subtitle: 'Utils & Tech',
                          onTap: () => widget.onNavigateToTab('Tools'),
                        ),
                      ],
                    ],
                  ));
                }

                // Field Operations Section
                if (permissions.workerManagement || permissions.inventoryManagement) {
                  actionTiles.add(const ProfessionalSectionHeader(
                    title: 'Field Operations',
                    subtitle: 'Site personnel and inventory tracking',
                  ));

                  actionTiles.add(_CompactActionGroup(
                    title: 'Operations',
                    children: [
                      if (permissions.workerManagement)
                        _CompactActionTile(
                          icon: Icons.engineering_rounded,
                          title: 'Site Personnel',
                          subtitle: 'Workforce management',
                          onTap: () => widget.onNavigateToTab('Workers', siteId: widget.activeSiteId), // Workers tab
                        ),
                      if (permissions.inventoryManagement)
                        _CompactActionTile(
                          icon: Icons.inventory_rounded,
                          title: 'Live Inventory',
                          subtitle: 'Stock consumption',
                          onTap: () => widget.onNavigateToTab('Inventory'),
                        ),
                    ],
                  ));
                }

                return Column(children: actionTiles);
              },
            ),
          ),

          const ProfessionalSectionHeader(
            title: 'Operational Timeline',
            subtitle: 'Snapshots of recent site activity',
          ),

          _buildRecentActivity(),

          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: _QuickAddFab(
        engineer: widget.engineer,
        isExpanded: _fabExpanded,
        onToggle: _toggleFab,
        controller: _fabController,
      ),
    );
  }

  Widget _buildQuickSearch() {
    return AppSearchField(
      hint: 'Search tasks, materials, or workers...',
      onChanged: (v) {
        // Future: Implement engineer-specific search
      },
      onFilterTap: () {
        // Future: Show engineer filters
      },
    );
  }

  Widget _buildPriorityAlerts(int lowStock, int systemAlerts) {
    return StaggeredAnimation(
      index: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            if (lowStock > 0)
              _buildPriorityCard(
                'Low Stock Alert',
                '$lowStock Materials',
                Icons.warning_amber_rounded,
                const Color(0xFFF57C00),
                () => widget.onNavigateToTab('Inventory'),
              ),
            if (lowStock > 0 && systemAlerts > 0) const SizedBox(height: 12),
            if (systemAlerts > 0)
              _buildPriorityCard(
                'Inactive Items',
                '$systemAlerts Flagged',
                Icons.info_outline_rounded,
                const Color(0xFF1976D2),
                () => widget.onNavigateToTab('Inventory'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return ProfessionalCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: EdgeInsets.zero,
      color: color.withOpacity(0.08),
      boxShadow: [],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: color.withOpacity(0.7),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;
    if (hour < 12) {
      greeting = 'Good Morning';
      icon = Icons.light_mode_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      icon = Icons.wb_sunny_rounded;
    } else {
      greeting = 'Good Evening';
      icon = Icons.nightlight_round;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, ${widget.engineer.name.split(' ')[0]}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroProfile() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with Notification Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1), width: 1),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
                        child: Text(
                          widget.engineer.name[0],
                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Notification Badge
                    Consumer<MockNotificationService>(
                      builder: (context, notifService, _) {
                        final unreadCount = notifService.unreadCount;
                        if (unreadCount == 0) return const SizedBox.shrink();
                        return Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.cardColor, width: 2),
                            ),
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.engineer.name,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.engineer.role.displayName.toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Shift Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ON DUTY',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.engineer.assignedSite != null) const SizedBox(height: 4),
                      if (widget.engineer.assignedSite != null) ...[
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 12, color: theme.textTheme.bodySmall?.color),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.engineer.assignedSite!.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.textTheme.bodySmall?.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                StatusChip(
                  status: widget.engineer.isActive ? UiStatus.ok : UiStatus.stop,
                  labelOverride: widget.engineer.isActive ? 'ACTIVE' : 'OFFLINE',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShiftMetric('SHIFT START', '08:00 AM'),
                  Container(width: 1, height: 24, color: theme.colorScheme.primary.withOpacity(0.05)),
                  _buildShiftMetric('DURATION', '6h 45m'),
                  Container(width: 1, height: 24, color: theme.colorScheme.primary.withOpacity(0.05)),
                  _buildShiftMetric('TARGET', '95%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftMetric(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.textTheme.bodySmall?.color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }



  Widget _buildRecentActivity() {
    final theme = Theme.of(context);
    final approvalService = context.watch<ApprovalService>();
    
    final recentApprovals = approvalService.requests
        .where((r) => r.siteId == widget.activeSiteId)
        .take(5)
        .toList();

    if (recentApprovals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.05)),
              const SizedBox(height: 16),
              Text(
                'NO RECENT ACTIVITY',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.2), 
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Operational logs will appear here',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.15), 
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recentApprovals.asMap().entries.map((entry) {
        final index = entry.key;
        final req = entry.value;
        
        String title = '';
        IconData icon = Icons.info_outline_rounded;
        Color color = Colors.blueAccent;
        String tab = 'Dashboard';

        switch (req.entityType.toLowerCase()) {
          case 'worker':
            title = 'Labor Management';
            icon = Icons.engineering_rounded;
            color = Colors.tealAccent;
            tab = 'Workers';
            break;
          case 'tool':
            title = 'Equipment Request';
            icon = Icons.build_rounded;
            color = Colors.purpleAccent;
            tab = 'Tools';
            break;
          case 'machine':
            title = 'Machine Logistics';
            icon = Icons.precision_manufacturing_rounded;
            color = Colors.blueAccent;
            tab = 'Machines';
            break;
          case 'inventory':
            title = 'Material Log';
            icon = Icons.inventory_2_rounded;
            color = Colors.orangeAccent;
            tab = 'Inventory';
            break;
          case 'payment':
            title = 'Payment Record';
            icon = Icons.payments_rounded;
            color = Colors.greenAccent;
            tab = 'Financials';
            break;
        }

        return StaggeredAnimation(
          index: index + 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ProfessionalCard(
              padding: EdgeInsets.zero,
              child: InkWell(
                onTap: () => widget.onNavigateToTab(tab),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 22, color: color),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(req.createdAt),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${req.action.name.toUpperCase()}: ${req.payload['name'] ?? 'Action Item'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StatusChip(
                              status: req.status == ApprovalStatus.approved 
                                  ? UiStatus.approved 
                                  : (req.status == ApprovalStatus.rejected ? UiStatus.rejected : UiStatus.pending),
                              labelOverride: req.status.name.toUpperCase(),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withOpacity(0.15)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDashboardLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ProfessionalSectionHeader(
            title: 'Loading Data...',
            subtitle: 'Syncing site metrics',
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
            childAspectRatio: MediaQuery.of(context).size.width < 600 ? 1.05 : 1.3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: List.generate(4, (index) => _buildLoadingCard()),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    final theme = Theme.of(context);
    return ProfessionalCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 10,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {}),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiTile extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;
  final String? status;
  final VoidCallback? onTap;

  const _KpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
    this.status,
    this.onTap,
  });

  @override
  State<_KpiTile> createState() => _KpiTileState();
}

class _KpiTileState extends State<_KpiTile> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: ProfessionalCard(
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.icon, color: widget.color, size: 20),
                      ),
                      if (widget.status != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_rounded, size: 8, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'APPROVED',
                                style: TextStyle(color: Colors.green, fontSize: 7, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (widget.isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.trend,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: widget.isPositive ? Colors.green.shade800 : Colors.red.shade800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              widget.title.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textTheme.bodySmall?.color,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        height: 20,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _generateDummySpots(),
                                isCurved: true,
                                color: widget.color,
                                barWidth: 2.5,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: widget.color.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _generateDummySpots() {
    final rand = math.Random(widget.title.hashCode);
    return List.generate(6, (i) => FlSpot(i.toDouble(), rand.nextDouble() * 5));
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ProfessionalCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: theme.iconTheme.color?.withOpacity(0.5), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactActionGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CompactActionGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isMobile = SidebarProvider.of(context)?.isMobile ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: isMobile ? 2 : 3,
        childAspectRatio: isMobile ? 1.2 : 1.0,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: children,
      ),
    );
  }
}

class _CompactActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _CompactActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ProfessionalCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF78909C),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddFab extends StatelessWidget {
  final EngineerModel engineer;
  final bool isExpanded;
  final VoidCallback onToggle;
  final AnimationController controller;

  const _QuickAddFab({
    required this.engineer,
    required this.isExpanded,
    required this.onToggle,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final permissions = engineer.permissions;
    final actions = <Widget>[];
    int actionIndex = 0;

    // Log Payment - Financials
    if (permissions.siteManagement || permissions.reportViewing) {
      actions.add(_buildFabOption(
        context,
        icon: Icons.payments_rounded,
        label: 'Log Payment',
        onTap: () {
          onToggle();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: PaymentFormSheet(
                category: 'worker',
                onSubmit: (payment) {
                  context.read<PaymentService>().createPayment(payment);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment logged successfully')),
                  );
                },
              ),
            ),
          );
        },
        index: actionIndex++,
      ));
      if (actions.isNotEmpty) actions.add(const SizedBox(height: 12));
    }

    // Mark Attendance - Worker Management
    if (permissions.workerManagement) {
      actions.add(_buildFabOption(
        context,
        icon: Icons.person_add_rounded,
        label: 'Mark Attendance',
        onTap: () {
          onToggle();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkersListScreen()));
        },
        index: actionIndex++,
      ));
      if (actions.length > 1) actions.add(const SizedBox(height: 12));
    }

    // Add Material - Inventory Management
    if (permissions.inventoryManagement) {
      actions.add(_buildFabOption(
        context,
        icon: Icons.inventory_2_rounded,
        label: 'Add Material',
        onTap: () {
          onToggle();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialFormScreen()));
        },
        index: actionIndex++,
      ));
      if (actions.length > 2) actions.add(const SizedBox(height: 12));
    }

    // Add Machine - Tool/Machine Management
    if (permissions.toolMachineManagement) {
      actions.add(_buildFabOption(
        context,
        icon: Icons.precision_manufacturing_rounded,
        label: 'Add Machine',
        onTap: () {
          onToggle();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Machine Management coming soon')),
          );
        },
        index: actionIndex++,
      ));
    }

    // Only show FAB if engineer has any permissions
    if (!permissions.hasAnyPermission) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isExpanded) ...[
          ...actions,
          if (actions.isNotEmpty) const SizedBox(height: 16),
        ],
        FloatingActionButton.extended(
          onPressed: onToggle,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 8,
          label: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Row(
                children: [
                  Transform.rotate(
                    angle: controller.value * (math.pi / 4),
                    child: Icon(
                      isExpanded ? Icons.add_rounded : Icons.bolt_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isExpanded ? 'Close' : 'Quick Actions',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int index,
  }) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutBack),
    );

    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton.small(
              onPressed: onTap,
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).colorScheme.primary,
              heroTag: 'fab_$label',
              child: Icon(icon),
            ),
          ],
        ),
      ),
    );
  }
}
