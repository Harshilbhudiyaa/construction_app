import 'package:flutter/material.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker updated (UI-only)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ProfessionalPage(
        title: 'Worker Details',
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
            Tab(text: 'Profile'),
            Tab(text: 'Work'),
            Tab(text: 'Finance'),
          ],
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
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
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.gradientColors),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBlue1.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _w.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepBlue1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.work_outline_rounded, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${_w.skill} • ${shiftLabel(_w.shift)} Shift',
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                        ],
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
          title: 'Account Information',
          subtitle: 'Core contact and contract details',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _kv('Worker ID', _w.id, icon: Icons.badge_outlined),
                const Divider(height: 32),
                _kv('Phone Number', _w.phone, icon: Icons.phone_android_rounded),
                const Divider(height: 32),
                _kv('Primary Skill', _w.skill, icon: Icons.bolt_rounded),
                const Divider(height: 32),
                _kv('Pay Structure', rateTypeLabel(_w.rateType), icon: Icons.payments_outlined),
                const Divider(height: 32),
                _kv('Agreed Rate', '₹${_w.rateAmount}', icon: Icons.currency_rupee_rounded, isHighlighted: true),
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
          title: 'Certified Competencies',
          subtitle: 'Tasks authorized for this profile',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _w.assignedWorkTypes.map((wt) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue1.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.deepBlue1.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    wt,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.orange, size: 20),
              ),
              title: const Text(
                'Security Protocol',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.deepBlue1),
              ),
              subtitle: const Text(
                'Access to unauthorized task categories is restricted via biometric verification at the kiosk.',
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
          title: 'Financial Cycle',
          subtitle: 'Current summary and accruals',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _kv('Weekly Accrued', '₹2,450', icon: Icons.trending_up_rounded),
                const Divider(height: 32),
                _kv('Disbursed Total', '₹1,800', icon: Icons.check_circle_outline_rounded),
                const Divider(height: 32),
                _kv('Net Arrears', '₹650', icon: Icons.pending_actions_rounded, isHighlighted: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepBlue1,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.history_rounded, size: 20),
                    label: const Text(
                      'Full Transaction History',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
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
            color: isHighlighted ? Colors.orange[800] : AppColors.deepBlue1,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
