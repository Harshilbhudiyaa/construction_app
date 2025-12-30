import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../core/utils/navigation_utils.dart';

class EngineerDashboardScreen extends StatefulWidget {
  final void Function(int tabIndex) onNavigateToTab;

  const EngineerDashboardScreen({super.key, required this.onNavigateToTab});

  @override
  State<EngineerDashboardScreen> createState() => _EngineerDashboardScreenState();
}

class _EngineerDashboardScreenState extends State<EngineerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // UI-only demo values
    const activeWorkers = 12;
    const pendingApprovals = 5;
    const blocksToday = 3200;
    const lowStockItems = 3;
    const trucksInTransit = 2;
    const backupAlerts = 1;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Engineer Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => NavigationUtils.showLogoutDialog(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
          ),
        ],
      ),
      body: ProfessionalBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              // Header card
              ProfessionalCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.deepBlue1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.engineering_rounded,
                        color: AppColors.deepBlue1,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Engineer A',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.deepBlue1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Site A • Shift: Day',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const StatusChip(
                      status: UiStatus.ok,
                      labelOverride: 'On Duty',
                    ),
                  ],
                ),
              ),

              // KPI grid
              StaggeredAnimation(
                index: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: const [
                      Expanded(
                        child: _KpiTile(
                          title: 'Active Workers',
                          value: '$activeWorkers',
                          icon: Icons.groups_rounded,
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _KpiTile(
                          title: 'Pending',
                          value: '$pendingApprovals',
                          icon: Icons.fact_check_rounded,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              StaggeredAnimation(
                index: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: const [
                      Expanded(
                        child: _KpiTile(
                          title: 'Blocks Today',
                          value: '$blocksToday',
                          icon: Icons.view_in_ar_rounded,
                          color: Colors.teal,
                        ),
                      ),
                      Expanded(
                        child: _KpiTile(
                          title: 'Low Stock',
                          value: '$lowStockItems',
                          icon: Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              StaggeredAnimation(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: const [
                      Expanded(
                        child: _KpiTile(
                          title: 'Trucks Transit',
                          value: '$trucksInTransit',
                          icon: Icons.local_shipping_rounded,
                          color: Colors.indigo,
                        ),
                      ),
                      Expanded(
                        child: _KpiTile(
                          title: 'Backup Alerts',
                          value: '$backupAlerts',
                          icon: Icons.sms_failed_rounded,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const ProfessionalSectionHeader(
                title: 'Action Center',
                subtitle: 'Manage site operations',
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.fact_check_rounded,
                      title: 'Approvals Queue',
                      subtitle: 'Verify worker sessions',
                      status: UiStatus.pending,
                      statusLabel: '5 Pending',
                      onTap: () => widget.onNavigateToTab(1),
                    ),
                    _ActionTile(
                      icon: Icons.precision_manufacturing_rounded,
                      title: 'Block Production',
                      subtitle: 'Production entry + logs',
                      status: UiStatus.low,
                      statusLabel: 'Backup Used',
                      onTap: () => widget.onNavigateToTab(2),
                    ),
                    _ActionTile(
                      icon: Icons.inventory_2_rounded,
                      title: 'Inventory',
                      subtitle: 'Low stock and ledger',
                      status: UiStatus.low,
                      statusLabel: '3 Low',
                      onTap: () => widget.onNavigateToTab(3),
                    ),
                    _ActionTile(
                      icon: Icons.local_shipping_rounded,
                      title: 'Truck Trips',
                      subtitle: 'Trips list & tracking',
                      status: UiStatus.ok,
                      statusLabel: '2 Active',
                      onTap: () => widget.onNavigateToTab(4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlue1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final UiStatus status;
  final String statusLabel;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.deepBlue1.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.deepBlue1, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue1,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: StatusChip(status: status, labelOverride: statusLabel),
        onTap: onTap,
      ),
    );
  }
}
