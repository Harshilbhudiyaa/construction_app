import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/utils/navigation_utils.dart';
import 'package:construction_app/profiles/worker_form_screen.dart';
import 'package:construction_app/profiles/engineer_form_screen.dart';
import 'package:construction_app/profiles/engineer_detail_screen.dart';
import 'package:construction_app/profiles/engineer_model.dart';
import 'package:construction_app/modules/resources/machine_form_screen.dart';
import 'package:construction_app/modules/inventory/material_form_screen.dart';
import 'package:construction_app/modules/inventory/inward_management_dashboard_screen.dart';
import 'package:construction_app/modules/inventory/material_list_screen.dart';
import 'package:construction_app/modules/inventory/master_material_list_screen.dart';
import 'package:construction_app/modules/inventory/party_management_screen.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/shared/widgets/responsive_sidebar.dart';

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

    // Determine if we have critical items
    final hasCriticalAlerts = lowStock > 0 || backupAlerts > 0;

    return Scaffold(
      body: ProfessionalPage(
        title: 'Command Center',
        actions: [
          IconButton(
            onPressed: () => widget.onNavigateTo(9),
            icon: const Icon(Icons.notifications_rounded),
          ),
          IconButton(
            onPressed: () => NavigationUtils.showLogoutDialog(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
        children: [
          _buildGreeting(),
          
          _buildQuickSearch(),

          // 1. New User Quick Start
          const ProfessionalSectionHeader(
            title: 'Quick Start Guide',
            subtitle: 'New here? Follow these steps to get set up',
          ),
          _buildQuickStartGuide(),

          // 2. Critical Actions Section (Conditional)
          if (hasCriticalAlerts) ...[
            const ProfessionalSectionHeader(
              title: 'Attention Required',
              subtitle: 'Priority items needing immediate oversight',
            ),
            _buildPriorityAlerts(lowStock, backupAlerts),
          ],

          // 2. Main Stats Grid
          const ProfessionalSectionHeader(
            title: 'Project Health & Stats',
            subtitle: 'Real-time summary of your construction site',
          ),
          _buildStatsGrid(totalWorkers, totalEngineers, activeMachines, lowStock, pendingPayments, backupAlerts),

          // 4. Categorized Strategic Control
          const ProfessionalSectionHeader(
            title: 'Personnel Management',
            subtitle: 'Track and manage your workforce and engineers',
          ),
          _buildActionGroup([
            _CompactActionTile(
              icon: Icons.groups_rounded,
              title: 'Workforce',
              subtitle: '$totalWorkers active',
              onTap: () => widget.onNavigateTo(4),
            ),
            _CompactActionTile(
              icon: Icons.engineering_rounded,
              title: 'Personnel',
              subtitle: '$totalEngineers registered',
              onTap: () => widget.onNavigateTo(3),
            ),
            _CompactActionTile(
              icon: Icons.local_shipping_rounded,
              title: 'Logistics',
              subtitle: 'Truck entries',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InwardManagementDashboardScreen()),
              ),
            ),
            _CompactActionTile(
              icon: Icons.business_rounded,
              title: 'Parties',
              subtitle: 'Suppliers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PartyManagementScreen()),
              ),
            ),
            _CompactActionTile(
              icon: Icons.inventory_2_rounded,
              title: 'Registry',
              subtitle: 'Master Materials',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MasterMaterialListScreen()),
              ),
            ),
          ]),

          const ProfessionalSectionHeader(
            title: 'Asset & Material Tracking',
            subtitle: 'Monitor machines, equipment, and material stock',
          ),
          _buildActionGroup([
            _CompactActionTile(
              icon: Icons.precision_manufacturing_rounded,
              title: 'Machines',
              subtitle: '3 Active assets',
              onTap: () => widget.onNavigateTo(7),
            ),
            _CompactActionTile(
              icon: Icons.inventory_2_rounded,
              title: 'Inventory',
              subtitle: 'Stock levels',
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const MaterialListScreen(isAdmin: true)),
              ),
            ),
            _CompactActionTile(
              icon: Icons.build_rounded,
              title: 'Tools',
              subtitle: 'Tech & Utils',
              onTap: () => widget.onNavigateTo(6),
            ),
          ]),

          const ProfessionalSectionHeader(
            title: 'Financials & Administration',
            subtitle: 'Review project costs and notifications',
          ),
          _buildActionGroup([
            _CompactActionTile(
              icon: Icons.payments_rounded,
              title: 'Financials',
              subtitle: 'Spend analysis',
              onTap: () => widget.onNavigateTo(8),
            ),
          ]),

          const ProfessionalSectionHeader(
            title: 'Recent Activity',
            subtitle: 'Live feed from site operations',
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

  Widget _buildQuickSearch() {
    return AppSearchField(
      hint: 'Search workers, materials, or sites...',
      onChanged: (v) {
        // Future: Implement global search or jump to specific list
      },
      onFilterTap: () {
        // Future: Show global filters
      },
    );
  }

  Widget _buildQuickStartGuide() {
    final steps = [
      {'icon': Icons.vpn_key_rounded, 'label': 'Grant Access', 'index': 1, 'color': Theme.of(context).colorScheme.primary},
      {'icon': Icons.fact_check_rounded, 'label': 'Approvals', 'index': 2, 'color': Colors.cyanAccent},
      {'icon': Icons.engineering_rounded, 'label': 'Manage Personnel', 'index': 3, 'color': Colors.orangeAccent},
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final theme = Theme.of(context);
          final step = steps[i];
          final color = step['color'] as Color;
          return Container(
            width: 110,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () => widget.onNavigateTo(step['index'] as int),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(step['icon'] as IconData, color: color, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      step['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityAlerts(int lowStock, int backupAlerts) {
    return StaggeredAnimation(
      index: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            if (lowStock > 0)
              _buildPriorityCard(
                'Low Stock',
                '$lowStock Items',
                Icons.warning_amber_rounded,
                const Color(0xFFF57C00),
                () => widget.onNavigateTo(5),
              ),
            if (lowStock > 0 && backupAlerts > 0) const SizedBox(height: 12),
            if (backupAlerts > 0)
              _buildPriorityCard(
                'System Alerts',
                '$backupAlerts Critical',
                Icons.error_outline_rounded,
                const Color(0xFFD32F2F),
                () => widget.onNavigateTo(9),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return ProfessionalCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: EdgeInsets.zero,
      color: color.withOpacity(0.08),
      boxShadow: [], // Flat look
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: color.withOpacity(0.7),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(int workers, int engineers, int machines, int stock, int payments, int alerts) {
    final sidebarProvider = SidebarProvider.of(context);
    final isMobile = sidebarProvider?.isMobile ?? false;

    return StaggeredAnimation(
      index: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GridView.count(  
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 3,
          childAspectRatio: isMobile ? 1.15 : 1.3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _KpiTile(
              title: 'Workforce',
              value: '$workers',
              icon: Icons.groups_rounded,
              color: Colors.blue,
              trend: '+5%',
              isPositive: true,
              onTap: () => widget.onNavigateTo(4),
            ),
            _KpiTile(
              title: 'Engineers',
              value: '$engineers',
              icon: Icons.engineering_rounded,
              color: Colors.orange,
              trend: 'Stable',
              isPositive: true,
              onTap: () => widget.onNavigateTo(3),
            ),
            _KpiTile(
              title: 'Active Assets',
              value: '$machines',
              icon: Icons.precision_manufacturing_rounded,
              color: Colors.purple,
              trend: '100%',
              isPositive: true,
              onTap: () => widget.onNavigateTo(7),
            ),
            _KpiTile(
              title: 'Financials',
              value: '₹14.2L',
              icon: Icons.payments_rounded,
              color: Colors.green,
              trend: 'On Track',
              isPositive: true,
              onTap: () => widget.onNavigateTo(8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGroup(List<Widget> children) {
    final sidebarProvider = SidebarProvider.of(context);
    final isMobile = sidebarProvider?.isMobile ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: isMobile ? 2 : 3,
        childAspectRatio: isMobile ? 1.2 : 0.95,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: children,
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

    final theme = Theme.of(context);
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
                  style: TextStyle(
                    color: theme.colorScheme.primary,
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
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final theme = Theme.of(context);
    final activities = [
      {'title': 'Worker Entry', 'time': '5 mins ago', 'desc': 'Ramesh Kumar checked in at Site A', 'icon': Icons.login_rounded, 'color': Colors.blueAccent, 'tab': 3},
      {'title': 'Material Alert', 'time': '12 mins ago', 'desc': 'Cement stock dropped below 10%', 'icon': Icons.warning_rounded, 'color': Colors.redAccent, 'tab': 4},
      {'title': 'Shift Started', 'time': '40 mins ago', 'desc': 'Night shift deployment completed', 'icon': Icons.history_rounded, 'color': Colors.greenAccent, 'tab': 8},
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  act['time'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.textTheme.bodySmall?.color,
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
                                color: theme.textTheme.bodyMedium?.color,
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
  final VoidCallback? onTap;

  const _KpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: ProfessionalCard(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
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
                              color: (widget.isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.trend,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: widget.isPositive ? Colors.green.shade800 : Colors.red.shade800,
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
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                widget.title.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.textTheme.bodySmall?.color,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ProfessionalCard(
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
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 24),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
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
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withOpacity(0.3), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _CompactActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ProfessionalCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF78909C),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialFormScreen()));
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