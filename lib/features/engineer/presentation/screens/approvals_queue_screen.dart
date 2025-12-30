import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import 'approval_detail_screen.dart';

enum ApprovalStatus { pending, approved, rejected }

class ApprovalsQueueScreen extends StatefulWidget {
  const ApprovalsQueueScreen({super.key});

  @override
  State<ApprovalsQueueScreen> createState() => _ApprovalsQueueScreenState();
}

class _ApprovalsQueueScreenState extends State<ApprovalsQueueScreen> {
  String _query = '';
  ApprovalStatus? _filter;

  List<ApprovalItem> _items = [
    ApprovalItem(
      id: 'AP-1205',
      workerName: 'Ramesh Kumar',
      workerRole: 'Mason',
      workType: 'Concrete Work',
      site: 'Site A',
      startTime: '10:10 AM',
      endTime: '11:45 AM',
      duration: '01:35',
      status: ApprovalStatus.pending,
      submittedAt: '11:50 AM',
    ),
    ApprovalItem(
      id: 'AP-1204',
      workerName: 'Suresh Patel',
      workerRole: 'Helper',
      workType: 'Brick / Block Work',
      site: 'Site A',
      startTime: '09:05 AM',
      endTime: '10:05 AM',
      duration: '01:00',
      status: ApprovalStatus.pending,
      submittedAt: '10:10 AM',
    ),
  ];

  UiStatus _toUi(ApprovalStatus s) {
    switch (s) {
      case ApprovalStatus.pending:
        return UiStatus.pending;
      case ApprovalStatus.approved:
        return UiStatus.approved;
      case ApprovalStatus.rejected:
        return UiStatus.rejected;
    }
  }

  List<ApprovalItem> get _filtered {
    final q = _query.trim().toLowerCase();
    return _items.where((a) {
      if (_filter != null && a.status != _filter) return false;
      if (q.isEmpty) return true;
      final hay =
          '${a.id} ${a.workerName} ${a.workerRole} ${a.workType} ${a.site}'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approvals')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(
            hint: 'Search worker, work type, id...',
            onChanged: (v) => setState(() => _query = v),
          ),
          const SectionHeader(
            title: 'Filters',
            subtitle: 'Pending / Approved / Rejected',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                    FilterChip(
                      label: const Text('Pending'),
                      selected: _filter == ApprovalStatus.pending,
                      onSelected: (_) =>
                          setState(() => _filter = ApprovalStatus.pending),
                    ),
                    FilterChip(
                      label: const Text('Approved'),
                      selected: _filter == ApprovalStatus.approved,
                      onSelected: (_) =>
                          setState(() => _filter = ApprovalStatus.approved),
                    ),
                    FilterChip(
                      label: const Text('Rejected'),
                      selected: _filter == ApprovalStatus.rejected,
                      onSelected: (_) =>
                          setState(() => _filter = ApprovalStatus.rejected),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(
            title: 'Queue',
            subtitle: 'Tap any item to review',
          ),
          if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: EmptyState(
                icon: Icons.fact_check_rounded,
                title: 'No approvals found',
                message: 'Try clearing filters or searching.',
              ),
            )
          else
            ..._filtered.map(
              (a) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Card(
                  child: ListTile(
                    title: Text(
                      '${a.workerName} • ${a.workType}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${a.workerRole} • ${a.site}\n${a.startTime}–${a.endTime} • ${a.duration} • ${a.id}',
                    ),
                    isThreeLine: true,
                    trailing: StatusChip(status: _toUi(a.status)),
                    onTap: () async {
                      final updated = await Navigator.push<ApprovalItem?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApprovalDetailScreen(item: a),
                        ),
                      );
                      if (updated != null) {
                        setState(() {
                          final idx = _items.indexWhere(
                            (x) => x.id == updated.id,
                          );
                          if (idx != -1) _items[idx] = updated;
                        });
                      }
                    },
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

class ApprovalItem {
  final String id;
  final String workerName;
  final String workerRole;
  final String workType;
  final String site;
  final String startTime;
  final String endTime;
  final String duration;
  final ApprovalStatus status;
  final String submittedAt;
  final String? remark;

  const ApprovalItem({
    required this.id,
    required this.workerName,
    required this.workerRole,
    required this.workType,
    required this.site,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.status,
    required this.submittedAt,
    this.remark,
  });

  ApprovalItem copyWith({ApprovalStatus? status, String? remark}) {
    return ApprovalItem(
      id: id,
      workerName: workerName,
      workerRole: workerRole,
      workType: workType,
      site: site,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      status: status ?? this.status,
      submittedAt: submittedAt,
      remark: remark ?? this.remark,
    );
  }
}
