import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';

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
          title: 'Inventory Command',
          subtitle: 'Record outward tactical movement',
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StaggeredAnimation(
            index: 0,
            child: ProfessionalCard(
              padding: const EdgeInsets.all(24),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildGlassDropdown(
                      label: 'Target Work Segment',
                      icon: Icons.segment_rounded,
                      value: _workType,
                      items: const [
                        'Concrete Work',
                        'Brick / Block Work',
                        'Electrical',
                        'Plumbing'
                      ],
                      onChanged: (v) => setState(() => _workType = v!),
                    ),
                    const SizedBox(height: 20),
                    _buildGlassDropdown(
                      label: 'Primary Material',
                      icon: Icons.inventory_2_rounded,
                      value: _material,
                      items: const [
                        'Cement (Bags)',
                        'Sand',
                        'Steel Rod'
                      ],
                      onChanged: (v) => setState(() {
                        _material = v!;
                        _unit = _material == 'Sand' ? 'tons' : _material == 'Steel Rod' ? 'kg' : 'bags';
                      }),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildGlassInput(
                            label: 'Tactical Qty',
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return '??';
                              if (double.tryParse(v) == null) return '!#';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassInput(
                            label: 'Metrics',
                            controller: TextEditingController(text: _unit),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildGlassDropdown(
                      label: 'Deploy To (Engineer/Worker)',
                      icon: Icons.person_rounded,
                      value: _issuedTo,
                      items: const [
                        'Ramesh Kumar',
                        'Suresh Patel',
                        'Eng. Rajesh Khanna'
                      ],
                      onChanged: (v) => setState(() => _issuedTo = v!),
                    ),
                    const SizedBox(height: 20),
                    _buildGlassInput(
                      label: 'Strategic Remarks (optional)',
                      controller: _noteCtrl,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: AppColors.gradientColors),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepBlue1.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'ISSUE MATERIAL',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
                              ),
                            ),
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

        const SizedBox(height: 24),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StaggeredAnimation(
            index: 1,
            child: ProfessionalCard(
              padding: const EdgeInsets.all(16),
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.1),
                  Colors.blueAccent.withOpacity(0.05),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Colors.blueAccent, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'All tactical issuances are logged to the digital ledger and tracked against site budgets.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildGlassInput({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.deepBlue1,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.5)),
              selectedItemBuilder: (context) {
                return items.map((String item) {
                  return Row(
                    children: [
                      Icon(icon, size: 18, color: Colors.blueAccent),
                      const SizedBox(width: 12),
                      Text(
                        item,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  );
                }).toList();
              },
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
