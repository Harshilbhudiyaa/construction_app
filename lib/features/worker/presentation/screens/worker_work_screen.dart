import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/confirm_sheet.dart';

class WorkerWorkScreen extends StatefulWidget {
  const WorkerWorkScreen({super.key});

  @override
  State<WorkerWorkScreen> createState() => _WorkerWorkScreenState();
}

class _WorkerWorkScreenState extends State<WorkerWorkScreen> {
  bool _active = false;
  String _workType = 'Brick / Block Work';
  final _workTypes = const ['Brick / Block Work', 'Concrete Work', 'Electrical', 'Plumbing', 'Carpentry'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Work Type', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _workType,
                      decoration: const InputDecoration(labelText: 'Select work type'),
                      items: _workTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: _active ? null : (v) => setState(() => _workType = v ?? _workType),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Session Status', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        StatusChip(status: _active ? UiStatus.inTransit : UiStatus.ok, labelOverride: _active ? 'Running' : 'Idle'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _active
                          ? 'Timer running (UI-only). Selfie capture will be integrated later.'
                          : 'Start a work session with start selfie and stop selfie.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Session Controls', subtitle: 'Start/Stop work with proof (UI only for now)'),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Start selfie capture (placeholder)')),
                      );
                    },
                    icon: const Icon(Icons.photo_camera_front_rounded),
                    label: const Text('Start Selfie'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Stop selfie capture (placeholder)')),
                      );
                    },
                    icon: const Icon(Icons.photo_camera_front_rounded),
                    label: const Text('Stop Selfie'),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  if (!_active) {
                    setState(() => _active = true);
                    return;
                  }

                  final ok = await showConfirmSheet(
                    context: context,
                    title: 'Stop Work Session?',
                    message: 'This will end the current session and send it to engineer for approval (UI-only).',
                    confirmText: 'Stop',
                  );

                  if (ok) setState(() => _active = false);
                },
                icon: Icon(_active ? Icons.stop_circle_rounded : Icons.play_circle_rounded),
                label: Text(_active ? 'Stop Work' : 'Start Work'),
              ),
            ),
          ),

          if (!_active)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: const EmptyState(
                icon: Icons.timer_off_rounded,
                title: 'No active session',
                message: 'Start a work session to begin tracking time and proof.',
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
