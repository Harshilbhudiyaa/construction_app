import 'package:flutter/material.dart';

import '../../../../app/ui/widgets/kpi_card.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/theme/app_spacing.dart';

class WorkerHomeDashboardScreen extends StatelessWidget {
  const WorkerHomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Demo values (UI-only)
    const todayMinutes = 135;
    const earnedToday = 650;
    const pending = 2;
    const lastSession = 'Concrete Work • 10:10 AM–11:45 AM';
    const currentStatus = UiStatus.pending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          // Profile header card
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
                      child: Icon(Icons.badge_rounded, color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ramesh Kumar', style: TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text('Mason • Site A (demo)', style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const StatusChip(status: currentStatus),
                  ],
                ),
              ),
            ),
          ),

          // KPIs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Today Work', value: '${todayMinutes} min', icon: Icons.timer_rounded)),
                Expanded(child: KpiCard(title: 'Earned Today', value: '₹$earnedToday', icon: Icons.paid_rounded)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Pending Approvals', value: '$pending', icon: Icons.fact_check_rounded)),
                Expanded(child: KpiCard(title: 'This Week', value: '₹2,450', icon: Icons.trending_up_rounded)),
              ],
            ),
          ),

          const SectionHeader(
            title: 'Quick Actions',
            subtitle: 'Use bottom tabs for Work / History / Earnings / Profile',
          ),

          // Quick actions grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Open Work tab to Start/Stop (UI-only)')),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.play_circle_rounded),
                            SizedBox(height: AppSpacing.sm),
                            Text('Start Work', style: TextStyle(fontWeight: FontWeight.w900)),
                            SizedBox(height: 4),
                            Text('Begin a session'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Open History tab (UI-only)')),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.history_rounded),
                            SizedBox(height: AppSpacing.sm),
                            Text('History', style: TextStyle(fontWeight: FontWeight.w900)),
                            SizedBox(height: 4),
                            Text('Sessions & status'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Open Earnings tab (UI-only)')),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.account_balance_wallet_rounded),
                            SizedBox(height: AppSpacing.sm),
                            Text('Earnings', style: TextStyle(fontWeight: FontWeight.w900)),
                            SizedBox(height: 4),
                            Text('Earned / Paid / Pending'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Open Profile tab (UI-only)')),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.person_rounded),
                            SizedBox(height: AppSpacing.sm),
                            Text('Profile', style: TextStyle(fontWeight: FontWeight.w900)),
                            SizedBox(height: 4),
                            Text('Account settings'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SectionHeader(title: 'Last Session', subtitle: 'Most recent work entry (demo)'),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.work_history_rounded, color: cs.primary),
                title: const Text('Last session summary', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text(lastSession),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
