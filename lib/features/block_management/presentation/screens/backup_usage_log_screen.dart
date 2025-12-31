import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';

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
    return ProfessionalPage(
      title: 'Backup Usage Log',
      children: [
        AppSearchField(
          hint: 'Search by work type, worker, id...',
          onChanged: (v) => setState(() => _query = v),
        ),

        const ProfessionalSectionHeader(
          title: 'Duration Filters',
          subtitle: 'Audit stock movement across timelines',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Today', 'This Week', 'This Month'].map((r) {
                final selected = _range == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(r),
                    selected: selected,
                    onSelected: (_) => setState(() => _range = r),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.deepBlue1 : Colors.white,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Usage Records',
          subtitle: 'Detailed logs for site verification',
        ),

        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No backup usage entries',
              message: 'No records match your search.',
            ),
          )
        else
          ..._filtered.map((x) {
            final status = x.acknowledged ? UiStatus.approved : UiStatus.pending;
            final label = x.acknowledged ? 'Acknowledged' : 'Pending Ack';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ProfessionalCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.deepBlue1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.history_edu_rounded,
                      color: x.acknowledged ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    'Qty: ${x.qty} • ${x.workType}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue1),
                  ),
                  subtitle: Text(
                    '${x.date}\nWorker: ${x.worker} • Ref: ${x.id}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  isThreeLine: true,
                  trailing: StatusChip(status: status, labelOverride: label),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open entry: ${x.id}')),
                    );
                  },
                ),
              ),
            );
          }),
        const SizedBox(height: 32),
      ],
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
