import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../app/ui/widgets/confirm_dialog.dart';
import '../../../../app/ui/widgets/info_tooltip.dart';
import '../../../../app/utils/feedback_helper.dart';
import 'worker_detail_screen.dart';
import 'worker_form_screen.dart';
import 'worker_types.dart';

class WorkersListScreen extends StatefulWidget {
  const WorkersListScreen({super.key});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  String _q = '';
  WorkerShift? _shift;
  WorkerStatus? _status;
  String? _skill;

  final List<Worker> _items = [
    Worker(
      id: 'WK-1001',
      name: 'Ramesh Kumar',
      phone: '9876543210',
      skill: 'Mason',
      shift: WorkerShift.day,
      rateType: PayRateType.perDay,
      rateAmount: 900,
      status: WorkerStatus.active,
      assignedWorkTypes: const ['Concrete Work', 'Brick / Block Work'],
    ),
    Worker(
      id: 'WK-1002',
      name: 'Suresh Patel',
      phone: '9988776655',
      skill: 'Helper',
      shift: WorkerShift.day,
      rateType: PayRateType.perDay,
      rateAmount: 650,
      status: WorkerStatus.active,
      assignedWorkTypes: const ['General Labor', 'Brick / Block Work'],
    ),
    Worker(
      id: 'WK-1003',
      name: 'Vikram Singh',
      phone: '9123456780',
      skill: 'Electrician',
      shift: WorkerShift.night,
      rateType: PayRateType.perHour,
      rateAmount: 120,
      status: WorkerStatus.inactive,
      assignedWorkTypes: const ['Electrical'],
    ),
  ];

  List<Worker> get _filtered {
    final q = _q.trim().toLowerCase();
    return _items.where((w) {
      if (_shift != null && w.shift != _shift) return false;
      if (_status != null && w.status != _status) return false;
      if (_skill != null && w.skill != _skill) return false;
      if (q.isEmpty) return true;
      final hay =
          '${w.id} ${w.name} ${w.phone} ${w.skill} ${shiftLabel(w.shift)} ${statusLabel(w.status)} ${w.assignedWorkTypes.join(' ')}'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  UiStatus _toUi(WorkerStatus s) =>
      s == WorkerStatus.active ? UiStatus.ok : UiStatus.pending;

  Future<void> _add() async {
    final created = await Navigator.push<Worker?>(
      context,
      MaterialPageRoute(builder: (_) => const WorkerFormScreen()),
    );
    if (created != null) {
      setState(() => _items.insert(0, created));
    }
  }

  Future<void> _edit(Worker w) async {
    final updated = await Navigator.push<Worker?>(
      context,
      MaterialPageRoute(builder: (_) => WorkerFormScreen(initial: w)),
    );
    if (updated != null) {
      setState(() {
        final idx = _items.indexWhere((x) => x.id == updated.id);
        if (idx != -1) _items[idx] = updated;
      });
    }
  }

  Future<void> _toggleActive(Worker w) async {
    final next = w.status == WorkerStatus.active
        ? WorkerStatus.inactive
        : WorkerStatus.active;
    
    final action = next == WorkerStatus.active ? 'activate' : 'deactivate';
    
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: '${action == 'activate' ? 'Activate' : 'Deactivate'} Worker?',
      message: 'Are you sure you want to $action ${w.name}? ${next == WorkerStatus.inactive ? 'They will not be available for new work assignments.' : 'They will be available for work assignments.'}',
      confirmText: action == 'activate' ? 'Activate' : 'Deactivate',
      icon: next == WorkerStatus.active ? Icons.check_circle_outline : Icons.cancel_outlined,
      iconColor: next == WorkerStatus.active ? Colors.green : Colors.orange,
      isDangerous: next == WorkerStatus.inactive,
    );

    if (!confirmed) return;

    setState(() {
      final idx = _items.indexWhere((x) => x.id == w.id);
      if (idx != -1) _items[idx] = _items[idx].copyWith(status: next);
    });
    
    FeedbackHelper.showSuccess(
      context,
      '✓ ${w.name} has been ${next == WorkerStatus.active ? 'activated' : 'deactivated'} successfully',
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(
        currentShift: _shift,
        currentStatus: _status,
        currentSkill: _skill,
        onApply: (shift, status, skill) {
          setState(() {
            _shift = shift;
            _status = status;
            _skill = skill;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _items.where((w) => w.status == WorkerStatus.active).length;
    final dayCount = _items.where((w) => w.shift == WorkerShift.day).length;
    final nightCount = _items.where((w) => w.shift == WorkerShift.night).length;

    return ProfessionalPage(
      title: 'Workforce',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: AppColors.deepBlue1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Worker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      children: [
        // Workforce Summary Header
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _SummaryTile(label: 'Total', value: '${_items.length}', color: Colors.blue),
              _SummaryTile(label: 'Active', value: '$activeCount', color: Colors.green),
              _SummaryTile(label: 'Day', value: '$dayCount', color: Colors.orange),
              _SummaryTile(label: 'Night', value: '$nightCount', color: Colors.indigo),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: AppSearchField(
                  hint: 'Search name, skill...',
                  onChanged: (v) => setState(() => _q = v),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _showFilters,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Badge(
                      isLabelVisible: _shift != null || _status != null || _skill != null,
                      child: Icon(Icons.tune_rounded, color: AppColors.deepBlue1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Directory',
          subtitle: 'Active and archived workforce records',
        ),

        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: EmptyState(
              icon: Icons.groups_rounded,
              title: 'No workers found',
              message: 'Try changing filters or search terms.',
            ),
          )
        else
          ..._filtered.asMap().entries.map((entry) {
            final index = entry.key;
            final w = entry.value;
            return StaggeredAnimation(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ProfessionalCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkerDetailScreen(worker: w),
                        ),
                      );
                    },
                    leading: Hero(
                      tag: 'worker_icon_${w.id}',
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.deepBlue1.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.deepBlue1,
                          size: 26,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            w.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.deepBlue1,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _SkillBadge(skill: w.skill),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${shiftLabel(w.shift)} Shift • Rate: ₹${w.rateAmount}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            StatusChip(
                              status: _toUi(w.status),
                              labelOverride: statusLabel(w.status),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => launchUrl(Uri.parse('tel:${w.phone}')),
                              icon: const Icon(Icons.phone_rounded, color: Colors.green, size: 20),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              tooltip: 'Call Worker',
                            ),
                            const SizedBox(width: 8),
                            Switch.adaptive(
                              value: w.status == WorkerStatus.active,
                              onChanged: (_) => _toggleActive(w),
                              activeColor: Colors.green,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            );
          }),

        const SizedBox(height: 100),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillBadge extends StatelessWidget {
  final String skill;

  const _SkillBadge({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.deepBlue1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        skill.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.deepBlue1,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final WorkerShift? currentShift;
  final WorkerStatus? currentStatus;
  final String? currentSkill;
  final Function(WorkerShift?, WorkerStatus?, String?) onApply;

  const _FilterSheet({
    this.currentShift,
    this.currentStatus,
    this.currentSkill,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late WorkerShift? _shift = widget.currentShift;
  late WorkerStatus? _status = widget.currentStatus;
  late String? _skill = widget.currentSkill;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Workforce',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepBlue1,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Shift Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _chip('All', _shift == null, () => setState(() => _shift = null)),
              _chip('Day', _shift == WorkerShift.day, () => setState(() => _shift = WorkerShift.day)),
              _chip('Night', _shift == WorkerShift.night, () => setState(() => _shift = WorkerShift.night)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Work Status', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _chip('All', _status == null, () => setState(() => _status = null)),
              _chip('Active', _status == WorkerStatus.active, () => setState(() => _status = WorkerStatus.active)),
              _chip('Inactive', _status == WorkerStatus.inactive, () => setState(() => _status = WorkerStatus.inactive)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Expertise / Skill', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: _skill,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Skills')),
              ...kSkills.map((s) => DropdownMenuItem(value: s, child: Text(s))),
            ],
            onChanged: (v) => setState(() => _skill = v),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _shift = null;
                      _status = null;
                      _skill = null;
                    });
                  },
                  child: const Text('Reset All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_shift, _status, _skill);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.deepBlue1.withOpacity(0.1),
      labelStyle: TextStyle(
        color: selected ? AppColors.deepBlue1 : Colors.grey[600],
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
