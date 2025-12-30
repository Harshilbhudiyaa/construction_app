import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class MaterialIssueEntryScreen extends StatefulWidget {
  const MaterialIssueEntryScreen({super.key});

  @override
  State<MaterialIssueEntryScreen> createState() =>
      _MaterialIssueEntryScreenState();
}

class _MaterialIssueEntryScreenState extends State<MaterialIssueEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  String _workType = 'Concrete Work';
  String _material = 'Cement (Bags)';
  final _qtyCtrl = TextEditingController(text: '10');
  String _unit = 'bags';
  String _issuedTo = 'Ramesh Kumar';
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Material issued (UI-only)')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Issue Material')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          const SectionHeader(
            title: 'Issue Entry',
            subtitle: 'Record outward movement (UI-only)',
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
                        value: _workType,
                        decoration: const InputDecoration(
                          labelText: 'Work Type',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Concrete Work',
                            child: Text('Concrete Work'),
                          ),
                          DropdownMenuItem(
                            value: 'Brick / Block Work',
                            child: Text('Brick / Block Work'),
                          ),
                          DropdownMenuItem(
                            value: 'Electrical',
                            child: Text('Electrical'),
                          ),
                          DropdownMenuItem(
                            value: 'Plumbing',
                            child: Text('Plumbing'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _workType = v ?? _workType),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _material,
                        decoration: const InputDecoration(
                          labelText: 'Material',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Cement (Bags)',
                            child: Text('Cement (Bags)'),
                          ),
                          DropdownMenuItem(value: 'Sand', child: Text('Sand')),
                          DropdownMenuItem(
                            value: 'Steel Rod',
                            child: Text('Steel Rod'),
                          ),
                        ],
                        onChanged: (v) => setState(() {
                          _material = v ?? _material;
                          _unit = _material == 'Sand'
                              ? 'tons'
                              : _material == 'Steel Rod'
                              ? 'kg'
                              : 'bags';
                        }),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _qtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                              ),
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty) return 'Required';
                                final n = int.tryParse(t);
                                if (n == null || n <= 0) return 'Invalid qty';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Unit',
                                hintText: _unit,
                              ),
                              controller: TextEditingController(text: _unit),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _issuedTo,
                        decoration: const InputDecoration(
                          labelText: 'Issued To (Worker)',
                        ),
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
                            setState(() => _issuedTo = v ?? _issuedTo),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _noteCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          hintText:
                              'Add remark like machine used, location, etc.',
                        ),
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
                  'Final version will decrease stock and add a ledger entry automatically.',
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
