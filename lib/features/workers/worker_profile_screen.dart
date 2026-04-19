import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/worker_model.dart';
import 'package:construction_app/data/repositories/worker_repository.dart';
import 'package:construction_app/features/workers/worker_history_screen.dart';
import 'package:construction_app/features/workers/worker_list_screen.dart';

class WorkerProfileScreen extends StatefulWidget {
  final WorkerModel worker;
  const WorkerProfileScreen({super.key, required this.worker});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WorkerRepository>();
    final now = DateTime.now();
    final earned = repo.computeEarnedSalary(widget.worker.id, now.year, now.month);
    final paid = repo.getTotalAdvanceForMonth(widget.worker.id, now.year, now.month);
    final pending = repo.getSalaryDue(widget.worker.id, now.year, now.month);
    final attendance = repo.getAttendanceForMonth(widget.worker.id, now.year, now.month);
    final presentDays = attendance.where((a) => a.status == AttendanceStatus.present).length;
    final halfDays = attendance.where((a) => a.status == AttendanceStatus.halfDay).length;
    final absentDays = attendance.where((a) => a.status == AttendanceStatus.absent).length;
    final totalUnits = presentDays + (halfDays * 0.5);
    final attendancePct = attendance.isEmpty ? 0.0 : (totalUnits / attendance.length).clamp(0.0, 1.0);
    final occupationLabel = widget.worker.occupation == WorkerOccupation.other
        ? ((widget.worker.customOccupation?.isNotEmpty ?? false) ? widget.worker.customOccupation! : 'Other')
        : widget.worker.occupation.displayName;

    return Scaffold(
      backgroundColor: bcSurface,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 315,
                pinned: true,
                stretch: true,
                backgroundColor: bcNavy,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: bcAmber, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: bcAmber),
                    onPressed: () => _editWorker(context),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [bcNavy, Color(0xFF142133)],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 108,
                              height: 108,
                              decoration: BoxDecoration(
                                color: bcAmber.withValues(alpha: 0.10),
                                shape: BoxShape.circle,
                                border: Border.all(color: bcAmber.withValues(alpha: 0.30), width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  widget.worker.name.isNotEmpty ? widget.worker.name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: bcAmber, fontSize: 44, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              widget.worker.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _DarkTag(text: occupationLabel),
                                _DarkTag(text: widget.worker.salaryType == SalaryType.daily ? 'Daily Worker' : 'Monthly Worker'),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(child: _HeroMiniStat(label: 'Earned', value: fmt.format(earned), color: Colors.white)),
                                const SizedBox(width: 10),
                                Expanded(child: _HeroMiniStat(label: 'Paid', value: fmt.format(paid), color: bcAmber)),
                                const SizedBox(width: 10),
                                Expanded(child: _HeroMiniStat(label: 'Pending', value: fmt.format(pending), color: pending > 0 ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: bcSurface,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: const BorderSide(color: bcAmber, width: 4),
                      insets: const EdgeInsets.symmetric(horizontal: 60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    labelColor: bcNavy,
                    unselectedLabelColor: bcTextSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.1),
                    tabs: const [
                      Tab(text: 'OVERVIEW'),
                      Tab(text: 'HISTORY'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(
                  worker: widget.worker,
                  earned: earned,
                  paid: paid,
                  pending: pending,
                  presentDays: presentDays,
                  halfDays: halfDays,
                  absentDays: absentDays,
                  attendancePct: attendancePct,
                  fmt: fmt,
                ),
                WorkerHistoryScreen(worker: widget.worker, isEmbedded: true),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _FloatingActionDock(worker: widget.worker),
          ),
        ],
      ),
    );
  }

  void _editWorker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkerFormSheet(siteId: widget.worker.siteId, existing: widget.worker),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final WorkerModel worker;
  final double earned;
  final double paid;
  final double pending;
  final int presentDays;
  final int halfDays;
  final int absentDays;
  final double attendancePct;
  final NumberFormat fmt;

  const _OverviewTab({
    required this.worker,
    required this.earned,
    required this.paid,
    required this.pending,
    required this.presentDays,
    required this.halfDays,
    required this.absentDays,
    required this.attendancePct,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final occupationLabel = worker.occupation == WorkerOccupation.other
        ? ((worker.customOccupation?.isNotEmpty ?? false) ? worker.customOccupation! : 'Other')
        : worker.occupation.displayName;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 132),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _PrimaryStatCard(
                label: 'Pending Amount',
                value: fmt.format(pending),
                color: pending > 0 ? bcDanger : const Color(0xFF64748B),
                icon: Icons.account_balance_wallet_rounded,
                helper: pending > 0 ? 'Amount still remaining' : 'No pending amount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _AttendanceProgressCard(attendancePct: attendancePct),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionTitle('PAYMENT BREAKDOWN'),
        Row(
          children: [
            Expanded(child: _MiniStat(title: 'Total Earned', value: fmt.format(earned), color: bcNavy)),
            const SizedBox(width: 12),
            Expanded(child: _MiniStat(title: 'Total Paid', value: fmt.format(paid), color: bcAmber)),
          ],
        ),
        const SizedBox(height: 12),
        _InfoBanner(
          icon: Icons.info_outline_rounded,
          text: 'Pending amount is calculated from attendance-based earned salary minus recorded payment/advance entries.',
        ),
        const SizedBox(height: 28),
        _SectionTitle('ATTENDANCE SUMMARY'),
        Row(
          children: [
            Expanded(child: _MiniStat(title: 'Present', value: '$presentDays', color: bcSuccess)),
            const SizedBox(width: 12),
            Expanded(child: _MiniStat(title: 'Half Days', value: '$halfDays', color: bcAmber)),
            const SizedBox(width: 12),
            Expanded(child: _MiniStat(title: 'Absent', value: '$absentDays', color: bcDanger)),
          ],
        ),
        const SizedBox(height: 28),
        _SectionTitle('WORKER DETAILS'),
        _DetailTile(
          icon: Icons.phone_rounded,
          label: 'Phone',
          value: worker.phone ?? 'Not provided',
          color: bcInfo,
          onTap: worker.phone == null || worker.phone!.isEmpty ? null : () => _makeCall(worker.phone),
        ),
        _DetailTile(
          icon: Icons.work_rounded,
          label: 'Occupation',
          value: occupationLabel,
          color: bcAmber,
        ),
        _DetailTile(
          icon: Icons.payments_rounded,
          label: 'Salary Basis',
          value: worker.salaryType == SalaryType.daily ? '₹${worker.salaryAmount.toStringAsFixed(0)}/day' : '${fmt.format(worker.salaryAmount)}/month',
          color: bcSuccess,
        ),
        _DetailTile(
          icon: Icons.badge_rounded,
          label: 'Worker Type',
          value: worker.salaryType.displayName,
          color: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  void _makeCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}

class _HeroMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HeroMiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DarkTag extends StatelessWidget {
  final String text;
  const _DarkTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

class _PrimaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final String helper;

  const _PrimaryStatCard({required this.label, required this.value, required this.color, required this.icon, required this.helper});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(color: bcNavy.withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.9)),
          const SizedBox(height: 8),
          Text(helper, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.35)),
        ],
      ),
    );
  }
}

class _AttendanceProgressCard extends StatelessWidget {
  final double attendancePct;
  const _AttendanceProgressCard({required this.attendancePct});

  @override
  Widget build(BuildContext context) {
    final color = attendancePct > 0.8 ? bcSuccess : (attendancePct > 0.5 ? bcAmber : bcDanger);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: bcBorder.withValues(alpha: 0.55)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: CircularProgressIndicator(
                  value: attendancePct,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text('${(attendancePct * 100).toInt()}%', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 14),
          const Text('ATTENDANCE', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.8)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _MiniStat({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBanner({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bcInfo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bcInfo.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: bcInfo, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: bcNavy, fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  const _DetailTile({required this.icon, required this.label, required this.value, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700)),
                  Text(value, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 14)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(text, style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.8)),
    );
  }
}

class _FloatingActionDock extends StatelessWidget {
  final WorkerModel worker;
  const _FloatingActionDock({required this.worker});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bcNavy.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1.3),
            boxShadow: [
              BoxShadow(color: bcNavy.withValues(alpha: 0.42), blurRadius: 25, offset: const Offset(0, 12)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _markAttendance(context),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fact_check_rounded, color: Colors.white, size: 19),
                          SizedBox(width: 10),
                          Text('ATTENDANCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.7)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: bcAmber,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: () => _givePayment(context),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    child: const Row(
                      children: [
                        Icon(Icons.payments_rounded, color: bcNavy, size: 19),
                        SizedBox(width: 8),
                        Text('PAYMENT', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.7)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAttendance(BuildContext context) {
    showDialog(context: context, builder: (_) => AttendanceDialog(worker: worker));
  }

  void _givePayment(BuildContext context) {
    showDialog(context: context, builder: (_) => AdvanceDialog(worker: worker));
  }
}
