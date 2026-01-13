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
          onPressed: () {},
          icon: const Icon(Icons.history_rounded, color: Colors.white),
        ),
      ],
      children: [
        // 1. Stats Deck (Horizontal Scroll)
        const ProfessionalSectionHeader(
          title: 'STRATEGIC RESERVES',
          subtitle: 'Global stock metrics and health',
        ),
        
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildStatCard(
                title: 'Total Assets',
                value: '2.4K',
                unit: 'SKUs',
                trend: '+12%',
                isPositive: true,
                color: Colors.blueAccent,
                icon: Icons.inventory_2_rounded,
                progress: 0.82,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Low Threshold',
                value: '03',
                unit: 'Items',
                trend: 'CRITICAL',
                isPositive: false,
                color: Colors.redAccent,
                icon: Icons.warning_amber_rounded,
                progress: 0.15,
                pulse: true,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Outflow',
                value: '142',
                unit: 'Units',
                trend: 'STABLE',
                isPositive: true,
                color: Colors.orangeAccent,
                icon: Icons.output_rounded,
                progress: 0.65,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // 2. Action Center
        const ProfessionalSectionHeader(
          title: 'OPERATIONAL HUB',
          subtitle: 'Inventory management & auditing',
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildActionTile(
                title: 'Issue Material',
                subtitle: 'Dispatch resources to active sites',
                icon: Icons.unarchive_rounded,
                color: Colors.purpleAccent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MaterialIssueEntryScreen()),
                ),
              ),
              _buildActionTile(
                title: 'Inventory Ledger',
                subtitle: 'Audit all material movements',
                icon: Icons.list_alt_rounded,
                color: Colors.cyanAccent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventoryLedgerScreen()),
                ),
              ),
              _buildActionTile(
                title: 'Stock Audit',
                subtitle: 'Verify physical vs digital counts',
                icon: Icons.fact_check_rounded,
                color: Colors.amberAccent,
                onTap: () {},
              ),
            ],
          ),
        ),

        // 3. Threshold Alerts
        const ProfessionalSectionHeader(
          title: 'IMMEDIATE ATTENTION',
          subtitle: 'Critical resource depletion alerts',
        ),
        
        _buildInventoryAlerts(),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required String trend,
    required bool isPositive,
    required Color color,
    required IconData icon,
    required double progress,
    bool pulse = false,
  }) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              if (pulse)
                 _buildPulseIndicator()
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: isPositive ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: color,
            borderRadius: BorderRadius.circular(2),
            minHeight: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPulseIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2 + (_pulseController.value * 0.3)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.redAccent.withOpacity(_pulseController.value),
            ),
          ),
          child: const Text(
            'ALERT',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ProfessionalCard(
        useGlass: true,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Text(
                        subtitle.toUpperCase(),
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.2), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryAlerts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProfessionalCard(
        useGlass: true,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notification_important_rounded, color: Colors.redAccent, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '3 Items Below Threshold',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cement, Steel Bars, Sand (Medium)'.toUpperCase(),
                    style: TextStyle(color: Colors.redAccent.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryLowStockScreen()),
              ),
              child: const Text('MANAGE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}



