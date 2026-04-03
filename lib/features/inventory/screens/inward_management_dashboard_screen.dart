import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/shared/widgets/status_badge.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'inward_bill_view_screen.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/responsive_layout.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/shared/widgets/loading_indicators.dart';
import 'inward_entry_form_screen.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';

import 'package:construction_app/core/services/workflow_service.dart';

class InwardManagementDashboardScreen extends StatefulWidget {
  final String? activeSiteId;
  const InwardManagementDashboardScreen({super.key, this.activeSiteId});

  @override
  State<InwardManagementDashboardScreen> createState() => _InwardManagementDashboardScreenState();
}

class _InwardManagementDashboardScreenState extends State<InwardManagementDashboardScreen> {
  late final InventoryRepository _inventoryService;
  late final WorkflowService _workflowService;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _inventoryService = context.read<InventoryRepository>();
    _workflowService = context.read<WorkflowService>();
  }

  Future<void> _approveLog(InwardMovementModel entry) async {
    try {
      final auth = context.read<AuthRepository>();
      await _workflowService.approveInwardEntry(entry, performedBy: auth.userName ?? 'Admin');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log approved! Inventory and Party Ledger updated.'),
            backgroundColor: bcSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approval failed: $e'), backgroundColor: bcDanger));
      }
    } finally {
    }
  }

  Future<void> _rejectLog(String logId) async {
    try {
      final auth = context.read<AuthRepository>();
      await _inventoryService.rejectInwardLog(logId, auth.userName ?? 'Admin', 'Manually Rejected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log rejected. No stock added.'), backgroundColor: bcDanger));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rejection failed: $e'), backgroundColor: bcDanger));
      }
    } finally {
    }
  }

  void _editLog(InwardMovementModel log) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InwardEntryFormScreen(siteId: log.siteId, editingLog: log),
      ),
    );
  }

  Future<void> _deleteLog(String logId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Permanently remove this inward entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE', style: TextStyle(color: bcDanger))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _inventoryService.deleteInwardLog(logId);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log deleted successfully.')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deletion failed: $e'), backgroundColor: bcDanger));
      } finally {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bcSurface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SmartConstructionSliverAppBar(
            title: 'Inward Logistics',
            subtitle: 'Supply chain verification',
            category: 'INVENTORY MODULE',
            isFull: true,
            headerStats: [
              const HeroStatPill(label: 'Pending', value: '1', icon: Icons.pending_actions_rounded, color: bcAmber),
              const HeroStatPill(label: 'Transit', value: '3', icon: Icons.local_shipping_rounded, color: bcNavy),
              const HeroStatPill(label: 'Approved', value: '5', icon: Icons.check_circle_rounded, color: bcSuccess),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppSearchField(
                      hint: 'Search by material, driver, vehicle...',
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLogsStream(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


/* Unused
  Widget _summaryPill(String label, String value, Color color) {
...
  }
*/

  Widget _buildLogsStream() {
    return StreamBuilder<List<InwardMovementModel>>(
      stream: _inventoryService.getInwardLogsStream(siteId: widget.activeSiteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(40), child: AppLoader(size: 32)));
        }
        
        final allItems = snapshot.data ?? [];
        final filteredItems = allItems.where((x) {
          final query = _searchQuery.toLowerCase();
          return x.materialName.toLowerCase().contains(query) || x.vehicleNumber.toLowerCase().contains(query) || x.driverName.toLowerCase().contains(query);
        }).toList();
        
        final pending = filteredItems.where((x) => x.status == InwardStatus.pendingApproval).toList();
        final historical = filteredItems.where((x) => x.status != InwardStatus.pendingApproval).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pending.isNotEmpty && context.read<AuthRepository>().canApprove) ...[
              _buildSectionTitle('AWAITING VERIFICATION'),
              _buildInwardList(pending),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle('RECENT DELIVERIES'),
            _buildInwardList(historical),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SteelBeamDivider(width: 30, height: 2),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: bcNavy, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildInwardList(List<InwardMovementModel> items) {
    if (items.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No industrial records found', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11))));
    }

    return ResponsiveGrid(
      mobileCrossAxisCount: 1,
      tabletCrossAxisCount: 2,
      desktopCrossAxisCount: 3,
      childAspectRatio: 2.8,
      spacing: 16,
      runSpacing: 16,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final auth = context.read<AuthRepository>();
        return StaggeredAnimation(
          index: index,
          child: _InwardCard(
            item: item,
            onApprove: auth.canApprove ? () => _showApprovalDialog(item) : () {},
            onEdit: () => _editLog(item),
            onDelete: () => _deleteLog(item.id),
          ),
        );
      }),
    );
  }

  void _showApprovalDialog(InwardMovementModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('PURGE VERIFICATION', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900)),
        content: Text('Authorize arrival of ${item.quantity} ${item.unit} ${item.materialName} into active site stock?'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _rejectLog(item.id); }, child: const Text('REJECT', style: TextStyle(color: bcDanger, fontWeight: FontWeight.bold))),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ABORT', style: TextStyle(color: bcNavy))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _approveLog(item); },
            style: ElevatedButton.styleFrom(backgroundColor: bcSuccess, foregroundColor: Colors.white),
            child: const Text('AUTHORIZE'),
          ),
        ],
      ),
    );
  }
}

class _InwardCard extends StatelessWidget {
  final InwardMovementModel item;
  final VoidCallback onApprove;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _InwardCard({
    required this.item, 
    required this.onApprove,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = item.status == InwardStatus.pendingApproval;
    final auth = context.watch<AuthRepository>();

    return ProfessionalCard(
      useGlass: true,
      padding: EdgeInsets.zero,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InwardBillViewScreen(item: item))),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InwardBillViewScreen(item: item))),
        onLongPress: (isPending && auth.canApprove) ? onApprove : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.materialName.toUpperCase(),
                      style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.quantity} ${item.unit} • ${item.vehicleNumber}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.driverName,
                      style: TextStyle(color: bcNavy.withValues(alpha: 0.4), fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isPending)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (auth.canEdit)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 16),
                            onPressed: onEdit,
                          ),
                        if (auth.canEdit) const SizedBox(width: 8),
                        if (auth.canDelete)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.delete_rounded, color: bcDanger, size: 16),
                            onPressed: onDelete,
                          ),
                        if (auth.canDelete) const SizedBox(width: 8),
                      ],
                    ),
                  StatusBadge(
                    label: item.status == InwardStatus.approved ? 'APPROVED' : (item.status == InwardStatus.rejected ? 'REJECTED' : 'PENDING'),
                    type: item.status == InwardStatus.approved ? StatusBadgeType.success : (item.status == InwardStatus.rejected ? StatusBadgeType.danger : StatusBadgeType.warning),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${item.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    final color = item.status == InwardStatus.approved ? bcSuccess : (item.status == InwardStatus.rejected ? bcDanger : bcAmber);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(item.status == InwardStatus.approved ? Icons.verified_rounded : Icons.pending_rounded, color: color, size: 20),
    );
  }
}
