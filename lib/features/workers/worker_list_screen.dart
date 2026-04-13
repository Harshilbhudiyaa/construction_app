import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/worker_model.dart';
import 'package:construction_app/data/repositories/worker_repository.dart' show WorkerRepository, daysInMonth;
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/features/workers/worker_history_screen.dart';
import 'package:construction_app/features/workers/worker_profile_screen.dart';

class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final workerRepo = context.watch<WorkerRepository>();
    final siteRepo   = context.watch<SiteRepository>();
    final siteId     = siteRepo.selectedSiteId;
    final now        = DateTime.now();
    final fmt        = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final workers = (siteId != null ? workerRepo.getWorkersForSite(siteId) : workerRepo.workers)
        .where((w) => _search.isEmpty || w.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    final totalDue = workers.fold(0.0, (s, w) => s + workerRepo.getSalaryDue(w.id, now.year, now.month));

    return Scaffold(
      backgroundColor: bcSurface,
      appBar: AppBar(
        backgroundColor: bcNavy,
        foregroundColor: Colors.white,
        title: const Text('Workers', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        actions: [
          // Attendance button
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.fact_check_rounded, color: bcAmber),
              tooltip: 'Mark Attendance',
              onPressed: () => _showAttendanceSheet(context, siteId, workers),
            ),
          ),
          if (totalDue > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: bcInfo.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('Due: ${fmt.format(totalDue)}', style: const TextStyle(color: bcInfo, fontWeight: FontWeight.w800, fontSize: 11)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: _SearchBar(onChanged: (v) => setState(() => _search = v)),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => workerRepo.refresh(),
              color: bcAmber,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                children: [
                  const SizedBox(height: 12),
                  _DashboardHeader(siteId: siteId),
                  const SizedBox(height: 20),
                  
                  // Occupation chips (quick filter row)
                  _OccupationChipRow(workers: workers),
                  const SizedBox(height: 12),

                  if (workerRepo.isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: bcAmber),
                    ))
                  else if (workers.isEmpty)
                    _emptyState(context)
                  else
                    ...workers.map((w) {
                      final salaryDue = workerRepo.getSalaryDue(w.id, now.year, now.month);
                      final advance   = workerRepo.getTotalAdvancePaid(w.id);
                      return _WorkerCard(
                        worker: w,
                        salaryDue: salaryDue,
                        advancePaid: advance,
                        fmt: fmt,
                        onTap: () => _showWorkerDetail(context, w),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWorkerSheet(context, siteId),
        backgroundColor: bcAmber,
        foregroundColor: bcNavy,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Worker', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.engineering_outlined, size: 62, color: Color(0xFFCBD5E1)),
      const SizedBox(height: 14),
      const Text('No workers on site', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 6),
      const Text('Add workers to start tracking attendance & salary', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
    ]),
  );

  void _showAddWorkerSheet(BuildContext context, String? siteId) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => WorkerFormSheet(siteId: siteId ?? context.read<SiteRepository>().selectedSiteId ?? 'S-001'),
    );
  }

  void _showWorkerDetail(BuildContext context, WorkerModel worker) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkerProfileScreen(worker: worker)),
    );
  }

  void _showAttendanceSheet(BuildContext context, String? siteId, List<WorkerModel> workers) {
    if (workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No workers to mark attendance for')));
      return;
    }
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _DailyAttendanceSheet(workers: workers),
    );
  }
}

// ─── Worker Card ──────────────────────────────────────────────────────────────

class _WorkerCard extends StatelessWidget {
  final WorkerModel worker;
  final double salaryDue;
  final double advancePaid;
  final NumberFormat fmt;
  final VoidCallback onTap;

  const _WorkerCard({
    required this.worker,
    required this.salaryDue,
    required this.advancePaid,
    required this.fmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final occColor = _occColor(worker.occupation);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: bcNavy.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'worker_pfp_${worker.id}',
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [occColor.withValues(alpha: 0.15), occColor.withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        worker.name[0].toUpperCase(),
                        style: TextStyle(color: occColor, fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(worker.name, 
                              style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.2)),
                          ),
                          _RecentActivityTracker(workerId: worker.id),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: occColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              worker.occupation == WorkerOccupation.other
                                  ? (worker.customOccupation?.isNotEmpty == true ? worker.customOccupation! : 'Other')
                                  : worker.occupation.displayName,
                              style: TextStyle(color: occColor, fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            worker.salaryType == SalaryType.daily
                                ? '₹${worker.salaryAmount.toStringAsFixed(0)}/d'
                                : '₹${fmt.format(worker.salaryAmount)}/m',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(fmt.format(salaryDue), 
                      style: TextStyle(color: salaryDue > 0 ? bcSuccess : bcNavy, fontWeight: FontWeight.w900, fontSize: 15)),
                    const Text('NET DUE', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _occColor(WorkerOccupation o) {
    switch (o) {
      case WorkerOccupation.mason:       return const Color(0xFFF59E0B);
      case WorkerOccupation.electrician: return const Color(0xFF60A5FA);
      case WorkerOccupation.carpenter:   return const Color(0xFF34D399);
      case WorkerOccupation.engineer:    return const Color(0xFFA78BFA);
      case WorkerOccupation.supervisor:  return bcAmber;
      case WorkerOccupation.plumber:     return const Color(0xFF0EA5E9);
      case WorkerOccupation.painter:     return const Color(0xFFFB7185);
      default:                           return const Color(0xFF94A3B8);
    }
  }
}

// ─── Occupation Chip Row ──────────────────────────────────────────────────────

class _OccupationChipRow extends StatefulWidget {
  final List<WorkerModel> workers;
  const _OccupationChipRow({required this.workers});

  @override
  State<_OccupationChipRow> createState() => _OccupationChipRowState();
}

class _OccupationChipRowState extends State<_OccupationChipRow> {
  final Map<String, int> _counts = {};

  @override
  void didUpdateWidget(covariant _OccupationChipRow old) {
    super.didUpdateWidget(old);
    _rebuild();
  }

  @override
  void initState() { super.initState(); _rebuild(); }

  void _rebuild() {
    _counts.clear();
    for (final w in widget.workers) {
      final name = w.occupation == WorkerOccupation.other
          ? (w.customOccupation?.isNotEmpty == true ? w.customOccupation! : 'Other')
          : w.occupation.displayName;
      _counts[name] = (_counts[name] ?? 0) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_counts.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 40,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _counts.entries.map((e) => Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Text(e.key, style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700, fontSize: 11)),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: bcNavy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(5)),
              child: Text('${e.value}', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 10)),
            ),
          ]),
        )).toList(),
      ),
    );
  }
}

// ─── Worker Form Sheet ────────────────────────────────────────────────────────

class WorkerFormSheet extends StatefulWidget {
  final String siteId;
  final WorkerModel? existing;
  const WorkerFormSheet({super.key, required this.siteId, this.existing});

  @override
  State<WorkerFormSheet> createState() => _WorkerFormSheetState();
}

class _WorkerFormSheetState extends State<WorkerFormSheet> {
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _customOccupationCtrl = TextEditingController();
  WorkerOccupation _occupation = WorkerOccupation.helper;
  SalaryType _salaryType = SalaryType.daily;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final w = widget.existing!;
      _nameCtrl.text   = w.name;
      _phoneCtrl.text  = w.phone ?? '';
      _salaryCtrl.text = w.salaryAmount.toStringAsFixed(0);
      _customOccupationCtrl.text = w.customOccupation ?? '';
      _occupation  = w.occupation;
      _salaryType  = w.salaryType;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _salaryCtrl.dispose();
    _customOccupationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(widget.existing == null ? 'Add Worker' : 'Edit Worker',
                style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 20),

            _formField('Full Name *', _nameCtrl, hint: 'e.g. Suresh Kumar'),
            const SizedBox(height: 12),
            _formField('Phone Number', _phoneCtrl, hint: '9876501234', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),

            const Text('Occupation', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: WorkerOccupation.values.map((o) =>
              GestureDetector(
                onTap: () => setState(() => _occupation = o),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _occupation == o ? bcNavy.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _occupation == o ? bcNavy : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(o.displayName, style: TextStyle(
                    color: _occupation == o ? bcNavy : const Color(0xFF64748B),
                    fontWeight: FontWeight.w700, fontSize: 12,
                  )),
                ),
              ),
            ).toList()),
            const SizedBox(height: 14),

            if (_occupation == WorkerOccupation.other) ...[
              _formField('Occupation Name', _customOccupationCtrl, hint: 'e.g. Security, Driver'),
              const SizedBox(height: 14),
            ],

            const Text('Salary Type', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Row(children: SalaryType.values.map((s) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _salaryType = s),
                child: Container(
                  margin: EdgeInsets.only(right: s == SalaryType.daily ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _salaryType == s ? bcAmber.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _salaryType == s ? bcAmber : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_salaryType == s ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                        color: _salaryType == s ? bcAmber : const Color(0xFFCBD5E1), size: 16),
                    const SizedBox(height: 4),
                    Text(s.displayName, style: TextStyle(
                        color: _salaryType == s ? bcAmber : const Color(0xFF64748B),
                        fontWeight: FontWeight.w700, fontSize: 12)),
                  ]),
                ),
              ),
            )).toList()),
            const SizedBox(height: 12),

            _formField(
              _salaryType == SalaryType.daily ? 'Daily Rate (₹)' : 'Monthly Salary (₹)',
              _salaryCtrl, hint: _salaryType == SalaryType.daily ? '700' : '18000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : () => _submit(context),
                icon: _submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_rounded),
                label: Text(widget.existing == null ? 'Add Worker' : 'Save Changes'),
                style: ElevatedButton.styleFrom(backgroundColor: bcNavy, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final name = _nameCtrl.text.trim();
    final salary = double.tryParse(_salaryCtrl.text) ?? 0;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker name is required')));
      return;
    }
    setState(() => _submitting = true);
    final repo = context.read<WorkerRepository>();
    if (widget.existing == null) {
      await repo.addWorker(WorkerModel(
        id: const Uuid().v4(), siteId: widget.siteId, name: name,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        occupation: _occupation,
        customOccupation: _occupation == WorkerOccupation.other ? _customOccupationCtrl.text.trim() : null,
        salaryType: _salaryType,
        salaryAmount: salary, createdAt: DateTime.now(),
      ));
    } else {
      await repo.updateWorker(widget.existing!.copyWith(
        name: name, occupation: _occupation,
        customOccupation: _occupation == WorkerOccupation.other ? _customOccupationCtrl.text.trim() : null,
        salaryType: _salaryType, salaryAmount: salary,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      ));
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
}

// ─── Worker Detail Sheet ──────────────────────────────────────────────────────

class _WorkerDetailSheet extends StatelessWidget {
  final WorkerModel worker;
  const _WorkerDetailSheet({required this.worker});

  @override
  Widget build(BuildContext context) {
    final workerRepo = context.watch<WorkerRepository>();
    final advances   = workerRepo.getAdvancesForWorker(worker.id);
    final attendance = workerRepo.getAttendanceForWorker(worker.id);
    final now        = DateTime.now();
    final salaryDue  = workerRepo.getSalaryDue(worker.id, now.year, now.month);
    final advanceInMonth = workerRepo.getTotalAdvanceForMonth(worker.id, now.year, now.month);
    final earned     = workerRepo.computeEarnedSalary(worker.id, now.year, now.month);
    final fmt        = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            // Header
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: bcNavy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(worker.name[0].toUpperCase(),
                    style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(worker.name, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 18)),
                Row(children: [
                  Text(
                    worker.occupation == WorkerOccupation.other
                        ? (worker.customOccupation?.isNotEmpty == true ? worker.customOccupation! : 'Other')
                        : worker.occupation.displayName,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                  const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
                  Text(worker.salaryType.displayName, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ]),
              ])),
            ]),

            const SizedBox(height: 20),

            // Salary Summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [bcNavy, Color(0xFF1E293B)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SalaryStat('Earned', fmt.format(earned), Colors.white),
                  _VSep(),
                  _SalaryStat('Advance', fmt.format(advanceInMonth), const Color(0xFFFCA5A5)),
                  _VSep(),
                  _SalaryStat('Net Due', fmt.format(salaryDue), bcAmber),
                ],
      ),
    ),

    const SizedBox(height: 16),

    // Action Buttons
    GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _ActionBtn('Mark Attendance', Icons.fact_check_rounded, bcInfo, () => _showMarkAttendance(context)),
        _ActionBtn('Give Advance', Icons.payments_rounded, const Color(0xFF34D399), () => _showGiveAdvance(context)),
        _ActionBtn('Edit Worker', Icons.edit_rounded, const Color(0xFFA78BFA), () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
            builder: (_) => WorkerFormSheet(siteId: worker.siteId, existing: worker),
          );
        }),
        _ActionBtn('View Full History', Icons.history_rounded, const Color(0xFF64748B), () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerHistoryScreen(worker: worker)));
        }),
      ],
    ),

    const SizedBox(height: 24),
  ],
),
      ),
    );
  }

  void _showMarkAttendance(BuildContext context) {
    showDialog(context: context, builder: (_) => AttendanceDialog(worker: worker));
  }

  void _showGiveAdvance(BuildContext context) {
    showDialog(context: context, builder: (_) => AdvanceDialog(worker: worker));
  }
}

class _SalaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SalaryStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
  ]);
}

class _VSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Colors.white10);
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ─── Attendance Dialog ────────────────────────────────────────────────────────

class AttendanceDialog extends StatefulWidget {
  final WorkerModel worker;
  const AttendanceDialog({super.key, required this.worker});

  @override
  State<AttendanceDialog> createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends State<AttendanceDialog> {
  AttendanceStatus _status = AttendanceStatus.present;
  final DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Attendance: ${widget.worker.name}', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: AttendanceStatus.values.map((s) =>
            GestureDetector(
              onTap: () => setState(() => _status = s),
              child: Column(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _status == s ? _statusColor(s) : _statusColor(s).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon(s), color: _status == s ? Colors.white : _statusColor(s), size: 20),
                ),
                const SizedBox(height: 4),
                Text(s.displayName, style: TextStyle(color: _status == s ? bcNavy : const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700)),
              ]),
            ),
          ).toList()),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            await context.read<WorkerRepository>().markAttendance(AttendanceRecord(
              id: const Uuid().v4(), workerId: widget.worker.id, date: _date, status: _status,
            ));
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: bcNavy),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:  return bcSuccess;
      case AttendanceStatus.absent:   return bcDanger;
      case AttendanceStatus.halfDay:  return bcAmber;
    }
  }

  IconData _statusIcon(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:  return Icons.check_circle_rounded;
      case AttendanceStatus.absent:   return Icons.cancel_rounded;
      case AttendanceStatus.halfDay:  return Icons.timelapse_rounded;
    }
  }
}

// ─── Advance Dialog ────────────────────────────────────────────────────────────

class AdvanceDialog extends StatefulWidget {
  final WorkerModel worker;
  const AdvanceDialog({super.key, required this.worker});

  @override
  State<AdvanceDialog> createState() => _AdvanceDialogState();
}

class _AdvanceDialogState extends State<AdvanceDialog> {
  final _amountCtrl  = TextEditingController();
  final _remarksCtrl = TextEditingController();

  @override
  void dispose() { _amountCtrl.dispose(); _remarksCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Advance: ${widget.worker.name}', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 16)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: _amountCtrl, keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount (₹)',
              filled: true, fillColor: bcSurface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bcAmber, width: 2)),
            )),
        const SizedBox(height: 10),
        TextFormField(controller: _remarksCtrl,
            decoration: InputDecoration(
              labelText: 'Remarks (optional)',
              filled: true, fillColor: bcSurface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bcAmber, width: 2)),
            )),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final amount = double.tryParse(_amountCtrl.text) ?? 0;
            if (amount <= 0) return;
            await context.read<WorkerRepository>().addAdvance(WorkerAdvance(
              id: const Uuid().v4(), workerId: widget.worker.id,
              amount: amount, date: DateTime.now(),
              remarks: _remarksCtrl.text.trim().isEmpty ? null : _remarksCtrl.text.trim(),
              paidBy: context.read<WorkerRepository>().workers.isNotEmpty ? 'Admin' : 'Admin',
            ));
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: bcNavy),
          child: const Text('Record', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ─── Daily Attendance Sheet (bulk) ────────────────────────────────────────────

class _DailyAttendanceSheet extends StatefulWidget {
  final List<WorkerModel> workers;
  const _DailyAttendanceSheet({required this.workers});

  @override
  State<_DailyAttendanceSheet> createState() => _DailyAttendanceSheetState();
}

class _DailyAttendanceSheetState extends State<_DailyAttendanceSheet> {
  final Map<String, AttendanceStatus> _statusMap = {};
  DateTime _selectedDate = DateTime.now();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _refreshStatusMap();
  }

  void _refreshStatusMap() {
    final repo = context.read<WorkerRepository>();
    for (final w in widget.workers) {
      _statusMap[w.id] = repo.getAttendanceStatus(w.id, _selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Daily Attendance', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 20)),
            Text('Tap icons to change status', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          ])),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(primary: bcAmber, onPrimary: bcNavy, surface: Colors.white, onSurface: bcNavy),
                  ),
                  child: child!,
                ),
              );
              if (d != null) {
                setState(() {
                  _selectedDate = d;
                  _refreshStatusMap();
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: bcAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: bcAmber.withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.calendar_today_rounded, color: bcAmber, size: 13),
                const SizedBox(width: 6),
                Text(DateFormat('d MMM yyyy').format(_selectedDate), style: const TextStyle(color: bcAmber, fontWeight: FontWeight.w800, fontSize: 13)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: widget.workers.length,
            itemBuilder: (_, i) {
              final w = widget.workers[i];
              final status = _statusMap[w.id] ?? AttendanceStatus.absent;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: bcNavy.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(w.name[0].toUpperCase(), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 16))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(w.name, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13)),
                    Text(
                      w.occupation == WorkerOccupation.other
                          ? (w.customOccupation?.isNotEmpty == true ? w.customOccupation! : 'Other')
                          : w.occupation.displayName,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  ])),
                  Row(children: AttendanceStatus.values.map((s) => GestureDetector(
                    onTap: () => setState(() => _statusMap[w.id] = s),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: status == s ? _sColor(s) : _sColor(s).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_sIcon(s), color: status == s ? Colors.white : _sColor(s), size: 14),
                    ),
                  )).toList()),
                ]),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : () => _submit(context),
            style: ElevatedButton.styleFrom(backgroundColor: bcNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: _submitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Save All Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ]),
    );
  }

  Color _sColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present: return bcSuccess;
      case AttendanceStatus.absent:  return bcDanger;
      case AttendanceStatus.halfDay: return bcAmber;
    }
  }

  IconData _sIcon(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present: return Icons.check_rounded;
      case AttendanceStatus.absent:  return Icons.close_rounded;
      case AttendanceStatus.halfDay: return Icons.timelapse_rounded;
    }
  }

  Future<void> _submit(BuildContext context) async {
    setState(() => _submitting = true);
    await context.read<WorkerRepository>().markBulkAttendance(
      siteId: widget.workers.first.siteId,
      date: _selectedDate,
      statusByWorkerId: _statusMap,
      generatedIdPrefix: 'ATT-BULK',
    );
    if (!mounted) return;
    Navigator.pop(context);
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: bcSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
    child: Row(children: [
      const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 18),
      const SizedBox(width: 8),
      Expanded(child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: bcNavy),
        decoration: const InputDecoration(hintText: 'Search workers…', border: InputBorder.none,
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13), contentPadding: EdgeInsets.zero, isDense: true),
      )),
    ]),
  );
}

Widget _formField(String label, TextEditingController ctrl, {String? hint, TextInputType keyboardType = TextInputType.text}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl, keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: bcNavy),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          filled: true, fillColor: bcSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bcAmber, width: 2)),
        ),
      ),
    ]);

// ─── Dashboard Header ────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final String? siteId;
  const _DashboardHeader({this.siteId});

  @override
  Widget build(BuildContext context) {
    final workerRepo = context.watch<WorkerRepository>();
    final stats = workerRepo.getTodayStats(siteId: siteId);
    final totalDue = siteId != null ? workerRepo.getTotalSalaryDueForSite(siteId!) : 0.0;
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
          colors: [bcNavy, Color(0xFF1E3A8A), Color(0xFF1E1B4B)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: bcNavy.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: bcAmber.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TODAY\'S ATTENDANCE', 
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${stats['present']}', 
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1)),
                      Text(' / ${stats['total']}', 
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('MONTHLY DUE', 
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    Text(fmt.format(totalDue), 
                      style: const TextStyle(color: bcAmber, fontSize: 15, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _statMini(Icons.check_circle_rounded, '${stats['present']}', 'Present', bcSuccess),
              _statMini(Icons.timelapse_rounded, '${stats['halfDay']}', 'Half', bcAmber),
              _statMini(Icons.cancel_rounded, '${stats['absent']}', 'Absent', bcDanger),
              _statMini(Icons.help_outline_rounded, '${stats['notMarked']}', 'Pending', Colors.white24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statMini(IconData icon, String value, String label, Color color) => Expanded(
    child: Row(
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// ─── Recent Activity Tracker ──────────────────────────────────────────────────

class _RecentActivityTracker extends StatelessWidget {
  final String workerId;
  const _RecentActivityTracker({required this.workerId});

  @override
  Widget build(BuildContext context) {
    final workerRepo = context.watch<WorkerRepository>();
    final history = workerRepo.getRecentAttendance(workerId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: history.map((status) {
        Color color;
        switch (status) {
          case AttendanceStatus.present: color = bcSuccess; break;
          case AttendanceStatus.absent:  color = bcDanger; break;
          case AttendanceStatus.halfDay: color = bcAmber; break;
          default:                       color = const Color(0xFFE2E8F0);
        }
        return Container(
          width: 6, height: 6,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      }).toList(),
    );
  }
}
