import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

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

class _EngineerDashboardScreenState extends State<EngineerDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
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
        _buildEngineerIdCard(),
        
        const ProfessionalSectionHeader(
          title: 'Field Operations',
          subtitle: 'Live tactical metrics',
        ),
        
        _buildEngineerKpis(),
        
        const ProfessionalSectionHeader(
          title: 'Strategic Control',
          subtitle: 'Execute site-level operations',
        ),
        
        _buildOperationsHub(),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildEngineerIdCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(20),
        gradient: LinearGradient(
          colors: [
            AppColors.deepBlue1,
            AppColors.deepBlue1.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                radius: 30,
                backgroundColor: Colors.white12,
                child: Icon(Icons.engineering_rounded, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Eng. Rajesh Khanna',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'METROPOLIS HEIGHTS • DAY SHIFT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const StatusChip(
              status: UiStatus.ok,
              labelOverride: 'ON SITE',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineerKpis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _EngineerKpiTile(
            title: 'Active Crew',
            value: '14/15',
            icon: Icons.groups_3_rounded,
            color: Colors.blueAccent,
            trend: '94% Cap',
          ),
          _EngineerKpiTile(
            title: 'Pending Appr.',
            value: '5',
            icon: Icons.fact_check_rounded,
            color: Colors.orangeAccent,
            trend: 'Priority',
          ),
          _EngineerKpiTile(
            title: 'Yield Today',
            value: '3.2K',
            icon: Icons.view_in_ar_rounded,
            color: Colors.greenAccent,
            trend: '+12%',
          ),
          _EngineerKpiTile(
            title: 'Material Alert',
            value: '3 High',
            icon: Icons.warning_amber_rounded,
            color: Colors.redAccent,
            trend: 'Action Reqd',
            shouldPulse: true,
            pulseController: _pulseController,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsHub() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _OperationTile(
            icon: Icons.approval_rounded,
            title: 'Approvals Queue',
            subtitle: 'Verify work sessions and attendance',
            status: '5 Pending',
            onTap: () => widget.onNavigateToTab(1),
          ),
          _OperationTile(
            icon: Icons.precision_manufacturing_rounded,
            title: 'Production Ledger',
            subtitle: 'Detailed block yield and machine logs',
            status: 'Synced',
            onTap: () => widget.onNavigateToTab(2),
          ),
          _OperationTile(
            icon: Icons.inventory_2_rounded,
            title: 'Inventory Ops',
            subtitle: 'Stock levels and material consumption',
            status: '3 Low',
            onTap: () => widget.onNavigateToTab(3),
          ),
          _OperationTile(
            icon: Icons.local_shipping_rounded,
            title: 'Logistics Monitor',
            subtitle: 'Track inbound trucks and manifests',
            status: '2 Inbound',
            onTap: () => widget.onNavigateToTab(4),
          ),
        ],
      ),
    );
  }
}

class _EngineerKpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool shouldPulse;
  final AnimationController? pulseController;

  const _EngineerKpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    this.shouldPulse = false,
    this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController ?? kAlwaysDismissedAnimation,
      builder: (context, child) {
        final scale = shouldPulse ? 1.0 + (pulseController!.value * 0.05) : 1.0;
        return Transform.scale(
          scale: scale,
          child: ProfessionalCard(
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
          ),
        );
      },
    );
  }

  List<FlSpot> _generateDummySpots() {
    final rand = math.Random(title.hashCode);
    return List.generate(6, (i) => FlSpot(i.toDouble(), rand.nextDouble() * 5));
  }
}

class _OperationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback onTap;

  const _OperationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ProfessionalCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deepBlue1.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blueAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.2), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
