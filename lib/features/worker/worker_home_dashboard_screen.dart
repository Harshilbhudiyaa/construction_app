import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/responsive_sidebar.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../work_sessions/work_type_select_screen.dart';

class WorkerHomeDashboardScreen extends StatefulWidget {
  const WorkerHomeDashboardScreen({super.key});

  @override
  State<WorkerHomeDashboardScreen> createState() => _WorkerHomeDashboardScreenState();
}

class _WorkerHomeDashboardScreenState extends State<WorkerHomeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Demo values (UI-only)
    const todayMinutes = 135;
    const earnedToday = 650;
    const pending = 2;
    const lastSession = 'Concrete Work • 10:10 AM–11:45 AM';
    const currentStatus = UiStatus.pending;

    // Check if we're on mobile
    final sidebarProvider = SidebarProvider.of(context);
    final isMobile = sidebarProvider?.isMobile ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: isMobile
            ? IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => SidebarProvider.openDrawer(context),
              )
            : null,
        title: const Text(
          'Worker Dashboard',
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
              // Profile header card
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
                        Icons.badge_rounded,
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
                            'Ramesh Kumar',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.deepBlue1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mason • Site A',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const StatusChip(status: currentStatus),
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
                          title: 'Today Work',
                          value: '${todayMinutes} min',
                          icon: Icons.timer_rounded,
                          color: Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _KpiTile(
                          title: 'Earned Today',
                          value: '₹$earnedToday',
                          icon: Icons.paid_rounded,
                          color: Colors.green,
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
                          title: 'Pending',
                          value: '$pending',
                          icon: Icons.fact_check_rounded,
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _KpiTile(
                          title: 'This Week',
                          value: '₹2,450',
                          icon: Icons.trending_up_rounded,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const ProfessionalSectionHeader(
                title: 'Quick Actions',
                subtitle: 'Manage your work and profile',
              ),

              // Quick actions grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.play_circle_rounded,
                        title: 'Start Work',
                        subtitle: 'Begin session',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WorkTypeSelectScreen()),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.history_rounded,
                        title: 'History',
                        subtitle: 'View logs',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'Earnings',
                        subtitle: 'Check payments',
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.person_rounded,
                        title: 'Profile',
                        subtitle: 'Settings',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),

              const ProfessionalSectionHeader(
                title: 'Last Session',
                subtitle: 'Recent activity log',
              ),

              ProfessionalCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.deepBlue1.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.work_history_rounded, color: AppColors.deepBlue1),
                  ),
                  title: const Text(
                    'Last session summary',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue1),
                  ),
                  subtitle: const Text(lastSession),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {},
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.deepBlue2),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.deepBlue1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
