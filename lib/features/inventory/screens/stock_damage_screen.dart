import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/shared/widgets/tactile_material_selector.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/widgets/loading_indicators.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfessionalCard(
                padding: const EdgeInsets.all(24),
                useGlass: true,
                border: Border.all(color: bcDanger.withValues(alpha: 0.2)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Select Item', Icons.warning_amber_rounded),
                      const SizedBox(height: 16),
                      _buildMaterialSelector(),
                      const SizedBox(height: 32),
                      
                      _buildSectionHeader('Damage Details', Icons.description_rounded),
                      const SizedBox(height: 16),
                      
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: HelpfulDropdown<String>(
                                label: 'Type',
                                value: _damageType,
                                items: const ['Damaged', 'Wasted', 'Expired', 'Lost'],
                                onChanged: (value) => setState(() => _damageType = value!),
                                useGlass: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: HelpfulTextField(
                                label: _selectedMaterial != null ? 'Quantity (${_selectedMaterial!.unitType})' : 'Quantity',
                                controller: _quantityController,
                                hintText: 'Enter quantity',
                                keyboardType: TextInputType.number,
                                useGlass: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter quantity';
                                  final qty = double.tryParse(value);
                                  if (qty == null || qty <= 0) return 'Invalid quantity';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        )
                      else ...[
                        HelpfulDropdown<String>(
                          label: 'Type',
                          value: _damageType,
                          items: const ['Damaged', 'Wasted', 'Expired', 'Lost'],
                          onChanged: (value) => setState(() => _damageType = value!),
                          useGlass: true,
                        ),
                        const SizedBox(height: 16),
                        HelpfulTextField(
                          label: _selectedMaterial != null ? 'Quantity (${_selectedMaterial!.unitType})' : 'Quantity',
                          controller: _quantityController,
                          hintText: 'Enter quantity',
                          keyboardType: TextInputType.number,
                          useGlass: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter quantity';
                            final qty = double.tryParse(value);
                            if (qty == null || qty <= 0) return 'Invalid quantity';
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      
                      HelpfulTextField(
                        label: 'Reason',
                        controller: _reasonController,
                        hintText: 'e.g., Water damage, Improper storage',
                        useGlass: true,
                        validator: (value) => value!.isEmpty ? 'Reason is required' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      HelpfulTextField(
                        label: 'Details (Optional)',
                        controller: _remarksController,
                        hintText: 'Additional info',
                        maxLines: 3,
                        useGlass: true,
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitDamage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bcNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 12,
                            shadowColor: bcDanger.withValues(alpha: 0.5),
                          ),
                          child: _isLoading 
                            ? const SizedBox(
                                width: 28, 
                                height: 28, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.gpp_maybe_rounded, size: 20, color: bcDanger),
                                  SizedBox(width: 12),
                                  Text(
                                    'LOG INCIDENT', 
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900, 
                                      letterSpacing: 2.0,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
    );
  }

  Widget _buildMaterialSelector() {
    return TactileMaterialSelector(
      selectedMaterial: _selectedMaterial,
      onTap: _showMaterialSelectionSheet,
      showSyncButton: widget.material == null,
      themeColor: bcDanger,
      label: 'Damage & Waste Report',
      subLabel: 'Incident Reporting',
      techTag: 'INCIDENT-DELTA',
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: bcNavy.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: bcNavy.withValues(alpha: 0.6),
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Future<void> _submitDamage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a material'), backgroundColor: bcDanger));
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      final quantity = double.tryParse(_quantityController.text) ?? 0.0;
      final inventoryService = context.read<InventoryRepository>();
      
      await inventoryService.recordStockDamage(
        materialId: _selectedMaterial!.id,
        materialName: _selectedMaterial!.name,
        quantity: quantity,
        unit: _selectedMaterial!.unitType,
        type: _damageType,
        remarks: _reasonController.text + (_remarksController.text.isNotEmpty ? ' - ${_remarksController.text}' : ''),
        recordedBy: context.read<AuthRepository>().userName ?? 'System',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Damage/loss reported successfully'),
            backgroundColor: bcSuccess,
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

  void _showMaterialSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.gpp_maybe_rounded, color: bcNavy, size: 20),
                    const SizedBox(width: 12),
                    Text('Select Material', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: bcNavy)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<ConstructionMaterial>>(
                  stream: context.read<InventoryRepository>().getMaterialsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: AppLoader(size: 32));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No materials found'));
                    }
                    
                    final materials = snapshot.data!;
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: materials.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final material = materials[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: bcNavy.withValues(alpha: 0.05),
                            child: const Icon(Icons.foundation_rounded, color: bcNavy, size: 20),
                          ),
                          title: Text(material.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          subtitle: Text('Bal: ${material.currentStock} ${material.unitType} • ${material.brand ?? "Default"}', style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: bcNavy, size: 20),
                          onTap: () {
                            setState(() => _selectedMaterial = material);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



