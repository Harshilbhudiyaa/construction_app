import 'package:flutter/material.dart';

import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../app/ui/widgets/helpful_text_field.dart';
import '../../../../app/ui/widgets/helpful_dropdown.dart';
import '../../../../app/ui/widgets/confirm_dialog.dart';
import '../../../../app/utils/feedback_helper.dart';

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

  Future<void> _handleBack() async {
    final hasData = _vehicleCtrl.text.trim().isNotEmpty ||
        _driverCtrl.text.trim().isNotEmpty ||
        _qtyCtrl.text.trim().isNotEmpty;

    if (!hasData) {
      Navigator.pop(context);
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Discard Changes?',
      message: 'You have unsaved changes. Are you sure you want to go back without saving?',
      confirmText: 'Discard',
      cancelText: 'Keep Editing',
      icon: Icons.warning_rounded,
      iconColor: Colors.orange,
      isDangerous: true,
    );

    if (confirmed && mounted) {
      Navigator.pop(context);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    FeedbackHelper.showSuccess(
      context,
      '✓ Truck entry for ${_vehicleCtrl.text} has been created',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'New Truck Entry',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ProfessionalCard(
                useGlass: true,
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Trip Details', Icons.local_shipping_rounded),
                      const SizedBox(height: 24),
                      HelpfulDropdown<String>(
                        label: 'Supplier',
                        value: _supplier,
                        useGlass: true,
                        items: const ['ABC Sand Supplier', 'Cement Depot', 'Steel Yard'],
                        icon: Icons.business_rounded,
                        onChanged: (v) => setState(() => _supplier = v!),
                      ),
                      const SizedBox(height: 20),
                      HelpfulDropdown<String>(
                        label: 'Material',
                        value: _material,
                        useGlass: true,
                        items: const ['Sand', 'Cement (Bags)', 'Steel Rod'],
                        icon: Icons.category_rounded,
                        onChanged: (v) => setState(() {
                          _material = v!;
                          _unit = _material == 'Sand' ? 'tons' : _material == 'Steel Rod' ? 'kg' : 'bags';
                        }),
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        label: 'Vehicle Number',
                        controller: _vehicleCtrl,
                        icon: Icons.badge_rounded,
                        useGlass: true,
                        hintText: 'e.g., GJ01AB1234',
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        label: 'Driver Name',
                        controller: _driverCtrl,
                        icon: Icons.person_rounded,
                        useGlass: true,
                        hintText: 'e.g., Rajesh',
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: HelpfulTextField(
                              label: 'Quantity',
                              controller: _qtyCtrl,
                              icon: Icons.scale_rounded,
                              useGlass: true,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty) return 'Required';
                                if (num.tryParse(t) == null) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: HelpfulTextField(
                              label: 'Unit',
                              controller: TextEditingController(text: _unit),
                              icon: Icons.straighten_rounded,
                              useGlass: true,
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleBack,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Discard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, AppColors.deepBlue3],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Save Trip Details',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
