import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/kpi_card.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import 'backup_usage_log_screen.dart';
import 'block_production_entry_screen.dart';

class BlockOverviewScreen extends StatelessWidget {
  const BlockOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // UI-only demo data
    const blocksToday = 3200;
    const mainStock = 42000;
    const backupStock = 13800;
    const backupLevel = 15000; // threshold
    final isBackupLow = backupStock < backupLevel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Management'),
        actions: [
          IconButton(
            tooltip: 'Production Entry',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BlockProductionEntryScreen(),
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
          // KPI grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(
                  child: KpiCard(
                    title: 'Blocks Today',
                    value: '$blocksToday',
                    icon: Icons.view_in_ar_rounded,
                  ),
                ),
                Expanded(
                  child: KpiCard(
                    title: 'Machines Active',
                    value: '2',
                    icon: Icons.precision_manufacturing_rounded,
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
                    title: 'Main Stock',
                    value: '$mainStock',
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                Expanded(
                  child: KpiCard(
                    title: 'Backup Stock',
                    value: '$backupStock',
                    icon: Icons.safety_check_rounded,
                  ),
                ),
              ],
            ),
          ),

          const SectionHeader(
            title: 'Stock Status',
            subtitle: 'Backup threshold monitoring (UI-only)',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Backup Threshold',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        StatusChip(
                          status: isBackupLow ? UiStatus.low : UiStatus.ok,
                          labelOverride: isBackupLow ? 'Below Threshold' : 'OK',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _kv(context, 'Backup Level', '$backupLevel blocks'),
                    _kv(context, 'Current Backup', '$backupStock blocks'),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (backupStock / backupLevel).clamp(0.0, 1.0),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isBackupLow
                          ? 'Backup stock is below threshold. Escalation + refill action needed.'
                          : 'Backup stock is within safe limit.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(
            title: 'Actions',
            subtitle: 'Production entry and backup usage logs',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.add_task_rounded, color: cs.primary),
                title: const Text(
                  'Add Production Entry',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Machine + worker + blocks produced'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BlockProductionEntryScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.receipt_long_rounded, color: cs.primary),
                title: const Text(
                  'Backup Usage Log',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Every backup usage entry (audit trail)'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BackupUsageLogScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          const SectionHeader(
            title: 'Machines (Demo)',
            subtitle: 'Per-machine output snapshot',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Column(
                children: const [
                  _MachineTile(
                    machineId: 'BM-01',
                    machineType: 'Semi Automatic',
                    blockType: 'Hollow',
                    blocksPerCycle: 12,
                    outputPerHour: 450,
                    todayOutput: 1800,
                    status: UiStatus.ok,
                  ),
                  Divider(height: 1),
                  _MachineTile(
                    machineId: 'BM-02',
                    machineType: 'Manual',
                    blockType: 'Solid',
                    blocksPerCycle: 8,
                    outputPerHour: 260,
                    todayOutput: 1400,
                    status: UiStatus.pending,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Text(v, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _MachineTile extends StatelessWidget {
  final String machineId;
  final String machineType;
  final String blockType;
  final int blocksPerCycle;
  final int outputPerHour;
  final int todayOutput;
  final UiStatus status;

  const _MachineTile({
    required this.machineId,
    required this.machineType,
    required this.blockType,
    required this.blocksPerCycle,
    required this.outputPerHour,
    required this.todayOutput,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Icon(
          Icons.precision_manufacturing_rounded,
          color: cs.onPrimaryContainer,
        ),
      ),
      title: Text(
        '$machineId • $machineType',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        '$blockType • $blocksPerCycle/cycle • $outputPerHour/hr\nToday: $todayOutput blocks',
      ),
      isThreeLine: true,
      trailing: StatusChip(
        status: status,
        labelOverride: status == UiStatus.ok ? 'Running' : 'Idle',
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Open machine detail ($machineId) — next UI step'),
          ),
        );
      },
    );
  }
}
