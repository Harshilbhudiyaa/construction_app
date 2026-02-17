import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/services/mock_inventory_service.dart';
import 'package:construction_app/services/party_service.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/modules/inventory/parties/models/party_model.dart';
import 'package:construction_app/services/master_material_service.dart';
import 'package:construction_app/modules/inventory/materials/models/master_material_model.dart';
import 'package:construction_app/modules/inventory/materials/models/material_model.dart';


class MaterialFormScreen extends StatefulWidget {
  final ConstructionMaterial? material;
  final String? siteId;
  const MaterialFormScreen({super.key, this.material, this.siteId});

  @override
  State<MaterialFormScreen> createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends State<MaterialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final MockInventoryService _inventoryService;
  bool _isLoading = false;

  // Material Info Controllers
  late final TextEditingController _nameCtrl; // Used for "Specific Name / Label"
  late final TextEditingController _brandCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _sizeInputCtrl;
  late final TextEditingController _gstCtrl;
  late final TextEditingController _paidCtrl;

  // Multi-Dimension Controllers
  final List<TextEditingController> _dimLabelCtrls = [];
  final List<TextEditingController> _dimValueCtrls = [];
  final List<TextEditingController> _dimUnitCtrls = [];

  // Billing Details Controllers
  late final TextEditingController _billingPersonNameCtrl;
  late final TextEditingController _billingPersonContactCtrl;
  late final TextEditingController _billingRemarksCtrl;
  late final TextEditingController _invoiceNumberCtrl;

  late MaterialCategory _category;
  String? _selectedSubType;
  late UnitType _unitType;
  late bool _isActive;
  String? _photoUrl;
  String? _billPhotoUrl;
  String _billingPersonRole = 'Supplier Representative';
  final List<TextEditingController> _sizeCtrls = [];
  
  String? _selectedPartyId;
  String? _selectedMasterMaterialId;
  MasterMaterial? _selectedMasterMaterial;
  double _gstPercentage = 0;
  double _totalAmount = 0;
  double _paidAmount = 0;
  double _pendingAmount = 0;
  DateTime _purchaseDate = DateTime.now();
  String _paymentMode = 'Cash';
  final bool _showCustomDimension = false;

  final _partyService = PartyService();
  final _masterService = MasterMaterialService();
  String? _selectedSiteId;

  final List<String> _billingRoleOptions = [
    'Supplier Representative',
    'Site Staff',
    'Hand-to-Hand Purchase',
    'Contractor',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _inventoryService = context.read<MockInventoryService>();
    final m = widget.material;
    
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _brandCtrl = TextEditingController(text: m?.brand ?? '');
    _priceCtrl = TextEditingController(text: m?.pricePerUnit.toString() ?? '');
    _stockCtrl = TextEditingController(text: m?.currentStock.toString() ?? '0');
    _sizeInputCtrl = TextEditingController();
    _gstCtrl = TextEditingController(text: m?.gstPercentage.toString() ?? '0');
    _paidCtrl = TextEditingController(text: m?.paidAmount.toString() ?? '0');

    _billingPersonNameCtrl = TextEditingController(text: m?.billingDetails?.billingPersonName ?? '');
    _billingPersonContactCtrl = TextEditingController(text: m?.billingDetails?.billingPersonContact ?? '');
    _billingRemarksCtrl = TextEditingController(text: m?.billingDetails?.remarks ?? '');
    _invoiceNumberCtrl = TextEditingController(text: m?.billingDetails?.invoiceNumber ?? '');
    _billingPersonRole = m?.billingDetails?.billingPersonRole ?? 'Supplier Representative';
    _billPhotoUrl = m?.billingDetails?.billPhotoUrl;
    _purchaseDate = m?.purchaseDate ?? DateTime.now();
    _paymentMode = m?.paymentMode ?? 'Cash';
    // Initialize custom dimensions if editing
    if (m != null && m.customDimensions.isNotEmpty) {
      for (final dim in m.customDimensions) {
        _dimLabelCtrls.add(TextEditingController(text: dim.label));
        _dimValueCtrls.add(TextEditingController(text: dim.value.toString()));
        _dimUnitCtrls.add(TextEditingController(text: dim.unit));
      }
    }

    if (m != null) {
      _selectedMasterMaterialId = m.masterMaterialId;
      _selectedSiteId = m.siteId;
      _selectedPartyId = m.partyId;
      _category = m.category;
      _selectedSubType = m.subType;
      _unitType = m.unitType;
      _isActive = m.isActive;
      _photoUrl = m.photoUrl;
      for (final size in m.availableSizes) {
        _sizeCtrls.add(TextEditingController(text: size));
      }
    } else {
      _selectedSiteId = widget.siteId;
      _category = MaterialCategory.cement;
      _unitType = UnitType.bag;
      _isActive = true;
    }

    _priceCtrl.addListener(_calculateTotals);
    _stockCtrl.addListener(_calculateTotals);
    _gstCtrl.addListener(_calculateTotals);
    _paidCtrl.addListener(_calculateTotals);
    
    _calculateTotals();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _sizeInputCtrl.dispose();
    _billingPersonNameCtrl.dispose();
    _billingPersonContactCtrl.dispose();
    _billingRemarksCtrl.dispose();
    _invoiceNumberCtrl.dispose();
    _gstCtrl.dispose();
    _paidCtrl.dispose();
    for (final c in _sizeCtrls) {
      c.dispose();
    }
    for (final c in _dimLabelCtrls) {
      c.dispose();
    }
    for (final c in _dimValueCtrls) {
      c.dispose();
    }
    for (final c in _dimUnitCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onMasterMaterialChanged(MasterMaterial? mm) {
    if (mm == null) return;
    setState(() {
      _selectedMasterMaterialId = mm.id;
      _selectedMasterMaterial = mm;
      _category = mm.category;
      _unitType = mm.defaultUnit;
      _nameCtrl.text = mm.name;
    });
  }

  void _calculateTotals() {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final qty = double.tryParse(_stockCtrl.text) ?? 0;
    final gst = double.tryParse(_gstCtrl.text) ?? 0;
    final paid = double.tryParse(_paidCtrl.text) ?? 0;

    final subtotal = price * qty;
    final total = subtotal + (subtotal * gst / 100);
    
    setState(() {
      _gstPercentage = gst;
      _totalAmount = total;
      _paidAmount = paid;
      _pendingAmount = total - paid;
    });
  }


  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _photoUrl = pickedFile.path;
      });
    }
  }


  void _resetForm() {
    setState(() {
      _selectedMasterMaterialId = null;
      _selectedMasterMaterial = null;
      _selectedPartyId = null;
      _nameCtrl.clear();
      _brandCtrl.clear();
      _priceCtrl.clear();
      _stockCtrl.text = '0';
      _gstCtrl.text = '0';
      _paidCtrl.text = '0';
      _photoUrl = null;
      _billPhotoUrl = null;
      for (final c in _sizeCtrls) {
        c.dispose();
      }
      _sizeCtrls.clear();
      for (final c in _dimLabelCtrls) {
        c.clear();
      }
      for (final c in _dimValueCtrls) {
        c.clear();
      }
      for (final c in _dimUnitCtrls) {
        c.clear();
      }
      _dimLabelCtrls.clear();
      _dimValueCtrls.clear();
      _dimUnitCtrls.clear();
      _isLoading = false;
    });
  }

  Future<void> _save({bool addAnother = false}) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMasterMaterialId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select or add a material type')));
        return;
      }
      if (_selectedSiteId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a site')));
        return;
      }

      setState(() => _isLoading = true);
      try {
        final billingDetails = _billingPersonNameCtrl.text.isNotEmpty || _invoiceNumberCtrl.text.isNotEmpty
            ? BillingDetails(
                billPhotoUrl: _billPhotoUrl,
                billingPersonName: _billingPersonNameCtrl.text,
                billingPersonContact: _billingPersonContactCtrl.text.isEmpty ? null : _billingPersonContactCtrl.text,
                billingPersonRole: _billingPersonRole,
                remarks: _billingRemarksCtrl.text.isEmpty ? null : _billingRemarksCtrl.text,
                invoiceNumber: _invoiceNumberCtrl.text.isEmpty ? null : _invoiceNumberCtrl.text,
                billingDate: _purchaseDate,
              )
            : null;

        final List<CustomDimension> dims = [];
        for (int i = 0; i < _dimLabelCtrls.length; i++) {
          final val = double.tryParse(_dimValueCtrls[i].text) ?? 0;
          if (val > 0) {
            dims.add(CustomDimension(
              label: _dimLabelCtrls[i].text,
              value: val,
              unit: _dimUnitCtrls[i].text,
            ));
          }
        }

        final material = ConstructionMaterial(
          id: widget.material?.id ?? 'INV-${DateTime.now().millisecondsSinceEpoch}',
          masterMaterialId: _selectedMasterMaterialId ?? 'custom-${DateTime.now().millisecondsSinceEpoch}',
          siteId: _selectedSiteId!,
          name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : (_selectedMasterMaterial?.name ?? 'Unknown'),
          category: _category,
          subType: _selectedSubType ?? (_selectedMasterMaterial?.subType ?? 'General'),
          photoUrl: _photoUrl,
          brand: _brandCtrl.text.isEmpty ? null : _brandCtrl.text,
          availableSizes: _sizeCtrls.map((c) => c.text).where((s) => s.isNotEmpty).toList(),
          pricePerUnit: double.tryParse(_priceCtrl.text) ?? 0,
          unitType: _unitType,
          currentStock: double.tryParse(_stockCtrl.text) ?? 0,
          isActive: _isActive,
          billingDetails: billingDetails,
          gstPercentage: _gstPercentage,
          totalAmount: _totalAmount,
          paidAmount: _paidAmount,
          pendingAmount: _pendingAmount,
          partyId: _selectedPartyId,
          paymentMode: _paymentMode,
          purchaseDate: _purchaseDate,
          customDimensions: dims,
          history: [
            ...(widget.material?.history ?? []),
            MaterialHistoryLog(
              id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
              action: widget.material == null ? 'Stock Purchase' : 'Update',
              description: widget.material == null 
                  ? 'Initial purchase: ${_stockCtrl.text} ${_unitType.label} @ ${_priceCtrl.text}/unit'
                      '${dims.isNotEmpty ? " (Dimensions: ${dims.length})" : ""}'
                  : 'Adjusted details',
              timestamp: DateTime.now(),
              performedBy: 'Staff', 
            ),
          ],
          createdAt: widget.material?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.material == null) {
          await _inventoryService.addMaterial(material);
        } else {
          await _inventoryService.updateMaterial(material);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${material.name} stock saved to site'), backgroundColor: Colors.green),
          );
          if (addAnother) {
            _resetForm();
          } else {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: widget.material == null ? 'Add Material' : 'Edit Material',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                const SizedBox(height: 16),
                _buildSiteSelector(),
                const SizedBox(height: 24),
                _buildMaterialInformationCard(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionHeader('Purchase Details', Icons.shopping_basket_rounded),
                  ],
                ),
                _buildPurchaseDetailsCard(),
                const SizedBox(height: 24),
                _sectionHeader('Finance & Party', Icons.account_balance_wallet_rounded),
                _buildFinanceCard(),
                const SizedBox(height: 24),
                _sectionHeader('Billing & Proof', Icons.receipt_long_rounded),
                _buildBillingCard(),
                const SizedBox(height: 48),
                _buildSaveButton(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSiteSelector() {
    if (_selectedSiteId == null) {
      _selectedSiteId = 'warehouse';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Target Site', Icons.location_on_rounded),
        ProfessionalCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(20),
          useGlass: true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.store_rounded, color: Colors.blueAccent),
                const SizedBox(width: 12),
                const Text('Main Warehouse', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialInformationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Material Information', Icons.inventory_2_rounded),
        ProfessionalCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(24),
          useGlass: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelpfulDropdown<MaterialCategory>(
                label: 'Material Category',
                value: _category,
                useGlass: true,
                items: MaterialCategory.values,
                labelMapper: (cat) => cat.displayName,
                onChanged: (cat) {
                  if (cat != null) {
                    setState(() {
                      _category = cat;
                      _selectedMasterMaterialId = null;
                      _selectedMasterMaterial = null;
                      _unitType = MasterMaterial.getAutoUnit(cat);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<MasterMaterial>>(
                stream: _masterService.getMasterMaterialsStream(),
                builder: (context, snapshot) {
                  final allMaterials = snapshot.data ?? [];
                  final filteredMaterials = allMaterials.where((m) => m.category == _category).toList();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: HelpfulDropdown<String?>(
                          label: 'Material Type',
                          value: _selectedMasterMaterialId,
                          useGlass: true,
                          items: filteredMaterials.map((e) => e.id).toList(),
                          labelMapper: (id) => filteredMaterials.firstWhere((m) => m.id == id).name,
                          onChanged: (id) {
                            if (id != null) {
                              final mm = filteredMaterials.firstWhere((m) => m.id == id);
                              _onMasterMaterialChanged(mm);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 52,
                        margin: const EdgeInsets.only(bottom: 4),
                        child: IconButton.filled(
                          onPressed: _showAddInlineTypeDialog,
                          icon: Icon(Icons.add_rounded, color: Theme.of(context).colorScheme.onPrimary),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (_category == MaterialCategory.steel) ...[
                const SizedBox(height: 24),
                _buildSizesSection(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'REBAR SIZES (mm)',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _sizeCtrls.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: const Text('ADD SIZE', style: TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF818CF8)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(_sizeCtrls.length, (index) {
            return SizedBox(
              width: 100,
              child: HelpfulTextField(
                label: 'Size',
                controller: _sizeCtrls[index],
                hintText: '8mm',
                useGlass: true,
                keyboardType: TextInputType.text,
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _sizeCtrls[index].dispose();
                      _sizeCtrls.removeAt(index);
                    });
                  },
                  child: const Icon(Icons.cancel_rounded, size: 16, color: Colors.redAccent),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPurchaseDetailsCard() {
    return ProfessionalCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      useGlass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HelpfulTextField(
            label: 'Specific Name / Label (Optional)',
            controller: _nameCtrl,
            hintText: 'e.g. For Ground Floor Slab',
            useGlass: true,
          ),
          const SizedBox(height: 16),
          HelpfulTextField(
            label: 'Brand Name',
            controller: _brandCtrl,
            hintText: 'e.g. UltraTech, Tata Steel',
            useGlass: true,
            validator: (v) => v!.isEmpty ? 'Brand name required' : null,
          ),
          const SizedBox(height: 12),
          // Dynamic Brand Suggestions
          StreamBuilder<List<ConstructionMaterial>>(
            stream: _inventoryService.getMaterialsStream(),
            builder: (context, snapshot) {
              final brands = (snapshot.data ?? [])
                  .map((m) => m.brand)
                  .where((b) => b != null && b.isNotEmpty)
                  .toSet()
                  .toList();
              
              if (brands.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select or add: ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 11)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: brands.take(10).map((brand) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(brand!, style: const TextStyle(fontSize: 11)),
                          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                          onPressed: () => setState(() => _brandCtrl.text = brand),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HelpfulTextField(
                  label: 'Quantity',
                  controller: _stockCtrl,
                  keyboardType: TextInputType.number,
                  suffixText: _unitType.label,
                  useGlass: true,
                  readOnly: _selectedMasterMaterial == null,
                  helpText: _selectedMasterMaterial == null ? 'Select Material Type first' : null,
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid quantity' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HelpfulTextField(
                  label: 'Price / ${_unitType.label}',
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  prefixText: '₹',
                  useGlass: true,
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid price' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCustomDimensionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CUSTOM DIMENSIONS / SIZES',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _dimLabelCtrls.add(TextEditingController());
                  _dimValueCtrls.add(TextEditingController());
                  _dimUnitCtrls.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: Color(0xFF818CF8)),
              tooltip: 'Add Dimension',
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dimLabelCtrls.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: HelpfulTextField(
                    label: 'Label',
                    controller: _dimLabelCtrls[index],
                    hintText: 'Length',
                    useGlass: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: HelpfulTextField(
                    label: 'Value',
                    controller: _dimValueCtrls[index],
                    keyboardType: TextInputType.number,
                    hintText: '0.0',
                    useGlass: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: HelpfulTextField(
                    label: 'Unit',
                    controller: _dimUnitCtrls[index],
                    hintText: 'ft',
                    useGlass: true,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _dimLabelCtrls[index].dispose();
                      _dimValueCtrls[index].dispose();
                      _dimUnitCtrls[index].dispose();
                      _dimLabelCtrls.removeAt(index);
                      _dimValueCtrls.removeAt(index);
                      _dimUnitCtrls.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: Colors.redAccent),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showAddInlineTypeDialog() {
    final nameCtrl = TextEditingController();
    UnitType selectedUnit = MasterMaterial.getAutoUnit(_category);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HelpfulTextField(
                label: 'Type Name',
                controller: nameCtrl,
                hintText: _category == MaterialCategory.cement 
                    ? 'e.g. OPC 43, OPC 53, PPC' 
                    : _category == MaterialCategory.steel 
                        ? 'e.g. TMT, MS Rod' 
                        : 'e.g. Crushed Sand, River Sand',
                useGlass: true,
              ),
              const SizedBox(height: 16),
              HelpfulDropdown<UnitType>(
                label: 'Default Purchase Unit',
                value: selectedUnit,
                items: UnitType.values,
                labelMapper: (u) => u.label.toUpperCase(),
                onChanged: (u) {
                  if (u != null) setDialogState(() => selectedUnit = u);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  final newMM = MasterMaterial(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text,
                    category: _category,
                    defaultUnit: selectedUnit,
                    createdAt: DateTime.now(),
                  );
                  await _masterService.addMasterMaterial(newMM);
                  setState(() {
                    _selectedMasterMaterialId = newMM.id;
                    _onMasterMaterialChanged(newMM);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('ADD TYPE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.15), width: 2),
                image: _photoUrl != null
                    ? DecorationImage(
                        image: (_photoUrl!.startsWith('http') || kIsWeb)
                            ? NetworkImage(_photoUrl!)
                            : FileImage(File(_photoUrl!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _photoUrl == null
                  ? Icon(Icons.architecture_rounded, size: 60, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showImageSourceOptions(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Icon(Icons.camera_alt_rounded, size: 22, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _photoUrl == null ? 'ADD MATERIAL PHOTO' : 'CHANGE PHOTO',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ],
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: DesignSystem.deepNavy,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Wrap(
            children: [
              if (!Platform.isWindows)
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                  title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.white),
                title: Text(Platform.isWindows ? 'Browse Files' : 'Choose from Gallery', style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 24,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard() {
    return ProfessionalCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      useGlass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<List<PartyModel>>(
            stream: _partyService.getPartiesStream(),
            builder: (context, snapshot) {
              final parties = snapshot.data ?? [];
              return Column(
                children: [
                  HelpfulDropdown<String?>(
                    label: 'Select Party (Optional)',
                    value: _selectedPartyId,
                    items: [null, ...parties.map((e) => e.id)],
                    labelMapper: (id) => id == null ? 'None' : parties.firstWhere((p) => p.id == id).name,
                    onChanged: (v) => setState(() => _selectedPartyId = v),
                    useGlass: true,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showAddPartySheet(context), 
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Add New Party'),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF818CF8)),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HelpfulTextField(
                  label: 'GST %',
                  hintText: 'e.g. 18',
                  controller: _gstCtrl,
                  keyboardType: TextInputType.number,
                  useGlass: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Value', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '₹ ${_totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HelpfulTextField(
                  label: 'Paid Amount (₹)',
                  hintText: '0.00',
                  controller: _paidCtrl,
                  keyboardType: TextInputType.number,
                  useGlass: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HelpfulDropdown<String>(
                  label: 'Payment Mode',
                  value: _paymentMode,
                  items: const ['Cash', 'Bank Transfer', 'UPI', 'Credit', 'Cheque'],
                  onChanged: (v) => setState(() => _paymentMode = v!),
                  useGlass: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _purchaseDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _purchaseDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF818CF8)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Purchase Date', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                      Text(
                        "${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ProfessionalCard(
            margin: EdgeInsets.zero,
            color: _pendingAmount > 0 ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Bill', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    Text('₹ ${_totalAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_pendingAmount > 0 ? 'Pending Balance' : 'Fully Paid', 
                      style: TextStyle(fontSize: 12, color: _pendingAmount > 0 ? Colors.redAccent : Colors.greenAccent)),
                    Text('₹ ${_pendingAmount.toStringAsFixed(2)}', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _pendingAmount > 0 ? Colors.redAccent : Colors.greenAccent)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBillingCard() {
    return ProfessionalCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      useGlass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HelpfulTextField(
            label: 'Invoice / Bill Number',
            controller: _invoiceNumberCtrl,
            hintText: 'e.g. INV-2024-001',
            useGlass: true,
          ),
          const SizedBox(height: 24),
          // Bill Photo Upload Section
          Text(
            'BILL / INVOICE PHOTO',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showBillPhotoOptions,
            child: Container(
              width: double.infinity,
              height: _billPhotoUrl != null ? 200 : 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                image: _billPhotoUrl != null
                    ? DecorationImage(
                        image: _billPhotoUrl!.startsWith('http')
                            ? NetworkImage(_billPhotoUrl!) as ImageProvider
                            : FileImage(File(_billPhotoUrl!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _billPhotoUrl == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 36, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to upload bill photo',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), fontSize: 12),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _showBillPhotoOptions,
                                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () => setState(() => _billPhotoUrl = null),
                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          const SizedBox(height: 24),
          // Billing Person Details
          HelpfulTextField(
            label: 'Billing Person Name',
            controller: _billingPersonNameCtrl,
            hintText: 'Who handled this transaction?',
            useGlass: true,
          ),
          const SizedBox(height: 20),
          HelpfulTextField(
            label: 'Contact Number',
            controller: _billingPersonContactCtrl,
            keyboardType: TextInputType.phone,
            hintText: '10-digit mobile',
            useGlass: true,
          ),
          const SizedBox(height: 20),
          HelpfulDropdown<String>(
            label: 'Role / Relationship',
            value: _billingPersonRole,
            items: _billingRoleOptions,
            onChanged: (v) => setState(() => _billingPersonRole = v!),
            useGlass: true,
          ),
          const SizedBox(height: 20),
          HelpfulTextField(
            label: 'Remarks / Notes',
            controller: _billingRemarksCtrl,
            maxLines: 3,
            hintText: 'Any special conditions, discounts, or notes...',
            useGlass: true,
          ),
        ],
      ),
    );
  }

  void _showBillPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: DesignSystem.deepNavy,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Wrap(
            children: [
              if (!Platform.isWindows)
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                  title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickBillImage(ImageSource.camera);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.white),
                title: Text(Platform.isWindows ? 'Browse Files' : 'Choose from Gallery', style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickBillImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickBillImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _billPhotoUrl = pickedFile.path;
      });
    }
  }

  Widget _buildSaveButton() {
    return Column(
      children: [
        if (widget.material == null) ...[
          Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isLoading ? null : () => _save(addAnother: true),
              child: Center(
                child: _isLoading
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary.withOpacity(0.54)))
                    : Text(
                        'SAVE & ADD ANOTHER',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Color(0xFF448AFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _isLoading ? null : () => _save(),
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                  : Text(
                      widget.material == null ? 'FINISH & SAVE MATERIAL' : 'UPDATE MATERIAL DETAILS',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddPartySheet(BuildContext context) {
    final nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add New Party', 
                style: TextStyle(
                  fontWeight: FontWeight.w900, 
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              ),
              const SizedBox(height: 24),
              HelpfulTextField(label: 'Party Name', controller: nameCtrl, hintText: 'e.g. Bharat Steel'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) return;
                    final p = PartyModel(
                      id: 'P-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text,
                      category: PartyCategory.supplier,
                      createdAt: DateTime.now(),
                    );
                    await _partyService.addParty(p);
                    if (context.mounted) {
                      setState(() => _selectedPartyId = p.id);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('CREATE PARTY'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
