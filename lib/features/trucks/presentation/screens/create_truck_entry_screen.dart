import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class CreateTruckEntryScreen extends StatefulWidget {
  const CreateTruckEntryScreen({super.key});

  @override
  State<CreateTruckEntryScreen> createState() => _CreateTruckEntryScreenState();
}

class _CreateTruckEntryScreenState extends State<CreateTruckEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  String _supplier = 'ABC Sand Supplier';
  String _material = 'Sand';
  final _vehicleCtrl = TextEditingController(text: 'GJ01AB1234');
  final _driverCtrl = TextEditingController(text: 'Rajesh');
  final _qtyCtrl = TextEditingController(text: '3');
  String _unit = 'tons';

  @override
  void dispose() {
    _vehicleCtrl.dispose();
    _driverCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Truck entry created (UI-only)')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'New Truck Entry',
      children: [
        const ProfessionalSectionHeader(
          title: 'Trip Details',
          subtitle: 'Step 1: Supplier & Material information',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _supplier,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Supplier',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.business_rounded, color: AppColors.deepBlue1),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ABC Sand Supplier', child: Text('ABC Sand Supplier')),
                      DropdownMenuItem(value: 'Cement Depot', child: Text('Cement Depot')),
                      DropdownMenuItem(value: 'Steel Yard', child: Text('Steel Yard')),
                    ],
                    onChanged: (v) => setState(() => _supplier = v ?? _supplier),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _material,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Material',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.category_rounded, color: AppColors.deepBlue1),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Sand', child: Text('Sand')),
                      DropdownMenuItem(value: 'Cement (Bags)', child: Text('Cement (Bags)')),
                      DropdownMenuItem(value: 'Steel Rod', child: Text('Steel Rod')),
                    ],
                    onChanged: (v) => setState(() {
                      _material = v ?? _material;
                      _unit = _material == 'Sand' ? 'tons' : _material == 'Steel Rod' ? 'kg' : 'bags';
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleCtrl,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Vehicle Number',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.badge_rounded, color: AppColors.deepBlue1),
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _driverCtrl,
                    style: const TextStyle(color: AppColors.deepBlue1, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Driver Name',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person_rounded, color: AppColors.deepBlue1),
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
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
                            final n = num.tryParse(t);
                            if (n == null || n <= 0) return 'Invalid';
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
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.deepBlue1,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Save Trip'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
