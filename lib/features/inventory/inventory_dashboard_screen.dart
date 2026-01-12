import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import 'inventory_ledger_screen.dart';
import 'inventory_low_stock_screen.dart';
import 'material_issue_entry_screen.dart';

class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() => _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> with SingleTickerProviderStateMixin {
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
      title: 'Inventory Control',
      actions: [
        IconButton(
          tooltip: 'Issue Material',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MaterialIssueEntryScreen()),
          ),
          icon: const Icon(Icons.add_circle_rounded, color: Colors.white),
        ),
      ],
      children: [
        const ProfessionalSectionHeader(
          title: 'Stock Health',
          subtitle: 'Real-time inventory distribution',
        ),
        
        _buildInventoryKpis(),
        
        const ProfessionalSectionHeader(
          title: 'Strategic Actions',
          subtitle: 'Operational management tools',
        ),
        
        _buildActionGrid(),
        
        const ProfessionalSectionHeader(
          title: 'Threshold Alerts',
          subtitle: 'Items requiring immediate attention',
        ),
        
        _buildInventoryAlerts(),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildInventoryKpis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        mainAxisSpacing: 12, crossAxisSpacing: 12,
        children: [
          _InventoryKpiTile(
            title: 'Total Stock',
            value: '2.4K',
            icon: Icons.inventory_2_rounded,
            color: Colors.blueAccent,
            trend: '+12%',
          ),
          _InventoryKpiTile(
            title: 'Low Stock',
            value: '3',
            icon: Icons.warning_amber_rounded,
            color: Colors.redAccent,
            trend: 'Critical',
            shouldPulse: true,
            pulseController: _pulseController,
          ),
          _InventoryKpiTile(
            title: 'Issued Today',
            value: '142',
            icon: Icons.output_rounded,
            color: Colors.orangeAccent,
            trend: 'Stable',
          ),
          _InventoryKpiTile(
            title: 'Procured',
            value: '₹12.5L',
            icon: Icons.receipt_long_rounded,
            color: Colors.greenAccent,
            trend: 'Monthly',
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _ActionCard(
            title: 'Issue Material',
            subtitle: 'Dispatch resources to active sites',
            icon: Icons.unarchive_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MaterialIssueEntryScreen()),
            ),
          ),
          _ActionCard(
            title: 'Inventory Ledger',
            subtitle: 'Audit all material movements',
            icon: Icons.list_alt_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InventoryLedgerScreen()),
            ),
          ),
          _ActionCard(
            title: 'Stock Audit',
            subtitle: 'Verify physical vs digital counts',
            icon: Icons.fact_check_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryAlerts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StaggeredAnimation(
        index: 5,
        child: ProfessionalCard(
          padding: const EdgeInsets.all(16),
          gradient: LinearGradient(
            colors: [
              Colors.redAccent.withOpacity(0.1),
              Colors.redAccent.withOpacity(0.05),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notification_important_rounded, color: Colors.redAccent, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '3 Items Below Threshold',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Cement, Steel Bars, Sand (Medium)',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventoryLowStockScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('VIEW'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryKpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool shouldPulse;
  final AnimationController? pulseController;

  const _InventoryKpiTile({
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
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
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.2), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

