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
import '../../../../app/ui/widgets/helpful_dropdown.dart';
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
      title: 'Workforce Hub',
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, AppColors.deepBlue1],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _add,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Add Worker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      children: [
        // Workforce Summary Header
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              _SummaryTile(label: 'Total Force', value: '${_items.length}', icon: Icons.groups_rounded, color: Colors.blueAccent),
              _SummaryTile(label: 'On Duty', value: '$activeCount', icon: Icons.check_circle_rounded, color: Colors.greenAccent),
              _SummaryTile(label: 'Day Shift', value: '$dayCount', icon: Icons.wb_sunny_rounded, color: Colors.orangeAccent),
              _SummaryTile(label: 'Night Shift', value: '$nightCount', icon: Icons.nightlight_round, color: Colors.indigoAccent),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Expanded(
                child: AppSearchField(
                  hint: 'Search name, skill...',
                  onChanged: (v) => setState(() => _q = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: IconButton(
                    onPressed: _showFilters,
                    icon: Badge(
                      isLabelVisible: _shift != null || _status != null || _skill != null,
                      backgroundColor: Colors.blueAccent,
                      child: const Icon(Icons.tune_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Staff Directory',
          subtitle: 'Comprehensive list of project workforce',
        ),

        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 40),
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
                  useGlass: true,
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkerDetailScreen(worker: w),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'worker_icon_${w.id}',
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        w.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontSize: 17,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                    _SkillBadge(skill: w.skill),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'ID: ${w.id} • ${shiftLabel(w.shift)} SHIFT',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    StatusChip(
                                      status: _toUi(w.status),
                                      labelOverride: statusLabel(w.status).toUpperCase(),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () => launchUrl(Uri.parse('tel:${w.phone}')),
                                        icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.greenAccent, size: 18),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        tooltip: 'Call Worker',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Switch.adaptive(
                                      value: w.status == WorkerStatus.active,
                                      onChanged: (_) => _toggleActive(w),
                                      activeColor: Colors.greenAccent,
                                      activeTrackColor: Colors.greenAccent.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 0.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        skill.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.deepBlue1.withOpacity(0.95),
            AppColors.deepBlue2.withOpacity(0.95),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Refine Search',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const _FilterLabel(label: 'SHIFT ASSIGNMENT'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              _filterChip('All', _shift == null, () => setState(() => _shift = null)),
              _filterChip('Day', _shift == WorkerShift.day, () => setState(() => _shift = WorkerShift.day)),
              _filterChip('Night', _shift == WorkerShift.night, () => setState(() => _shift = WorkerShift.night)),
            ],
          ),
          const SizedBox(height: 32),
          const _FilterLabel(label: 'WORK STATUS'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              _filterChip('All', _status == null, () => setState(() => _status = null)),
              _filterChip('Active', _status == WorkerStatus.active, () => setState(() => _status = WorkerStatus.active)),
              _filterChip('Inactive', _status == WorkerStatus.inactive, () => setState(() => _status = WorkerStatus.inactive)),
            ],
          ),
          const SizedBox(height: 32),
          const _FilterLabel(label: 'EXPERTISE / SKILL'),
          const SizedBox(height: 12),
          HelpfulDropdown<String?>(
            label: 'EXPERTISE / SKILL',
            value: _skill,
            useGlass: true,
            items: [null, ...kSkills],
            labelMapper: (s) => s ?? 'All Expertise',
            onChanged: (v) => setState(() => _skill = v),
          ),
          const SizedBox(height: 40),
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
                  child: Text(
                    'Reset All',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
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
                    onPressed: () {
                      widget.onApply(_shift, _status, _skill);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Apply Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.05),
        labelStyle: TextStyle(
          color: selected ? AppColors.deepBlue1 : Colors.white70,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: selected ? Colors.white : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        elevation: selected ? 4 : 0,
        pressElevation: 8,
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String label;
  const _FilterLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Colors.white.withOpacity(0.5),
        letterSpacing: 1.2,
      ),
    );
  }
}

