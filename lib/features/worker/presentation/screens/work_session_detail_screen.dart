import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import 'work_history_list_screen.dart';

class WorkSessionDetailScreen extends StatelessWidget {
  final WorkSessionUi session;

  const WorkSessionDetailScreen({super.key, required this.session});

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

  String _statusText(WorkSessionStatus s) {
    switch (s) {
      case WorkSessionStatus.pending:
        return 'Pending approval by engineer';
      case WorkSessionStatus.approved:
        return 'Approved';
      case WorkSessionStatus.rejected:
        return 'Rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Session Detail')),
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
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(Icons.assignment_rounded, color: cs.onSecondaryContainer),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.workType, style: const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text('${session.site} • ${session.id}', style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    StatusChip(status: _toUiStatus(session.status)),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(_statusText(session.status), style: TextStyle(color: cs.onSurfaceVariant)),
                    if (session.status == WorkSessionStatus.rejected && (session.rejectionReason ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: cs.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: cs.error.withOpacity(0.25)),
                        ),
                        child: Text(
                          'Rejection reason:\n${session.rejectionReason}',
                          style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Timeline', subtitle: 'Selfie proof placeholders'),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Column(
                children: [
                  _timelineTile(
                    context,
                    icon: Icons.photo_camera_front_rounded,
                    title: 'Start Selfie',
                    subtitle: 'Captured at ${session.startTime} (placeholder)',
                    done: true,
                  ),
                  const Divider(height: 1),
                  _timelineTile(
                    context,
                    icon: Icons.timer_rounded,
                    title: 'Work Duration',
                    subtitle: '${session.startTime} → ${session.endTime} • ${session.duration} hrs',
                    done: true,
                  ),
                  const Divider(height: 1),
                  _timelineTile(
                    context,
                    icon: Icons.photo_camera_front_rounded,
                    title: 'End Selfie',
                    subtitle: 'Captured at ${session.endTime} (placeholder)',
                    done: true,
                  ),
                ],
              ),
            ),
          ),

          const SectionHeader(title: 'Verification', subtitle: 'Engineer decision (UI-only)'),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.verified_user_rounded, color: cs.primary),
                title: Text(session.engineer, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('Decision: ${_statusText(session.status)}'),
              ),
            ),
          ),

          const SectionHeader(title: 'Support', subtitle: 'Optional actions'),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: session.status == WorkSessionStatus.pending
                ? const EmptyState(
                    icon: Icons.info_outline_rounded,
                    title: 'Awaiting approval',
                    message: 'Your session is waiting for engineer verification.',
                  )
                : Card(
                    child: ListTile(
                      leading: Icon(Icons.report_problem_rounded, color: cs.tertiary),
                      title: const Text('Report an issue', style: TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: const Text('Raise a dispute (UI placeholder)'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report issue (next UI step)')),
                        );
                      },
                    ),
                  ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _timelineTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool done,
  }) {
    final cs = Theme.of(context).colorScheme;
    final c = done ? Colors.green : cs.onSurfaceVariant;

    return ListTile(
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: c.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Icon(icon, color: c),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: c),
      onTap: () {},
    );
  }
}
