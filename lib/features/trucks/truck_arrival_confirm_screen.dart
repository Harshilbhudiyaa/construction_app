import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/section_header.dart';

class TruckArrivalConfirmScreen extends StatefulWidget {
  final String tripId;

  const TruckArrivalConfirmScreen({super.key, required this.tripId});

  @override
  State<TruckArrivalConfirmScreen> createState() =>
      _TruckArrivalConfirmScreenState();
}

class _TruckArrivalConfirmScreenState extends State<TruckArrivalConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _timeCtrl = TextEditingController(text: 'Now (demo)');
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _timeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arrival confirmed (UI-only)')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arrival Confirmation')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          const SectionHeader(
            title: 'Confirm Arrival',
            subtitle: 'Trip arrival proof (UI-only)',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        readOnly: true,
                        initialValue: widget.tripId,
                        decoration: const InputDecoration(labelText: 'Trip ID'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _timeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Arrival Time',
                        ),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _noteCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          hintText: 'Unload issues, safety, mismatch...',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Capture arrival photo (next step)',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.photo_camera_rounded),
                          label: const Text('Add Arrival Photo (placeholder)'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _confirm,
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Confirm Arrival'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
