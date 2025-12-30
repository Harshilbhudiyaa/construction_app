import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../core/utils/navigation_utils.dart';

class ContractorDashboardScreen extends StatelessWidget {
  final void Function(int tabIndex) onNavigateTo;

  const ContractorDashboardScreen({super.key, required this.onNavigateTo});

  @override
  Widget build(BuildContext context) {
    // UI-only demo values
    const totalWorkers = 68;
    const totalEngineers = 4;
    const activeMachines = 3;
    const lowStock = 5;
    const pendingPayments = 12;
    const backupAlerts = 1;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Contractor Dashboard',
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
                        Icons.admin_panel_settings_rounded,
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
                            'Contractor (Admin)',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.deepBlue1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All Sites Overview',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const StatusChip(
                      status: UiStatus.ok,
                      labelOverride: 'Live',
                    ),
                  ],
                ),
              ),

              // KPIs
              StaggeredAnimation(
                index: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: const [
                      Expanded(
                        child: _KpiTile(
                          title: 'Workers',
                          value: '$totalWorkers',
                          icon: Icons.groups_rounded,
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _KpiTile(
                          title: 'Engineers',
                          value: '$totalEngineers',
                          icon: Icons.engineering_rounded,
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
                          title: 'Machines',
                          value: '$activeMachines',
                          icon: Icons.precision_manufacturing_rounded,
                          color: Colors.purple,
                        ),
                      ),
                      Expanded(
                        child: _KpiTile(
                          title: 'Low Stock',
                          value: '$lowStock',
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
                          title: 'Pending Pay',
                          value: '$pendingPayments',
                          icon: Icons.payments_rounded,
                          color: Colors.green,
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
                title: 'Quick Navigation',
                subtitle: 'Open modules directly',
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.groups_rounded,
                      title: 'Workers',
                      subtitle: 'Create/assign skills, rates, shifts',
                      onTap: () => onNavigateTo(1),
                    ),
                    _ActionTile(
                      icon: Icons.engineering_rounded,
                      title: 'Engineers',
                      subtitle: 'Sites, permissions, approvals',
                      onTap: () => onNavigateTo(2),
                    ),
                    _ActionTile(
                      icon: Icons.precision_manufacturing_rounded,
                      title: 'Machines',
                      subtitle: 'Block machines + utilization',
                      onTap: () => onNavigateTo(3),
                    ),
                    _ActionTile(
                      icon: Icons.inventory_2_rounded,
                      title: 'Inventory Master',
                      subtitle: 'Thresholds, backup levels',
                      onTap: () => onNavigateTo(4),
                    ),
                    _ActionTile(
                      icon: Icons.payments_rounded,
                      title: 'Payments',
                      subtitle: 'Worker payouts + billing status',
                      onTap: () => onNavigateTo(5),
                    ),
                    _ActionTile(
                      icon: Icons.analytics_rounded,
                      title: 'Reports',
                      subtitle: 'Productivity, materials, trucks',
                      onTap: () => onNavigateTo(6),
                    ),
                    _ActionTile(
                      icon: Icons.policy_rounded,
                      title: 'Audit Log',
                      subtitle: 'All critical actions timeline',
                      onTap: () => onNavigateTo(7),
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
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
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
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
