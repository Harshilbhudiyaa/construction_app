import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'models/inward_movement_model.dart';
import 'inward_entry_form_screen.dart';
import 'inward_bill_view_screen.dart';
import 'package:construction_app/services/inventory_service.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';

class InwardManagementDashboardScreen extends StatefulWidget {
  final String? activeSiteId;
  const InwardManagementDashboardScreen({super.key, this.activeSiteId});

  @override
  State<InwardManagementDashboardScreen> createState() => _InwardManagementDashboardScreenState();
}

class _InwardManagementDashboardScreenState extends State<InwardManagementDashboardScreen> {
  final _inventoryService = InventoryService();
  bool _isProcessing = false;
  String _searchQuery = '';

  Future<void> _approveLog(String logId) async {
    setState(() => _isProcessing = true);
    try {
      await _inventoryService.approveInwardLog(logId, 'Admin'); // Mocking admin for now
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log approved and Inventory updated!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Approval failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Inward Logistics',
      actions: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InwardEntryFormScreen(siteId: widget.activeSiteId))),
          icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF1A237E)),
        ),
      ],
      children: [
        _buildDashboardSummary(),
        
        AppSearchField(
          hint: 'Search by material, driver, vehicle...',
          onChanged: (v) => setState(() => _searchQuery = v),
        ),

        StreamBuilder<List<InwardMovementModel>>(
          stream: _inventoryService.getInwardLogsStream(siteId: widget.activeSiteId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
            }
            
            final allItems = snapshot.data ?? [];
            final filteredItems = allItems.where((x) {
              final query = _searchQuery.toLowerCase();
              return x.materialName.toLowerCase().contains(query) ||
                  x.vehicleNumber.toLowerCase().contains(query) ||
                  x.driverName.toLowerCase().contains(query) ||
                  x.id.toLowerCase().contains(query);
            }).toList();
            
            final pending = filteredItems.where((x) => x.status == InwardStatus.pendingApproval).toList();
            final approved = filteredItems.where((x) => x.status == InwardStatus.approved).toList();

            return Column(
              children: [
                const ProfessionalSectionHeader(
                  title: 'Strategic Verification',
                  subtitle: 'Movements awaiting administrative approval',
                ),
                _buildInwardList(pending, InwardStatus.pendingApproval),

                const ProfessionalSectionHeader(
                  title: 'Delivery History',
                  subtitle: 'Verified and completed inward deliveries',
                ),
                _buildInwardList(approved, InwardStatus.approved),
              ],
            );
          },
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDashboardSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _summaryCard('Active Proofs', '1', Colors.orangeAccent),
          const SizedBox(width: 12),
          _summaryCard('In-Transit', '3', Colors.blueAccent),
          const SizedBox(width: 12),
          _summaryCard('Approved Today', '5', Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String val, Color color) {
    return Expanded(
      child: ProfessionalCard(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(val, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 4),
            Text(title.toUpperCase(), style: TextStyle(color: const Color(0xFF78909C), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildInwardList(List<InwardMovementModel> items, InwardStatus filter) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: EmptyState(
          icon: filter == InwardStatus.pendingApproval ? Icons.fact_check_rounded : Icons.history_rounded,
          title: filter == InwardStatus.pendingApproval ? 'No Pending Approvals' : 'No History Records',
          message: 'Strategic logistics pipeline is clean.',
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return StaggeredAnimation(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProfessionalCard(
              padding: EdgeInsets.zero,
              child: InkWell(
                onLongPress: item.status == InwardStatus.pendingApproval 
                    ? () => _showApprovalDialog(item)
                    : null,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InwardBillViewScreen(item: item))),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildInwardIcon(item),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.materialName} • ${item.quantity}${item.unit[0]}',
                              style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.vehicleNumber} • ${item.driverName}',
                              style: TextStyle(color: const Color(0xFF78909C), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoBadge(item.id, Colors.blueAccent),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusChip(
                            status: item.status == InwardStatus.approved ? UiStatus.approved : UiStatus.pending,
                            labelOverride: item.status == InwardStatus.approved ? 'APPROVED' : 'PENDING',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${NumberFormat('#,##,###').format(item.totalAmount)}',
                            style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showApprovalDialog(InwardMovementModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Approve Inward Log', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to approve ${item.quantity} ${item.unit} of ${item.materialName}?\nThis will update inventory stock immediately.', style: const TextStyle(color: Color(0xFF546E7A))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Color(0xFF78909C)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveLog(item.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('APPROVE & UPDATE STOCK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInwardIcon(InwardMovementModel item) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: (item.status == InwardStatus.approved ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        item.status == InwardStatus.approved ? Icons.inventory_rounded : Icons.pending_actions_rounded,
        color: item.status == InwardStatus.approved ? Colors.greenAccent : Colors.orangeAccent,
        size: 24,
      ),
    );
  }

  Widget _buildInfoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}
