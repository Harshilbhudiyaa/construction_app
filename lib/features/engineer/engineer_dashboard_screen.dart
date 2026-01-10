import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
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

    return ProfessionalPage(
      title: 'Engineer Console',
      actions: [
        IconButton(
          onPressed: () {}, // Navigate to notifications if needed
          icon: const Icon(Icons.notifications_rounded, color: Colors.white),
        ),
        IconButton(
          onPressed: () => NavigationUtils.showLogoutDialog(context),
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
        ),
      ],
      children: [
        // Header card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.gradientColors),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBlue1.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.engineering_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Eng. Rajesh Khanna',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          color: AppColors.deepBlue1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Metropolis Heights • Day Shift',
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  status: UiStatus.ok,
                  labelOverride: 'Active',
                ),
              ],
            ),
          ),
        ),

        // KPI grid
        const ProfessionalSectionHeader(
          title: 'Field Metrics',
          subtitle: 'Live site performance indicators',
        ),

        StaggeredAnimation(
          index: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: const [
                _KpiTile(
                  title: 'Active Workers',
                  value: '$activeWorkers',
                  icon: Icons.groups_rounded,
                  color: Colors.blue,
                  trend: '92% Cap',
                  isPositive: true,
                ),
                _KpiTile(
                  title: 'Pending Appr.',
                  value: '$pendingApprovals',
                  icon: Icons.fact_check_rounded,
                  color: Colors.orange,
                  trend: 'Priority',
                  isPositive: false,
                ),
                _KpiTile(
                  title: 'Blocks Yield',
                  value: '$blocksToday',
                  icon: Icons.view_in_ar_rounded,
                  color: Colors.teal,
                  trend: '+12%',
                  isPositive: true,
                ),
                _KpiTile(
                  title: 'Stock Alerts',
                  value: '$lowStockItems',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                  trend: 'Reorder',
                  isPositive: false,
                ),
                _KpiTile(
                  title: 'Trucks Inbound',
                  value: '$trucksInTransit',
                  icon: Icons.local_shipping_rounded,
                  color: Colors.indigo,
                  trend: 'On-time',
                  isPositive: true,
                ),
                _KpiTile(
                  title: 'System Alerts',
                  value: '$backupAlerts',
                  icon: Icons.sms_failed_rounded,
                  color: Colors.deepOrange,
                  trend: 'Action Reqd',
                  isPositive: false,
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Operations Hub',
          subtitle: 'Execute site-level tasks',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.fact_check_rounded,
                title: 'Approvals Queue',
                subtitle: 'Verify worker sessions and attendance',
                status: UiStatus.pending,
                statusLabel: '5 Pending',
                onTap: () => widget.onNavigateToTab(1),
              ),
              _ActionTile(
                icon: Icons.precision_manufacturing_rounded,
                title: 'Production Logs',
                subtitle: 'Daily block yield and machine logs',
                status: UiStatus.low,
                statusLabel: 'Backup Active',
                onTap: () => widget.onNavigateToTab(2),
              ),
              _ActionTile(
                icon: Icons.inventory_2_rounded,
                title: 'Inventory Control',
                subtitle: 'Track material usage and stock levels',
                status: UiStatus.low,
                statusLabel: '3 Items Low',
                onTap: () => widget.onNavigateToTab(3),
              ),
              _ActionTile(
                icon: Icons.local_shipping_rounded,
                title: 'Logistics Monitor',
                subtitle: 'Inbound truck tracking and manifests',
                status: UiStatus.ok,
                statusLabel: '2 In Transit',
                onTap: () => widget.onNavigateToTab(4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;

  const _KpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.orange).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green[700] : Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.deepBlue1,
              letterSpacing: -1,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ProfessionalCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deepBlue1.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.deepBlue1, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.deepBlue1,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          trailing: StatusChip(status: status, labelOverride: statusLabel),
          onTap: onTap,
        ),
      ),
    );
  }
}


