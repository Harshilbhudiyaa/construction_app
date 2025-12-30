import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/section_header.dart';
import 'worker_types.dart';

class WorkerFormScreen extends StatefulWidget {
  final Worker? initial;

  const WorkerFormScreen({super.key, this.initial});

  @override
  State<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends State<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController _phoneCtrl =
      TextEditingController(text: widget.initial?.phone ?? '');
  late final TextEditingController _rateCtrl =
      TextEditingController(text: (widget.initial?.rateAmount ?? 800).toString());

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
      _workTypes = ['Concrete Work', 'Brick / Block Work'].where(kWorkTypes.contains).toList();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid rate amount')),
      );
      return;
    }

    final isEdit = widget.initial != null;
    final id = widget.initial?.id ?? 'WK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

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
      SnackBar(content: Text(isEdit ? 'Worker updated (UI-only)' : 'Worker added (UI-only)')),
    );
    Navigator.pop(context, worker);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Worker' : 'Add Worker')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          const SectionHeader(title: 'Basic Info', subtitle: 'Name, phone, skill, shift'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone (10 digits)'),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Required';
                          final digits = t.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 10) return 'Enter valid phone';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _skill,
                        decoration: const InputDecoration(labelText: 'Skill'),
                        items: kSkills.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _skill = v ?? _skill),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<WorkerShift>(
                        value: _shift,
                        decoration: const InputDecoration(labelText: 'Shift'),
                        items: WorkerShift.values
                            .map((s) => DropdownMenuItem(value: s, child: Text(shiftLabel(s))))
                            .toList(),
                        onChanged: (v) => setState(() => _shift = v ?? _shift),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<WorkerStatus>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: WorkerStatus.values
                            .map((s) => DropdownMenuItem(value: s, child: Text(statusLabel(s))))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v ?? _status),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Rate', subtitle: 'Payment type and amount'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    DropdownButtonFormField<PayRateType>(
                      value: _rateType,
                      decoration: const InputDecoration(labelText: 'Rate Type'),
                      items: PayRateType.values
                          .map((t) => DropdownMenuItem(value: t, child: Text(rateTypeLabel(t))))
                          .toList(),
                      onChanged: (v) => setState(() => _rateType = v ?? _rateType),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _rateCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Rate Amount'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Work Types', subtitle: 'Assign allowed work types'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: kWorkTypes.map((wt) {
                    final selected = _workTypes.contains(wt);
                    return FilterChip(
                      label: Text(wt),
                      selected: selected,
                      onSelected: (_) => _toggleWorkType(wt),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
