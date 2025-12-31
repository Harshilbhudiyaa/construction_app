import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
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

  void _toggleActive(Worker w) {
    final next = w.status == WorkerStatus.active
        ? WorkerStatus.inactive
        : WorkerStatus.active;
    setState(() {
      final idx = _items.indexWhere((x) => x.id == w.id);
      if (idx != -1) _items[idx] = _items[idx].copyWith(status: next);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Status updated: ${w.name} → ${statusLabel(next)} (UI-only)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Workers',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: AppColors.deepBlue1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Worker', style: TextStyle(color: Colors.white)),
      ),
      children: [
        AppSearchField(
          hint: 'Search name, skill, phone, id...',
          onChanged: (v) => setState(() => _q = v),
        ),

        const ProfessionalSectionHeader(
          title: 'Filters',
          subtitle: 'Shift, status, and skill selection',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      label: const Text('All Shifts'),
                      selected: _shift == null,
                      onSelected: (_) => setState(() => _shift = null),
                    ),
                    FilterChip(
                      label: const Text('Day'),
                      selected: _shift == WorkerShift.day,
                      onSelected: (_) =>
                          setState(() => _shift = WorkerShift.day),
                    ),
                    FilterChip(
                      label: const Text('Night'),
                      selected: _shift == WorkerShift.night,
                      onSelected: (_) =>
                          setState(() => _shift = WorkerShift.night),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      label: const Text('All Status'),
                      selected: _status == null,
                      onSelected: (_) => setState(() => _status = null),
                    ),
                    FilterChip(
                      label: const Text('Active'),
                      selected: _status == WorkerStatus.active,
                      onSelected: (_) =>
                          setState(() => _status = WorkerStatus.active),
                    ),
                    FilterChip(
                      label: const Text('Inactive'),
                      selected: _status == WorkerStatus.inactive,
                      onSelected: (_) =>
                          setState(() => _status = WorkerStatus.inactive),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: _skill,
                  decoration: const InputDecoration(
                    labelText: 'Skill (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Skills'),
                    ),
                    ...kSkills.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _skill = v),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _q = '';
                      _shift = null;
                      _status = null;
                      _skill = null;
                    }),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset Filters'),
                  ),
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Staff Directory',
          subtitle: 'Manage active workforce',
        ),

        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: EmptyState(
              icon: Icons.groups_rounded,
              title: 'No workers found',
              message: 'Try changing filters or search.',
            ),
          )
        else
          ..._filtered.asMap().entries.map((entry) {
            final index = entry.key;
            final w = entry.value;
            return StaggeredAnimation(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ProfessionalCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.deepBlue1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.deepBlue1,
                      ),
                    ),
                    title: Text(
                      w.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepBlue1,
                      ),
                    ),
                    subtitle: Text(
                      '${w.skill} • ${shiftLabel(w.shift)}\nRate: ₹${w.rateAmount} (${rateTypeLabel(w.rateType)})',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _edit(w);
                        if (v == 'toggle') _toggleActive(w);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                            w.status == WorkerStatus.active
                                ? 'Deactivate'
                                : 'Activate',
                          ),
                        ),
                      ],
                      child: StatusChip(
                        status: _toUi(w.status),
                        labelOverride: statusLabel(w.status),
                      ),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkerDetailScreen(worker: w),
                        ),
                      );
                    },
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

