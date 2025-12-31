import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/responsive_sidebar.dart';
import 'inventory_ledger_screen.dart';
import 'inventory_low_stock_screen.dart';
import 'material_issue_entry_screen.dart';

class InventoryDashboardScreen extends StatelessWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI-only demo values
    const totalItems = 42;
    const lowStock = 3;
    const issuedToday = 8;
    const receivedToday = 5;

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
          'Inventory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Issue Material',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MaterialIssueEntryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_rounded, color: Colors.white),
          ),
        ],
      ),
      body: ProfessionalBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              // KPIs
              StaggeredAnimation(
                index: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: const [
                      Expanded(
                        child: _KpiTile(
                          title: 'Total Items',
                          value: '$totalItems',
                          icon: Icons.inventory_2_rounded,
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _KpiTile(
                          title: 'Low Stock',
                          value: '$lowStock',
                          icon: Icons.warning_amber_rounded,
                          color: Colors.red,
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
                          title: 'Issued Today',
                          value: '$issuedToday',
                          icon: Icons.output_rounded,
                          color: Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _KpiTile(
                          title: 'Received',
                          value: '$receivedToday',
                          icon: Icons.input_rounded,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const ProfessionalSectionHeader(
                title: 'Alerts',
                subtitle: 'Threshold monitoring',
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _ActionTile(
                  icon: Icons.warning_amber_rounded,
                  title: 'Low Stock Items',
                  subtitle: 'Below backup threshold',
                  status: UiStatus.low,
                  statusLabel: '3 Items',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryLowStockScreen(),
                    ),
                  ),
                ),
              ),

              const ProfessionalSectionHeader(
                title: 'Actions',
                subtitle: 'Manage inventory operations',
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.output_rounded,
                      title: 'Issue Material',
                      subtitle: 'Record material issued to work',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MaterialIssueEntryScreen(),
                        ),
                      ),
                    ),
                    _ActionTile(
                      icon: Icons.receipt_long_rounded,
                      title: 'Inventory Ledger',
                      subtitle: 'All stock movement (in/out)',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InventoryLedgerScreen(),
                        ),
                      ),
                    ),
                    _ActionTile(
                      icon: Icons.warning_amber_rounded,
                      title: 'Low Stock List',
                      subtitle: 'Items below threshold',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InventoryLowStockScreen(),
                        ),
                      ),
                    ),
                  ],
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final UiStatus? status;
  final String? statusLabel;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.status,
    this.statusLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.deepBlue1.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.deepBlue1, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue1,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: status != null
            ? StatusChip(status: status!, labelOverride: statusLabel)
            : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

