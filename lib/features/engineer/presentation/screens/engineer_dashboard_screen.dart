import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/kpi_card.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class EngineerDashboardScreen extends StatelessWidget {
  final void Function(int tabIndex) onNavigateToTab;

  const EngineerDashboardScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // UI-only demo values
    const activeWorkers = 12;
    const pendingApprovals = 5;
    const blocksToday = 3200;
    const lowStockItems = 3;
    const trucksInTransit = 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineer Dashboard'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          // Header card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(Icons.engineering_rounded, color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Engineer A', style: TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text('Site A • Shift: Day (demo)', style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const StatusChip(status: UiStatus.ok, labelOverride: 'On Duty'),
                  ],
                ),
              ),
            ),
          ),

          // KPI grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Active Workers', value: '$activeWorkers', icon: Icons.groups_rounded)),
                Expanded(child: KpiCard(title: 'Pending Approvals', value: '$pendingApprovals', icon: Icons.fact_check_rounded)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Blocks Today', value: '$blocksToday', icon: Icons.view_in_ar_rounded)),
                Expanded(child: KpiCard(title: 'Low Stock Items', value: '$lowStockItems', icon: Icons.warning_amber_rounded)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Trucks In Transit', value: '$trucksInTransit', icon: Icons.local_shipping_rounded)),
                Expanded(child: KpiCard(title: 'Backup Alerts', value: '1', icon: Icons.sms_failed_rounded)),
              ],
            ),
          ),

          const SectionHeader(
            title: 'Action Center',
            subtitle: 'Open modules directly',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.fact_check_rounded, color: cs.primary),
                title: const Text('Approvals Queue', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Verify worker sessions'),
                trailing: const StatusChip(status: UiStatus.pending, labelOverride: '5 Pending'),
                onTap: () => onNavigateToTab(1), // ✅ Approvals
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.precision_manufacturing_rounded, color: cs.primary),
                title: const Text('Block Production', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Production entry + backup logs'),
                trailing: const StatusChip(status: UiStatus.low, labelOverride: 'Backup Used'),
                onTap: () => onNavigateToTab(2), // ✅ Blocks
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.inventory_2_rounded, color: cs.primary),
                title: const Text('Inventory', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Low stock and ledger'),
                trailing: const StatusChip(status: UiStatus.low, labelOverride: '3 Low'),
                onTap: () => onNavigateToTab(3), // ✅ Inventory
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.local_shipping_rounded, color: cs.primary),
                title: const Text('Truck Trips', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Trips list + decision engine'),
                trailing: const StatusChip(status: UiStatus.ok, labelOverride: '2 Active'),
                onTap: () => onNavigateToTab(4), // ✅ Trucks
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
