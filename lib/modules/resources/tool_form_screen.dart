import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/widgets/confirm_dialog.dart';
import 'package:construction_app/utils/feedback_helper.dart';
import 'tool_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/auth_service.dart';
import 'package:construction_app/services/approval_service.dart';
import 'package:construction_app/governance/approvals/models/action_request.dart';
import 'package:construction_app/governance/approvals/approvals_queue_screen.dart';
import 'package:construction_app/services/mock_notification_service.dart';

class ToolFormScreen extends StatefulWidget {
  final ToolModel? tool;
  final String? currentSiteId;

  const ToolFormScreen({super.key, this.tool, this.currentSiteId});

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

  Future<void> _handleBack() async {
    final hasData = _nameController.text.trim().isNotEmpty ||
        _purposeController.text.trim().isNotEmpty ||
        _siteNameController.text.trim().isNotEmpty;

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
                ProfessionalCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Tool Details', Icons.build_rounded),
                      const SizedBox(height: 24),
                      HelpfulTextField(
                        controller: _nameController,
                        label: 'Tool Name',
                        hintText: 'e.g. Bosch Hammer Drill',
                        icon: Icons.build_rounded,
                        useGlass: false,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      HelpfulDropdown<ToolType>(
                        label: 'Tool Type',
                        value: _selectedType,
                        items: ToolType.values,
                        labelMapper: (t) => t.displayName,
                        icon: Icons.category_rounded,
                        useGlass: false,
                        onChanged: (v) => setState(() => _selectedType = v!),
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        controller: _purposeController,
                        label: 'Usage Purpose',
                        hintText: 'What is this tool used for?',
                        icon: Icons.info_outline_rounded,
                        useGlass: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ProfessionalCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Inventory & Assignment', Icons.inventory_rounded),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: HelpfulTextField(
                              controller: _quantityController,
                              label: 'Total Qty',
                              hintText: 'Total',
                              keyboardType: TextInputType.number,
                              icon: Icons.inventory_rounded,
                              useGlass: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HelpfulTextField(
                              controller: _availableController,
                              label: 'Available',
                              hintText: 'In Stock',
                              keyboardType: TextInputType.number,
                              icon: Icons.check_circle_outline_rounded,
                              useGlass: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        controller: _siteNameController,
                        label: 'Assigned Site',
                        hintText: 'Current location',
                        icon: Icons.location_on_rounded,
                        useGlass: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ProfessionalCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Condition & Compliance', Icons.health_and_safety_rounded),
                      const SizedBox(height: 24),
                      HelpfulDropdown<ToolCondition>(
                        label: 'Condition',
                        value: _selectedCondition,
                        items: ToolCondition.values,
                        labelMapper: (t) => t.displayName,
                        icon: Icons.health_and_safety_rounded,
                        useGlass: false,
                        onChanged: (v) => setState(() => _selectedCondition = v!),
                      ),
                      const SizedBox(height: 20),
                      _buildDatePickerRow('Last Inspection', _lastInspection, () => _selectDate(context)),
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
                          side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Discard', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _saveTool,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            isEditing ? 'Update Tool' : 'Register Tool',
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

  Widget _buildDatePickerRow(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                  Text(
                    DateFormat('MMM dd, yyyy').format(date),
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 16),
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

      final updatedTool = tool.copyWith(
        assignedSiteName: widget.currentSiteId ?? widget.tool?.assignedSiteName,
      );

      final authService = context.read<AuthService>();
      final isEngineer = authService.userRole == 'engineer';

      if (isEngineer) {
        final approvalService = context.read<ApprovalService>();
        final notificationService = context.read<MockNotificationService>();
        approvalService.submitRequest(ActionRequest(
          id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
          siteId: widget.currentSiteId ?? 'S-001',
          requesterId: authService.userId ?? 'unknown',
          requesterName: 'Engineer',
          entityType: 'tool',
          action: widget.tool != null ? ActionType.edit : ActionType.add,
          payload: updatedTool.toJson(),
          createdAt: DateTime.now(),
        ), notificationService: notificationService);

        FeedbackHelper.showSuccess(
          context,
          'Your request to ${widget.tool != null ? "update" : "register"} ${tool.name} has been submitted to Admin for approval.',
        );
        Navigator.pop(context);
        return;
      }

      FeedbackHelper.showSuccess(
        context,
        widget.tool != null ? 'Tool updated successfully' : 'Tool registered successfully',
      );
      Navigator.pop(context, tool);
    }
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
