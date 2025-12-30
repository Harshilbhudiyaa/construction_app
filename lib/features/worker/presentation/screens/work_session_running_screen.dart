import 'dart:async';
import 'package:flutter/material.dart';
import 'work_session_stop_screen.dart';

class WorkSessionRunningScreen extends StatefulWidget {
  final String workType;

  const WorkSessionRunningScreen({super.key, required this.workType});

  @override
  State<WorkSessionRunningScreen> createState() => _WorkSessionRunningScreenState();
}

class _WorkSessionRunningScreenState extends State<WorkSessionRunningScreen> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
      appBar: AppBar(title: const Text('Work Session')),
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
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.work_rounded, color: cs.onSecondaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.workType, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('Session is running', style: TextStyle(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Chip(
                    label: const Text('LIVE'),
                    backgroundColor: cs.tertiaryContainer,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    _format(_seconds),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Timer (demo). In real app: start selfie captured before timer.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.photo_camera_front_rounded),
              title: const Text('Start Selfie (placeholder)'),
              subtitle: const Text('Already assumed captured for demo'),
              trailing: Icon(Icons.check_circle_rounded, color: cs.primary),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.stop_circle_rounded),
              label: const Text('Stop Work'),
              onPressed: () {
                _timer?.cancel();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkSessionStopScreen(
                      workType: widget.workType,
                      totalSeconds: _seconds,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
