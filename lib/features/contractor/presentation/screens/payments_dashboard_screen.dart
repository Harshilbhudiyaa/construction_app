import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/kpi_card.dart';
import '../../../../app/ui/widgets/section_header.dart';

class PaymentsDashboardScreen extends StatelessWidget {
  const PaymentsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI-only demo values
    const pending = 12;
    const paid = 48;
    const failed = 2;
    const totalThisMonth = '₹4,85,000';

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Pending', value: '$pending', icon: Icons.pending_actions_rounded)),
                Expanded(child: KpiCard(title: 'Paid', value: '$paid', icon: Icons.check_circle_rounded)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Failed', value: '$failed', icon: Icons.error_rounded)),
                Expanded(child: KpiCard(title: 'This Month', value: totalThisMonth, icon: Icons.payments_rounded)),
              ],
            ),
          ),
          const SectionHeader(title: 'Next', subtitle: 'We will build payout list + payout detail + approve flow'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long_rounded),
                title: const Text('Payout Queue (next step)', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Filter by pending/paid/failed'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('We will implement payout queue next.')),
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
