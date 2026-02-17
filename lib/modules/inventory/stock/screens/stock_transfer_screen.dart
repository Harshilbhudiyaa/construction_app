import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/modules/inventory/materials/models/material_model.dart';
import 'package:provider/provider.dart';

class StockTransferScreen extends StatefulWidget {
  final ConstructionMaterial? material;
  
  const StockTransferScreen({super.key, this.material});

  @override
  State<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _remarksController = TextEditingController();
  
  ConstructionMaterial? _selectedMaterial;
  String _fromSite = 'Main Site';
  String _toSite = 'Site A';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _selectedMaterial = widget.material;
  }

  @override
  void dispose() {
    _quantityController.dispose();
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
                  
                  // From Site
                  HelpfulDropdown<String>(
                    label: 'From Site (Source)',
                    value: _fromSite,
                    items: const ['Main Site', 'Site A', 'Site B', 'Warehouse'],
                    onChanged: (value) => setState(() => _fromSite = value!),
                    useGlass: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // To Site
                  HelpfulDropdown<String>(
                    label: 'To Site (Destination)',
                    value: _toSite,
                    items: const ['Main Site', 'Site A', 'Site B', 'Warehouse'],
                    onChanged: (value) => setState(() => _toSite = value!),
                    useGlass: true,
                    validator: (value) {
                      if (value == _fromSite) return 'Source and destination cannot be the same';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Quantity
                  HelpfulTextField(
                    label: 'Quantity to Transfer',
                    controller: _quantityController,
                    hintText: 'Enter quantity',
                    keyboardType: TextInputType.number,
                    useGlass: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter quantity';
                      final qty = double.tryParse(value);
                      if (qty == null || qty <= 0) return 'Please enter valid quantity';
                      if (_selectedMaterial != null && qty > _selectedMaterial!.currentStock) {
                        return 'Insufficient stock at source site';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Remarks
                  HelpfulTextField(
                    label: 'Remarks (Optional)',
                    controller: _remarksController,
                    hintText: 'Transfer notes',
                    maxLines: 3,
                    useGlass: true,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitTransfer,
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('INITIATE TRANSFER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.electricBlue,
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
          color: DesignSystem.electricBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DesignSystem.electricBlue.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DesignSystem.electricBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_rounded, color: DesignSystem.electricBlue),
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
          border: Border.all(color: DesignSystem.electricBlue.withOpacity(0.3), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline_rounded, size: 32, color: DesignSystem.electricBlue.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              'Select Material to Transfer',
              style: TextStyle(color: DesignSystem.electricBlue.withOpacity(0.7), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a material'), backgroundColor: DesignSystem.error));
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Simulate delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock transfer initiated successfully'),
          backgroundColor: DesignSystem.success,
        ),
      );
      _quantityController.clear();
      _remarksController.clear();
    }
  }
}

