import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/modules/inventory/materials/models/material_model.dart';
import 'package:construction_app/services/mock_inventory_service.dart';
import 'package:provider/provider.dart';

class StockOutwardScreen extends StatefulWidget {
  final ConstructionMaterial? material;
  
  const StockOutwardScreen({super.key, this.material});

  @override
  State<StockOutwardScreen> createState() => _StockOutwardScreenState();
}

class _StockOutwardScreenState extends State<StockOutwardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _purposeController = TextEditingController();
  final _remarksController = TextEditingController();
  
  ConstructionMaterial? _selectedMaterial;
  String _usageType = 'Project Use';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _selectedMaterial = widget.material;
  }

  @override
  void dispose() {
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
                  _buildMaterialSelector(),
                  const SizedBox(height: 24),
                  
                  HelpfulTextField(
                    label: 'Quantity Used',
                    controller: _quantityController,
                    hintText: 'Enter quantity',
                    keyboardType: TextInputType.number,
                    useGlass: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter quantity';
                      final qty = double.tryParse(value);
                      if (qty == null || qty <= 0) return 'Please enter valid quantity';
                      if (_selectedMaterial != null && qty > _selectedMaterial!.currentStock) {
                        return 'Insufficient stock (Available: ${_selectedMaterial!.currentStock})';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  HelpfulDropdown<String>(
                    label: 'Usage Type',
                    value: _usageType,
                    items: const ['Project Use', 'Testing', 'Sample', 'Other'],
                    onChanged: (value) => setState(() => _usageType = value!),
                    useGlass: true,
                  ),
                  const SizedBox(height: 16),
                  
                  HelpfulTextField(
                    label: 'Purpose / Location',
                    controller: _purposeController,
                    hintText: 'e.g., Foundation work, Slab casting',
                    useGlass: true,
                    validator: (value) => value!.isEmpty ? 'Please enter purpose' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  HelpfulTextField(
                    label: 'Remarks (Optional)',
                    controller: _remarksController,
                    hintText: 'Additional notes',
                    maxLines: 3,
                    useGlass: true,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitOutward,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.deepNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('RECORD USAGE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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

  Widget _buildMaterialSelector() {
    if (_selectedMaterial != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DesignSystem.deepNavy.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DesignSystem.deepNavy.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DesignSystem.deepNavy.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_rounded, color: DesignSystem.deepNavy),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedMaterial!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available: ${_selectedMaterial!.currentStock} ${_selectedMaterial!.unitType.label}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                  ),
                ],
              ),
            ),
            if (widget.material == null)
              IconButton(
                icon: const Icon(Icons.change_circle_outlined),
                tooltip: 'Change Material',
                onPressed: () {
                  // Future: open material selector
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material selection not implemented in demo')));
                },
              ),
          ],
        ),
      );
    }
    
    return InkWell(
      onTap: () {
        // Future: Open material selector
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: DesignSystem.deepNavy.withOpacity(0.3), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline_rounded, size: 32, color: DesignSystem.deepNavy.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              'Select Material',
              style: TextStyle(color: DesignSystem.deepNavy.withOpacity(0.7), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOutward() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a material'), backgroundColor: DesignSystem.error));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final quantity = double.parse(_quantityController.text);
      final inventoryService = context.read<MockInventoryService>();
      
      // Update stock
      final updatedMaterial = _selectedMaterial!.copyWith(
        currentStock: _selectedMaterial!.currentStock - quantity,
      );
      
      await inventoryService.updateMaterial(updatedMaterial);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock outward recorded successfully'),
            backgroundColor: DesignSystem.success,
          ),
        );
        _quantityController.clear();
        _purposeController.clear();
        _remarksController.clear();
        // Do not pop, just clear form
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

