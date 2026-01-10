import 'package:flutter/material.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import 'approval_detail_screen.dart';

enum ApprovalStatus { pending, approved, rejected }

class ApprovalsQueueScreen extends StatefulWidget {
  const ApprovalsQueueScreen({super.key});

  @override
  State<ApprovalsQueueScreen> createState() => _ApprovalsQueueScreenState();
}

class _ApprovalsQueueScreenState extends State<ApprovalsQueueScreen> {
  String _query = '';
  ApprovalStatus? _filter;

  List<ApprovalItem> _items = [
    ApprovalItem(
      id: "AP-1205",
      workerName: "Ramesh Kumar",
      workerRole: "Senior Mason",
      workType: "Structural Concrete",
      site: "Metropolis Heights",
      startTime: "08:00 AM",
      endTime: "12:00 PM",
      duration: "04:00",
      status: ApprovalStatus.pending,
      submittedAt: "12:05 PM",
    ),
    ApprovalItem(
      id: "AP-1204",
      workerName: "Suresh Patel",
      workerRole: "Junior Helper",
      workType: "Surface Preparation",
      site: "Metropolis Heights",
      startTime: "09:00 AM",
      endTime: "11:00 AM",
      duration: "02:00",
      status: ApprovalStatus.pending,
      submittedAt: "11:15 AM",
    ),
    ApprovalItem(
      id: "AP-1203",
      workerName: "Amit Shah",
      workerRole: "Operator",
      workType: "Machine Calib.",
      site: "Site B North",
      startTime: "07:30 AM",
      endTime: "08:30 AM",
      duration: "01:00",
      status: ApprovalStatus.approved,
      submittedAt: "08:45 AM",
    ),
  ];

  UiStatus _toUi(ApprovalStatus s) {
    switch (s) {
      case ApprovalStatus.pending: return UiStatus.pending;
      case ApprovalStatus.approved: return UiStatus.approved;
      case ApprovalStatus.rejected: return UiStatus.rejected;
    }
  }

  List<ApprovalItem> get _filtered {
    final q = _query.trim().toLowerCase();
    return _items.where((a) {
      if (_filter != null && a.status != _filter) return false;
      if (q.isEmpty) return true;
      final hay = '${a.id} ${a.workerName} ${a.workerRole} ${a.workType} ${a.site}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Verification Queue',
      children: [
        AppSearchField(
          hint: 'Search by UID, worker or task...',
          onChanged: (v) => setState(() => _query = v),
        ),
        
        const ProfessionalSectionHeader(
          title: 'Classification',
          subtitle: 'Filter requests by lifecycle state',
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterBtn(
                    label: 'All Activity',
                    isSelected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterBtn(
                    label: 'Pending',
                    isSelected: _filter == ApprovalStatus.pending,
                    onTap: () => setState(() => _filter = ApprovalStatus.pending),
                  ),
                  const SizedBox(width: 8),
                  _FilterBtn(
                    label: 'Approved',
                    isSelected: _filter == ApprovalStatus.approved,
                    onTap: () => setState(() => _filter = ApprovalStatus.approved),
                  ),
                  const SizedBox(width: 8),
                  _FilterBtn(
                    label: 'Rejected',
                    isSelected: _filter == ApprovalStatus.rejected,
                    onTap: () => setState(() => _filter = ApprovalStatus.rejected),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const ProfessionalSectionHeader(
          title: 'Active Sessions',
          subtitle: 'Worklogs awaiting engineering sign-off',
        ),
        
        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: EmptyState(
              icon: Icons.fact_check_rounded,
              title: 'No pending logs',
              message: 'Database is current. All logs processed.',
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final a = _filtered[index];
              return StaggeredAnimation(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ProfessionalCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        '${a.workerName} • ${a.workType}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppColors.deepBlue1,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${a.workerRole} • ${a.site}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                '${a.startTime} – ${a.endTime} (${a.duration}h)',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                              const Spacer(),
                              Text(
                                a.id,
                                style: TextStyle(color: Colors.grey[400], fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: StatusChip(status: _toUi(a.status)),
                      onTap: () async {
                        final updated = await Navigator.push<ApprovalItem?>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApprovalDetailScreen(item: a),
                          ),
                        );
                        if (updated != null) {
                          setState(() {
                            final idx = _items.indexWhere((x) => x.id == updated.id);
                            if (idx != -1) _items[idx] = updated;
                          });
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterBtn({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepBlue1 : AppColors.deepBlue1.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.deepBlue1 : AppColors.deepBlue1.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.deepBlue1,
          ),
        ),
      ),
    );
  }
}


class ApprovalItem {
  final String id;
  final String workerName;
  final String workerRole;
  final String workType;
  final String site;
  final String startTime;
  final String endTime;
  final String duration;
  final ApprovalStatus status;
  final String submittedAt;
  final String? remark;

  const ApprovalItem({
    required this.id,
    required this.workerName,
    required this.workerRole,
    required this.workType,
    required this.site,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.status,
    required this.submittedAt,
    this.remark,
  });

  ApprovalItem copyWith({ApprovalStatus? status, String? remark}) {
    return ApprovalItem(
      id: id,
      workerName: workerName,
      workerRole: workerRole,
      workType: workType,
      site: site,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      status: status ?? this.status,
      submittedAt: submittedAt,
      remark: remark ?? this.remark,
    );
  }
}
