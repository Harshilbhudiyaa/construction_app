import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/confirm_dialog.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/services/mock_worker_service.dart';
import 'package:construction_app/utils/feedback_helper.dart';
import 'package:construction_app/profiles/worker_form_screen.dart';
import 'package:construction_app/profiles/worker_types.dart';

class WorkerDetailScreen extends StatefulWidget {
  final String workerId;

  const WorkerDetailScreen({super.key, required this.workerId});

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  UiStatus _statusToUi(WorkerStatus s) =>
      s == WorkerStatus.active ? UiStatus.ok : UiStatus.pending;

  Future<void> _edit(Worker worker) async {
    final updated = await Navigator.push<Worker?>(
      context,
      MaterialPageRoute(builder: (_) => WorkerFormScreen(initial: worker)),
    );
    // Service handles the update now
  }

  Future<void> _delete(BuildContext context, Worker worker) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Worker?',
      message: 'Are you sure you want to permanently remove ${worker.name}? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (confirmed && mounted) {
      context.read<MockWorkerService>().deleteWorker(worker.id);
      FeedbackHelper.showSuccess(context, '${worker.name} removed from workforce');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MockWorkerService>(
      builder: (context, service, child) {
        final worker = service.workers.firstWhere(
          (w) => w.id == widget.workerId,
          orElse: () => const Worker(
            id: '',
            name: 'Not Found',
            phone: '',
            skill: '',
            shift: WorkerShift.day,
            rateType: PayRateType.perDay,
            rateAmount: 0,
            status: WorkerStatus.inactive,
            assignedWorkTypes: [],
          ),
        );

        if (worker.id.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
          return const Scaffold();
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            body: ProfessionalPage(
              title: 'Worker Profile',
              actions: [
                IconButton(
                  onPressed: () => _delete(context, worker),
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
                ),
                IconButton(
                  onPressed: () => _edit(worker),
                  icon: Icon(Icons.edit_note_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                ),
              ],
              bottom: TabBar(
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                      _buildProfileTab(worker),
                      _buildWorkTab(worker),
                      _buildFinanceTab(worker),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildStickyFooter(worker),
          ),
        );
      },
    );
  }

  Widget _buildStickyFooter(Worker worker) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
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
              onPressed: () => launchUrl(Uri.parse('tel:${worker.phone}')),
              icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.greenAccent),
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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

  Widget _buildProfileTab(Worker worker) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      children: [
        ProfessionalCard(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Hero(
                tag: 'worker_icon_${worker.id}',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
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
                      ? Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary, size: 42)
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
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
                        worker.skill.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                status: _statusToUi(worker.status),
                labelOverride: statusLabel(worker.status).toUpperCase(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ProfessionalCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('CORE METRICS'),
              const SizedBox(height: 24),
              _kv('Personnel ID', worker.id, icon: Icons.badge_rounded),
              _kv('Contact Number', worker.phone, icon: Icons.phone_android_rounded),
              _kv('Operational Shift', shiftLabel(worker.shift).toUpperCase(), icon: Icons.schedule_rounded),
              _kv('Pay Structure', rateTypeLabel(worker.rateType).toUpperCase(), icon: Icons.payments_outlined),
              _kv('Current Rate', '₹${worker.rateAmount}', icon: Icons.currency_rupee_rounded, isHighlighted: true),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildWorkTab(Worker worker) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      children: [
        ProfessionalCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('REGISTERED COMPETENCIES'),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: worker.assignedWorkTypes.map((wt) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                        const SizedBox(width: 10),
                        Text(
                          wt,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
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
                          color: const Color(0xFF78909C),
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

  Widget _buildFinanceTab(Worker worker) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      children: [
        ProfessionalCard(
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
                  color: const Color(0xFF1A237E).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: Icon(Icons.history_edu_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  label: Text(
                    'Access Full Transaction History',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
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
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                color: const Color(0xFF1A237E).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF1A237E)),
            ),
            const SizedBox(width: 16),
          ],
          Text(
            k,
            style: const TextStyle(
              color: Color(0xFF546E7A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            v,
            style: TextStyle(
              color: isHighlighted ? Colors.orangeAccent : Theme.of(context).colorScheme.onSurface,
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


