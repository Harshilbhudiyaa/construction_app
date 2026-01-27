import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/confirm_dialog.dart';
import 'package:construction_app/utils/feedback_helper.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/services/mock_worker_service.dart';
import 'package:construction_app/profiles/worker_detail_screen.dart';
import 'package:construction_app/profiles/worker_form_screen.dart';
import 'package:construction_app/profiles/worker_types.dart';

class WorkersListScreen extends StatefulWidget {
  final String? activeSiteId;
  const WorkersListScreen({super.key, this.activeSiteId});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  String _q = '';
  WorkerShift? _shiftFilter;
  WorkerStatus? _statusFilter;
  String? _skillFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer<MockWorkerService>(
      builder: (context, service, child) {
        final allItems = service.workers;
        final filteredItems = allItems.where((w) {
          if (widget.activeSiteId != null && w.siteId != widget.activeSiteId) return false;
          if (_shiftFilter != null && w.shift != _shiftFilter) return false;
          if (_statusFilter != null && w.status != _statusFilter) return false;
          if (_skillFilter != null && w.skill != _skillFilter) return false;
          
          final q = _q.trim().toLowerCase();
          if (q.isEmpty) return true;
          
          final hay = '${w.id} ${w.name} ${w.phone} ${w.skill}'.toLowerCase();
          return hay.contains(q);
        }).toList();

        final activeCount = allItems.where((w) => w.status == WorkerStatus.active).length;
        final dayCount = allItems.where((w) => w.shift == WorkerShift.day).length;
        final nightCount = allItems.where((w) => w.shift == WorkerShift.night).length;

        return ProfessionalPage(
          title: 'Workforce Hub',
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _addWorker(context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Add Worker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          children: [
            // 1. Stats Summary
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  _SummaryTile(label: 'Total Force', value: '${allItems.length}', icon: Icons.groups_rounded, color: Colors.blueAccent),
                  _SummaryTile(label: 'On Duty', value: '$activeCount', icon: Icons.check_circle_rounded, color: Colors.greenAccent),
                  _SummaryTile(label: 'Day Shift', value: '$dayCount', icon: Icons.wb_sunny_rounded, color: Colors.orangeAccent),
                  _SummaryTile(label: 'Night Shift', value: '$nightCount', icon: Icons.nightlight_round, color: Colors.indigoAccent),
                ],
              ),
            ),

            // 2. Search & Quick Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  AppSearchField(
                    hint: 'Search by name, ID, or skill...',
                    onChanged: (v) => setState(() => _q = v),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickFilters(),
                ],
              ),
            ),

            const ProfessionalSectionHeader(
              title: 'Staff Directory',
              subtitle: 'Comprehensive list of project workforce',
            ),

            // 3. Worker List
            if (filteredItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: EmptyState(
                  icon: Icons.groups_rounded,
                  title: 'No workers found',
                  message: 'Try adjusting filters or adding a new worker.',
                ),
              )
            else
              ...filteredItems.asMap().entries.map((entry) {
                final index = entry.key;
                final worker = entry.value;
                return StaggeredAnimation(
                  index: index,
                  child: _WorkerCard(worker: worker),
                );
              }),
            
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChip(
            label: 'All Workers',
            selected: _statusFilter == null && _shiftFilter == null,
            onSelected: () {
              setState(() {
                _statusFilter = null;
                _shiftFilter = null;
              });
            },
          ),
          const SizedBox(width: 8),
          VerticalDivider(width: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), indent: 10, endIndent: 10),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Active',
            selected: _statusFilter == WorkerStatus.active,
            onSelected: () => setState(() => _statusFilter = WorkerStatus.active),
          ),
          _FilterChip(
            label: 'Inactive',
            selected: _statusFilter == WorkerStatus.inactive,
            onSelected: () => setState(() => _statusFilter = WorkerStatus.inactive),
          ),
          const SizedBox(width: 8),
          VerticalDivider(width: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), indent: 10, endIndent: 10),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Day Shift',
            selected: _shiftFilter == WorkerShift.day,
            onSelected: () => setState(() => _shiftFilter = WorkerShift.day),
          ),
          _FilterChip(
            label: 'Night Shift',
            selected: _shiftFilter == WorkerShift.night,
            onSelected: () => setState(() => _shiftFilter = WorkerShift.night),
          ),
        ],
      ),
    );
  }

  Future<void> _addWorker(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkerFormScreen(currentSiteId: widget.activeSiteId)),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final Worker worker;

  const _WorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockWorkerService>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ProfessionalCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WorkerDetailScreen(workerId: worker.id)),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    image: worker.photoUrl != null
                        ? DecorationImage(
                            image: worker.photoUrl!.startsWith('http')
                                ? NetworkImage(worker.photoUrl!) as ImageProvider
                                : FileImage(File(worker.photoUrl!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: worker.photoUrl == null
                      ? Center(
                          child: Text(
                            worker.name[0],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              worker.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                          _SkillLabel(skill: worker.skill),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${worker.id} • ${shiftLabel(worker.shift)} SHIFT',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          StatusChip(
                            status: worker.status == WorkerStatus.active ? UiStatus.ok : UiStatus.pending,
                            labelOverride: statusLabel(worker.status).toUpperCase(),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => launchUrl(Uri.parse('tel:${worker.phone}')),
                            icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.green, size: 18),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch.adaptive(
                            value: worker.status == WorkerStatus.active,
                            onChanged: (_) => service.toggleStatus(worker.id),
                            activeColor: Colors.greenAccent,
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
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

class _SkillLabel extends StatelessWidget {
  final String skill;
  const _SkillLabel({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
      child: Text(
        skill.toUpperCase(),
        style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
