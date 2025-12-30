import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/kpi_card.dart';
import '../../../../app/ui/widgets/section_header.dart';

class ContractorBillingScreen extends StatelessWidget {
  const ContractorBillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Contractor Billing')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(
                  child: KpiCard(
                    title: 'Total Billed',
                    value: '₹45.2L',
                    icon: Icons.account_balance_rounded,
                  ),
                ),
                Expanded(
                  child: KpiCard(
                    title: 'Outstanding',
                    value: '₹3.8L',
                    icon: Icons.pending_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(
            title: 'Invoices',
            subtitle: 'Monthly billing cycles',
          ),
          ...[
            ('Dec 2025', '₹8,45,000', 'Paid', 'IN-2025-012'),
            ('Nov 2025', '₹7,90,000', 'Paid', 'IN-2025-011'),
            ('Oct 2025', '₹8,15,000', 'Paid', 'IN-2025-010'),
            ('Sep 2025', '₹9,20,000', 'Paid', 'IN-2025-009'),
          ].map((bill) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.description_rounded),
                  title: Text(
                    bill.$1,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(bill.$4),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        bill.$2,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        bill.$3,
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
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

