import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../worker/worker_form_screen.dart';
import '../engineer/engineer_form_screen.dart';
import '../engineer/engineer_detail_screen.dart';
import '../engineer/models/engineer_model.dart';
import '../engineer/machine_form_screen.dart';
import '../inventory/inventory_form_screen.dart';

class ContractorDashboardScreen extends StatefulWidget {
  final void Function(int tabIndex) onNavigateTo;

  const ContractorDashboardScreen({super.key, required this.onNavigateTo});

  @override
  State<ContractorDashboardScreen> createState() => _ContractorDashboardScreenState();
}

class _ContractorDashboardScreenState extends State<ContractorDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

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
      body: ProfessionalPage(
        title: 'Contractor Hub',
        actions: [
          IconButton(
            onPressed: () => widget.onNavigateTo(9),
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
          ),
          IconButton(
            onPressed: () => NavigationUtils.showLogoutDialog(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ],
        children: [
          _buildGreeting(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ProfessionalCard(
              useGlass: true,
            child: InkWell(
              onTap: () => widget.onNavigateTo(9),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Operations Center',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent.withOpacity(0.5),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Flexible(
                                child: Text(
                                  'System Fully Operational',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const StatusChip(
                      status: UiStatus.ok,
                      labelOverride: 'LIVE',
                    ),
                  ],
                ),
              ),
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
                childAspectRatio: 1.1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _KpiTile(
                    title: 'Workforce',
                    value: '$totalWorkers',
                    icon: Icons.groups_rounded,
                    color: Colors.blue,
                    trend: '+5%',
                    isPositive: true,
                    onTap: () => widget.onNavigateTo(1),
                  ),
                _KpiTile(
                    title: 'Engineers',
                    value: '$totalEngineers',
                    icon: Icons.engineering_rounded,
                    color: Colors.orange,
                    trend: 'Stable',
                    isPositive: true,
                    onTap: () => widget.onNavigateTo(2),
                  ),
                  _KpiTile(
                    title: 'Active Assets',
                    value: '$activeMachines',
                    icon: Icons.precision_manufacturing_rounded,
                    color: Colors.purple,
                    trend: '100%',
                    isPositive: true,
                    onTap: () => widget.onNavigateTo(3),
                  ),
                  _KpiTile(
                    title: 'Low Stock',
                    value: '$lowStock',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                    trend: '-2 items',
                    isPositive: false,
                    shouldPulse: true,
                    onTap: () => widget.onNavigateTo(4),
                  ),
                  _KpiTile(
                    title: 'Pending Pay',
                    value: '$pendingPayments',
                    icon: Icons.payments_rounded,
                    color: Colors.green,
                    trend: '₹140k',
                    isPositive: true,
                    onTap: () => widget.onNavigateTo(6),
                  ),
                  _KpiTile(
                    title: 'System Alerts',
                    value: '$backupAlerts',
                    icon: Icons.sms_failed_rounded,
                    color: Colors.deepOrange,
                    trend: 'Critical',
                    isPositive: false,
                    shouldPulse: true,
                    onTap: () => widget.onNavigateTo(9),
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
                  onTap: () => widget.onNavigateTo(1),
                ),
                _ActionTile(
                  icon: Icons.engineering_rounded,
                  title: 'Personnel Management',
                  subtitle: 'Role-based permissions and access control',
                  onTap: () => widget.onNavigateTo(2),
                ),
                _ActionTile(
                  icon: Icons.precision_manufacturing_rounded,
                  title: 'Machine Management',
                  subtitle: 'Heavy machinery tracking, utilization & maintenance',
                  onTap: () => widget.onNavigateTo(3),
                ),
                _ActionTile(
                  icon: Icons.inventory_2_rounded,
                  title: 'Inventory Details',
                  subtitle: 'Real-time material stock levels and consumption',
                  onTap: () => widget.onNavigateTo(4),
                ),
                _ActionTile(
                  icon: Icons.build_rounded,
                  title: 'Tools & Equipment',
                  subtitle: 'Asset allocation, condition monitoring & tracking',
                  onTap: () => widget.onNavigateTo(5),
                ),
                _ActionTile(
                  icon: Icons.payments_rounded,
                  title: 'Financial Settlements',
                  subtitle: 'Worker disbursals and billing cycles',
                  onTap: () => widget.onNavigateTo(6),
                ),
                _ActionTile(
                  icon: Icons.analytics_rounded,
                  title: 'Insight Analytics',
                  subtitle: 'Visual performance and trend reports',
                  onTap: () => widget.onNavigateTo(7),
                ),
                _ActionTile(
                  icon: Icons.notifications_rounded,
                  title: 'Alert Command',
                  subtitle: 'Broadcast system-wide messages',
                  onTap: () => widget.onNavigateTo(8),
                ),
                _ActionTile(
                  icon: Icons.policy_rounded,
                  title: 'Immutable Audit Log',
                  subtitle: 'Administrative security event timeline',
                  onTap: () => widget.onNavigateTo(9),
                ),
              ],
            ),
          ),

          const ProfessionalSectionHeader(
            title: 'Recent Activity',
            subtitle: 'Snapshot of site live reporting',
          ),

          _buildRecentActivity(),

          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: _QuickAddFab(
        isExpanded: _isFabExpanded,
        onToggle: _toggleFab,
        controller: _fabController,
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
                  '$greeting, Admin',
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

  Widget _buildRecentActivity() {
    final activities = [
      {'title': 'Worker Entry', 'time': '5 mins ago', 'desc': 'Ramesh Kumar checked in at Site A', 'icon': Icons.login_rounded, 'color': Colors.blueAccent, 'tab': 1},
      {'title': 'Material Alert', 'time': '12 mins ago', 'desc': 'Cement stock dropped below 10%', 'icon': Icons.warning_rounded, 'color': Colors.redAccent, 'tab': 4},
      {'title': 'Shift Started', 'time': '40 mins ago', 'desc': 'Night shift deployment completed', 'icon': Icons.history_rounded, 'color': Colors.greenAccent, 'tab': 9},
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
                onTap: () => widget.onNavigateTo(act['tab'] as int),
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


class _QuickAddFab extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final AnimationController controller;

  const _QuickAddFab({
    required this.isExpanded,
    required this.onToggle,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isExpanded) ...[
          _buildFabOption(
            context,
            icon: Icons.person_add_alt_1_rounded,
            label: 'Add Site Engineer',
            onTap: () async {
              onToggle();
              final newEngineer = await Navigator.push<EngineerModel>(
                context,
                MaterialPageRoute(
                  builder: (_) => const EngineerFormScreen(
                    initialRole: EngineerRole.siteEngineer,
                  ),
                ),
              );

              if (newEngineer != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EngineerDetailScreen(engineer: newEngineer),
                  ),
                );
              }
            },
            index: 4,
          ),
          const SizedBox(height: 12),
          _buildFabOption(
            context,
            icon: Icons.person_add_rounded,
            label: 'Add Worker',
            onTap: () {
              onToggle();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkerFormScreen()));
            },
            index: 3,
          ),
          const SizedBox(height: 12),
          _buildFabOption(
            context,
            icon: Icons.engineering_rounded,
            label: 'Add Personnel',
            onTap: () {
              onToggle();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EngineerFormScreen()));
            },
            index: 2,
          ),
          const SizedBox(height: 12),
          _buildFabOption(
            context,
            icon: Icons.precision_manufacturing_rounded,
            label: 'Add Machine',
            onTap: () {
              onToggle();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MachineFormScreen()));
            },
            index: 1,
          ),
          const SizedBox(height: 12),
          _buildFabOption(
            context,
            icon: Icons.inventory_2_rounded,
            label: 'Add Material',
            onTap: () {
              onToggle();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryFormScreen()));
            },
            index: 0,
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton.extended(
          onPressed: onToggle,
          backgroundColor: AppColors.deepBlue1,
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
                color: Colors.white,
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
                style: const TextStyle(
                  color: AppColors.deepBlue1,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton.small(
              onPressed: onTap,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.deepBlue1,
              heroTag: 'fab_$label',
              child: Icon(icon),
            ),
          ],
        ),
      ),
    );
  }
}