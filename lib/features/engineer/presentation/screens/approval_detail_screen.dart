import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/confirm_sheet.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import 'approvals_queue_screen.dart';

class ApprovalDetailScreen extends StatefulWidget {
  final ApprovalItem item;

  const ApprovalDetailScreen({super.key, required this.item});

  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  late ApprovalItem _item = widget.item;

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

  Future<void> _approve() async {
    final ok = await showConfirmSheet(
      context: context,
      title: 'Approve this session?',
      message: 'UI-only: marks as approved.',
      confirmText: 'Approve',
    );
    if (!ok) return;

    setState(
      () => _item = _item.copyWith(
        status: ApprovalStatus.approved,
        remark: 'Approved',
      ),
    );
    if (mounted) Navigator.pop(context, _item);
  }

  Future<void> _reject() async {
    final remark = await _rejectSheet(context);
    if (remark == null) return;

    setState(
      () => _item = _item.copyWith(
        status: ApprovalStatus.rejected,
        remark: remark,
      ),
    );
    if (mounted) Navigator.pop(context, _item);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Approval Detail')),
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
                        Icons.badge_rounded,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _item.workerName,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_item.workerRole} • ${_item.site}',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(status: _toUi(_item.status)),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Session', subtitle: 'Work and timing'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Work Type', _item.workType),
                    _kv('Time', '${_item.startTime}–${_item.endTime}'),
                    _kv('Duration', _item.duration),
                    _kv('Submitted', _item.submittedAt),
                    _kv('ID', _item.id),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Actions', subtitle: 'Approve / Reject'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _item.status == ApprovalStatus.approved
                        ? null
                        : _reject,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _item.status == ApprovalStatus.approved
                        ? null
                        : _approve,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Text(v),
        ],
      ),
    );
  }

  Future<String?> _rejectSheet(BuildContext context) async {
    final ctrl = TextEditingController();
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.sm,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reject Session',
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Remark'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final t = ctrl.text.trim();
                    if (t.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Remark required')),
                      );
                      return;
                    }
                    Navigator.pop(ctx, t);
                  },
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
    ctrl.dispose();
    return result;
  }
}
