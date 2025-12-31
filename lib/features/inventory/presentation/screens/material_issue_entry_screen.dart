import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';

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
    return ProfessionalPage(
      title: 'Issue Material',
      children: [
        const ProfessionalSectionHeader(
          title: 'Issue Entry',
          subtitle: 'Record outward movement of site inventory',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _workType,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Work Type',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.category_rounded, color: AppColors.deepBlue1),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Concrete Work', child: Text('Concrete Work')),
                      DropdownMenuItem(value: 'Brick / Block Work', child: Text('Brick / Block Work')),
                      DropdownMenuItem(value: 'Electrical', child: Text('Electrical')),
                      DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
                    ],
                    onChanged: (v) => setState(() => _workType = v ?? _workType),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _material,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Material',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.inventory_2_rounded, color: AppColors.deepBlue1),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cement (Bags)', child: Text('Cement (Bags)')),
                      DropdownMenuItem(value: 'Sand', child: Text('Sand')),
                      DropdownMenuItem(value: 'Steel Rod', child: Text('Steel Rod')),
                    ],
                    onChanged: (v) => setState(() {
                      _material = v ?? _material;
                      _unit = _material == 'Sand' ? 'tons' : _material == 'Steel Rod' ? 'kg' : 'bags';
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _qtyCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(text: _unit),
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _issuedTo,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Issued To (Worker)',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person_rounded, color: AppColors.deepBlue1),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Ramesh Kumar', child: Text('Ramesh Kumar')),
                      DropdownMenuItem(value: 'Suresh Patel', child: Text('Suresh Patel')),
                    ],
                    onChanged: (v) => setState(() => _issuedTo = v ?? _issuedTo),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.deepBlue1),
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'Add remark like machine used, location, etc.',
                    ),
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
                          child: const Text('Issue Material'),
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
                'Final version will decrease stock and add a ledger entry automatically.',
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
