import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/kpi_card.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import 'earnings_breakdown_screen.dart';
import 'payout_history_screen.dart';

class EarningsDashboardScreen extends StatelessWidget {
  const EarningsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const earned = 3450;
    const paid = 2000;
    const pending = 1450;

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Earned', value: '₹$earned', icon: Icons.paid_rounded)),
                Expanded(child: KpiCard(title: 'Paid', value: '₹$paid', icon: Icons.verified_rounded)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Pending', value: '₹$pending', icon: Icons.hourglass_bottom_rounded)),
                Expanded(child: KpiCard(title: 'This Month', value: '₹9,200', icon: Icons.calendar_month_rounded)),
              ],
            ),
          ),

          const SectionHeader(title: 'Latest', subtitle: 'Most recent approval (UI-only)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: const [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Brick / Block Work', style: TextStyle(fontWeight: FontWeight.w900)),
                          SizedBox(height: 4),
                          Text('₹420 • Yesterday 6:10 PM'),
                        ],
                      ),
                    ),
                    StatusChip(status: UiStatus.approved, labelOverride: 'Approved'),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Actions', subtitle: 'Breakdown and payouts'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.view_list_rounded),
                title: const Text('Earnings Breakdown', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Session-wise earnings'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EarningsBreakdownScreen()),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long_rounded),
                title: const Text('Payout History', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Paid / Pending / Failed'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PayoutHistoryScreen()),
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
