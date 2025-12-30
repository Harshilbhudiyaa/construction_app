import 'package:flutter/material.dart';
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Work Type')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
            child: Text(
              'Choose the work you are starting now.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          ..._workTypes.map((w) {
            return Card(
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(w.icon, color: cs.onPrimaryContainer),
                ),
                title: Text(w.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Tap to start (demo)'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkSessionRunningScreen(workType: w.title),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WorkType {
  final String title;
  final IconData icon;
  const _WorkType(this.title, this.icon);
}
