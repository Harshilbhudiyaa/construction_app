import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/core/theme/design_system.dart';



import 'package:construction_app/shared/widgets/tactile_material_selector.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:provider/provider.dart';

class StockOutFormScreen extends StatefulWidget {
  final ConstructionMaterial? material;
  final double? initialQuantity;
  final String? initialPurpose;
  
  const StockOutFormScreen({
    super.key, 
    this.material,
    this.initialQuantity,
    this.initialPurpose,
  });

  @override
  State<StockOutFormScreen> createState() => _StockOutFormScreenState();
}

class _StockOutFormScreenState extends State<StockOutFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _purposeController;
  final _remarksController = TextEditingController();
  
  ConstructionMaterial? _selectedMaterial;
  String _usageType = 'Project Use';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _selectedMaterial = widget.material;
    _quantityController = TextEditingController(
      text: widget.initialQuantity?.toString() ?? '',
    );
    _purposeController = TextEditingController(
      text: widget.initialPurpose ?? '',
    );
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 28,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Item Selection', Icons.inventory_2_rounded),
              const SizedBox(height: 16),
              _buildMaterialSelector(),
              const SizedBox(height: 32),
              
              _buildSectionHeader('Usage Specifications', Icons.tune_rounded),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 768;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildQuantityField(),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildUsageTypeDropdown(),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildQuantityField(),
                      const SizedBox(height: 20),
                      _buildUsageTypeDropdown(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              
              HelpfulTextField(
                label: 'Purpose / Location',
                controller: _purposeController,
                hintText: 'e.g., Foundation work, Slab casting',
                icon: Icons.place_rounded,
                validator: (value) => value!.isEmpty ? 'Please enter purpose' : null,
              ),
              const SizedBox(height: 20),
              
              HelpfulTextField(
                label: 'Remarks (Optional)',
                controller: _remarksController,
                hintText: 'Additional engineering notes',
                icon: Icons.notes_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitOutward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bcNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: bcNavy.withValues(alpha: 0.4),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 20, color: bcAmber),
                          const SizedBox(width: 12),
                          const Text(
                            'FINALIZE CONSUMPTION', 
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
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: bcAmber),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: bcNavy,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: bcNavy.withValues(alpha: 0.08))),
      ],
    );
  }

  Widget _buildQuantityField() {
    return HelpfulTextField(
      label: _selectedMaterial != null ? 'Quantity Used (${_selectedMaterial!.unitType.label})' : 'Quantity Used',
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
    );
  }

  Widget _buildUsageTypeDropdown() {
    return HelpfulDropdown<String>(
      label: 'Usage Type',
      value: _usageType,
      items: const ['Project Use', 'Testing', 'Sample', 'Other'],
      onChanged: (value) => setState(() => _usageType = value!),
      useGlass: true,
    );
  }

  Widget _buildMaterialSelector() {
    return TactileMaterialSelector(
      selectedMaterial: _selectedMaterial,
      onTap: _showMaterialSelectionSheet,
      showSyncButton: widget.material == null,
      themeColor: bcAmber,
      label: 'Inventory Outward Record',
      subLabel: 'Record material consumption for site work',
      techTag: 'SITE-OPS-ALPHA',
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
      final inventoryService = context.read<InventoryRepository>();
      
      // Update stock using transactional method
      final auth = context.read<AuthRepository>();
      await inventoryService.recordStockOut(
        materialId: _selectedMaterial!.id,
        quantity: quantity,
        purpose: _purposeController.text,
        issuedTo: _usageType,
        remarks: _remarksController.text,
        recordedBy: auth.userName ?? 'System',
      );
      
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
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: bcNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bcNavy,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: bcAmber, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Material',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: bcNavy,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Available Inventory'.toUpperCase(),
                            style: TextStyle(
                              color: bcNavy.withValues(alpha: 0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: bcNavy),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Expanded(
                child: StreamBuilder<List<ConstructionMaterial>>(
                  stream: context.read<InventoryRepository>().getMaterialsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: bcAmber));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No materials found'));
                    }
                    
                    final materials = snapshot.data!;
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
                        final material = materials[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedMaterial = material);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: bcNavy.withValues(alpha: 0.06)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: bcNavy.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(material.category.icon, color: bcNavy, size: 22),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          material.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            color: bcNavy,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Stock: ${material.currentStock} ${material.unitType.label} • ${material.brand ?? "No Brand"}',
                                          style: TextStyle(
                                            color: bcNavy.withValues(alpha: 0.5),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: bcAmber, size: 20),
                                ],
                              ),
                            ),
                          ),
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


