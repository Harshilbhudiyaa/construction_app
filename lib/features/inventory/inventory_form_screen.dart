import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/helpful_text_field.dart';
import '../../app/ui/widgets/helpful_dropdown.dart';
import '../../app/ui/widgets/confirm_dialog.dart';
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
                        onChanged: (v) => setState(() => _selectedCategory = v!),
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
}
