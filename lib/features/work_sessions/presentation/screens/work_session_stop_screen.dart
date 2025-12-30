import 'package:flutter/material.dart';

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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Stop Work')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workType,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total time: ${_format(totalSeconds)}',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.photo_camera_front_rounded),
              title: const Text('End Selfie (placeholder)'),
              subtitle: const Text('In real app: capture selfie here'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Status'),
              subtitle: const Text('Pending engineer verification (demo)'),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                // Pop to worker home shell (two pops: stop -> running -> shell, but we used replacement earlier)
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
