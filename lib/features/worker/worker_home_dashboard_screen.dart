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
        useGlass: true,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)],
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.deepBlue2,
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ramesh Kumar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 12, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(
                        'METROPOLIS SITE A',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            StatusChip(
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
        childAspectRatio: 1.1,
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
        childAspectRatio: 1.2,
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
        useGlass: true,
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
                  const Text(
                    'Concrete Work Summary',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '10:10 AM – 11:45 AM • 95 mins',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
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
      useGlass: true,
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
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
