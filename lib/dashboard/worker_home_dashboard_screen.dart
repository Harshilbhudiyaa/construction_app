import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/utils/navigation_utils.dart';
import 'package:construction_app/modules/work_sessions/work_type_select_screen.dart';
import 'package:construction_app/modules/work_sessions/work_history_list_screen.dart';
import 'package:construction_app/modules/payments/earnings_dashboard_screen.dart';
import 'package:construction_app/profiles/worker_types.dart';
import 'package:construction_app/services/mock_notification_service.dart';

class WorkerHomeDashboardScreen extends StatefulWidget {
  final Worker worker;
  final Function(int) onNavigateToTab;

  const WorkerHomeDashboardScreen({
    super.key,
    required this.worker,
    required this.onNavigateToTab,
  });

  @override
  State<WorkerHomeDashboardScreen> createState() => _WorkerHomeDashboardScreenState();
}

class _WorkerHomeDashboardScreenState extends State<WorkerHomeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Worker Console',
      actions: [
        IconButton(
          onPressed: () => widget.onNavigateToTab(4), // Profile tab
          icon: Icon(Icons.account_circle_rounded, color: Theme.of(context).colorScheme.onSurface),
        ),
        IconButton(
          onPressed: () => NavigationUtils.showLogoutDialog(context),
          icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
      children: [
        _buildWorkerProfileHeader(),
        
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: AppSearchField(hint: 'Search sessions, earnings...'),
        ),

        const ProfessionalSectionHeader(
          title: 'Shift Performance',
          subtitle: 'Daily work and earnings tracking',
        ),
        
        _buildWorkerKpis(),
        
        const ProfessionalSectionHeader(
          title: 'Quick Operations',
          subtitle: 'Manage sessions and history',
        ),
        
        _buildQuickActions(),
        
        const ProfessionalSectionHeader(
          title: 'Recent Activity',
          subtitle: 'Your latest work session',
        ),
        
        _buildRecentActivity(),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildWorkerProfileHeader() {
    final theme = Theme.of(context);
    final worker = widget.worker;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Avatar with Notification Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
                    child: Text(
                      worker.name[0],
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        worker.skill.toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ON DUTY',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  if (worker.assignedSite != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(
                          worker.assignedSite!.toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            StatusChip(
              status: worker.status == WorkerStatus.active ? UiStatus.ok : UiStatus.stop,
              labelOverride: worker.status == WorkerStatus.active ? 'ACTIVE' : 'INACTIVE',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerKpis() {
    final permissions = widget.worker.permissions;
    final List<Widget> tiles = [];

    // Today Work - Always visible for basic tracking
    tiles.add(const _WorkerKpiTile(
      title: 'Today Work',
      value: '135m',
      icon: Icons.timer_rounded,
      color: Colors.orangeAccent,
      trend: 'On Track',
    ));

    // Earned Today - Restricted
    if (permissions.earningsViewing) {
      tiles.add(const _WorkerKpiTile(
        title: 'Earned Today',
        value: '₹650',
        icon: Icons.paid_rounded,
        color: Colors.greenAccent,
        trend: '+₹150 OT',
      ));
    }

    // Pending Approvals - Base feature
    tiles.add(const _WorkerKpiTile(
      title: 'Pending',
      value: '2',
      icon: Icons.fact_check_rounded,
      color: Colors.blueAccent,
      trend: 'Approvals',
    ));

    // Weekly Total - Restricted
    if (permissions.earningsViewing) {
      tiles.add(const _WorkerKpiTile(
        title: 'Weekly Total',
        value: '₹2.4K',
        icon: Icons.trending_up_rounded,
        color: Colors.purpleAccent,
        trend: 'Optimal',
      ));
    }

    if (tiles.isEmpty) {
      return _buildNoAccessFallback('No accessible performance metrics');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: tiles,
      ),
    );
  }

  Widget _buildQuickActions() {
    final permissions = widget.worker.permissions;
    final List<Widget> items = [];

    if (permissions.workSessionLogging) {
      items.add(_ActionSquare(
        icon: Icons.play_circle_rounded,
        title: 'Start Work',
        subtitle: 'Begin session',
        color: Colors.blueAccent,
        onTap: () => widget.onNavigateToTab(1),
      ));
    }

    if (permissions.historyViewing) {
      items.add(_ActionSquare(
        icon: Icons.history_rounded,
        title: 'Sessions',
        subtitle: 'Work history',
        color: Colors.orangeAccent,
        onTap: () => widget.onNavigateToTab(2),
      ));
    }

    if (permissions.earningsViewing) {
      items.add(_ActionSquare(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Earnings',
        subtitle: 'Check salary',
        color: Colors.greenAccent,
        onTap: () => widget.onNavigateToTab(3),
      ));
    }

    if (permissions.profileEditing) {
      items.add(_ActionSquare(
        icon: Icons.manage_accounts_rounded,
        title: 'Profile',
        subtitle: 'Your settings',
        color: Colors.purpleAccent,
        onTap: () => widget.onNavigateToTab(4),
      ));
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: items,
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
              ),
              child: const Icon(Icons.work_history_rounded, color: Colors.blueAccent, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Concrete Work Summary',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '10:10 AM – 11:45 AM • 95 mins',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            StatusChip(status: UiStatus.pending, labelOverride: 'WAITING'),
          ],
        ),
      ),
    );
  }

  // --- Helper States ---

  Widget _buildNoAccessFallback(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_person_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ProfessionalSectionHeader(
            title: 'Syncing Metrics...',
            subtitle: 'Updating your work data',
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: List.generate(4, (index) => _buildLoadingCard()),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return ProfessionalCard(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
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
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
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

class _WorkerKpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _WorkerKpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 24,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateDummySpots(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateDummySpots() {
    final rand = math.Random(title.hashCode);
    return List.generate(6, (i) => FlSpot(i.toDouble(), rand.nextDouble() * 5));
  }
}

class _ActionSquare extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionSquare({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
