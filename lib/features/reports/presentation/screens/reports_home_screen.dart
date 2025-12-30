import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/section_header.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          const SectionHeader(
            title: 'Reports',
            subtitle: 'Analytics (UI-only)',
          ),
          ...[
            (
              'Worker Productivity',
              'Output per shift analysis',
              Icons.trending_up_rounded
            ),
            (
              'Material Usage',
              'Cement, sand, and aggregate tracking',
              Icons.inventory_2_rounded
            ),
            (
              'Block Production',
              'Daily machine output vs targets',
              Icons.precision_manufacturing_rounded
            ),
            (
              'Truck Delays',
              'Logistics and turnaround time',
              Icons.local_shipping_rounded
            ),
            (
              'Payments Summary',
              'Total payouts vs budgets',
              Icons.payments_rounded
            ),
          ].map((r) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Card(
                child: ListTile(
                  leading: Icon(r.$3, color: cs.primary),
                  title: Text(
                    r.$1,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(r.$2),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Generating ${r.$1} report...')),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
