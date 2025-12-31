import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';

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
    return ProfessionalPage(
      title: 'Block Production',
      children: [
        const ProfessionalSectionHeader(
          title: 'Machine & Block Type',
          subtitle: 'Step 1: Configuration',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _machine,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Machine ID',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.precision_manufacturing_rounded, color: AppColors.deepBlue1),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'BM-01', child: Text('BM-01')),
                      DropdownMenuItem(value: 'BM-02', child: Text('BM-02')),
                    ],
                    onChanged: (v) => setState(() => _machine = v ?? _machine),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _machineType,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Machine Type',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.settings_suggest_rounded, color: AppColors.deepBlue1),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Semi Automatic', child: Text('Semi Automatic')),
                      DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                      DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                    ],
                    onChanged: (v) => setState(() => _machineType = v ?? _machineType),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _blockType,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Block Type',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.grid_view_rounded, color: AppColors.deepBlue1),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Hollow', child: Text('Hollow')),
                      DropdownMenuItem(value: 'Solid', child: Text('Solid')),
                      DropdownMenuItem(value: 'Paver', child: Text('Paver')),
                    ],
                    onChanged: (v) => setState(() => _blockType = v ?? _blockType),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _shift,
                          style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Shift',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.shutter_speed_rounded, color: AppColors.deepBlue1),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Day', child: Text('Day')),
                            DropdownMenuItem(value: 'Night', child: Text('Night')),
                          ],
                          onChanged: (v) => setState(() => _shift = v ?? _shift),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _operator,
                          style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Operator',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Ramesh Kumar', child: Text('Ramesh Kumar')),
                            DropdownMenuItem(value: 'Suresh Patel', child: Text('Suresh Patel')),
                          ],
                          onChanged: (v) => setState(() => _operator = v ?? _operator),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _blocksCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Blocks Produced',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.analytics_rounded, color: AppColors.deepBlue1),
                    ),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Enter blocks produced';
                      final n = int.tryParse(t);
                      if (n == null || n <= 0) return 'Enter valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _startCtrl,
                          style: const TextStyle(color: AppColors.deepBlue1),
                          decoration: InputDecoration(
                            labelText: 'Start Time',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.access_time_rounded, color: AppColors.deepBlue1),
                          ),
                          validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _endCtrl,
                          style: const TextStyle(color: AppColors.deepBlue1),
                          decoration: InputDecoration(
                            labelText: 'End Time',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.update_rounded, color: AppColors.deepBlue1),
                          ),
                          validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.deepBlue1,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Save Entry'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, color: Colors.blue),
              ),
              title: const Text(
                'Note',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue1),
              ),
              subtitle: const Text(
                'In final app, this saves to backend and updates stock automatically.',
                style: TextStyle(fontSize: 13),
              ),
              trailing: const StatusChip(
                status: UiStatus.pending,
                labelOverride: 'UI-only',
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
