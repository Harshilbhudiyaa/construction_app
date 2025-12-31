import 'package:flutter/material.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/confirm_sheet.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
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
      case ApprovalStatus.pending: return UiStatus.pending;
      case ApprovalStatus.approved: return UiStatus.approved;
      case ApprovalStatus.rejected: return UiStatus.rejected;
    }
  }

  Future<void> _approve() async {
    final ok = await showConfirmSheet(
      context: context,
      title: 'Authorize Worklog',
      message: 'Confirm to verify work completion and trigger automatic payroll processing.',
      confirmText: 'Verify & Authorize',
    );
    if (!ok) return;

    setState(() => _item = _item.copyWith(status: ApprovalStatus.approved, remark: 'Verified & Approved'));
    if (mounted) Navigator.pop(context, _item);
  }

  Future<void> _reject() async {
    final remark = await _rejectSheet(context);
    if (remark == null) return;

    setState(() => _item = _item.copyWith(status: ApprovalStatus.rejected, remark: remark));
    if (mounted) Navigator.pop(context, _item);
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Review Signature',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.gradientColors),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBlue1.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _item.workerName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepBlue1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_item.workerRole} • ${_item.site}',
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: _toUi(_item.status), labelOverride: _item.status.name.toUpperCase()),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Session Verification',
          subtitle: 'Audit trail of work execution',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _kv('Operational Work Type', _item.workType, icon: Icons.assignment_rounded),
                const Divider(height: 32),
                _kv('Deployment Windows', '${_item.startTime} – ${_item.endTime}', icon: Icons.schedule_rounded),
                const Divider(height: 32),
                _kv('Certified Duration', '${_item.duration} Hours', icon: Icons.timelapse_rounded, isHighlighted: true),
                const Divider(height: 32),
                _kv('Digital Submission', _item.submittedAt, icon: Icons.cloud_done_rounded),
                const Divider(height: 32),
                _kv('Immutable Session ID', _item.id, icon: Icons.fingerprint_rounded),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Engineering Decisions',
          subtitle: 'Sign-off on worklog accuracy',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _item.status == ApprovalStatus.approved ? null : _reject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: Colors.red[800],
                    side: BorderSide(color: Colors.red[300]!),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text('Decline log', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _item.status == ApprovalStatus.approved ? null : _approve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text('Authorize', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _kv(String k, String v, {IconData? icon, bool isHighlighted = false}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 12),
        ],
        Text(k, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(
          v,
          style: TextStyle(
            color: isHighlighted ? AppColors.deepBlue1 : AppColors.deepBlue1.withOpacity(0.8),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<String?> _rejectSheet(BuildContext context) async {
    final ctrl = TextEditingController();
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text(
                'Decline Worklog',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.deepBlue1, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Identify the inconsistency or reason for non-approval.',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: ctrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'e.g. Incomplete task, incorrect duration...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final t = ctrl.text.trim();
                    if (t.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Reason for decline is mandatory')));
                      return;
                    }
                    Navigator.pop(ctx, t);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text('Confirm Decline', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
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
