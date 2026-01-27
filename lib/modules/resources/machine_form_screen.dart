import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/widgets/confirm_dialog.dart';
import 'package:construction_app/utils/feedback_helper.dart';
import 'machine_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/auth_service.dart';
import 'package:construction_app/services/approval_service.dart';
import 'package:construction_app/governance/approvals/models/action_request.dart';
import 'package:construction_app/governance/approvals/approvals_queue_screen.dart';
import 'package:construction_app/services/mock_notification_service.dart';

class MachineFormScreen extends StatefulWidget {
  final MachineModel? machine;
  final String? currentSiteId;

  const MachineFormScreen({super.key, this.machine, this.currentSiteId});

  @override
  State<MachineFormScreen> createState() => _MachineFormScreenState();
}

class _MachineFormScreenState extends State<MachineFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _siteNameController;
  late final TextEditingController _operatorNameController;

  late MachineType _selectedType;
  late MachineStatus _selectedStatus;
  NatureOfWork? _selectedWork;
  late DateTime _lastMaintenance;
  DateTime? _nextMaintenance;

  @override
  void initState() {
    super.initState();
    final m = widget.machine;
    _nameController = TextEditingController(text: m?.name ?? '');
    _siteNameController = TextEditingController(text: m?.assignedSiteName ?? '');
    _operatorNameController = TextEditingController(text: m?.operatorName ?? '');

    _selectedType = m?.type ?? MachineType.excavator;
    _selectedStatus = m?.status ?? MachineStatus.available;
    _selectedWork = m?.natureOfWork;
    _lastMaintenance = m?.lastMaintenanceDate ?? DateTime.now();
    _nextMaintenance = m?.nextMaintenanceDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _siteNameController.dispose();
    _operatorNameController.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    final hasData = _nameController.text.trim().isNotEmpty ||
        _siteNameController.text.trim().isNotEmpty ||
        _operatorNameController.text.trim().isNotEmpty;

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

  Future<void> _selectDate(BuildContext context, bool isLast) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isLast ? _lastMaintenance : (_nextMaintenance ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isLast) {
          _lastMaintenance = picked;
        } else {
          _nextMaintenance = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.machine != null;

    return ProfessionalPage(
      title: isEditing ? 'Edit Machine' : 'Add Machine',
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
                      _sectionTitle(context, 'Basic Information', Icons.precision_manufacturing_rounded),
                      const SizedBox(height: 24),
                      HelpfulTextField(
                        controller: _nameController,
                        label: 'Machine Name',
                        hintText: 'e.g. Caterpillar 320D',
                        icon: Icons.precision_manufacturing_rounded,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      HelpfulDropdown<MachineType>(
                        label: 'Machine Type',
                        value: _selectedType,
                        items: MachineType.values,
                        labelMapper: (t) => t.displayName,
                        icon: Icons.category_rounded,
                        onChanged: (v) => setState(() => _selectedType = v!),
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
                      _sectionTitle(context, 'Deployment Details', Icons.location_on_rounded),
                      const SizedBox(height: 24),
                      HelpfulTextField(
                        controller: _siteNameController,
                        label: 'Assigned Site',
                        hintText: 'Enter site name',
                        icon: Icons.location_on_rounded,
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        controller: _operatorNameController,
                        label: 'Operator Name',
                        hintText: 'Assigned personnel',
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 20),
                      HelpfulDropdown<NatureOfWork>(
                        label: 'Nature of Work',
                        value: _selectedWork ?? NatureOfWork.earthwork,
                        items: NatureOfWork.values,
                        labelMapper: (t) => t.displayName,
                        icon: Icons.work_rounded,
                        onChanged: (v) => setState(() => _selectedWork = v),
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
                      _sectionTitle(context, 'Status & Maintenance', Icons.settings_suggest_rounded),
                      const SizedBox(height: 24),
                      HelpfulDropdown<MachineStatus>(
                        label: 'Current Status',
                        value: _selectedStatus,
                        items: MachineStatus.values,
                        labelMapper: (t) => t.displayName,
                        icon: Icons.info_rounded,
                        onChanged: (v) => setState(() => _selectedStatus = v!),
                      ),
                      const SizedBox(height: 20),
                      _buildDatePickerRow(context, 'Last Maintenance', _lastMaintenance, () => _selectDate(context, true)),
                      const SizedBox(height: 20),
                      _buildDatePickerRow(context, 'Next Maintenance', _nextMaintenance, () => _selectDate(context, false), isOptional: true),
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
                        child: Text('Discard', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 16)),
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
                          onPressed: _saveMachine,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            isEditing ? 'Update Machine' : 'Register Machine',
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

  Widget _buildDatePickerRow(BuildContext context, String label, DateTime? date, VoidCallback onTap, {bool isOptional = false}) {
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
                    date != null ? DateFormat('MMM dd, yyyy').format(date) : (isOptional ? 'Set date' : 'Not set'),
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }

  void _saveMachine() {
    if (_formKey.currentState!.validate()) {
      final machine = MachineModel(
        id: widget.machine?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        assignedSiteName: _siteNameController.text.trim().isEmpty ? null : _siteNameController.text.trim(),
        operatorName: _operatorNameController.text.trim().isEmpty ? null : _operatorNameController.text.trim(),
        natureOfWork: _selectedWork,
        lastMaintenanceDate: _lastMaintenance,
        nextMaintenanceDate: _nextMaintenance,
      );

      final updatedMachine = machine.copyWith(
        assignedSiteName: widget.currentSiteId ?? widget.machine?.assignedSiteName,
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
          entityType: 'machine',
          action: widget.machine != null ? ActionType.edit : ActionType.add,
          payload: updatedMachine.toJson(),
          createdAt: DateTime.now(),
        ), notificationService: notificationService);

        FeedbackHelper.showSuccess(
          context,
          'Your request to ${widget.machine != null ? "update" : "register"} ${machine.name} has been submitted to Admin for approval.',
        );
        Navigator.pop(context);
        return;
      }

      FeedbackHelper.showSuccess(
        context,
        widget.machine != null ? 'Machine updated successfully' : 'Machine registered successfully',
      );
      Navigator.pop(context, machine);
    }
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
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
