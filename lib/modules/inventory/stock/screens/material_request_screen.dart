import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:uuid/uuid.dart';

class MaterialRequestScreen extends StatefulWidget {
  const MaterialRequestScreen({super.key});

  @override
  State<MaterialRequestScreen> createState() => _MaterialRequestScreenState();
}

class _MaterialRequestScreenState extends State<MaterialRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _materialNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _purposeController = TextEditingController();
  final _remarksController = TextEditingController();
  
  String _priority = 'Medium';
  String _site = 'Main Site';
  bool _isLoading = false;
  
  @override
  void dispose() {
    _materialNameController.dispose();
    _quantityController.dispose();
    _purposeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfessionalCard(
            padding: const EdgeInsets.all(24),
            useGlass: true,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Material Name
                  HelpfulTextField(
                    label: 'Material Name',
                    controller: _materialNameController,
                    hintText: 'e.g., Cement, Steel bars',
                    useGlass: true,
                    validator: (value) => value!.isEmpty ? 'Please enter material name' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Quantity
                  HelpfulTextField(
                    label: 'Quantity Required',
                    controller: _quantityController,
                    hintText: 'Enter quantity',
                    keyboardType: TextInputType.number,
                    useGlass: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter quantity';
                      final qty = double.tryParse(value);
                      if (qty == null || qty <= 0) return 'Please enter valid quantity';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Site
                  HelpfulDropdown<String>(
                    label: 'Destination Site',
                    value: _site,
                    items: const ['Main Site', 'Site A', 'Site B', 'Warehouse'],
                    onChanged: (value) => setState(() => _site = value!),
                    useGlass: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Priority
                  HelpfulDropdown<String>(
                    label: 'Priority',
                    value: _priority,
                    items: const ['Low', 'Medium', 'High', 'Urgent'],
                    onChanged: (value) => setState(() => _priority = value!),
                    useGlass: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Purpose
                  HelpfulTextField(
                    label: 'Purpose',
                    controller: _purposeController,
                    hintText: 'Why is this material needed?',
                    useGlass: true,
                    validator: (value) => value!.isEmpty ? 'Please enter purpose' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Remarks
                  HelpfulTextField(
                    label: 'Additional Notes (Optional)',
                    controller: _remarksController,
                    hintText: 'Any special requirements',
                    maxLines: 3,
                    useGlass: true,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitRequest,
                      icon: const Icon(Icons.send_rounded),
                      label: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('SUBMIT REQUEST', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.softGold, // Use gold/accent for requests
                        foregroundColor: DesignSystem.deepNavy, // Dark text on gold
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Simulate delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material request submitted for approval'),
          backgroundColor: DesignSystem.success,
        ),
      );
      _materialNameController.clear();
      _quantityController.clear();
      _purposeController.clear();
      _remarksController.clear();
    }
  }
}

