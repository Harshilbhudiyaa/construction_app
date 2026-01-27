import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/approval_service.dart';
import 'package:construction_app/governance/approvals/models/action_request.dart';
import 'approval_detail_screen.dart';

// enum ApprovalStatus removed, imported from ActionRequest model

class ApprovalsQueueScreen extends StatefulWidget {
  final String? activeSiteId;
  const ApprovalsQueueScreen({super.key, this.activeSiteId});

  @override
  State<ApprovalsQueueScreen> createState() => _ApprovalsQueueScreenState();
}

class _ApprovalsQueueScreenState extends State<ApprovalsQueueScreen> {
  String _query = '';
  ApprovalStatus? _filter;

  // Hardcoded items removed, now using ApprovalService

  UiStatus _toUi(ApprovalStatus s) {
    switch (s) {
      case ApprovalStatus.pending: return UiStatus.pending;
      case ApprovalStatus.approved: return UiStatus.approved;
      case ApprovalStatus.rejected: return UiStatus.rejected;
    }
  }

  List<ActionRequest> _filterRequests(List<ActionRequest> requests) {
    final q = _query.trim().toLowerCase();
    return requests.where((a) {
      if (widget.activeSiteId != null && a.siteId != widget.activeSiteId) return false;
      if (_filter != null) {
        if (_filter == ApprovalStatus.pending && a.status != ApprovalStatus.pending) return false;
        if (_filter == ApprovalStatus.approved && a.status != ApprovalStatus.approved) return false;
        if (_filter == ApprovalStatus.rejected && a.status != ApprovalStatus.rejected) return false;
      }
      if (q.isEmpty) return true;
      final hay = '${a.id} ${a.requesterName} ${a.entityType} ${a.action.name}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Verification Queue',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.history_rounded, color: Colors.white),
        ),
      ],
      children: [
        // 1. Search Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppSearchField(
            hint: 'Search by UID, worker or task...',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        
        // 2. Filter Section
        const ProfessionalSectionHeader(
          title: 'Classification',
          subtitle: 'Filter requests by lifecycle state',
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
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
        
        Consumer<ApprovalService>(
          builder: (context, approvalService, child) {
            final requests = _filterRequests(approvalService.requests);

            return Column(
              children: [
                // 3. Stats Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildMiniStat('TOTAL', requests.length.toString(), Colors.blueAccent),
                      const SizedBox(width: 12),
                      _buildMiniStat('PENDING', requests.where((e) => e.status == ApprovalStatus.pending).length.toString(), Colors.orangeAccent),
                      const SizedBox(width: 12),
                      _buildMiniStat('SITE', widget.activeSiteId ?? 'ALL', Colors.greenAccent),
                    ],
                  ),
                ),

                const ProfessionalSectionHeader(
                  title: 'Verification Queue',
                  subtitle: 'Action requests awaiting administrative sign-off',
                ),
                
                if (requests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: EmptyState(
                      icon: Icons.fact_check_rounded,
                      title: 'Queue is Clear',
                      message: 'No pending action requests for this context.',
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final a = requests[index];
                      return StaggeredAnimation(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: _buildActionRequestTile(a),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: const Color(0xFF78909C), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Color(0xFF1A237E), fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRequestTile(ActionRequest a) {
    final statusColor = a.status == ApprovalStatus.pending 
        ? Colors.orangeAccent 
        : (a.status == ApprovalStatus.approved ? Colors.greenAccent : Colors.redAccent);

    return ProfessionalCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ApprovalDetailScreen(request: a)),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getEntityIcon(a.entityType), color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${a.action.name.toUpperCase()} ${a.entityType.toUpperCase()}',
                          style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          'Requested by ${a.requesterName}',
                          style: TextStyle(color: const Color(0xFF78909C), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: a.status),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTileDetail(Icons.location_on_rounded, a.siteId),
                    const SizedBox(width: 16),
                    _buildTileDetail(Icons.schedule_rounded, DateFormat('MMM dd, HH:mm').format(a.createdAt)),
                    const Spacer(),
                    Text(a.id, style: TextStyle(color: const Color(0xFF1A237E).withOpacity(0.1), fontSize: 10, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEntityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'worker': return Icons.badge_rounded;
      case 'tool': return Icons.build_circle_rounded;
      case 'machine': return Icons.precision_manufacturing_rounded;
      case 'material': return Icons.inventory_2_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final ApprovalStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    String label = 'UNKNOWN';
    switch (status) {
      case ApprovalStatus.pending: color = Colors.orangeAccent; label = 'PENDING'; break;
      case ApprovalStatus.approved: color = Colors.greenAccent; label = 'APPROVED'; break;
      case ApprovalStatus.rejected: color = Colors.redAccent; label = 'REJECTED'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}

Widget _buildTileDetail(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 12, color: const Color(0xFF1A237E).withOpacity(0.4)),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(color: Color(0xFF546E7A), fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterBtn({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A237E) : const Color(0xFF1A237E).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF1A237E) : const Color(0xFF1A237E).withOpacity(0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : const Color(0xFF1A237E).withOpacity(0.5),
            ),
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
