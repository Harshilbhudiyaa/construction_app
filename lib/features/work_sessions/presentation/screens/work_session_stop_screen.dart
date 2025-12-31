import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class WorkSessionStopScreen extends StatelessWidget {
  final String workType;
  final int totalSeconds;

  const WorkSessionStopScreen({
    super.key,
    required this.workType,
    required this.totalSeconds,
  });

  String _format(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Session Complete',
      children: [
        const ProfessionalSectionHeader(
          title: 'Summary',
          subtitle: 'Detailed session outcomes',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.deepBlue1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: AppColors.deepBlue1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workType,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.deepBlue1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total time: ${_format(totalSeconds)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _kv('Start Time', '09:00 AM'),
                const Divider(height: 24),
                _kv('End Time', '11:15 AM'),
                const Divider(height: 24),
                _kv('Efficiency', '94%'),
              ],
            ),
          ),
        ),
        const ProfessionalSectionHeader(
          title: 'Verification',
          subtitle: 'Final proofs captured',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_front_rounded, color: AppColors.deepBlue1),
                  title: const Text('End Selfie', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue1)),
                  subtitle: const Text('Captured successfully'),
                  trailing: const Icon(Icons.check_circle_rounded, color: Colors.green),
                  onTap: () {},
                ),
                Divider(height: 1, indent: 56, color: Colors.grey[200]),
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: AppColors.deepBlue1),
                  title: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue1)),
                  subtitle: Text('Awaiting verification by Site Engineer'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: () {
                // Redirect to dashboard (WorkerShell)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.workerHome,
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.deepBlue1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
        Text(v, style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
