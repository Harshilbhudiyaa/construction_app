import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/kpi_card.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import 'inventory_ledger_screen.dart';
import 'inventory_low_stock_screen.dart';
import 'material_issue_entry_screen.dart';

class InventoryDashboardScreen extends StatelessWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // UI-only demo values
    const totalItems = 42;
    const lowStock = 3;
    const issuedToday = 8;
    const receivedToday = 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
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
            icon: const Icon(Icons.add_circle_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(
                  child: KpiCard(
                    title: 'Total Items',
                    value: '$totalItems',
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                Expanded(
                  child: KpiCard(
                    title: 'Low Stock',
                    value: '$lowStock',
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(
                  child: KpiCard(
                    title: 'Issued Today',
                    value: '$issuedToday',
                    icon: Icons.output_rounded,
                  ),
                ),
                Expanded(
                  child: KpiCard(
                    title: 'Received Today',
                    value: '$receivedToday',
                    icon: Icons.input_rounded,
                  ),
                ),
              ],
            ),
          ),

          const SectionHeader(
            title: 'Alerts',
            subtitle: 'Threshold monitoring (UI-only)',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.warning_amber_rounded, color: cs.error),
                title: const Text(
                  'Low stock items',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  'Some materials are below backup threshold',
                ),
                trailing: const StatusChip(
                  status: UiStatus.low,
                  labelOverride: '3 Items',
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InventoryLowStockScreen(),
                  ),
                ),
              ),
            ),
          ),

          const SectionHeader(
            title: 'Actions',
            subtitle: 'Issue material, view ledger, check low stock',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.output_rounded, color: cs.primary),
                title: const Text(
                  'Issue Material',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Record material issued to work'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MaterialIssueEntryScreen(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.receipt_long_rounded, color: cs.primary),
                title: const Text(
                  'Inventory Ledger',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('All stock movement (in/out)'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InventoryLedgerScreen(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.warning_amber_rounded, color: cs.primary),
                title: const Text(
                  'Low Stock List',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Items below threshold'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InventoryLowStockScreen(),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
