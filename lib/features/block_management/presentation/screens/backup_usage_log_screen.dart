import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class BackupUsageLogScreen extends StatefulWidget {
  const BackupUsageLogScreen({super.key});

  @override
  State<BackupUsageLogScreen> createState() => _BackupUsageLogScreenState();
}

class _BackupUsageLogScreenState extends State<BackupUsageLogScreen> {
  String _query = '';
  String _range = 'This Week';

  final _items = <BackupUsageItem>[
    const BackupUsageItem(
      id: 'BU-3004',
      date: 'Today 02:15 PM',
      qty: 1200,
      workType: 'Brick / Block Work',
      worker: 'Suresh Patel',
      engineer: 'Engineer A',
      acknowledged: false,
    ),
    const BackupUsageItem(
      id: 'BU-2999',
      date: 'Yesterday 06:10 PM',
      qty: 800,
      workType: 'Concrete Work',
      worker: 'Ramesh Kumar',
      engineer: 'Engineer A',
      acknowledged: true,
    ),
  ];

  List<BackupUsageItem> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((x) {
      final hay =
          '${x.id} ${x.date} ${x.workType} ${x.worker} ${x.engineer} ${x.qty}'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup Usage Log')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(
            hint: 'Search by work type, worker, id...',
            onChanged: (v) => setState(() => _query = v),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Today', 'This Week', 'This Month'].map((r) {
                final selected = _range == r;
                return ChoiceChip(
                  label: Text(r),
                  selected: selected,
                  onSelected: (_) => setState(() => _range = r),
                );
              }).toList(),
            ),
          ),

          const SectionHeader(
            title: 'Entries',
            subtitle: 'Each backup usage is logged for audit',
          ),

          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: const EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No backup usage entries',
                message: 'No records match your search.',
              ),
            )
          else
            ..._filtered.map((x) {
              final status = x.acknowledged
                  ? UiStatus.approved
                  : UiStatus.pending;
              final label = x.acknowledged ? 'Acknowledged' : 'Pending Ack';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: (x.acknowledged ? Colors.green : cs.tertiary)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        Icons.safety_check_rounded,
                        color: x.acknowledged ? Colors.green : cs.tertiary,
                      ),
                    ),
                    title: Text(
                      'Qty: ${x.qty} • ${x.workType}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${x.date}\nWorker: ${x.worker} • Engineer: ${x.engineer} • ${x.id}',
                    ),
                    isThreeLine: true,
                    trailing: StatusChip(status: status, labelOverride: label),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Open backup usage detail (${x.id}) — next UI step',
                          ),
                        ),
                      );
                    },
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

class BackupUsageItem {
  final String id;
  final String date;
  final int qty;
  final String workType;
  final String worker;
  final String engineer;
  final bool acknowledged;

  const BackupUsageItem({
    required this.id,
    required this.date,
    required this.qty,
    required this.workType,
    required this.worker,
    required this.engineer,
    required this.acknowledged,
  });
}
