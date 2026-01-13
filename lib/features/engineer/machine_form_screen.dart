import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/helpful_text_field.dart';
import '../../app/ui/widgets/helpful_dropdown.dart';
import '../../app/ui/widgets/confirm_dialog.dart';
import '../../app/utils/feedback_helper.dart';
import 'models/machine_model.dart';
import 'package:intl/intl.dart';

class MachineFormScreen extends StatefulWidget {
  final MachineModel? machine;

  const MachineFormScreen({super.key, this.machine});

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
                  useGlass: true,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Basic Information', Icons.precision_manufacturing_rounded),
                      const SizedBox(height: 24),
                      HelpfulTextField(
                        controller: _nameController,
                        label: 'Machine Name',
                        hintText: 'e.g. Caterpillar 320D',
                        icon: Icons.precision_manufacturing_rounded,
                        useGlass: true,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      HelpfulDropdown<MachineType>(
                        label: 'Machine Type',
                        value: _selectedType,
                        items: MachineType.values,
                        labelMapper: (t) => t.displayName,
                        icon: Icons.category_rounded,
                        useGlass: true,
                        onChanged: (v) => setState(() => _selectedType = v!),
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
                      _sectionTitle('Deployment Details', Icons.location_on_rounded),
                      const SizedBox(height: 24),
                      HelpfulTextField(
                        controller: _siteNameController,
                        label: 'Assigned Site',
                        hintText: 'Enter site name',
                        icon: Icons.location_on_rounded,
                        useGlass: true,
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        controller: _operatorNameController,
                        label: 'Operator Name',
                        hintText: 'Assigned personnel',
                        icon: Icons.person_rounded,
                        useGlass: true,
                      ),
                      const SizedBox(height: 20),
                      HelpfulDropdown<NatureOfWork>(
                        label: 'Nature of Work',
                        value: _selectedWork ?? NatureOfWork.earthwork,
                        items: NatureOfWork.values,
                        labelMapper: (t) => t.displayName,
                        icon: Icons.work_rounded,
                        useGlass: true,
                        onChanged: (v) => setState(() => _selectedWork = v),
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
                      _sectionTitle('Status & Maintenance', Icons.settings_suggest_rounded),
                      const SizedBox(height: 24),
                      HelpfulDropdown<MachineStatus>(
                        label: 'Current Status',
                        value: _selectedStatus,
                        items: MachineStatus.values,
                        labelMapper: (t) => t.displayName,
                        icon: Icons.info_rounded,
                        useGlass: true,
                        onChanged: (v) => setState(() => _selectedStatus = v!),
                      ),
                      const SizedBox(height: 20),
                      _buildDatePickerRow('Last Maintenance', _lastMaintenance, () => _selectDate(context, true)),
                      const SizedBox(height: 20),
                      _buildDatePickerRow('Next Maintenance', _nextMaintenance, () => _selectDate(context, false), isOptional: true),
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

  Widget _buildDatePickerRow(String label, DateTime? date, VoidCallback onTap, {bool isOptional = false}) {
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
                    date != null ? DateFormat('MMM dd, yyyy').format(date) : (isOptional ? 'Set date' : 'Not set'),
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

      FeedbackHelper.showSuccess(
        context,
        widget.machine != null ? 'Machine updated successfully' : 'Machine registered successfully',
      );
      Navigator.pop(context, machine);
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
