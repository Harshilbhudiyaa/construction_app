import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import 'earning_session_detail_screen.dart';

class EarningsBreakdownScreen extends StatefulWidget {
  const EarningsBreakdownScreen({super.key});

  @override
  State<EarningsBreakdownScreen> createState() =>
      _EarningsBreakdownScreenState();
}

class _EarningsBreakdownScreenState extends State<EarningsBreakdownScreen> {
  String _range = 'This Week';
  String _query = '';

  final _rows = <_BreakdownRow>[
    const _BreakdownRow(
      id: 'WS-1005',
      date: 'Today',
      workType: 'Concrete Work',
      amount: 650,
      status: UiStatus.pending,
    ),
    const _BreakdownRow(
      id: 'WS-1004',
      date: 'Today',
      workType: 'Brick / Block Work',
      amount: 420,
      status: UiStatus.approved,
    ),
    const _BreakdownRow(
      id: 'WS-1001',
      date: 'Yesterday',
      workType: 'Plumbing',
      amount: 300,
      status: UiStatus.rejected,
    ),
    const _BreakdownRow(
      id: 'WS-0999',
      date: 'Earlier',
      workType: 'Electrical',
      amount: 260,
      status: UiStatus.approved,
    ),
  ];

  List<_BreakdownRow> get _filtered {
    final q = _query.trim().toLowerCase();
    final base = q.isEmpty
        ? _rows
        : _rows
              .where(
                (r) => ('${r.id} ${r.date} ${r.workType} ${r.amount}')
                    .toLowerCase()
                    .contains(q),
              )
              .toList();

    // Range is UI-only; keeping it as visual filter
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings Breakdown')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(
            hint: 'Search by id, date, work type...',
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
            title: 'Sessions',
            subtitle: 'Tap any row to view details',
          ),

          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: const EmptyState(
                icon: Icons.account_balance_wallet_rounded,
                title: 'No entries',
                message: 'Try changing filters.',
              ),
            )
          else
            ..._filtered.map((r) {
              Color badgeColor() {
                switch (r.status) {
                  case UiStatus.approved:
                    return Colors.green;
                  case UiStatus.pending:
                    return cs.tertiary;
                  case UiStatus.rejected:
                    return cs.error;
                  default:
                    return cs.primary;
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: badgeColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        Icons.work_history_rounded,
                        color: badgeColor(),
                      ),
                    ),
                    title: Text(
                      r.workType,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text('${r.date} • ₹${r.amount} • ${r.id}'),
                    trailing: StatusChip(status: r.status),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EarningSessionDetailScreen(
                          sessionId: r.id,
                          workType: r.workType,
                          dateLabel: r.date,
                          startTime: '10:10 AM',
                          endTime: '11:45 AM',
                          duration: '01:35',
                          amount: r.amount,
                          status: r.status,
                        ),
                      ),
                    ),
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

class _BreakdownRow {
  final String id;
  final String date;
  final String workType;
  final int amount;
  final UiStatus status;

  const _BreakdownRow({
    required this.id,
    required this.date,
    required this.workType,
    required this.amount,
    required this.status,
  });
}
