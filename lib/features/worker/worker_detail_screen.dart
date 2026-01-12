import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
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

  UiStatus _statusToUi(WorkerStatus s) =>
      s == WorkerStatus.active ? UiStatus.ok : UiStatus.pending;

  Future<void> _edit() async {
    final updated = await Navigator.push<Worker?>(
      context,
      MaterialPageRoute(builder: (_) => WorkerFormScreen(initial: _w)),
    );
    if (updated != null) {
      setState(() => _w = updated);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker profile updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: ProfessionalPage(
          title: 'Worker Profile',
          actions: [
            IconButton(
              onPressed: _edit,
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.5),
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'OVERVIEW'),
              Tab(text: 'WORKLOAD'),
              Tab(text: 'FINANCIALS'),
            ],
          ),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: TabBarView(
                children: [
                  _buildProfileTab(),
                  _buildWorkTab(),
                  _buildFinanceTab(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildStickyFooter(),
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.deepBlue2.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, -10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
            ),
            child: IconButton(
              onPressed: () => launchUrl(Uri.parse('tel:${_w.phone}')),
              icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.greenAccent),
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, AppColors.deepBlue1],
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
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.fact_check_rounded, color: Colors.white),
                label: const Text(
                  'Mark Attendance',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      children: [
        ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Hero(
                tag: 'worker_icon_${_w.id}',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 42),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _w.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _w.skill.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                status: _statusToUi(_w.status),
                labelOverride: statusLabel(_w.status).toUpperCase(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('CORE METRICS'),
              const SizedBox(height: 24),
              _kv('Personnel ID', _w.id, icon: Icons.badge_rounded),
              _kv('Contact Number', _w.phone, icon: Icons.phone_android_rounded),
              _kv('Operational Shift', shiftLabel(_w.shift).toUpperCase(), icon: Icons.schedule_rounded),
              _kv('Pay Structure', rateTypeLabel(_w.rateType).toUpperCase(), icon: Icons.payments_outlined),
              _kv('Current Rate', '₹${_w.rateAmount}', icon: Icons.currency_rupee_rounded, isHighlighted: true),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildWorkTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      children: [
        ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('REGISTERED COMPETENCIES'),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _w.assignedWorkTypes.map((wt) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 10),
                        Text(
                          wt,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.blueAccent, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Assignment to these categories is verified during daily site entry protocols.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      children: [
        ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('FINANCIAL LEDGER'),
              const SizedBox(height: 24),
              _kv('Current Week', '₹3,200', icon: Icons.trending_up_rounded),
              _kv('Last Payout', '₹2,800', icon: Icons.check_circle_rounded),
              _kv('Pending Settlement', '₹400', icon: Icons.hourglass_empty_rounded, isHighlighted: true),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.history_edu_rounded, color: Colors.white70),
                  label: const Text(
                    'Access Full Transaction History',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Colors.white.withOpacity(0.4),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _kv(String k, String v, {IconData? icon, bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: Colors.white70),
            ),
            const SizedBox(width: 16),
          ],
          Text(
            k,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            v,
            style: TextStyle(
              color: isHighlighted ? Colors.orangeAccent : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 17,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}


