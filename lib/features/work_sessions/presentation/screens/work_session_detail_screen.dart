import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/professional_page.dart';
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
    return ProfessionalPage(
      title: 'Session Details',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_rounded, color: AppColors.deepBlue1),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.workType,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${session.site} • ID: ${session.id}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: _toUiStatus(session.status)),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Status',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue1),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusText(session.status),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                if (session.status == WorkSessionStatus.rejected &&
                    (session.rejectionReason ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rejection Reason:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.rejectionReason!,
                          style: TextStyle(color: Colors.grey[800], height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Work Timeline',
          subtitle: 'Verified activities and proofs',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _timelineTile(
                  context,
                  icon: Icons.photo_camera_front_rounded,
                  title: 'Start Selfie',
                  subtitle: 'Verified at ${session.startTime} (Biometric Match)',
                  done: true,
                ),
                Divider(height: 1, indent: 64, color: Colors.grey[200]),
                _timelineTile(
                  context,
                  icon: Icons.timer_rounded,
                  title: 'Production Phase',
                  subtitle: '${session.startTime} – ${session.endTime} • ${session.duration} hrs',
                  done: true,
                ),
                Divider(height: 1, indent: 64, color: Colors.grey[200]),
                _timelineTile(
                  context,
                  icon: Icons.photo_camera_front_rounded,
                  title: 'End Selfie',
                  subtitle: 'Verified at ${session.endTime} (Site Exit)',
                  done: true,
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Verification Details',
          subtitle: 'Audit trail of the session',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.deepBlue1.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: AppColors.deepBlue1),
              ),
              title: Text(
                session.engineer,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue1),
              ),
              subtitle: Text(
                'Assigned Site Engineer • Decision Logged',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ),
        ),

        if (session.status != WorkSessionStatus.pending) ...[
          const ProfessionalSectionHeader(
            title: 'Assistance',
            subtitle: 'Optionally raise concerns',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ProfessionalCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.report_problem_rounded, color: Colors.orange),
                ),
                title: const Text(
                  'Report Discrepancy',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue1),
                ),
                subtitle: const Text('Dispute hours or work type verification'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Raising dispute request...')),
                  );
                },
              ),
            ),
          ),
        ],

        const SizedBox(height: 48),
      ],
    );
  }

  Widget _timelineTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool done,
  }) {
    final c = done ? Colors.green : Colors.grey;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue1, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Icon(
        done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: c,
        size: 20,
      ),
      onTap: () {},
    );
  }
}
