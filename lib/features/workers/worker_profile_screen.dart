import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/worker_repository.dart';
import 'package:construction_app/data/models/worker_model.dart';
import 'package:construction_app/features/workers/worker_history_screen.dart';
import 'package:construction_app/features/workers/worker_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final workerRepo = context.watch<WorkerRepository>();
    final now = DateTime.now();
    
    // Monthly stats
    final earned = workerRepo.computeEarnedSalary(widget.worker.id, now.year, now.month);
    final advanced = workerRepo.getTotalAdvanceForMonth(widget.worker.id, now.year, now.month);
    final netDue = workerRepo.getSalaryDue(widget.worker.id, now.year, now.month);
    
    final attendance = workerRepo.getAttendanceForMonth(widget.worker.id, now.year, now.month);
    final presentDays = attendance.where((a) => a.status == AttendanceStatus.present).length;
    final halfDays = attendance.where((a) => a.status == AttendanceStatus.halfDay).length;
    
    final totalDaysMarked = attendance.length;
    final attendancePct = totalDaysMarked > 0 ? (presentDays + (halfDays * 0.5)) / totalDaysMarked : 0.0;

    return Scaffold(
      backgroundColor: bcSurface,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 300,
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
                  background: Stack(
                    children: [
                      // Architectural Mesh
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BlueprintGridPainter(opacity: 0.15, gridColor: bcAmber.withValues(alpha: 0.1)),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              bcNavy,
                              bcNavy.withValues(alpha: 0.8),
                              bcSurface,
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Hero(
                              tag: 'worker_pfp_${widget.worker.id}',
                              child: GlassCard(
                                blur: 20,
                                opacity: 0.1,
                                borderRadius: BorderRadius.circular(36),
                                border: Border.all(color: bcAmber.withValues(alpha: 0.3), width: 2),
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  width: 100, height: 100,
                                  decoration: BoxDecoration(
                                    color: bcNavy.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.worker.name[0].toUpperCase(),
                                      style: const TextStyle(color: bcAmber, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(widget.worker.name, 
                                style: const TextStyle(color: bcNavy, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.5, height: 1)),
                            const SizedBox(height: 10),
                            StatusPill(label: widget.worker.occupation.displayName, color: bcInfo),
                          ],
                        ),
                      ),
                    ],
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
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
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
                  advanced: advanced,
                  due: netDue,
                  presentDays: presentDays,
                  halfDays: halfDays,
                  attendancePct: attendancePct,
                  fmt: fmt,
                ),
                WorkerHistoryScreen(worker: widget.worker, isEmbedded: true),
              ],
            ),
          ),
          
          // Floating Action Dock
          Positioned(
            left: 20, right: 20, bottom: 25,
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
  final double advanced;
  final double due;
  final int presentDays;
  final int halfDays;
  final double attendancePct;
  final NumberFormat fmt;

  const _OverviewTab({
    required this.worker,
    required this.earned,
    required this.advanced,
    required this.due,
    required this.presentDays,
    required this.halfDays,
    required this.attendancePct,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // Performance & Stats Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _statCard('Net Due', fmt.format(due), due > 0 ? bcSuccess : Color(0xFF64748B), Icons.account_balance_wallet_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _performanceIndicator(),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Detailed Financial Breakdown
        _sectionHeader('SALARY BREAKDOWN (THIS MONTH)'),
        Row(
          children: [
            Expanded(child: _miniFstat('Total Earned', fmt.format(earned), bcNavy)),
            const SizedBox(width: 12),
            Expanded(child: _miniFstat('Advances Taken', fmt.format(advanced), bcDanger)),
          ],
        ),
        
        const SizedBox(height: 28),
        
        // Personal Info
        _sectionHeader('PERSONAL DETAILS'),
        _detailTile(context, Icons.phone_rounded, 'Phone', worker.phone ?? 'Not provided', bcInfo, onTap: () => _makeCall(worker.phone)),
        _detailTile(context, Icons.work_rounded, 'Occupation', worker.occupation.displayName, bcAmber),
        _detailTile(context, Icons.payments_rounded, 'Salary Basis', 
            worker.salaryType == SalaryType.daily ? '₹${worker.salaryAmount}/day' : '₹${fmt.format(worker.salaryAmount)}/month', 
            bcSuccess),
        _detailTile(context, Icons.event_available_rounded, 'Days Present', '$presentDays Days (+ $halfDays half)', const Color(0xFF6366F1)),

        const SizedBox(height: 120), // Spacing for floating dock
      ],
    );
  }

  Widget _performanceIndicator() => GlassCard(
    blur: 10,
    opacity: 0.02,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: bcBorder.withValues(alpha: 0.5)),
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 54, height: 54,
              child: CircularProgressIndicator(
                value: attendancePct,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(attendancePct > 0.8 ? bcSuccess : (attendancePct > 0.5 ? bcAmber : bcDanger)),
              ),
            ),
            Text('${(attendancePct * 100).toInt()}%', 
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: bcNavy, letterSpacing: -0.5)),
          ],
        ),
        const SizedBox(height: 12),
        const Text('ATTENDANCE', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    ),
  );

  Widget _statCard(String label, String value, Color color, IconData icon) => GlassCard(
    blur: 5,
    opacity: 0.03,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 16),
        Text(value, style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ],
    ),
  );

  Widget _miniFstat(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(24), 
      border: Border.all(color: const Color(0xFFF1F5F9)),
      boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    ),
  );

  Widget _detailTile(BuildContext context, IconData icon, String label, String value, Color color, {VoidCallback? onTap}) => GestureDetector(
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
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
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

  void _makeCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4),
    child: Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.8)),
  );
}

class _FloatingActionDock extends StatelessWidget {
  final WorkerModel worker;
  const _FloatingActionDock({required this.worker});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bcNavy.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            boxShadow: [
              BoxShadow(color: bcNavy.withValues(alpha: 0.4), blurRadius: 25, offset: const Offset(0, 12)),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08), 
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fact_check_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text('MARK ATTENDANCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8)),
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
                  onTap: () => _giveAdvance(context),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.payments_rounded, color: bcNavy, size: 24),
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
  
  void _giveAdvance(BuildContext context) {
    showDialog(context: context, builder: (_) => AdvanceDialog(worker: worker));
  }
}
