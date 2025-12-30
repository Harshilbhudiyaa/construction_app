import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import 'work_session_detail_screen.dart';

enum WorkSessionStatus { pending, approved, rejected }

class WorkHistoryListScreen extends StatefulWidget {
  const WorkHistoryListScreen({super.key});

  @override
  State<WorkHistoryListScreen> createState() => _WorkHistoryListScreenState();
}

class _WorkHistoryListScreenState extends State<WorkHistoryListScreen> {
  String _query = '';
  WorkSessionStatus? _statusFilter; // null = all
  String _range = 'This Week'; // Today / This Week / This Month

  // UI-only demo data
  final List<WorkSessionUi> _sessions = [
    WorkSessionUi(
      id: 'WS-1005',
      dateLabel: 'Today',
      workType: 'Concrete Work',
      startTime: '10:10 AM',
      endTime: '11:45 AM',
      duration: '01:35',
      status: WorkSessionStatus.pending,
      site: 'Site A',
      engineer: 'Engineer A',
    ),
    WorkSessionUi(
      id: 'WS-1004',
      dateLabel: 'Today',
      workType: 'Brick / Block Work',
      startTime: '09:05 AM',
      endTime: '10:05 AM',
      duration: '01:00',
      status: WorkSessionStatus.approved,
      site: 'Site A',
      engineer: 'Engineer A',
    ),
    WorkSessionUi(
      id: 'WS-1001',
      dateLabel: 'Yesterday',
      workType: 'Plumbing',
      startTime: '04:10 PM',
      endTime: '05:05 PM',
      duration: '00:55',
      status: WorkSessionStatus.rejected,
      site: 'Site A',
      engineer: 'Engineer B',
      rejectionReason: 'End selfie unclear. Please retry next time.',
    ),
    WorkSessionUi(
      id: 'WS-0999',
      dateLabel: 'Earlier',
      workType: 'Electrical',
      startTime: '11:20 AM',
      endTime: '12:00 PM',
      duration: '00:40',
      status: WorkSessionStatus.approved,
      site: 'Site A',
      engineer: 'Engineer B',
    ),
  ];

  UiStatus _toUiStatus(WorkSessionStatus s) {
    switch (s) {
      case WorkSessionStatus.pending:
        return UiStatus.pending;
      case WorkSessionStatus.approved:
        return UiStatus.approved;
      case WorkSessionStatus.rejected:
        return UiStatus.rejected;
    }
  }

  List<WorkSessionUi> get _filtered {
    final q = _query.trim().toLowerCase();

    return _sessions.where((s) {
      if (_statusFilter != null && s.status != _statusFilter) return false;

      if (q.isEmpty) return true;

      final hay = '${s.workType} ${s.site} ${s.engineer} ${s.id}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  Map<String, List<WorkSessionUi>> get _grouped {
    final out = <String, List<WorkSessionUi>>{};
    for (final s in _filtered) {
      out.putIfAbsent(s.dateLabel, () => []).add(s);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final grouped = _grouped;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _query = '';
                _statusFilter = null;
                _range = 'This Week';
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset filters',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(
            hint: 'Search by work type, engineer, id...',
            onChanged: (v) => setState(() => _query = v),
          ),

          // Range chips
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
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

          // Status filter
          const SectionHeader(
            title: 'Filters',
            subtitle: 'Use status filter to find sessions quickly',
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
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                    FilterChip(
                      label: const Text('Pending'),
                      selected: _statusFilter == WorkSessionStatus.pending,
                      onSelected: (_) => setState(() => _statusFilter = WorkSessionStatus.pending),
                    ),
                    FilterChip(
                      label: const Text('Approved'),
                      selected: _statusFilter == WorkSessionStatus.approved,
                      onSelected: (_) => setState(() => _statusFilter = WorkSessionStatus.approved),
                    ),
                    FilterChip(
                      label: const Text('Rejected'),
                      selected: _statusFilter == WorkSessionStatus.rejected,
                      onSelected: (_) => setState(() => _statusFilter = WorkSessionStatus.rejected),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(
            title: 'Work Sessions',
            subtitle: 'Grouped by date (UI-only)',
          ),

          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: EmptyState(
                icon: Icons.history_rounded,
                title: 'No sessions found',
                message: _query.trim().isEmpty
                    ? 'No sessions available for the selected filters.'
                    : 'No results match your search.',
                actionText: 'Clear filters',
                onAction: () {
                  setState(() {
                    _query = '';
                    _statusFilter = null;
                    _range = 'This Week';
                  });
                },
              ),
            )
          else
            ...grouped.entries.map((entry) {
              final label = entry.key;
              final list = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ),
                    ...list.map((s) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Card(
                            child: ListTile(
                              leading: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                                child: Icon(Icons.work_history_rounded, color: cs.onPrimaryContainer),
                              ),
                              title: Text(
                                s.workType,
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                              subtitle: Text(
                                '${s.startTime}–${s.endTime} • ${s.duration} hrs\n${s.site} • ${s.engineer} • ${s.id}',
                              ),
                              isThreeLine: true,
                              trailing: StatusChip(status: _toUiStatus(s.status)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => WorkSessionDetailScreen(session: s)),
                                );
                              },
                            ),
                          ),
                        )),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class WorkSessionUi {
  final String id;
  final String dateLabel; // Today / Yesterday / Earlier
  final String workType;
  final String startTime;
  final String endTime;
  final String duration;
  final WorkSessionStatus status;
  final String site;
  final String engineer;
  final String? rejectionReason;

  WorkSessionUi({
    required this.id,
    required this.dateLabel,
    required this.workType,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.status,
    required this.site,
    required this.engineer,
    this.rejectionReason,
  });
}
