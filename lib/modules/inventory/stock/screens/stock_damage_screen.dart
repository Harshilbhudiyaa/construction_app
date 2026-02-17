import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/modules/inventory/materials/models/material_model.dart';
import 'package:construction_app/services/mock_inventory_service.dart';
import 'package:provider/provider.dart';

class StockDamageScreen extends StatefulWidget {
  final ConstructionMaterial? material;
  
  const StockDamageScreen({super.key, this.material});

  @override
  State<StockDamageScreen> createState() => _StockDamageScreenState();
}

class _StockDamageScreenState extends State<StockDamageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _remarksController = TextEditingController();
  
  ConstructionMaterial? _selectedMaterial;
  String _damageType = 'Damaged';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _selectedMaterial = widget.material;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
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
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMaterialSelector(),
                  const SizedBox(height: 24),
                  
                  // Damage Type
                  HelpfulDropdown<String>(
                    label: 'Type',
                    value: _damageType,
                    items: const ['Damaged', 'Wasted', 'Expired', 'Lost'],
                    onChanged: (value) => setState(() => _damageType = value!),
                    useGlass: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Quantity
                  HelpfulTextField(
                    label: 'Quantity',
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
                  
                  // Reason
                  HelpfulTextField(
                    label: 'Reason',
                    controller: _reasonController,
                    hintText: 'e.g., Water damage, Improper storage',
                    useGlass: true,
                    validator: (value) => value!.isEmpty ? 'Please enter reason' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Remarks
                  HelpfulTextField(
                    label: 'Additional Details (Optional)',
                    controller: _remarksController,
                    hintText: 'Any additional information',
                    maxLines: 3,
                    useGlass: true,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitDamage,
                      icon: const Icon(Icons.warning_amber_rounded),
                      label: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('REPORT DAMAGE/LOSS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        foregroundColor: Colors.white,
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

  Widget _buildMaterialSelector() {
    if (_selectedMaterial != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_rounded, color: Colors.orange[800]),
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
                    'Current Stock: ${_selectedMaterial!.currentStock} ${_selectedMaterial!.unitType.label}',
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
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material selection not implemented in demo')));
                },
              ),
          ],
        ),
      );
    }
    
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.withOpacity(0.3), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.warning_amber_rounded, size: 32, color: Colors.orange.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              'Select Material to Report',
              style: TextStyle(color: Colors.orange.withOpacity(0.7), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitDamage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a material'), backgroundColor: DesignSystem.error));
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      final quantity = double.parse(_quantityController.text);
      
      // Update stock
      final inventoryService = context.read<MockInventoryService>();
      final updatedMaterial = _selectedMaterial!.copyWith(
        currentStock: _selectedMaterial!.currentStock - quantity,
      );
      
      await inventoryService.updateMaterial(updatedMaterial);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Damage/waste reported successfully'),
            backgroundColor: DesignSystem.success,
          ),
        );
        _quantityController.clear();
        _reasonController.clear();
        _remarksController.clear();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

