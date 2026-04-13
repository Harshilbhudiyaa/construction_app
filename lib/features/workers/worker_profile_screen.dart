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
                expandedHeight: 240,
                pinned: true,
                stretch: true,
                backgroundColor: bcNavy,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [bcNavy, Color(0xFF1E3A8A), Color(0xFF1E1B4B)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Hero(
                            tag: 'worker_pfp_${widget.worker.id}',
                            child: Container(
                              width: 85, height: 85,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
                                ],
                                border: Border.all(color: bcAmber.withValues(alpha: 0.4), width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  widget.worker.name[0].toUpperCase(),
                                  style: const TextStyle(color: bcAmber, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(widget.worker.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              widget.worker.occupation.displayName.toUpperCase(),
                              style: const TextStyle(color: bcAmber, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: bcNavy,
                  child: TabBar(
                    controller: _tabController,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(color: bcAmber, width: 3),
                      insets: EdgeInsets.symmetric(horizontal: 40),
                    ),
                    labelColor: bcAmber,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
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

  Widget _performanceIndicator() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      children: [
        SizedBox(
          width: 50, height: 50,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: attendancePct,
                strokeWidth: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(attendancePct > 0.8 ? bcSuccess : (attendancePct > 0.5 ? bcAmber : bcDanger)),
              ),
              Center(
                child: Text('${(attendancePct * 100).toInt()}%', 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: bcNavy)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Attendance', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Widget _statCard(String label, String value, Color color, IconData icon) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withValues(alpha: 0.1), Colors.white],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 20)),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ],
    ),
  );

  Widget _miniFstat(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bcNavy.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: bcNavy.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _markAttendance(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(18)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fact_check_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Text('MARK ATTENDANCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _giveAdvance(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: bcAmber, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.payments_rounded, color: bcNavy, size: 22),
            ),
          ),
        ],
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
