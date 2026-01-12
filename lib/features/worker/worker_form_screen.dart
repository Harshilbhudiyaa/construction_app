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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ProfessionalCard(
                useGlass: true,
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Core Identity', Icons.person_search_rounded),
                      const SizedBox(height: 24),
                      HelpfulTextField(
                        label: 'Full Name',
                        controller: _nameCtrl,
                        icon: Icons.person_rounded,
                        useGlass: true,
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
                        useGlass: true,
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
                        useGlass: true,
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
              const SizedBox(height: 12),
              ProfessionalCard(
                useGlass: true,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Employment & Pay', Icons.payments_rounded),
                    const SizedBox(height: 24),
                    HelpfulDropdown<WorkerShift>(
                      label: 'Assigned Shift',
                      value: _shift,
                      useGlass: true,
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
                            useGlass: true,
                            items: PayRateType.values,
                            labelMapper: rateTypeLabel,
                            icon: Icons.speed_rounded,
                            tooltipMessage: 'Payment calculation basis',
                            helpText: 'How compensation is calculated',
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
                            useGlass: true,
                            hintText: '800',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            tooltipMessage: 'Pay rate amount in Indian Rupees',
                            helpText: 'Standard rate',
                            inputFormatters: [CurrencyFormatter()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    HelpfulDropdown<WorkerStatus>(
                      label: 'System Status',
                      value: _status,
                      useGlass: true,
                      items: WorkerStatus.values,
                      labelMapper: statusLabel,
                      icon: Icons.verified_user_rounded,
                      tooltipMessage: 'Current availability in the system',
                      onChanged: (v) => setState(() => _status = v!),
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
                    _sectionTitle('Competencies', Icons.fact_check_rounded),
                    const SizedBox(height: 8),
                    Text(
                      'Select assigned task categories for this worker',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: kWorkTypes.map((wt) {
                        final selected = _workTypes.contains(wt);
                        return GestureDetector(
                          onTap: () => _toggleWorkType(wt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? Colors.white : Colors.white.withOpacity(0.1),
                                width: 1.5,
                              ),
                              boxShadow: selected ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  selected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                  size: 16,
                                  color: selected ? AppColors.deepBlue1 : Colors.white70,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  wt,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: selected ? AppColors.deepBlue1 : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Discard',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          isEdit ? 'Update Details' : 'Finalize Registration',
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

}
