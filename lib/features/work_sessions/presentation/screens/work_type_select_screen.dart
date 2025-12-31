import 'package:flutter/material.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import 'work_session_running_screen.dart';

class WorkTypeSelectScreen extends StatelessWidget {
  const WorkTypeSelectScreen({super.key});

  static const _workTypes = <_WorkType>[
    _WorkType('Brick / Block Work', Icons.view_module_rounded),
    _WorkType('Concrete Work', Icons.foundation_rounded),
    _WorkType('Electrical', Icons.electrical_services_rounded),
    _WorkType('Plumbing', Icons.plumbing_rounded),
    _WorkType('Carpentry', Icons.carpenter_rounded),
    _WorkType('Painting', Icons.format_paint_rounded),
    _WorkType('Excavation', Icons.agriculture_rounded),
    _WorkType('General Labor', Icons.engineering_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Select Work Type',
      children: [
        const ProfessionalSectionHeader(
          title: 'New Session',
          subtitle: 'Choose the work you are starting now',
        ),
        ..._workTypes.map((w) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ProfessionalCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(w.icon, color: AppColors.deepBlue1),
                ),
                title: Text(
                  w.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepBlue1,
                  ),
                ),
                subtitle: const Text('Tap to start session'),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WorkSessionRunningScreen(workType: w.title),
                    ),
                  );
                },
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _WorkType {
  final String title;
  final IconData icon;
  const _WorkType(this.title, this.icon);
}

