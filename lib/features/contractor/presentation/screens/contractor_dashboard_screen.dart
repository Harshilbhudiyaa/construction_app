import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/kpi_card.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class ContractorDashboardScreen extends StatelessWidget {
  final void Function(int tabIndex) onNavigateTo;

  const ContractorDashboardScreen({super.key, required this.onNavigateTo});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // UI-only demo values
    const totalWorkers = 68;
    const totalEngineers = 4;
    const activeMachines = 3;
    const lowStock = 5;
    const pendingPayments = 12;
    const backupAlerts = 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contractor Dashboard'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
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
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contractor (Admin)',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All Sites Overview (demo)',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const StatusChip(
                      status: UiStatus.ok,
                      labelOverride: 'Live',
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(
                  child: KpiCard(
                    title: 'Workers',
                    value: '$totalWorkers',
                    icon: Icons.groups_rounded,
                  ),
                ),
                Expanded(
                  child: KpiCard(
                    title: 'Engineers',
                    value: '$totalEngineers',
                    icon: Icons.engineering_rounded,
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
                    title: 'Machines Active',
                    value: '$activeMachines',
                    icon: Icons.precision_manufacturing_rounded,
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
                    title: 'Pending Payments',
                    value: '$pendingPayments',
                    icon: Icons.payments_rounded,
                  ),
                ),
                Expanded(
                  child: KpiCard(
                    title: 'Backup Alerts',
                    value: '$backupAlerts',
                    icon: Icons.sms_failed_rounded,
                  ),
                ),
              ],
            ),
          ),

          const SectionHeader(
            title: 'Quick Navigation',
            subtitle: 'Open modules directly',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.groups_rounded, color: cs.primary),
                title: const Text(
                  'Workers',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Create/assign skills, rates, shifts'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onNavigateTo(1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.engineering_rounded, color: cs.primary),
                title: const Text(
                  'Engineers',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Sites, permissions, approvals'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onNavigateTo(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(
                  Icons.precision_manufacturing_rounded,
                  color: cs.primary,
                ),
                title: const Text(
                  'Machines',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Block machines + utilization'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onNavigateTo(3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.inventory_2_rounded, color: cs.primary),
                title: const Text(
                  'Inventory Master',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Thresholds, backup levels'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onNavigateTo(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.payments_rounded, color: cs.primary),
                title: const Text(
                  'Payments',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Worker payouts + billing status'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onNavigateTo(5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.analytics_rounded, color: cs.primary),
                title: const Text(
                  'Reports',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Productivity, materials, trucks'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onNavigateTo(6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.policy_rounded, color: cs.primary),
                title: const Text(
                  'Audit Log',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('All critical actions timeline'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onNavigateTo(7),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
