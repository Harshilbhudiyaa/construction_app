import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/kpi_card.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/empty_state.dart';

class WorkerEarningsDashboardScreen extends StatelessWidget {
  const WorkerEarningsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Earned', value: '₹3,450', icon: Icons.paid_rounded)),
                Expanded(child: KpiCard(title: 'Paid', value: '₹2,000', icon: Icons.verified_rounded)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Pending', value: '₹1,450', icon: Icons.hourglass_bottom_rounded)),
                Expanded(child: KpiCard(title: 'This Month', value: '₹9,200', icon: Icons.calendar_month_rounded)),
              ],
            ),
          ),
          const SectionHeader(title: 'Breakdown', subtitle: 'Next step adds weekly/monthly breakdown + payout history'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: EmptyState(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Earnings UI ready',
              message: 'Step 1.3 will implement breakdown and payout history screens.',
            ),
          ),
        ],
      ),
    );
  }
}
