import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/helpful_text_field.dart';
import '../../app/ui/widgets/helpful_dropdown.dart';
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
                const ProfessionalSectionHeader(
                  title: 'Basic Information',
                  subtitle: 'Identify and categorize the machinery',
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _nameController,
                  label: 'Machine Name',
                  hintText: 'e.g. Caterpillar 320D',
                  icon: Icons.precision_manufacturing_rounded,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulDropdown<MachineType>(
                  label: 'Machine Type',
                  value: _selectedType,
                  items: MachineType.values,
                  labelMapper: (t) => t.displayName,
                  icon: Icons.category_rounded,
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                const SizedBox(height: AppSpacing.lg),
                const ProfessionalSectionHeader(
                  title: 'Deployment Details',
                  subtitle: 'Where and who is using the machine',
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _siteNameController,
                  label: 'Assigned Site',
                  hintText: 'Enter site name',
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulTextField(
                  controller: _operatorNameController,
                  label: 'Operator Name',
                  hintText: 'Assigned personnel',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulDropdown<NatureOfWork>(
                  label: 'Nature of Work',
                  value: _selectedWork ?? NatureOfWork.earthwork,
                  items: NatureOfWork.values,
                  labelMapper: (t) => t.displayName,
                  icon: Icons.work_rounded,
                  onChanged: (v) => setState(() => _selectedWork = v),
                ),
                const SizedBox(height: AppSpacing.lg),
                const ProfessionalSectionHeader(
                  title: 'Status & Maintenance',
                  subtitle: 'Current condition and service record',
                ),
                const SizedBox(height: AppSpacing.md),
                HelpfulDropdown<MachineStatus>(
                  label: 'Current Status',
                  value: _selectedStatus,
                  items: MachineStatus.values,
                  labelMapper: (t) => t.displayName,
                  icon: Icons.info_rounded,
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildDatePickerRow('Last Maintenance', _lastMaintenance, () => _selectDate(context, true)),
                const SizedBox(height: AppSpacing.md),
                _buildDatePickerRow('Next Maintenance', _nextMaintenance, () => _selectDate(context, false), isOptional: true),
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
                        onPressed: _saveMachine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.deepBlue1,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isEditing ? 'Update Machine' : 'Register Machine'),
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
}
