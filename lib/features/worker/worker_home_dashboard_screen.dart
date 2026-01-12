import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
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
    return ProfessionalPage(
      title: 'Worker Console',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_rounded, color: Colors.white),
        ),
        IconButton(
          onPressed: () => NavigationUtils.showLogoutDialog(context),
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
        ),
      ],
      children: [
        _buildWorkerProfileHeader(),
        
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(20),
        gradient: LinearGradient(
          colors: [
            AppColors.deepBlue1,
            AppColors.deepBlue1.withOpacity(0.8),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white12,
                child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ramesh Kumar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'MASON • METROPOLIS SITE A',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const StatusChip(
              status: UiStatus.ok,
              labelOverride: 'ACTIVE',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerKpis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: const [
          _WorkerKpiTile(
            title: 'Today Work',
            value: '135m',
            icon: Icons.timer_rounded,
            color: Colors.orangeAccent,
            trend: 'On Track',
          ),
          _WorkerKpiTile(
            title: 'Earned Today',
            value: '₹650',
            icon: Icons.paid_rounded,
            color: Colors.greenAccent,
            trend: '+₹150 OT',
          ),
          _WorkerKpiTile(
            title: 'Pending',
            value: '2',
            icon: Icons.fact_check_rounded,
            color: Colors.blueAccent,
            trend: 'Approvals',
          ),
          _WorkerKpiTile(
            title: 'Weekly Total',
            value: '₹2.4K',
            icon: Icons.trending_up_rounded,
            color: Colors.purpleAccent,
            trend: 'Optimal',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.25,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          _ActionSquare(
            icon: Icons.play_circle_rounded,
            title: 'Start Work',
            subtitle: 'Begin session',
            color: Colors.blueAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkTypeSelectScreen()),
              );
            },
          ),
          _ActionSquare(
            icon: Icons.history_rounded,
            title: 'Sessions',
            subtitle: 'Work history',
            color: Colors.orangeAccent,
            onTap: () {},
          ),
          _ActionSquare(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Earnings',
            subtitle: 'Check salary',
            color: Colors.greenAccent,
            onTap: () {},
          ),
          _ActionSquare(
            icon: Icons.manage_accounts_rounded,
            title: 'Profile',
            subtitle: 'Your settings',
            color: Colors.purpleAccent,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.work_history_rounded, color: Colors.blueAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Concrete Work Summary',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '10:10 AM – 11:45 AM • 95 mins',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const StatusChip(status: UiStatus.pending, labelOverride: 'WAITING'),
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
      padding: EdgeInsets.zero,
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
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
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Text(
                  trend,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 16,
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
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.white.withOpacity(0.04),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
