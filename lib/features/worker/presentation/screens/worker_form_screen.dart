import 'package:flutter/material.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../app/ui/widgets/helpful_text_field.dart';
import '../../../../app/ui/widgets/helpful_dropdown.dart';
import '../../../../app/ui/widgets/confirm_dialog.dart';
import '../../../../app/utils/input_formatters.dart';
import '../../../../app/utils/feedback_helper.dart';
import 'worker_types.dart';

class WorkerFormScreen extends StatefulWidget {
  final Worker? initial;

  const WorkerFormScreen({super.key, this.initial});

  @override
  State<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends State<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.initial?.name ?? '',
  );
  late final TextEditingController _phoneCtrl = TextEditingController(
    text: widget.initial?.phone ?? '',
  );
  late final TextEditingController _rateCtrl = TextEditingController(
    text: (widget.initial?.rateAmount ?? 800).toString(),
  );

  String _skill = (kSkills.contains('Mason') ? 'Mason' : kSkills.first);
  WorkerShift _shift = WorkerShift.day;
  PayRateType _rateType = PayRateType.perDay;
  WorkerStatus _status = WorkerStatus.active;
  late List<String> _workTypes = [];

  @override
  void initState() {
    super.initState();
    final w = widget.initial;
    if (w != null) {
      _skill = w.skill;
      _shift = w.shift;
      _rateType = w.rateType;
      _status = w.status;
      _workTypes = List<String>.from(w.assignedWorkTypes);
    } else {
      _workTypes = [
        'Concrete Work',
        'Brick / Block Work',
      ].where(kWorkTypes.contains).toList();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _toggleWorkType(String wt) {
    setState(() {
      if (_workTypes.contains(wt)) {
        _workTypes.remove(wt);
      } else {
        _workTypes.add(wt);
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      FeedbackHelper.showWarning(
        context,
        'Please fill in all required fields correctly',
      );
      return;
    }
    
    if (_workTypes.isEmpty) {
      FeedbackHelper.showWarning(
        context,
        'Please select at least one work type for this worker',
      );
      return;
    }

    // Parse and validate rate amount
    final rateText = _rateCtrl.text.trim().replaceAll(RegExp(r'[^\d.]'), '');
    final rate = num.tryParse(rateText);
    if (rate == null || rate <= 0) {
      FeedbackHelper.showError(
        context,
        'Please enter a valid pay rate greater than zero',
      );
      return;
    }

    final isEdit = widget.initial != null;
    final id =
        widget.initial?.id ??
        'WK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final worker = Worker(
      id: id,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), ''),
      skill: _skill,
      shift: _shift,
      rateType: _rateType,
      rateAmount: rate,
      status: _status,
      assignedWorkTypes: List<String>.from(_workTypes),
    );

    FeedbackHelper.showSuccess(
      context,
      isEdit 
          ? '✓ ${worker.name}\'s profile has been updated successfully'
          : '✓ ${worker.name} has been added to your workforce',
    );
    Navigator.pop(context, worker);
  }

  Future<void> _handleBack() async {
    // Check if form has any data
    final hasData = _nameCtrl.text.trim().isNotEmpty ||
        _phoneCtrl.text.trim().isNotEmpty ||
        _rateCtrl.text.trim() != '800';

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
    final isEdit = widget.initial != null;

    return ProfessionalPage(
      title: isEdit ? 'Update Profile' : 'Register Workforce',
      children: [
        const ProfessionalSectionHeader(
          title: 'Core Identity',
          subtitle: 'Legal name, contact and primary skill',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  HelpfulTextField(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    icon: Icons.person_outline_rounded,
                    hintText: 'e.g., Ramesh Kumar',
                    tooltipMessage: 'Enter the worker\'s full legal name as per official documents',
                    helpText: 'First name and surname',
                    inputFormatters: [NameFormatter()],
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 20),
                  HelpfulTextField(
                    label: 'Phone Number',
                    controller: _phoneCtrl,
                    icon: Icons.phone_android_rounded,
                    hintText: 'e.g., 9876543210',
                    keyboardType: TextInputType.phone,
                    tooltipMessage: 'Primary contact number for work notifications and payments',
                    helpText: '10-digit mobile number',
                    inputFormatters: [PhoneNumberFormatter()],
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Phone number is required';
                      final digits = t.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 10) return 'Enter a valid 10-digit phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  HelpfulDropdown<String>(
                    label: 'Primary Skill',
                    value: _skill,
                    items: kSkills,
                    icon: Icons.engineering_rounded,
                    tooltipMessage: 'Main area of expertise and work specialization',
                    helpText: 'Select the worker\'s primary skill set',
                    onChanged: (v) => setState(() => _skill = v!),
                  ),
                ],
              ),
            ),
          ),
        ),
        const ProfessionalSectionHeader(
          title: 'Employment & Pay',
          subtitle: 'Operational shift and payout structure',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                HelpfulDropdown<WorkerShift>(
                  label: 'Assigned Shift',
                  value: _shift,
                  items: WorkerShift.values,
                  labelMapper: shiftLabel,
                  icon: Icons.access_time_rounded,
                  tooltipMessage: 'Work shift timing - affects scheduling and availability',
                  helpText: 'Day shift: 6 AM - 6 PM, Night shift: 6 PM - 6 AM',
                  onChanged: (v) => setState(() => _shift = v!),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: HelpfulDropdown<PayRateType>(
                        label: 'Rate Type',
                        value: _rateType,
                        items: PayRateType.values,
                        labelMapper: rateTypeLabel,
                        icon: Icons.payments_rounded,
                        tooltipMessage: 'Payment calculation basis',
                        helpText: 'How the worker will be compensated',
                        onChanged: (v) => setState(() => _rateType = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: HelpfulTextField(
                        label: 'Amount (₹)',
                        controller: _rateCtrl,
                        icon: Icons.currency_rupee_rounded,
                        hintText: '800',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        tooltipMessage: 'Pay rate amount in Indian Rupees',
                        helpText: 'Standard rate for this skill',
                        inputFormatters: [CurrencyFormatter()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                HelpfulDropdown<WorkerStatus>(
                  label: 'Current Status',
                  value: _status,
                  items: WorkerStatus.values,
                  labelMapper: statusLabel,
                  icon: Icons.toggle_on_rounded,
                  tooltipMessage: 'Worker availability status in the system',
                  helpText: 'Active workers can be assigned to tasks',
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ],
            ),
          ),
        ),
        const ProfessionalSectionHeader(
          title: 'Competencies',
          subtitle: 'Specific task categories authorized',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: kWorkTypes.map((wt) {
                final selected = _workTypes.contains(wt);
                return GestureDetector(
                  onTap: () => _toggleWorkType(wt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.deepBlue1 : AppColors.deepBlue1.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.deepBlue1 : AppColors.deepBlue1.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      wt,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : AppColors.deepBlue1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.close_rounded, size: 20, color: Colors.grey[700]),
                  label: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text(
                    'Save Record',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
