 import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/helpful_text_field.dart';
import '../../app/ui/widgets/helpful_dropdown.dart';
import '../../app/ui/widgets/confirm_dialog.dart';
import '../../app/utils/feedback_helper.dart';
import 'models/inventory_detail_model.dart';
import 'inward_entry_form_screen.dart';
import 'inward_bill_view_screen.dart';
import 'models/inward_movement_model.dart';
import 'package:intl/intl.dart';

class InventoryFormScreen extends StatefulWidget {
  final InventoryDetailModel? material;

  const InventoryFormScreen({super.key, this.material});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _totalQtyController;
  late final TextEditingController _consumedQtyController;
  late final TextEditingController _unitController;
  late final TextEditingController _reorderController;
  late final TextEditingController _supplierController;
  late final TextEditingController _locationController;
  late final TextEditingController _steelSizeController;
  late final TextEditingController _brickTypeController;
  late final TextEditingController _aggregateSizeController;
  late final TextEditingController _paintFinishController;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _truckNoController;
  late final TextEditingController _driverNameController;
  late final TextEditingController _transporterController;

  late MaterialCategory _selectedCategory;

  // Multi-add support
  final List<InventoryDetailModel> _pendingMaterials = [];
  
  // Custom properties support
  final List<({TextEditingController key, TextEditingController value})> _customProperties = [];

  @override
  void initState() {
    super.initState();
    final m = widget.material;
    _nameController = TextEditingController(text: m?.materialName ?? '');
    _totalQtyController = TextEditingController(text: m?.totalQuantity.toString() ?? '');
    _consumedQtyController = TextEditingController(text: m?.consumedQuantity.toString() ?? '0');
    _supplierController = TextEditingController(text: m?.supplierName ?? '');
    _locationController = TextEditingController(text: m?.storageLocation ?? '');

    _selectedCategory = m?.category ?? MaterialCategory.cement;

    _reorderController = TextEditingController(text: m?.reorderLevel?.toString() ?? '');

    // Unit initialization
    String unit = m?.unit ?? 'kg';
    if (m == null) {
      if (_selectedCategory == MaterialCategory.cement) unit = 'kg';
      if (_selectedCategory == MaterialCategory.sand) unit = 'tone';
    }
    _unitController = TextEditingController(text: unit);

    // Sub-category fields (metadata)
    _steelSizeController = TextEditingController(text: m?.metadata?['steelSize']?.toString() ?? '');
    _brickTypeController = TextEditingController(text: m?.metadata?['brickType']?.toString() ?? '');
    _aggregateSizeController = TextEditingController(text: m?.metadata?['aggregateSize']?.toString() ?? '');
    _paintFinishController = TextEditingController(text: m?.metadata?['paintFinish']?.toString() ?? '');
    _customCategoryController = TextEditingController(text: m?.metadata?['customCategory']?.toString() ?? '');
    _truckNoController = TextEditingController();
    _driverNameController = TextEditingController();
    _transporterController = TextEditingController();

    // Initialize custom properties from metadata if they don't match standard keys
    if (m?.metadata != null) {
      final standardKeys = ['steelSize', 'brickType', 'aggregateSize', 'paintFinish', 'customCategory'];
      m!.metadata!.forEach((key, value) {
        if (!standardKeys.contains(key)) {
          _customProperties.add((
            key: TextEditingController(text: key),
            value: TextEditingController(text: value?.toString() ?? ''),
          ));
        }
      });
    }

    // Listen to name changes to update logs filtering in real-time
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _addProperty() {
    setState(() {
      _customProperties.add((
        key: TextEditingController(),
        value: TextEditingController(),
      ));
    });
  }

  void _removeProperty(int index) {
    setState(() {
      _customProperties[index].key.dispose();
      _customProperties[index].value.dispose();
      _customProperties.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var prop in _customProperties) {
      prop.key.dispose();
      prop.value.dispose();
    }
    _nameController.dispose();
    _totalQtyController.dispose();
    _consumedQtyController.dispose();
    _unitController.dispose();
    _reorderController.dispose();
    _supplierController.dispose();
    _locationController.dispose();
    _steelSizeController.dispose();
    _brickTypeController.dispose();
    _aggregateSizeController.dispose();
    _paintFinishController.dispose();
    _customCategoryController.dispose();
    _truckNoController.dispose();
    _driverNameController.dispose();
    _transporterController.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    final hasData = _nameController.text.trim().isNotEmpty ||
        _totalQtyController.text.trim().isNotEmpty ||
        _supplierController.text.trim().isNotEmpty;

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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.material != null;

    return ProfessionalPage(
      title: isEditing ? 'Edit Material' : 'Add Material',
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfessionalCard(
                  useGlass: true,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Material Information', Icons.inventory_2_rounded),
                      const SizedBox(height: 24),
                      HelpfulTextField(
                        controller: _nameController,
                        label: 'Material Name',
                        hintText: 'e.g. Portland Cement 53 Grade',
                        icon: Icons.inventory_2_rounded,
                        useGlass: true,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      HelpfulDropdown<MaterialCategory>(
                        label: 'Category',
                        value: _selectedCategory,
                        items: MaterialCategory.values,
                        labelMapper: (c) => c.displayName,
                        icon: Icons.category_rounded,
                        useGlass: true,
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _selectedCategory = v;
                              // Update unit based on category
                              if (v == MaterialCategory.cement) _unitController.text = 'kg';
                              else if (v == MaterialCategory.sand) _unitController.text = 'tone';
                              else if (v == MaterialCategory.steel) _unitController.text = 'kg';
                              else if (v == MaterialCategory.aggregate) _unitController.text = 'tone';
                              else if (v == MaterialCategory.bricks) _unitController.text = 'units';
                              else if (v == MaterialCategory.paint) _unitController.text = 'liter';
                            });
                          }
                        },
                      ),
                      _buildDynamicFields(),
                      
                      const SizedBox(height: 12),
                      if (!isEditing) ...[
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: InkWell(
                            onTap: _addAnotherVariant,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_circle_outline_rounded, color: Colors.blueAccent, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Log this ${_selectedCategory.displayName} variant & Add next',
                                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (!isEditing && _pendingMaterials.isNotEmpty) ...[
                  _buildPendingList(),
                  const SizedBox(height: 12),
                ],
                ProfessionalCard(
                  useGlass: true,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Inventory Metrics', Icons.analytics_rounded),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: HelpfulTextField(
                              controller: _totalQtyController,
                              label: 'Total Quantity',
                              hintText: 'Quantity',
                              keyboardType: TextInputType.number,
                              useGlass: true,
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HelpfulTextField(
                              controller: _unitController,
                              label: 'Unit',
                              hintText: 'e.g. bags, kg',
                              useGlass: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildQuickUnits(),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        controller: _consumedQtyController,
                        label: 'Consumed Quantity',
                        hintText: 'Current usage',
                        keyboardType: TextInputType.number,
                        useGlass: true,
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        controller: _reorderController,
                        label: 'Reorder Level',
                        hintText: 'Alert threshold',
                        keyboardType: TextInputType.number,
                        icon: Icons.warning_amber_rounded,
                        useGlass: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ProfessionalCard(
                  useGlass: true,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Sourcing & Storage', Icons.business_rounded),
                      const SizedBox(height: 24),
                      HelpfulTextField(
                        controller: _supplierController,
                        label: 'Supplier Name',
                        hintText: 'Main supplier',
                        icon: Icons.business_rounded,
                        useGlass: true,
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        controller: _locationController,
                        label: 'Storage Location',
                        hintText: 'Warehouse/Section',
                        icon: Icons.warehouse_rounded,
                        useGlass: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ProfessionalCard(
                  useGlass: true,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Logistics & Truck Details', Icons.local_shipping_rounded),
                      const SizedBox(height: 24),
                      HelpfulTextField(
                        controller: _truckNoController,
                        label: 'Truck / Vehicle Number',
                        hintText: 'e.g. GJ01-AB-1234',
                        icon: Icons.numbers_rounded,
                        useGlass: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: HelpfulTextField(
                              controller: _driverNameController,
                              label: 'Driver Name',
                              hintText: 'Full name',
                              icon: Icons.person_rounded,
                              useGlass: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HelpfulTextField(
                              controller: _transporterController,
                              label: 'Transporter',
                              hintText: 'Company name',
                              icon: Icons.business_rounded,
                              useGlass: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.1)),
                    ),
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InwardEntryFormScreen(
                            preselectedMaterial: widget.material!.materialName,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.greenAccent),
                      label: const Text(
                        'Log Arrival for this Material',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.greenAccent),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                ],
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
                          onPressed: _saveMaterial,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            isEditing ? 'Update Material' : 'Add Material',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildLogsHeader('Recent Inward Logs', Icons.history_rounded),
                const SizedBox(height: 16),
                _buildInwardLogsSection(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addAnotherVariant() {
    if (_formKey.currentState!.validate()) {
      final material = _createMaterialFromCurrentState();
      setState(() {
        _pendingMaterials.add(material);
        // Reset only variant-specific fields
        _totalQtyController.clear();
        _consumedQtyController.text = '0';
        _steelSizeController.clear();
        _brickTypeController.clear();
        _aggregateSizeController.clear();
        _paintFinishController.clear();
        _customCategoryController.clear();
        // Clear custom properties too
        for (var prop in _customProperties) {
          prop.key.dispose();
          prop.value.dispose();
        }
        _customProperties.clear();
      });
      FeedbackHelper.showSuccess(context, 'Variant added to queue');
    }
  }

  Widget _buildPendingList() {
    if (_pendingMaterials.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Queued Materials (${_pendingMaterials.length})', Icons.list_alt_rounded),
        const SizedBox(height: 12),
        ..._pendingMaterials.asMap().entries.map((entry) {
          final index = entry.key;
          final m = entry.value;
          String variantInfo = '';
          if (m.metadata != null) {
            variantInfo = ' • ${m.metadata!.values.join(', ')}';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ListTile(
              dense: true,
              leading: Text(m.category.icon, style: const TextStyle(fontSize: 20)),
              title: Text(
                '${m.materialName}$variantInfo',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${m.totalQuantity} ${m.unit}',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                onPressed: () => setState(() => _pendingMaterials.removeAt(index)),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  InventoryDetailModel _createMaterialFromCurrentState() {
    Map<String, dynamic> metadata = {};
    if (_selectedCategory == MaterialCategory.steel) {
      metadata['steelSize'] = _steelSizeController.text.trim();
    } else if (_selectedCategory == MaterialCategory.bricks) {
      metadata['brickType'] = _brickTypeController.text.trim();
    } else if (_selectedCategory == MaterialCategory.aggregate) {
      metadata['aggregateSize'] = _aggregateSizeController.text.trim();
    } else if (_selectedCategory == MaterialCategory.paint) {
      metadata['paintFinish'] = _paintFinishController.text.trim();
    } else if (_selectedCategory == MaterialCategory.other) {
      metadata['customCategory'] = _customCategoryController.text.trim();
    }

    // Add custom properties to metadata
    for (var prop in _customProperties) {
      final key = prop.key.text.trim();
      final val = prop.value.text.trim();
      if (key.isNotEmpty && val.isNotEmpty) {
        metadata[key] = val;
      }
    }

    return InventoryDetailModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() + _pendingMaterials.length.toString(),
      materialName: _nameController.text.trim(),
      category: _selectedCategory,
      totalQuantity: double.tryParse(_totalQtyController.text) ?? 0,
      consumedQuantity: double.tryParse(_consumedQtyController.text) ?? 0,
      unit: _unitController.text.trim(),
      reorderLevel: double.tryParse(_reorderController.text),
      supplierName: _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim(),
      storageLocation: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      lastUpdatedDate: DateTime.now(),
      lastUpdatedBy: 'Current User',
      metadata: metadata.isNotEmpty ? metadata : null,
    );
  }

  void _saveMaterial() {
    if (_formKey.currentState!.validate()) {
      final currentMaterial = _createMaterialFromCurrentState();
      final allMaterials = [..._pendingMaterials, currentMaterial];

      FeedbackHelper.showSuccess(
        context,
        widget.material != null ? 'Material updated' : '${allMaterials.length} item(s) saved',
      );
      
      // If editing, we only return the edited one. If adding, we return a list.
      if (widget.material != null) {
        Navigator.pop(context, currentMaterial);
      } else {
        Navigator.pop(context, allMaterials);
      }
    }
  }

  Widget _buildQuickUnits() {
    List<String> units;
    switch (_selectedCategory) {
      case MaterialCategory.cement:
        units = ['kg', 'bags'];
        break;
      case MaterialCategory.sand:
        units = ['tone', 'units', 'cft'];
        break;
      case MaterialCategory.steel:
        units = ['kg', 'tone', 'meters'];
        break;
      case MaterialCategory.bricks:
        units = ['units', 'nos'];
        break;
      case MaterialCategory.aggregate:
        units = ['tone', 'cft'];
        break;
      case MaterialCategory.timber:
        units = ['sqft', 'cft', 'meters'];
        break;
      case MaterialCategory.paint:
        units = ['liter', 'kg', 'drums'];
        break;
      case MaterialCategory.tiles:
        units = ['sqft', 'boxes', 'units'];
        break;
      case MaterialCategory.glass:
        units = ['sqft', 'units'];
        break;
      default:
        units = ['kg', 'tone', 'units', 'bags', 'liter'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt_rounded, size: 14, color: Colors.blueAccent.withOpacity(0.7)),
            const SizedBox(width: 6),
            Text(
              'QUICK UNIT SELECT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: units.map((u) {
              final isSelected = _unitController.text.trim().toLowerCase() == u.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _unitController.text = u),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                        ? const LinearGradient(colors: [Colors.blueAccent, AppColors.deepBlue3])
                        : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    child: Text(
                      u,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicFields() {
    Widget? activeField;

    switch (_selectedCategory) {
      case MaterialCategory.steel:
        activeField = HelpfulTextField(
          controller: _steelSizeController,
          label: 'Bar Diameter (mm)',
          hintText: 'e.g. 8mm, 12mm, 16mm',
          icon: Icons.architecture_rounded,
          useGlass: true,
          keyboardType: TextInputType.number,
        );
        break;
      case MaterialCategory.bricks:
        activeField = HelpfulTextField(
          controller: _brickTypeController,
          label: 'Brick Type',
          hintText: 'e.g. Red Clay, Fly Ash, AAC Block',
          icon: Icons.grid_view_rounded,
          useGlass: true,
        );
        break;
      case MaterialCategory.aggregate:
        activeField = HelpfulTextField(
          controller: _aggregateSizeController,
          label: 'Aggregate Size',
          hintText: 'e.g. 10mm, 20mm, 40mm',
          icon: Icons.grain_rounded,
          useGlass: true,
        );
        break;
      case MaterialCategory.paint:
        activeField = HelpfulTextField(
          controller: _paintFinishController,
          label: 'Paint Finish',
          hintText: 'e.g. Gloss, Matt, Satin',
          icon: Icons.format_paint_rounded,
          useGlass: true,
        );
        break;
      case MaterialCategory.other:
        activeField = HelpfulTextField(
          controller: _customCategoryController,
          label: 'Material Type Name',
          hintText: 'e.g. Electrical Conduit, Waterproofing Chemical',
          icon: Icons.edit_note_rounded,
          useGlass: true,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        );
        break;
      default:
        activeField = const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeField is! SizedBox) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: activeField,
          ),
        ],
        
        // Custom Properties Header
        if (_customProperties.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 14, color: Colors.white.withOpacity(0.4)),
              const SizedBox(width: 8),
              Text(
                'ADDITIONAL SPECIFICATIONS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Custom Properties List
        ..._customProperties.asMap().entries.map((entry) {
          final idx = entry.key;
          final prop = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: HelpfulTextField(
                    label: 'Property Name',
                    controller: prop.key,
                    hintText: 'e.g. Length',
                    useGlass: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: HelpfulTextField(
                    label: 'Property Value',
                    controller: prop.value,
                    hintText: 'e.g. 12m',
                    useGlass: true,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeProperty(idx),
                  icon: Icon(Icons.remove_circle_outline_rounded, color: Colors.white.withOpacity(0.3), size: 18),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addProperty,
          icon: const Icon(Icons.add_rounded, size: 18, color: Colors.blueAccent),
          label: const Text(
            'Add Property (Type, Length, etc.)',
            style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
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

  Widget _buildLogsHeader(String title, IconData icon) {
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

  Widget _buildInwardLogsSection(BuildContext context) {
    final currentName = _nameController.text.trim();
    if (currentName.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Enter a material name to see history.',
            style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
          ),
        ),
      );
    }
    
    // Simulated mock database of logs (same pool as Detail screen)
    final List<InwardMovementModel> allLogs = [
      InwardMovementModel(
        id: 'LOG-7721',
        vehicleType: 'Dumper / Truck',
        vehicleNumber: 'GJ01-AB-1234',
        vehicleCapacity: '12 Tons',
        transporterName: 'ABC Logistics',
        driverName: 'Rajesh Kumar',
        driverMobile: '+91 98765 43210',
        driverLicense: 'GJ01-2023-0001',
        materialName: 'Sand',
        category: MaterialCategory.sand,
        quantity: 120.0,
        unit: 'tons',
        photoProofs: [], 
        ratePerUnit: 450.0,
        transportCharges: 5000.0,
        taxPercentage: 18.0,
        totalAmount: 69620.0,
        status: InwardStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      InwardMovementModel(
        id: 'LOG-7689',
        vehicleType: 'Tractor',
        vehicleNumber: 'GJ01-XY-5678',
        vehicleCapacity: '8 Tons',
        transporterName: 'Self Owned',
        driverName: 'Amit Shah',
        driverMobile: '+91 99887 76655',
        driverLicense: 'GJ01-2022-0456',
        materialName: 'Portland Cement (OPC 53)',
        category: MaterialCategory.cement,
        quantity: 500.0,
        unit: 'bags',
        photoProofs: [], 
        ratePerUnit: 380.0,
        transportCharges: 2000.0,
        taxPercentage: 18.0,
        totalAmount: 226560.0,
        status: InwardStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      InwardMovementModel(
        id: 'LOG-8012',
        vehicleType: 'Truck',
        vehicleNumber: 'MH04-KT-9012',
        vehicleCapacity: '15 Tons',
        transporterName: 'Express Cargo',
        driverName: 'Suresh Raina',
        driverMobile: '+91 91234 56789',
        driverLicense: 'MH04-2021-999',
        materialName: 'Steel Rebars (12mm)',
        category: MaterialCategory.steel,
        quantity: 15.0,
        unit: 'tons',
        photoProofs: [], 
        ratePerUnit: 65000.0,
        transportCharges: 8000.0,
        taxPercentage: 18.0,
        totalAmount: 1159940.0,
        status: InwardStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    final materialLogs = allLogs.where((log) => 
      log.materialName.toLowerCase() == currentName.toLowerCase()
    ).toList();

    if (materialLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No history for this material.',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
          ),
        ),
      );
    }

    return Column(
      children: materialLogs.map((log) => _buildLogCard(context, log)).toList(),
    );
  }

  Widget _buildLogCard(BuildContext context, InwardMovementModel log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InwardBillViewScreen(item: log)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: Colors.blueAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.vehicleNumber,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Driver: ${log.driverName}',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${log.quantity} ${log.unit}',
                        style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                      Text(
                        DateFormat('MMM dd').format(log.createdAt),
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                   _photoQuickDot(),
                   _photoQuickDot(),
                   _photoQuickDot(),
                   const SizedBox(width: 8),
                   Text('VERIFIED PROOFS', style: TextStyle(color: Colors.blueAccent.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                   const Spacer(),
                   const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoQuickDot() {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.only(right: 3),
      decoration: const BoxDecoration(
        color: Colors.greenAccent,
        shape: BoxShape.circle,
      ),
    );
  }
}
