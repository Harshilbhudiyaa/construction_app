import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/section_header.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Create Truck Entry')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          const SectionHeader(title: 'Trip Info', subtitle: 'Supplier, material, driver, qty'),
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
                        value: _supplier,
                        decoration: const InputDecoration(labelText: 'Supplier'),
                        items: const [
                          DropdownMenuItem(value: 'ABC Sand Supplier', child: Text('ABC Sand Supplier')),
                          DropdownMenuItem(value: 'Cement Depot', child: Text('Cement Depot')),
                          DropdownMenuItem(value: 'Steel Yard', child: Text('Steel Yard')),
                        ],
                        onChanged: (v) => setState(() => _supplier = v ?? _supplier),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _material,
                        decoration: const InputDecoration(labelText: 'Material'),
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
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _vehicleCtrl,
                        decoration: const InputDecoration(labelText: 'Vehicle Number'),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _driverCtrl,
                        decoration: const InputDecoration(labelText: 'Driver Name'),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _qtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Quantity'),
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty) return 'Required';
                                final n = num.tryParse(t);
                                if (n == null || n <= 0) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: TextEditingController(text: _unit),
                              decoration: const InputDecoration(labelText: 'Unit'),
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
                              onPressed: _save,
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
