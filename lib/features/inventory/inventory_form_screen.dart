import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/helpful_text_field.dart';
import '../../app/ui/widgets/helpful_dropdown.dart';
import '../../app/utils/feedback_helper.dart';
import 'models/inventory_detail_model.dart';

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

  late MaterialCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    final m = widget.material;
    _nameController = TextEditingController(text: m?.materialName ?? '');
    _totalQtyController = TextEditingController(text: m?.totalQuantity.toString() ?? '');
    _consumedQtyController = TextEditingController(text: m?.consumedQuantity.toString() ?? '0');
    _unitController = TextEditingController(text: m?.unit ?? 'kg');
    _reorderController = TextEditingController(text: m?.reorderLevel?.toString() ?? '');
    _supplierController = TextEditingController(text: m?.supplierName ?? '');
    _locationController = TextEditingController(text: m?.storageLocation ?? '');

    _selectedCategory = m?.category ?? MaterialCategory.cement;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalQtyController.dispose();
    _consumedQtyController.dispose();
    _unitController.dispose();
    _reorderController.dispose();
    _supplierController.dispose();
    _locationController.dispose();
    super.dispose();
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
                const ProfessionalSectionHeader(
                  title: 'Material Info',
                  subtitle: 'Item identification and group',
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _nameController,
                  label: 'Material Name',
                  hintText: 'e.g. Portland Cement 53 Grade',
                  icon: Icons.inventory_2_rounded,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulDropdown<MaterialCategory>(
                  label: 'Category',
                  value: _selectedCategory,
                  items: MaterialCategory.values,
                  labelMapper: (c) => c.displayName,
                  icon: Icons.category_rounded,
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: AppSpacing.lg),
                const ProfessionalSectionHeader(
                  title: 'Inventory Metrics',
                  subtitle: 'Quantities and usage tracking',
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: HelpfulTextField(
                        controller: _totalQtyController,
                        label: 'Total Qty',
                        hintText: 'Quantity',
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: HelpfulTextField(
                        controller: _unitController,
                        label: 'Unit',
                        hintText: 'e.g. bags, kg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _consumedQtyController,
                  label: 'Consumed Quantity',
                  hintText: 'Current usage',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _reorderController,
                  label: 'Reorder Level',
                  hintText: 'Alert threshold',
                  keyboardType: TextInputType.number,
                  icon: Icons.warning_amber_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
                const ProfessionalSectionHeader(
                  title: 'Sourcing & Storage',
                  subtitle: 'Supplier and location details',
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _supplierController,
                  label: 'Supplier Name',
                  hintText: 'Main supplier',
                  icon: Icons.business_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _locationController,
                  label: 'Storage Location',
                  hintText: 'Wharehouse/Section',
                  icon: Icons.warehouse_rounded,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.white70),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveMaterial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.deepBlue1,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isEditing ? 'Update Material' : 'Add Material'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveMaterial() {
    if (_formKey.currentState!.validate()) {
      final material = InventoryDetailModel(
        id: widget.material?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
      );

      FeedbackHelper.showSuccess(
        context,
        widget.material != null ? 'Material updated' : 'Material added to inventory',
      );
      Navigator.pop(context, material);
    }
  }
}
