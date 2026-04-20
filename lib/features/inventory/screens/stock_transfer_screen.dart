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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Item Selector', Icons.inventory_2_rounded),
                      const SizedBox(height: 16),
                      _buildMaterialSelector(),
                      const SizedBox(height: 32),
                      
                      _buildSectionHeader('Transfer Logistics', Icons.local_shipping_rounded),
                      const SizedBox(height: 16),
                      
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: HelpfulDropdown<String>(
                                label: 'From Site (Source)',
                                value: _fromSite,
                                items: const ['Main Site', 'Site A', 'Site B', 'Warehouse'],
                                onChanged: (value) => setState(() => _fromSite = value!),
                                useGlass: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: HelpfulDropdown<String>(
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
                            ),
                          ],
                        )
                      else ...[
                        HelpfulDropdown<String>(
                          label: 'From Site (Source)',
                          value: _fromSite,
                          items: const ['Main Site', 'Site A', 'Site B', 'Warehouse'],
                          onChanged: (value) => setState(() => _fromSite = value!),
                          useGlass: true,
                        ),
                        const SizedBox(height: 16),
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
                      ],
                      const SizedBox(height: 16),
                      
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: HelpfulTextField(
                                label: _selectedMaterial != null ? 'Quantity to Transfer (${_selectedMaterial!.unitType})' : 'Quantity to Transfer',
                                controller: _quantityController,
                                hintText: 'Enter quantity',
                                keyboardType: TextInputType.number,
                                useGlass: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please enter quantity';
                                  final qty = double.tryParse(value);
                                  if (qty == null || qty <= 0) return 'Enter valid quantity';
                                  if (_selectedMaterial != null && qty > _selectedMaterial!.currentStock) {
                                    return 'Insufficient stock';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: HelpfulTextField(
                                label: 'Remarks (Optional)',
                                controller: _remarksController,
                                hintText: 'Transfer notes',
                                maxLines: 1,
                                useGlass: true,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        HelpfulTextField(
                          label: _selectedMaterial != null ? 'Quantity (${_selectedMaterial!.unitType})' : 'Quantity',
                          controller: _quantityController,
                          hintText: 'Enter quantity',
                          keyboardType: TextInputType.number,
                          useGlass: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter quantity';
                            final qty = double.tryParse(value);
                            if (qty == null || qty <= 0) return 'Enter valid quantity';
                            if (_selectedMaterial != null && qty > _selectedMaterial!.currentStock) {
                              return 'Insufficient stock';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        HelpfulTextField(
                          label: 'Remarks (Optional)',
                          controller: _remarksController,
                          hintText: 'Transfer notes',
                          maxLines: 3,
                          useGlass: true,
                        ),
                      ],
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitTransfer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bcNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 10,
                            shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
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
                                  Icon(Icons.local_shipping_rounded, size: 20, color: Color(0xFF6366F1)),
                                  SizedBox(width: 12),
                                  Text(
                                    'INITIATE TRANSFER', 
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
      themeColor: const Color(0xFF6366F1), // Indigo Logistics
      label: 'Inter-Site Logistics',
      subLabel: 'Logistics Movement',
      techTag: 'LOGISTICS-BRAVO',
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

  Future<void> _submitTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a material'), backgroundColor: bcDanger));
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final inventoryService = context.read<InventoryRepository>();
      await inventoryService.recordStockTransfer(
        materialId: _selectedMaterial!.id,
        materialName: _selectedMaterial!.name,
        quantity: double.tryParse(_quantityController.text) ?? 0.0,
        unit: _selectedMaterial!.unitType,
        fromSiteId: _fromSite,
        toSiteId: _toSite,
        remarks: _remarksController.text,
        recordedBy: context.read<AuthRepository>().userName ?? 'System',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock transfer initiated successfully'),
            backgroundColor: bcSuccess,
          ),
        );
        _quantityController.clear();
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
                    const Icon(Icons.inventory_2_rounded, color: bcNavy),
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
                            backgroundColor: bcAmber.withValues(alpha: 0.1),
                            child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF6366F1), size: 20),
                          ),
                          title: Text(material.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          subtitle: Text('Bal: ${material.currentStock} ${material.unitType} • ${material.brand ?? "Default"}', style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6366F1), size: 20),
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



