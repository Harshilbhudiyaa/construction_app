import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../core/utils/navigation_utils.dart';

import 'models/engineer_model.dart';

class EngineerDashboardScreen extends StatefulWidget {
  final EngineerModel engineer;
  final void Function(int tabIndex) onNavigateToTab;

  const EngineerDashboardScreen({
    super.key, 
    required this.engineer,
    required this.onNavigateToTab,
  });

  @override
  State<EngineerDashboardScreen> createState() => _EngineerDashboardScreenState();
}

class _EngineerDashboardScreenState extends State<EngineerDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfessionalPage(
        title: 'Engineer Console',
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
          _buildGreeting(),

          // Hero Profile Card
          StaggeredAnimation(
            index: 0,
            child: _buildHeroProfile(),
          ),
          
          const ProfessionalSectionHeader(
            title: 'Performance Metrics',
            subtitle: 'Real-time operational statistics',
          ),

          // KPI Grid
          StaggeredAnimation(
            index: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _KpiTile(
                    title: 'Block Yield',
                    value: '1,240',
                    icon: Icons.grid_view_rounded,
                    color: Colors.blue,
                    trend: '+8%',
                    isPositive: true,
                    onTap: () => widget.onNavigateToTab(2),
                  ),

                  _KpiTile(
                    title: 'Workforce',
                    value: '45',
                    icon: Icons.groups_rounded,
                    color: Colors.orange,
                    trend: '98% Att.',
                    isPositive: true,
                    onTap: () {},
                  ),
                  _KpiTile(
                    title: 'Materials',
                    value: 'Low',
                    icon: Icons.inventory_2_rounded,
                    color: Colors.red,
                    trend: 'ACTION',
                    isPositive: false,
                    shouldPulse: true,
                    onTap: () => widget.onNavigateToTab(3),
                  ),
                  _KpiTile(
                    title: 'Approvals',
                    value: '5',
                    icon: Icons.fact_check_rounded,
                    color: Colors.purple,
                    trend: 'Pending',
                    isPositive: true,
                    onTap: () => widget.onNavigateToTab(1),
                  ),
                ],
              ),
            ),
          ),

          const ProfessionalSectionHeader(
            title: 'Control Center',
            subtitle: 'Direct management interfaces',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.fact_check_rounded,
                  title: 'Approvals Queue',
                  subtitle: 'Review and approve pending requests',
                  onTap: () => widget.onNavigateToTab(1),
                ),
                _ActionTile(
                  icon: Icons.grid_view_rounded,
                  title: 'Block Production',
                  subtitle: 'Monitor manufacturing progress and quality',
                  onTap: () => widget.onNavigateToTab(2),
                ),
                _ActionTile(
                  icon: Icons.inventory_rounded,
                  title: 'Inventory Management',
                  subtitle: 'Track stock levels and consumption rates',
                  onTap: () => widget.onNavigateToTab(3),
                ),
                _ActionTile(
                  icon: Icons.local_shipping_rounded,
                  title: 'Logistics Operations',
                  subtitle: 'Truck scheduling and delivery tracking',
                  onTap: () => widget.onNavigateToTab(4),
                ),
              ],
            ),
          ),

          const ProfessionalSectionHeader(
            title: 'Recent Activity',
            subtitle: 'Site operations timeline',
          ),

          _buildRecentActivity(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
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
                  style: const TextStyle(
                    color: Colors.white,
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
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.orangeAccent, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ProfessionalCard(
        useGlass: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.deepBlue2,
                    child: Text(
                      widget.engineer.name[0],
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.engineer.name,
                        style: const TextStyle(
                          color: Colors.white,
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
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.engineer.role.displayName.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (widget.engineer.assignedSite != null) ...[ 
                            const SizedBox(width: 8),
                            Icon(Icons.location_on_rounded, size: 12, color: Colors.white.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.engineer.assignedSite!.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShiftMetric('SHIFT START', '08:00 AM'),
                  Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
                  _buildShiftMetric('DURATION', '6h 45m'),
                  Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
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
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'title': 'Material Request', 'time': '10 mins ago', 'desc': 'Cement delivery approved for Site A', 'icon': Icons.check_circle_rounded, 'color': Colors.greenAccent, 'tab': 3},
      {'title': 'Production Update', 'time': '25 mins ago', 'desc': 'Block production batch #402 completed', 'icon': Icons.grid_view_rounded, 'color': Colors.blueAccent, 'tab': 2},

      {'title': 'Approval Pending', 'time': '1 hour ago', 'desc': 'Worker overtime request awaiting review', 'icon': Icons.pending_actions_rounded, 'color': Colors.orangeAccent, 'tab': 1},
    ];

    return Column(
      children: activities.asMap().entries.map((entry) {
        final index = entry.key;
        final act = entry.value;
        return StaggeredAnimation(
          index: index + 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ProfessionalCard(
              useGlass: true,
              padding: EdgeInsets.zero,
              child: InkWell(
                onTap: () => widget.onNavigateToTab(act['tab'] as int),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (act['color'] as Color).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(act['icon'] as IconData, size: 20, color: act['color'] as Color),
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
                                  act['title'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  act['time'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.4),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              act['desc'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

class _KpiTile extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;
  final bool shouldPulse;
  final VoidCallback? onTap;

  const _KpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
    this.shouldPulse = false,
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
    if (widget.shouldPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.03);
        return GestureDetector(
          onTap: widget.onTap,
          child: Transform.scale(
            scale: widget.shouldPulse ? scale : 1.0,
            child: ProfessionalCard(
              useGlass: true,
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (widget.isPositive ? Colors.greenAccent : Colors.redAccent).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.trend,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: widget.isPositive ? Colors.greenAccent : Colors.redAccent,
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
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                widget.title.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.5),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ProfessionalCard(
        useGlass: true,
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
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
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
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
