import 'package:flutter/material.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';
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
    if (!_formKey.currentState!.validate()) return;
    if (_workTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 1 work type')),
      );
      return;
    }

    final rate = num.tryParse(_rateCtrl.text.trim());
    if (rate == null || rate <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter valid rate amount')));
      return;
    }

    final isEdit = widget.initial != null;
    final id =
        widget.initial?.id ??
        'WK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final worker = Worker(
      id: id,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      skill: _skill,
      shift: _shift,
      rateType: _rateType,
      rateAmount: rate,
      status: _status,
      assignedWorkTypes: List<String>.from(_workTypes),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEdit ? 'Worker updated successfully' : 'Worker added to directory',
        ),
      ),
    );
    Navigator.pop(context, worker);
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
                  _buildField(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    icon: Icons.person_outline_rounded,
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    label: 'Phone Number',
                    controller: _phoneCtrl,
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Required';
                      final digits = t.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 10) return 'Valid phone required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown<String>(
                    label: 'Primary Skill',
                    value: _skill,
                    items: kSkills,
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
                _buildDropdown<WorkerShift>(
                  label: 'Assigned Shift',
                  value: _shift,
                  items: WorkerShift.values,
                  labelMapper: shiftLabel,
                  onChanged: (v) => setState(() => _shift = v!),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildDropdown<PayRateType>(
                        label: 'Rate Type',
                        value: _rateType,
                        items: PayRateType.values,
                        labelMapper: rateTypeLabel,
                        onChanged: (v) => setState(() => _rateType = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _buildField(
                        label: 'Amount (₹)',
                        controller: _rateCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDropdown<WorkerStatus>(
                  label: 'Current Status',
                  value: _status,
                  items: WorkerStatus.values,
                  labelMapper: statusLabel,
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
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Discard',
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.deepBlue1) : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.deepBlue1, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    String Function(T)? labelMapper,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem<T>(
            value: e,
            child: Text(labelMapper?.call(e) ?? e.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          )).toList(),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.deepBlue1, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
