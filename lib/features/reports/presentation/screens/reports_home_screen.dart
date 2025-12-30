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
            ('Worker Productivity', Icons.trending_up_rounded),
            ('Material Usage', Icons.inventory_2_rounded),
            ('Block Production', Icons.precision_manufacturing_rounded),
            ('Truck Delays', Icons.local_shipping_rounded),
            ('Payments Summary', Icons.payments_rounded),
          ].map((r) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Card(
                child: ListTile(
                  leading: Icon(r.$2, color: cs.primary),
                  title: Text(
                    r.$1,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text('Open report (next step)'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Open ${r.$1} report (next step)')),
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
