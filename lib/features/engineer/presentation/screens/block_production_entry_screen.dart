import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class BlockProductionEntryScreen extends StatefulWidget {
  const BlockProductionEntryScreen({super.key});

  @override
  State<BlockProductionEntryScreen> createState() =>
      _BlockProductionEntryScreenState();
}

class _BlockProductionEntryScreenState
    extends State<BlockProductionEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  String _machine = 'BM-01';
  String _machineType = 'Semi Automatic';
  String _blockType = 'Hollow';
  String _shift = 'Day';
  String _operator = 'Ramesh Kumar';
  final _blocksCtrl = TextEditingController(text: '1200');
  final _startCtrl = TextEditingController(text: '09:00 AM');
  final _endCtrl = TextEditingController(text: '12:00 PM');

  @override
  void dispose() {
    _blocksCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Production entry saved (UI-only)')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Production Entry')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          const SectionHeader(
            title: 'Machine',
            subtitle: 'Select machine and block type',
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
                      DropdownButtonFormField<String>(
                        value: _machine,
                        items: const [
                          DropdownMenuItem(
                            value: 'BM-01',
                            child: Text('BM-01'),
                          ),
                          DropdownMenuItem(
                            value: 'BM-02',
                            child: Text('BM-02'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _machine = v ?? _machine),
                        decoration: const InputDecoration(
                          labelText: 'Machine ID',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _machineType,
                        items: const [
                          DropdownMenuItem(
                            value: 'Semi Automatic',
                            child: Text('Semi Automatic'),
                          ),
                          DropdownMenuItem(
                            value: 'Manual',
                            child: Text('Manual'),
                          ),
                          DropdownMenuItem(
                            value: 'Automatic',
                            child: Text('Automatic'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _machineType = v ?? _machineType),
                        decoration: const InputDecoration(
                          labelText: 'Machine Type',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _blockType,
                        items: const [
                          DropdownMenuItem(
                            value: 'Hollow',
                            child: Text('Hollow'),
                          ),
                          DropdownMenuItem(
                            value: 'Solid',
                            child: Text('Solid'),
                          ),
                          DropdownMenuItem(
                            value: 'Paver',
                            child: Text('Paver'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _blockType = v ?? _blockType),
                        decoration: const InputDecoration(
                          labelText: 'Block Type',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _shift,
                        items: const [
                          DropdownMenuItem(value: 'Day', child: Text('Day')),
                          DropdownMenuItem(
                            value: 'Night',
                            child: Text('Night'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _shift = v ?? _shift),
                        decoration: const InputDecoration(labelText: 'Shift'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _operator,
                        items: const [
                          DropdownMenuItem(
                            value: 'Ramesh Kumar',
                            child: Text('Ramesh Kumar'),
                          ),
                          DropdownMenuItem(
                            value: 'Suresh Patel',
                            child: Text('Suresh Patel'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _operator = v ?? _operator),
                        decoration: const InputDecoration(
                          labelText: 'Operator',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _blocksCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Blocks Produced',
                        ),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Enter blocks produced';
                          final n = int.tryParse(t);
                          if (n == null || n <= 0) return 'Enter valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _startCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Start Time',
                              ),
                              validator: (v) =>
                                  (v ?? '').trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _endCtrl,
                              decoration: const InputDecoration(
                                labelText: 'End Time',
                              ),
                              validator: (v) =>
                                  (v ?? '').trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.info_outline_rounded, color: cs.primary),
                title: const Text(
                  'Note',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  'In final app, this saves to backend and updates stock automatically.',
                ),
                trailing: const StatusChip(
                  status: UiStatus.pending,
                  labelOverride: 'UI-only',
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
