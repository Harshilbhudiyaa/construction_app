import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/worker_model.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/worker_repository.dart';
import 'package:construction_app/features/workers/worker_history_screen.dart';
import 'package:construction_app/features/workers/worker_profile_screen.dart';

class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

enum _WorkerSort {
  nameAsc,
  pendingHigh,
  paidHigh,
  attendanceHigh,
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  String _search = '';
  _WorkerSort _sort = _WorkerSort.nameAsc;

  @override
  Widget build(BuildContext context) {
    final workerRepo = context.watch<WorkerRepository>();
    final siteRepo = context.watch<SiteRepository>();
    final siteId = siteRepo.selectedSiteId;
    final now = DateTime.now();
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final workers = (siteId != null ? workerRepo.getWorkersForSite(siteId) : workerRepo.workers)
        .where((w) => _search.isEmpty || w.name.toLowerCase().contains(_search.toLowerCase()))
        .toList()
      ..sort((a, b) => _compareWorkers(workerRepo, a, b, now));

    final totalEarned = workers.fold<double>(0, (sum, w) => sum + workerRepo.computeEarnedSalary(w.id, now.year, now.month));
    final totalPaid = workers.fold<double>(0, (sum, w) => sum + workerRepo.getTotalAdvanceForMonth(w.id, now.year, now.month));
    final totalPending = workers.fold<double>(0, (sum, w) => sum + workerRepo.getSalaryDue(w.id, now.year, now.month));
    final presentUnits = workers.fold<double>(0, (sum, w) => sum + _attendanceUnits(workerRepo, w.id, now.year, now.month));

    return Scaffold(
      backgroundColor: bcSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 210,
            backgroundColor: bcNavy,
            elevation: 0,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'Bulk Attendance',
                icon: const Icon(Icons.fact_check_rounded, color: bcAmber),
                onPressed: () => _showAttendanceSheet(context, workers),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          siteId != null ? 'SITE: $siteId' : 'ALL SITES',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Workers',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Attendance, payment history and pending amount in one simple workflow',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _TopSummaryCard(
                  workerCount: workers.length,
                  totalEarned: totalEarned,
                  totalPaid: totalPaid,
                  totalPending: totalPending,
                  presentUnits: presentUnits,
                  fmt: fmt,
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              child: Container(
                color: bcSurface,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  children: [
                    _SearchBar(onChanged: (v) => setState(() => _search = v)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickHeaderChip(
                            icon: Icons.swap_vert_rounded,
                            label: _sortLabel(_sort),
                            onTap: _showSortSheet,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickHeaderChip(
                            icon: Icons.fact_check_rounded,
                            label: 'Bulk Attendance',
                            highlight: true,
                            onTap: () => _showAttendanceSheet(context, workers),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _OccupationChipRow(workers: workers),
                  ],
                ),
              ),
              height: 176,
            ),
          ),
        ],
        body: RefreshIndicator(
          color: bcAmber,
          onRefresh: () => workerRepo.refresh(),
          child: workerRepo.isLoading
              ? const Center(child: CircularProgressIndicator(color: bcAmber))
              : workers.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: workers.length,
                      itemBuilder: (_, i) {
                        final worker = workers[i];
                        final earned = workerRepo.computeEarnedSalary(worker.id, now.year, now.month);
                        final paid = workerRepo.getTotalAdvanceForMonth(worker.id, now.year, now.month);
                        final pending = workerRepo.getSalaryDue(worker.id, now.year, now.month);
                        final attendance = workerRepo.getAttendanceForMonth(worker.id, now.year, now.month);
                        final presentDays = attendance.where((a) => a.status == AttendanceStatus.present).length;
                        final halfDays = attendance.where((a) => a.status == AttendanceStatus.halfDay).length;

                        return _WorkerCard(
                          worker: worker,
                          earned: earned,
                          paid: paid,
                          pending: pending,
                          presentDays: presentDays,
                          halfDays: halfDays,
                          fmt: fmt,
                          onOpen: () => _openWorker(context, worker),
                          onAttendance: () => _showMarkAttendance(context, worker),
                          onAdvance: () => _showGiveAdvance(context, worker),
                          onHistory: () => _openHistory(context, worker),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWorkerSheet(context, siteId),
        backgroundColor: bcAmber,
        foregroundColor: bcNavy,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Worker', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  String _sortLabel(_WorkerSort sort) {
    switch (sort) {
      case _WorkerSort.nameAsc:
        return 'Sort: Name';
      case _WorkerSort.pendingHigh:
        return 'Sort: Pending';
      case _WorkerSort.paidHigh:
        return 'Sort: Paid';
      case _WorkerSort.attendanceHigh:
        return 'Sort: Attendance';
    }
  }

  int _compareWorkers(WorkerRepository repo, WorkerModel a, WorkerModel b, DateTime now) {
    switch (_sort) {
      case _WorkerSort.nameAsc:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case _WorkerSort.pendingHigh:
        return repo.getSalaryDue(b.id, now.year, now.month).compareTo(repo.getSalaryDue(a.id, now.year, now.month));
      case _WorkerSort.paidHigh:
        return repo.getTotalAdvanceForMonth(b.id, now.year, now.month).compareTo(repo.getTotalAdvanceForMonth(a.id, now.year, now.month));
      case _WorkerSort.attendanceHigh:
        return _attendanceUnits(repo, b.id, now.year, now.month).compareTo(_attendanceUnits(repo, a.id, now.year, now.month));
    }
  }

  double _attendanceUnits(WorkerRepository repo, String workerId, int year, int month) {
    final list = repo.getAttendanceForMonth(workerId, year, month);
    double total = 0;
    for (final item in list) {
      switch (item.status) {
        case AttendanceStatus.present:
          total += 1;
          break;
        case AttendanceStatus.halfDay:
          total += 0.5;
          break;
        case AttendanceStatus.absent:
          break;
      }
    }
    return total;
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: bcNavy.withValues(alpha: 0.05),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.engineering_outlined, size: 42, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              const Text(
                'No workers found',
                style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add workers to start attendance, salary and payment tracking.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ],
          ),
        ),
      );

  void _showSortSheet() async {
    final result = await showModalBottomSheet<_WorkerSort>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(current: _sort),
    );
    if (result != null) {
      setState(() => _sort = result);
    }
  }

  void _showAddWorkerSheet(BuildContext context, String? siteId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkerFormSheet(siteId: siteId ?? context.read<SiteRepository>().selectedSiteId ?? 'S-001'),
    );
  }

  void _openWorker(BuildContext context, WorkerModel worker) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerProfileScreen(worker: worker)));
  }

  void _openHistory(BuildContext context, WorkerModel worker) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerHistoryScreen(worker: worker)));
  }

  void _showAttendanceSheet(BuildContext context, List<WorkerModel> workers) {
    if (workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No workers to mark attendance for')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DailyAttendanceSheet(workers: workers),
    );
  }

  void _showMarkAttendance(BuildContext context, WorkerModel worker) {
    showDialog(context: context, builder: (_) => AttendanceDialog(worker: worker));
  }

  void _showGiveAdvance(BuildContext context, WorkerModel worker) {
    showDialog(context: context, builder: (_) => AdvanceDialog(worker: worker));
  }
}

class _TopSummaryCard extends StatelessWidget {
  final int workerCount;
  final double totalEarned;
  final double totalPaid;
  final double totalPending;
  final double presentUnits;
  final NumberFormat fmt;

  const _TopSummaryCard({
    required this.workerCount,
    required this.totalEarned,
    required this.totalPaid,
    required this.totalPending,
    required this.presentUnits,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, Color(0xFFF8FAFC)]),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: bcBorder.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: bcNavy.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _SummaryTile(label: 'Workers', value: '$workerCount', icon: Icons.groups_rounded, color: bcInfo)),
              const SizedBox(width: 10),
              Expanded(child: _SummaryTile(label: 'Present Units', value: presentUnits.toStringAsFixed(presentUnits % 1 == 0 ? 0 : 1), icon: Icons.fact_check_rounded, color: bcSuccess)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _SummaryTile(label: 'Earned', value: fmt.format(totalEarned), icon: Icons.account_balance_wallet_rounded, color: bcNavy)),
              const SizedBox(width: 10),
              Expanded(child: _SummaryTile(label: 'Paid', value: fmt.format(totalPaid), icon: Icons.payments_rounded, color: bcAmber)),
              const SizedBox(width: 10),
              Expanded(child: _SummaryTile(label: 'Pending', value: fmt.format(totalPending), icon: Icons.currency_rupee_rounded, color: totalPending > 0 ? bcDanger : bcSuccess)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 9, letterSpacing: 0.8)),
        ],
      ),
    );
  }
}

class _QuickHeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  const _QuickHeaderChip({required this.icon, required this.label, required this.onTap, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? bcAmber : bcNavy;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: highlight ? bcAmber.withValues(alpha: 0.10) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: highlight ? bcAmber.withValues(alpha: 0.22) : bcBorder.withValues(alpha: 0.65)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final WorkerModel worker;
  final double earned;
  final double paid;
  final double pending;
  final int presentDays;
  final int halfDays;
  final NumberFormat fmt;
  final VoidCallback onOpen;
  final VoidCallback onAttendance;
  final VoidCallback onAdvance;
  final VoidCallback onHistory;

  const _WorkerCard({
    required this.worker,
    required this.earned,
    required this.paid,
    required this.pending,
    required this.presentDays,
    required this.halfDays,
    required this.fmt,
    required this.onOpen,
    required this.onAttendance,
    required this.onAdvance,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final occColor = _occupationColor(worker.occupation);
    final occupationLabel = worker.occupation == WorkerOccupation.other
        ? ((worker.customOccupation?.isNotEmpty ?? false) ? worker.customOccupation! : 'Other')
        : worker.occupation.displayName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: bcBorder.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(color: bcNavy.withValues(alpha: 0.05), blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [occColor.withValues(alpha: 0.16), occColor.withValues(alpha: 0.06)]),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: occColor.withValues(alpha: 0.18)),
                      ),
                      child: Center(
                        child: Text(
                          worker.name.isNotEmpty ? worker.name[0].toUpperCase() : '?',
                          style: TextStyle(color: occColor, fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(worker.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _TagChip(label: occupationLabel, color: occColor),
                              _TextPill(icon: Icons.currency_rupee_rounded, text: worker.salaryType == SalaryType.daily ? '${worker.salaryAmount.toStringAsFixed(0)}/day' : '${fmt.format(worker.salaryAmount)}/month'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _PendingBadge(value: pending, fmt: fmt),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _MetricBox(label: 'Earned', value: fmt.format(earned), color: bcNavy, icon: Icons.account_balance_wallet_rounded)),
                    const SizedBox(width: 10),
                    Expanded(child: _MetricBox(label: 'Paid', value: fmt.format(paid), color: bcAmber, icon: Icons.payments_rounded)),
                    const SizedBox(width: 10),
                    Expanded(child: _MetricBox(label: 'Attendance', value: '$presentDays + ${halfDays}½', color: bcSuccess, icon: Icons.event_available_rounded)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _ActionButton(label: 'Attendance', icon: Icons.fact_check_rounded, color: bcInfo, onTap: onAttendance)),
                    const SizedBox(width: 8),
                    Expanded(child: _ActionButton(label: 'Payment', icon: Icons.payments_rounded, color: bcAmber, onTap: onAdvance)),
                    const SizedBox(width: 8),
                    Expanded(child: _ActionButton(label: 'History', icon: Icons.history_rounded, color: const Color(0xFF64748B), onTap: onHistory)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _occupationColor(WorkerOccupation o) {
    switch (o) {
      case WorkerOccupation.mason:
        return const Color(0xFFF59E0B);
      case WorkerOccupation.electrician:
        return const Color(0xFF60A5FA);
      case WorkerOccupation.carpenter:
        return const Color(0xFF34D399);
      case WorkerOccupation.engineer:
        return const Color(0xFFA78BFA);
      case WorkerOccupation.supervisor:
        return bcAmber;
      case WorkerOccupation.plumber:
        return const Color(0xFF0EA5E9);
      case WorkerOccupation.painter:
        return const Color(0xFFFB7185);
      case WorkerOccupation.helper:
        return const Color(0xFF94A3B8);
      case WorkerOccupation.other:
        return const Color(0xFF64748B);
    }
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricBox({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(height: 8),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  final double value;
  final NumberFormat fmt;

  const _PendingBadge({required this.value, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final color = value > 0 ? bcDanger : bcSuccess;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(fmt.format(value < 0 ? 0 : value), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 2),
          Text(value > 0 ? 'PENDING' : 'CLEAR', style: TextStyle(color: color.withValues(alpha: 0.68), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

class _TextPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TextPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800))),
            ],
          ),
        ),
      ),
    );
  }
}

class _OccupationChipRow extends StatelessWidget {
  final List<WorkerModel> workers;
  const _OccupationChipRow({required this.workers});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final w in workers) {
      final key = w.occupation == WorkerOccupation.other
          ? ((w.customOccupation?.isNotEmpty ?? false) ? w.customOccupation! : 'Other')
          : w.occupation.displayName;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: counts.entries.map((e) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: bcBorder.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.key, style: const TextStyle(color: bcNavy, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: bcNavy.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(999)),
                  child: Text('${e.value}', style: const TextStyle(color: bcNavy, fontSize: 10, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class WorkerFormSheet extends StatefulWidget {
  final String siteId;
  final WorkerModel? existing;
  const WorkerFormSheet({super.key, required this.siteId, this.existing});

  @override
  State<WorkerFormSheet> createState() => _WorkerFormSheetState();
}

class _WorkerFormSheetState extends State<WorkerFormSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _customOccupationCtrl = TextEditingController();
  WorkerOccupation _occupation = WorkerOccupation.helper;
  SalaryType _salaryType = SalaryType.daily;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final w = widget.existing;
    if (w != null) {
      _nameCtrl.text = w.name;
      _phoneCtrl.text = w.phone ?? '';
      _salaryCtrl.text = w.salaryAmount.toStringAsFixed(0);
      _customOccupationCtrl.text = w.customOccupation ?? '';
      _occupation = w.occupation;
      _salaryType = w.salaryType;
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
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 16),
            Text(widget.existing == null ? 'Add Worker' : 'Edit Worker', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(height: 6),
            const Text('Keep details simple so attendance and payment management stays fast.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            const SizedBox(height: 20),
            _InputField(label: 'Full Name *', hint: 'e.g. Suresh Kumar', controller: _nameCtrl),
            const SizedBox(height: 12),
            _InputField(label: 'Phone Number', hint: '9876501234', controller: _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            const Text('Occupation', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WorkerOccupation.values.map((o) {
                final selected = _occupation == o;
                return GestureDetector(
                  onTap: () => setState(() => _occupation = o),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected ? bcNavy.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? bcNavy : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(o.displayName, style: TextStyle(color: selected ? bcNavy : const Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
            if (_occupation == WorkerOccupation.other) ...[
              const SizedBox(height: 12),
              _InputField(label: 'Occupation Name', hint: 'e.g. Security, Driver', controller: _customOccupationCtrl),
            ],
            const SizedBox(height: 16),
            const Text('Salary Type', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: SalaryType.values.map((s) {
                final selected = _salaryType == s;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _salaryType = s),
                    child: Container(
                      margin: EdgeInsets.only(right: s == SalaryType.daily ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? bcAmber.withValues(alpha: 0.10) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selected ? bcAmber : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? bcAmber : const Color(0xFFCBD5E1), size: 18),
                          const SizedBox(height: 6),
                          Text(s.displayName, style: TextStyle(color: selected ? bcAmber : const Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _InputField(
              label: _salaryType == SalaryType.daily ? 'Daily Rate (₹)' : 'Monthly Salary (₹)',
              hint: _salaryType == SalaryType.daily ? '700' : '18000',
              controller: _salaryCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : () => _submit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bcNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: _submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_rounded),
                label: Text(widget.existing == null ? 'Add Worker' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final name = _nameCtrl.text.trim();
    final salary = double.tryParse(_salaryCtrl.text.trim()) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker name is required')));
      return;
    }
    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid salary amount')));
      return;
    }
    if (_occupation == WorkerOccupation.other && _customOccupationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter custom occupation name')));
      return;
    }

    setState(() => _submitting = true);
    final repo = context.read<WorkerRepository>();
    if (widget.existing == null) {
      await repo.addWorker(WorkerModel(
        id: const Uuid().v4(),
        siteId: widget.siteId,
        name: name,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        occupation: _occupation,
        customOccupation: _occupation == WorkerOccupation.other ? _customOccupationCtrl.text.trim() : null,
        salaryType: _salaryType,
        salaryAmount: salary,
        createdAt: DateTime.now(),
      ));
    } else {
      await repo.updateWorker(widget.existing!.copyWith(
        name: name,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        occupation: _occupation,
        customOccupation: _occupation == WorkerOccupation.other ? _customOccupationCtrl.text.trim() : null,
        salaryType: _salaryType,
        salaryAmount: salary,
      ));
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
}

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Mark Attendance • ${widget.worker.name}', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 17)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AttendanceStatus.values.map((s) {
          final selected = _status == s;
          final color = _statusColor(s);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _status = s),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.10) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selected ? color : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: selected ? color : color.withValues(alpha: 0.10),
                      child: Icon(_statusIcon(s), color: selected ? Colors.white : color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(s.displayName, style: TextStyle(color: bcNavy, fontWeight: selected ? FontWeight.w900 : FontWeight.w700))),
                    if (selected) Icon(Icons.check_circle_rounded, color: color),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            await context.read<WorkerRepository>().markAttendance(AttendanceRecord(id: const Uuid().v4(), workerId: widget.worker.id, date: _date, status: _status));
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
      case AttendanceStatus.present:
        return bcSuccess;
      case AttendanceStatus.absent:
        return bcDanger;
      case AttendanceStatus.halfDay:
        return bcAmber;
    }
  }

  IconData _statusIcon(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return Icons.check_circle_rounded;
      case AttendanceStatus.absent:
        return Icons.cancel_rounded;
      case AttendanceStatus.halfDay:
        return Icons.timelapse_rounded;
    }
  }
}

class AdvanceDialog extends StatefulWidget {
  final WorkerModel worker;
  const AdvanceDialog({super.key, required this.worker});

  @override
  State<AdvanceDialog> createState() => _AdvanceDialogState();
}

class _AdvanceDialogState extends State<AdvanceDialog> {
  final _amountCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Record Payment • ${widget.worker.name}', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 17)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InputField(label: 'Amount (₹)', hint: 'Enter amount', controller: _amountCtrl, keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          _InputField(label: 'Remarks (optional)', hint: 'Optional note', controller: _remarksCtrl),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
            if (amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount')));
              return;
            }
            await context.read<WorkerRepository>().addAdvance(WorkerAdvance(
                  id: const Uuid().v4(),
                  workerId: widget.worker.id,
                  amount: amount,
                  date: DateTime.now(),
                  remarks: _remarksCtrl.text.trim().isEmpty ? null : _remarksCtrl.text.trim(),
                  paidBy: 'Admin',
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
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Attendance', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 20)),
                      SizedBox(height: 4),
                      Text('Mark everyone quickly from one place', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: bcAmber.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: bcAmber.withValues(alpha: 0.20)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: bcAmber, size: 16),
                        const SizedBox(width: 8),
                        Text(DateFormat('d MMM yyyy').format(_selectedDate), style: const TextStyle(color: bcAmber, fontWeight: FontWeight.w800, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.workers.length,
                itemBuilder: (_, i) {
                  final w = widget.workers[i];
                  final status = _statusMap[w.id] ?? AttendanceStatus.absent;
                  final label = w.occupation == WorkerOccupation.other
                      ? ((w.customOccupation?.isNotEmpty ?? false) ? w.customOccupation! : 'Other')
                      : w.occupation.displayName;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: bcNavy.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(w.name.isNotEmpty ? w.name[0].toUpperCase() : '?', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 18))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w.name, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: AttendanceStatus.values.map((s) {
                            final selected = status == s;
                            final color = _sColor(s);
                            return GestureDetector(
                              onTap: () => setState(() => _statusMap[w.id] = s),
                              child: Container(
                                margin: const EdgeInsets.only(left: 6),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(color: selected ? color : color.withValues(alpha: 0.10), shape: BoxShape.circle),
                                child: Icon(_sIcon(s), size: 16, color: selected ? Colors.white : color),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : () => _submit(context),
                style: ElevatedButton.styleFrom(backgroundColor: bcNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _submitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Save All Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _sColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return bcSuccess;
      case AttendanceStatus.absent:
        return bcDanger;
      case AttendanceStatus.halfDay:
        return bcAmber;
    }
  }

  IconData _sIcon(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return Icons.check_rounded;
      case AttendanceStatus.absent:
        return Icons.close_rounded;
      case AttendanceStatus.halfDay:
        return Icons.timelapse_rounded;
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

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bcBorder.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(color: bcNavy.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),

      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: bcAmber),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(color: bcNavy, fontSize: 15, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search worker by name...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _InputField({required this.label, required this.hint, required this.controller, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: bcAmber, width: 1.8)),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final _WorkerSort current;
  const _SortSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Sort Workers', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 20)),
            ),
            const SizedBox(height: 14),
            ..._WorkerSort.values.map((sort) {
              String label;
              switch (sort) {
                case _WorkerSort.nameAsc:
                  label = 'Name';
                  break;
                case _WorkerSort.pendingHigh:
                  label = 'Pending Amount High to Low';
                  break;
                case _WorkerSort.paidHigh:
                  label = 'Paid Amount High to Low';
                  break;
                case _WorkerSort.attendanceHigh:
                  label = 'Attendance High to Low';
                  break;
              }
              final selected = sort == current;
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: selected ? bcAmber.withValues(alpha: 0.10) : const Color(0xFFF8FAFC),
                leading: Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, color: selected ? bcAmber : const Color(0xFF94A3B8)),
                title: Text(label, style: TextStyle(color: bcNavy, fontWeight: selected ? FontWeight.w900 : FontWeight.w700)),
                onTap: () => Navigator.pop(context, sort),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  const _SliverHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) => true;
}
