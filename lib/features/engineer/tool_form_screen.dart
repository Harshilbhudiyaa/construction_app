import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/helpful_text_field.dart';
import '../../app/ui/widgets/helpful_dropdown.dart';
import '../../app/utils/feedback_helper.dart';
import 'models/tool_model.dart';
import 'package:intl/intl.dart';

class ToolFormScreen extends StatefulWidget {
  final ToolModel? tool;

  const ToolFormScreen({super.key, this.tool});

  @override
  State<ToolFormScreen> createState() => _ToolFormScreenState();
}

class _ToolFormScreenState extends State<ToolFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _purposeController;
  late final TextEditingController _siteNameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _availableController;

  late ToolType _selectedType;
  late ToolCondition _selectedCondition;
  late DateTime _lastInspection;

  @override
  void initState() {
    super.initState();
    final t = widget.tool;
    _nameController = TextEditingController(text: t?.name ?? '');
    _purposeController = TextEditingController(text: t?.usagePurpose ?? '');
    _siteNameController = TextEditingController(text: t?.assignedSiteName ?? '');
    _quantityController = TextEditingController(text: t?.quantity.toString() ?? '1');
    _availableController = TextEditingController(text: t?.availableQuantity.toString() ?? '1');

    _selectedType = t?.type ?? ToolType.handTool;
    _selectedCondition = t?.condition ?? ToolCondition.good;
    _lastInspection = t?.lastInspectionDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _siteNameController.dispose();
    _quantityController.dispose();
    _availableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tool != null;

    return ProfessionalPage(
      title: isEditing ? 'Edit Tool' : 'Register Tool',
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfessionalSectionHeader(
                  title: 'Tool Details',
                  subtitle: 'Item identification and classification',
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _nameController,
                  label: 'Tool Name',
                  hintText: 'e.g. Bosch Hammer Drill',
                  icon: Icons.build_rounded,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulDropdown<ToolType>(
                  label: 'Tool Type',
                  value: _selectedType,
                  items: ToolType.values,
                  labelMapper: (t) => t.displayName,
                  icon: Icons.category_rounded,
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _purposeController,
                  label: 'Usage Purpose',
                  hintText: 'What is this tool used for?',
                  icon: Icons.info_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
                const ProfessionalSectionHeader(
                  title: 'Inventory & Assignment',
                  subtitle: 'Stock levels and location',
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: HelpfulTextField(
                        controller: _quantityController,
                        label: 'Total Qty',
                        hintText: 'Total',
                        keyboardType: TextInputType.number,
                        icon: Icons.inventory_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: HelpfulTextField(
                        controller: _availableController,
                        label: 'Available',
                        hintText: 'In Stock',
                        keyboardType: TextInputType.number,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _siteNameController,
                  label: 'Assigned Site',
                  hintText: 'Current location',
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
                const ProfessionalSectionHeader(
                  title: 'Condition & Compliance',
                  subtitle: 'Safety check and physical state',
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulDropdown<ToolCondition>(
                  label: 'Condition',
                  value: _selectedCondition,
                  items: ToolCondition.values,
                  labelMapper: (t) => t.displayName,
                  icon: Icons.health_and_safety_rounded,
                  onChanged: (v) => setState(() => _selectedCondition = v!),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildDatePickerRow('Last Inspection', _lastInspection, () => _selectDate(context)),
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
                        onPressed: _saveTool,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.deepBlue1,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isEditing ? 'Update Tool' : 'Register Tool'),
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

  Widget _buildDatePickerRow(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    DateFormat('MMM dd, yyyy').format(date),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_rounded, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastInspection,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _lastInspection = picked);
    }
  }

  void _saveTool() {
    if (_formKey.currentState!.validate()) {
      final tool = ToolModel(
        id: widget.tool?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        usagePurpose: _purposeController.text.trim(),
        quantity: int.tryParse(_quantityController.text) ?? 1,
        availableQuantity: int.tryParse(_availableController.text) ?? 1,
        condition: _selectedCondition,
        lastInspectionDate: _lastInspection,
        assignedSiteName: _siteNameController.text.trim().isEmpty ? null : _siteNameController.text.trim(),
      );

      FeedbackHelper.showSuccess(
        context,
        widget.tool != null ? 'Tool updated successfully' : 'Tool registered successfully',
      );
      Navigator.pop(context, tool);
    }
  }
}
