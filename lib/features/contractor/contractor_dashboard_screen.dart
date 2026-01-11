import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
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

    return ProfessionalPage(
      title: 'Contractor Hub',
      actions: [
        IconButton(
          onPressed: () => onNavigateTo(7),
          icon: const Icon(Icons.notifications_rounded, color: Colors.white),
        ),
        IconButton(
          onPressed: () => NavigationUtils.showLogoutDialog(context),
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
        ),
      ],
      children: [
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
                    Icons.admin_panel_settings_rounded,
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
                        'Site Administrator',
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
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Operational • All Sites Live',
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  status: UiStatus.ok,
                  labelOverride: 'Admin Mode',
                ),
              ],
            ),
          ),
        ),

        // KPIs section with Horizontal Scroll or Grid
        const ProfessionalSectionHeader(
          title: 'Infrastructure Metrics',
          subtitle: 'Real-time resource allocation status',
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
                  title: 'Workforce',
                  value: '$totalWorkers',
                  icon: Icons.groups_rounded,
                  color: Colors.blue,
                  trend: '+5%',
                  isPositive: true,
                ),
                _KpiTile(
                  title: 'Engineers',
                  value: '$totalEngineers',
                  icon: Icons.engineering_rounded,
                  color: Colors.orange,
                  trend: 'Stable',
                  isPositive: true,
                ),
                _KpiTile(
                  title: 'Active Assets',
                  value: '$activeMachines',
                  icon: Icons.precision_manufacturing_rounded,
                  color: Colors.purple,
                  trend: '100%',
                  isPositive: true,
                ),
                _KpiTile(
                  title: 'Low Stock',
                  value: '$lowStock',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                  trend: '-2 items',
                  isPositive: false,
                ),
                _KpiTile(
                  title: 'Pending Pay',
                  value: '$pendingPayments',
                  icon: Icons.payments_rounded,
                  color: Colors.green,
                  trend: '₹140k',
                  isPositive: true,
                ),
                _KpiTile(
                  title: 'System Alerts',
                  value: '$backupAlerts',
                  icon: Icons.sms_failed_rounded,
                  color: Colors.deepOrange,
                  trend: 'Critical',
                  isPositive: false,
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Strategic Control',
          subtitle: 'Direct management interfaces',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.groups_rounded,
                title: 'Workforce Directory',
                subtitle: 'Manage workers, skills, shifts, and payout rates',
                onTap: () => onNavigateTo(1),
              ),
              _ActionTile(
                icon: Icons.engineering_rounded,
                title: 'Personnel Management',
                subtitle: 'Role-based permissions and access control',
                onTap: () => onNavigateTo(2),
              ),
              _ActionTile(
                icon: Icons.precision_manufacturing_rounded,
                title: 'Machine Management',
                subtitle: 'Heavy machinery tracking, utilization & maintenance',
                onTap: () => onNavigateTo(3),
              ),
              _ActionTile(
                icon: Icons.inventory_2_rounded,
                title: 'Inventory Details',
                subtitle: 'Real-time material stock levels and consumption',
                onTap: () => onNavigateTo(4),
              ),
              _ActionTile(
                icon: Icons.build_rounded,
                title: 'Tools & Equipment',
                subtitle: 'Asset allocation, condition monitoring & tracking',
                onTap: () => onNavigateTo(5),
              ),
              _ActionTile(
                icon: Icons.payments_rounded,
                title: 'Financial Settlements',
                subtitle: 'Worker disbursals and billing cycles',
                onTap: () => onNavigateTo(6),
              ),
              _ActionTile(
                icon: Icons.analytics_rounded,
                title: 'Insight Analytics',
                subtitle: 'Visual performance and trend reports',
                onTap: () => onNavigateTo(7),
              ),
              _ActionTile(
                icon: Icons.notifications_rounded,
                title: 'Alert Command',
                subtitle: 'Broadcast system-wide messages',
                onTap: () => onNavigateTo(8),
              ),
              _ActionTile(
                icon: Icons.policy_rounded,
                title: 'Immutable Audit Log',
                subtitle: 'Administrative security event timeline',
                onTap: () => onNavigateTo(9),
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
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green[700] : Colors.red[700],
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
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
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
          trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[300], size: 14),
          onTap: onTap,
        ),
      ),
    );
  }
}

