import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/features/inventory/widgets/unit_picker_sheet.dart';

class AddEditItemScreen extends StatefulWidget {
  final String? materialId;
  const AddEditItemScreen({super.key, this.materialId});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _salePriceCtrl = TextEditingController(text: '0');
  final _purchasePriceCtrl = TextEditingController(text: '0');
  final _openingStockCtrl = TextEditingController(text: '0');
  final _lowStockCtrl = TextEditingController(text: '10');
  final _hsnCtrl = TextEditingController();
  final _conversionCtrl = TextEditingController(text: '1.0');
  
  MaterialCategory _category = MaterialCategory.civilStructural;
  UnitType _primaryUnit = UnitType.pcs;
  String? _selectedSiteId;
  bool _taxIncluded = true;
  bool _hasSecondaryUnit = false;
  UnitType? _secondaryUnit;

  @override
  void initState() {
    super.initState();
    
    // Schedule data loading after first frame to avoid inhibiting initState if providers throw
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final repo = context.read<InventoryRepository>();
      final siteRepo = context.read<SiteRepository>();
      
      ConstructionMaterial? material;
      if (widget.materialId != null) {
        try {
          material = repo.materials.firstWhere((m) => m.id == widget.materialId);
        } catch (_) {
          material = null;
        }
      }

      final ConstructionMaterial? initialMaterial = material;
      if (initialMaterial != null) {
        setState(() {
          _nameCtrl.text = initialMaterial.name;
          _salePriceCtrl.text = initialMaterial.salePrice.toString();
          _purchasePriceCtrl.text = initialMaterial.purchasePrice.toString();
          _openingStockCtrl.text = initialMaterial.currentStock.toString();
          _lowStockCtrl.text = initialMaterial.minimumStockLimit.toString();
          _hsnCtrl.text = initialMaterial.hsnCode ?? '';
          _conversionCtrl.text = initialMaterial.conversionFactor?.toString() ?? '1.0';
          
          _category = initialMaterial.category;
          _primaryUnit = initialMaterial.unitType;
          _selectedSiteId = initialMaterial.siteId;
          _taxIncluded = initialMaterial.taxIncluded;
          _secondaryUnit = initialMaterial.secondaryUnit;
          _hasSecondaryUnit = initialMaterial.secondaryUnit != null;
        });
      } else {
        setState(() {
          _selectedSiteId = siteRepo.selectedSiteId;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _salePriceCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _openingStockCtrl.dispose();
    _lowStockCtrl.dispose();
    _hsnCtrl.dispose();
    _conversionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickUnit(bool isPrimary) async {
    final result = await showModalBottomSheet<UnitType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UnitPickerSheet(initialUnit: isPrimary ? _primaryUnit : _secondaryUnit),
    );

    if (result != null) {
      setState(() {
        if (isPrimary) {
          _primaryUnit = result;
        } else {
          _secondaryUnit = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: widget.materialId == null ? 'Add Product' : 'Edit Product',
      subtitle: 'Stock Inventory Details',
      category: 'SmartConstruction STOCK',
      actions: [
        TextButton(
          onPressed: _save,
          child: const Text('SAVE', style: TextStyle(color: bcAmber, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfessionalSectionHeader(
                  title: 'General Details',
                  subtitle: 'Basic item information',
                ),
                ProfessionalCard(
                  child: Column(
                    children: [
                      _buildTextField('Item Name *', _nameCtrl, 'Enter Item Name', icon: Icons.inventory_2_rounded),
                      const SizedBox(height: 28),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 28),
                      _buildSiteDropdown(),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                const ProfessionalSectionHeader(
                  title: 'Units',
                  subtitle: 'Measurement units and conversion',
                ),
                ProfessionalCard(
                  child: Column(
                    children: [
                      _buildUnitButton('Primary Unit', _primaryUnit, () => _pickUnit(true), icon: Icons.straighten_rounded),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.layers_rounded, color: bcTextSecondary, size: 20),
                          const SizedBox(width: 12),
                          const Text('Secondary Unit', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Switch.adaptive(
                            value: _hasSecondaryUnit,
                            activeTrackColor: bcAmber.withValues(alpha: 0.4),
                            activeThumbColor: bcAmber,
                            onChanged: (v) => setState(() => _hasSecondaryUnit = v),
                          ),
                        ],
                      ),
                      if (_hasSecondaryUnit) ...[
                        const SizedBox(height: 20),
                        _buildUnitButton('Secondary Unit', _secondaryUnit ?? UnitType.none, () => _pickUnit(false), icon: Icons.layers_outlined),
                        const SizedBox(height: 28),
                        _buildTextField('Conversion Factor', _conversionCtrl, 'e.g. 1 Box = 10 Pcs', isNumber: true, icon: Icons.swap_horiz_rounded),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                const ProfessionalSectionHeader(
                  title: 'Pricing (Optional)',
                  subtitle: 'Sale and purchase rates',
                ),
                ProfessionalCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Sale Price (₹)', _salePriceCtrl, '0', isNumber: true, icon: Icons.sell_rounded)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildTextField('Purchase Price (₹)', _purchasePriceCtrl, '0', isNumber: true, icon: Icons.shopping_basket_rounded)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_rounded, color: bcTextSecondary, size: 20),
                          const SizedBox(width: 12),
                          const Text('Tax Included', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Switch.adaptive(
                            value: _taxIncluded,
                            activeTrackColor: bcAmber.withValues(alpha: 0.4),
                            activeThumbColor: bcAmber,
                            onChanged: (v) => setState(() => _taxIncluded = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                const ProfessionalSectionHeader(
                  title: 'Stock (Optional)',
                  subtitle: 'Initial levels and alerts',
                ),
                ProfessionalCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTextField('In Stock', _openingStockCtrl, '0', isNumber: true, icon: Icons.warehouse_rounded)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildTextField('Low Stock Warning', _lowStockCtrl, '10', isNumber: true, icon: Icons.notification_important_rounded)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildTextField('HSN Code', _hsnCtrl, 'Optional', icon: Icons.qr_code_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController? ctrl, String hint, {bool isNumber = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: bcTextSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: bcNavy.withValues(alpha: 0.6), size: 20) : null,
            filled: true,
            fillColor: Colors.grey[50],
            hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: bcBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: bcAmber, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: bcDanger, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          validator: (v) => label.contains('*') && (v == null || v.isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: bcTextSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        DropdownButtonFormField<MaterialCategory>(
          initialValue: _category,
          style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category_rounded, color: bcNavy, size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: bcBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: bcAmber, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          items: MaterialCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName))).toList(),
          onChanged: (v) => setState(() => _category = v!),
        ),
      ],
    );
  }

  Widget _buildSiteDropdown() {
    final siteRepo = context.watch<SiteRepository>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assigned Site *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: bcTextSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _selectedSiteId,
          style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.business_rounded, color: bcNavy, size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: bcBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: bcAmber, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          items: siteRepo.sites.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
          onChanged: (v) => setState(() => _selectedSiteId = v),
          validator: (v) => v == null ? 'Site is required' : null,
        ),
      ],
    );
  }

  Widget _buildUnitButton(String label, UnitType unit, VoidCallback onTap, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: bcTextSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bcBorder, width: 1.5),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: bcNavy, size: 20),
                  const SizedBox(width: 12),
                ],
                Text(
                  unit == UnitType.none ? 'Select Unit' : unit.label,
                  style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down_rounded, color: bcTextSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: bcDanger,
        ),
      );
      return;
    }

    try {
      final repo = context.read<InventoryRepository>();
      final material = ConstructionMaterial(
        id: widget.materialId ?? 'mat_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text,
        category: _category,
        unitType: _primaryUnit,
        minimumStockLimit: double.tryParse(_lowStockCtrl.text) ?? 10.0,
        currentStock: double.tryParse(_openingStockCtrl.text) ?? 0.0,
        siteId: _selectedSiteId ?? '',
        subType: '',
        brand: '',
        pricePerUnit: double.tryParse(_purchasePriceCtrl.text) ?? 0.0,
        totalAmount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salePrice: double.tryParse(_salePriceCtrl.text) ?? 0.0,
        purchasePrice: double.tryParse(_purchasePriceCtrl.text) ?? 0.0,
        taxIncluded: _taxIncluded,
        hsnCode: _hsnCtrl.text,
        secondaryUnit: _hasSecondaryUnit ? _secondaryUnit : null,
        conversionFactor: double.tryParse(_conversionCtrl.text) ?? 1.0,
      );

      if (widget.materialId == null) {
        await repo.addMaterial(material);
      } else {
        await repo.updateMaterial(material);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item saved successfully'),
            backgroundColor: bcSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving item: ${e.toString()}'),
            backgroundColor: bcDanger,
          ),
        );
      }
    }
  }
}
