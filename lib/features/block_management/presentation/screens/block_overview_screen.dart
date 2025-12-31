import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import 'backup_usage_log_screen.dart';
import 'block_production_entry_screen.dart';

class BlockOverviewScreen extends StatelessWidget {
  const BlockOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI-only demo data
    const blocksToday = 3200;
    const mainStock = 42000;
    const backupStock = 13800;
    const backupLevel = 15000; // threshold
    final isBackupLow = backupStock < backupLevel;

    return ProfessionalPage(
      title: 'Block Management',
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
          icon: const Icon(Icons.add_circle_rounded, color: Colors.white),
        ),
      ],
      children: [
        // KPI grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: const [
                  Expanded(
                    child: _KpiTile(
                      title: 'Blocks Today',
                      value: '$blocksToday',
                      icon: Icons.view_in_ar_rounded,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _KpiTile(
                      title: 'Machines',
                      value: '2 Active',
                      icon: Icons.precision_manufacturing_rounded,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _KpiTile(
                      title: 'Main Stock',
                      value: '$mainStock',
                      icon: Icons.inventory_2_rounded,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _KpiTile(
                      title: 'Backup',
                      value: '$backupStock',
                      icon: Icons.safety_check_rounded,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Stock Status',
          subtitle: 'Refill alerts and thresholds',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Backup Threshold',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepBlue1,
                        ),
                      ),
                    ),
                    StatusChip(
                      status: isBackupLow ? UiStatus.low : UiStatus.ok,
                      labelOverride: isBackupLow ? 'Refill Needed' : 'Safe',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _kv(context, 'Critical Level', '$backupLevel blocks'),
                _kv(context, 'Current Stock', '$backupStock blocks'),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (backupStock / backupLevel).clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isBackupLow ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isBackupLow
                      ? 'Stock is below threshold. Refill action recommended.'
                      : 'Stock levels are currently optimal.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Actions',
          subtitle: 'Logs and production entries',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.add_task_rounded, color: AppColors.deepBlue1),
                  title: const Text(
                    'Add Production Entry',
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue1),
                  ),
                  subtitle: const Text('New block production count'),
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
                const Divider(height: 1, indent: 40),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long_rounded, color: AppColors.deepBlue1),
                  title: const Text(
                    'Backup Usage Log',
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue1),
                  ),
                  subtitle: const Text('Audit trail for stock usage'),
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
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Machines',
          subtitle: 'Real-time output monitoring',
        ),

        const _MachineList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Text(
            v,
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.deepBlue1),
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue1,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _MachineList extends StatelessWidget {
  const _MachineList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ProfessionalCard(
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
            Divider(height: 1, indent: 50),
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
