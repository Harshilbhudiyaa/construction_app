import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/responsive_layout.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/loading_indicators.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/data/models/user_model.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';

class ApprovalDashboardScreen extends StatelessWidget {
  const ApprovalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InwardMovementModel>>(
      stream: context.read<InventoryRepository>().getInwardLogsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: AppLoader()),
          );
        }

        final allLogs = snapshot.data ?? [];
        final pending = allLogs.where((l) => l.status == InwardStatus.pendingApproval).toList();
        final approvedToday = allLogs.where((l) {
          if (l.status != InwardStatus.approved) return false;
          final today = DateTime.now();
          return l.approvedAt != null &&
              l.approvedAt!.year == today.year &&
              l.approvedAt!.month == today.month &&
              l.approvedAt!.day == today.day;
        }).length;

        final auth = context.watch<AuthRepository>();
        final role = auth.userRole ?? UserRole.storekeeper;
        final canApprove = role == UserRole.admin || role == UserRole.manager;

        return Scaffold(
          backgroundColor: bcSurface,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SmartConstructionSliverAppBar(
                title: 'Approval Center',
                subtitle: 'Critical authorization queue',
                category: 'AUTHORIZATION GATE',
                isFull: true,
                headerStats: [
                  HeroStatPill(
                    label: 'Pending',
                    value: '${pending.length}',
                    icon: Icons.pending_rounded,
                    color: bcAmber,
                  ),
                  HeroStatPill(
                    label: 'Approved Today',
                    value: '$approvedToday',
                    icon: Icons.today_rounded,
                    color: bcSuccess,
                  ),
                  HeroStatPill(
                    label: 'Total Received',
                    value: '${allLogs.length}',
                    icon: Icons.inventory_2_rounded,
                    color: bcNavy,
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const ProfessionalSectionHeader(
                      title: 'Pending Inward Requests',
                      subtitle: 'Review and authorize material deliveries',
                    ),
                    _buildRequestsList(context, pending, canApprove),

                    if (allLogs.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const ProfessionalSectionHeader(
                        title: 'History',
                        subtitle: 'Previously processed inward entries',
                      ),
                      _buildHistoryList(
                          context,
                          allLogs
                              .where((l) => l.status != InwardStatus.pendingApproval)
                              .toList()),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestsList(
      BuildContext context, List<InwardMovementModel> pending, bool canApprove) {
    if (pending.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ProfessionalCard(
          useGlass: true,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: bcSuccess),
                  SizedBox(height: 16),
                  Text(
                    'All Clear!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: bcNavy),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No pending inward requests',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ResponsiveGrid(
        mobileCrossAxisCount: 1,
        tabletCrossAxisCount: 2,
        desktopCrossAxisCount: 2,
        childAspectRatio: 1.6,
        spacing: 16,
        runSpacing: 16,
        children: List.generate(pending.length, (i) {
          return StaggeredAnimation(
            index: i,
            child: _buildRequestCard(context, pending[i], canApprove),
          );
        }),
      ),
    );
  }

  Widget _buildRequestCard(
      BuildContext context, InwardMovementModel log, bool canApprove) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bcAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(log.category.icon, color: bcAmber, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.materialName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: bcNavy,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'QTY: ${log.quantity} ${log.unit}  •  ₹${log.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bcAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    color: bcAmber,
                    fontWeight: FontWeight.w900,
                    fontSize: 8,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const SteelBeamDivider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCompactInfo(Icons.local_shipping_rounded, log.transporterName),
              const SizedBox(width: 12),
              _buildCompactInfo(
                Icons.calendar_today_rounded,
                DateFormat('dd MMM, yy').format(log.createdAt),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (canApprove)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _rejectRequest(context, log.id),
                    style: TextButton.styleFrom(
                      foregroundColor: bcDanger,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('REJECT',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveRequest(context, log.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bcSuccess,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('APPROVE',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('VIEW ONLY — Contact admin to approve',
                    style: TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<InwardMovementModel> logs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(logs.take(10).length, (i) {
          final log = logs[i];
          final isApproved = log.status == InwardStatus.approved;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ProfessionalCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isApproved ? bcSuccess : bcDanger).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: isApproved ? bcSuccess : bcDanger,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.materialName.toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 12, color: bcNavy),
                        ),
                        Text(
                          '${log.quantity} ${log.unit}  •  ${log.transporterName}',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isApproved ? bcSuccess : bcDanger).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isApproved ? 'APPROVED' : 'REJECTED',
                          style: TextStyle(
                            color: isApproved ? bcSuccess : bcDanger,
                            fontWeight: FontWeight.w900,
                            fontSize: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (log.approvedAt != null)
                        Text(
                          DateFormat('dd MMM').format(log.approvedAt!),
                          style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCompactInfo(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 12, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRequest(BuildContext context, String logId) async {
    final service = context.read<InventoryRepository>();
    final auth = context.read<AuthRepository>();
    final userName = auth.userName ?? 'Admin';
    try {
      await service.approveInwardLog(logId, userName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Inward entry approved — stock updated'),
            backgroundColor: bcSuccess,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: bcDanger),
        );
      }
    }
  }

  void _rejectRequest(BuildContext context, String logId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reject Inward Entry',
            style: TextStyle(fontWeight: FontWeight.w900, color: bcNavy)),
        content: TextField(
          controller: reasonCtrl,
          decoration: InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: bcDanger, foregroundColor: Colors.white),
            onPressed: () async {
              final reason = reasonCtrl.text.isEmpty ? 'No reason provided' : reasonCtrl.text;
              Navigator.pop(dialogCtx);
              final service = context.read<InventoryRepository>();
              final auth = context.read<AuthRepository>();
              final user = auth.userName ?? 'Admin';
              await service.rejectInwardLog(logId, user, reason);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry rejected'),
                    backgroundColor: bcDanger,
                  ),
                );
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}


