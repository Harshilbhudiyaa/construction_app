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
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Deployment'),
              Tab(text: 'Earnings'),
            ],
          ),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse('tel:${_w.phone}')),
              icon: const Icon(Icons.phone_rounded, size: 20),
              label: const Text('Call Now', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.assignment_turned_in_rounded, size: 20),
              label: const Text('Mark Attendance', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlue1,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Row(
              children: [
                Hero(
                  tag: 'worker_icon_${_w.id}',
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.gradientColors),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlue1.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 38),
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
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepBlue1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_w.skill} • ${_w.id}',
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  status: _statusToUi(_w.status),
                  labelOverride: statusLabel(_w.status),
                ),
              ],
            ),
          ),
        ),
        const ProfessionalSectionHeader(
          title: 'Employment Details',
          subtitle: 'Core operational and contact metrics',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _kv('Phone', _w.phone, icon: Icons.phone_android_rounded),
                const Divider(height: 32),
                _kv('Shift', shiftLabel(_w.shift), icon: Icons.schedule_rounded),
                const Divider(height: 32),
                _kv('Rate Basis', rateTypeLabel(_w.rateType), icon: Icons.payments_outlined),
                const Divider(height: 32),
                _kv('Current Rate', '₹${_w.rateAmount}', icon: Icons.currency_rupee_rounded, isHighlighted: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildWorkTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const ProfessionalSectionHeader(
          title: 'Authorized Work Categories',
          subtitle: 'Competencies registered in the system',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 12,
              children: _w.assignedWorkTypes.map((wt) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue1.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.deepBlue1.withOpacity(0.1)),
                  ),
                  child: Text(
                    wt,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
              ),
              title: const Text(
                'Security Check',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue1),
              ),
              subtitle: const Text(
                'Assignment to these categories is verified daily via QR scan at site entry.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const ProfessionalSectionHeader(
          title: 'Earnings Summary',
          subtitle: 'Current cycle financial status',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _kv('This Week', '₹3,200', icon: Icons.trending_up_rounded),
                const Divider(height: 32),
                _kv('Last Payout', '₹2,800', icon: Icons.check_circle_rounded),
                const Divider(height: 32),
                _kv('Outstanding', '₹400', icon: Icons.pending_rounded, isHighlighted: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('View Detailed Ledger', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kv(String k, String v, {IconData? icon, bool isHighlighted = false}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 12),
        ],
        Text(
          k,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          v,
          style: TextStyle(
            color: isHighlighted ? Colors.orange[900] : AppColors.deepBlue1,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
