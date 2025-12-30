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
                Expanded(
                  child: KpiCard(
                    title: 'Pending',
                    value: '$pending',
                    icon: Icons.pending_actions_rounded,
                  ),
                ),
                Expanded(
                  child: KpiCard(
                    title: 'Paid',
                    value: '$paid',
                    icon: Icons.check_circle_rounded,
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
                    title: 'Failed',
                    value: '$failed',
                    icon: Icons.error_rounded,
                  ),
                ),
                Expanded(
                  child: KpiCard(
                    title: 'This Month',
                    value: totalThisMonth,
                    icon: Icons.payments_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(
            title: 'Recent Payouts',
            subtitle: 'Overview of worker payments',
          ),
          ...[
            (name: 'Ramesh Kumar', amount: '₹12,450', status: 'Paid', date: '28 Dec'),
            (name: 'Suresh Singh', amount: '₹8,900', status: 'Pending', date: '29 Dec'),
            (name: 'Mahesh Babu', amount: '₹15,000', status: 'Failed', date: '27 Dec'),
            (name: 'Amit Shah', amount: '₹6,700', status: 'Paid', date: '26 Dec'),
          ].map((p) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(p.name[0]),
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text('${p.date} • ${p.status}'),
                  trailing: Text(
                    p.amount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: p.status == 'Paid' 
                        ? Colors.green 
                        : (p.status == 'Failed' ? Colors.red : Colors.orange),
                    ),
                  ),
                  onTap: () {},
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

