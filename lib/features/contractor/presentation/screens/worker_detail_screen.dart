import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import 'worker_form_screen.dart';
import 'worker_types.dart';

class WorkerDetailScreen extends StatefulWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  late Worker _w = widget.worker;

  UiStatus _statusToUi(WorkerStatus s) => s == WorkerStatus.active ? UiStatus.ok : UiStatus.pending;

  Future<void> _edit() async {
    final updated = await Navigator.push<Worker?>(
      context,
      MaterialPageRoute(builder: (_) => WorkerFormScreen(initial: _w)),
    );
    if (updated != null) {
      setState(() => _w = updated);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker updated (UI-only)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Worker Details'),
          actions: [
            IconButton(onPressed: _edit, icon: const Icon(Icons.edit_rounded)),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Work Types'),
              Tab(text: 'Payments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Profile
            ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: Icon(Icons.person_rounded, color: cs.onPrimaryContainer),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_w.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                                const SizedBox(height: 2),
                                Text('${_w.skill} • ${shiftLabel(_w.shift)} shift', style: TextStyle(color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          StatusChip(status: _statusToUi(_w.status), labelOverride: statusLabel(_w.status)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SectionHeader(title: 'Details', subtitle: 'Contact and rate'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _kv('Worker ID', _w.id),
                          _kv('Phone', _w.phone),
                          _kv('Skill', _w.skill),
                          _kv('Shift', shiftLabel(_w.shift)),
                          _kv('Rate Type', rateTypeLabel(_w.rateType)),
                          _kv('Rate', '₹${_w.rateAmount}'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

            // Work Types
            ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                const SectionHeader(title: 'Assigned Work Types', subtitle: 'Worker can only do these'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _w.assignedWorkTypes.map((wt) => Chip(label: Text(wt))).toList(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Card(
                    child: ListTile(
                      leading: Icon(Icons.security_rounded, color: cs.primary),
                      title: const Text('Rule', style: TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: const Text('Worker cannot start unassigned work types.'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

            // Payments summary (UI-only)
            ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                const SectionHeader(title: 'Payments Summary', subtitle: 'UI-only demo'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _kv('Earned (This Week)', '₹2,450'),
                          _kv('Paid', '₹1,800'),
                          _kv('Pending', '₹650'),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Open payment history (next step)')),
                              ),
                              icon: const Icon(Icons.receipt_long_rounded),
                              label: const Text('View History'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(fontWeight: FontWeight.w800))),
          Flexible(child: Text(v, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
