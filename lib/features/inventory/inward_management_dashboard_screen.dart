import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import 'models/inward_movement_model.dart';
import 'models/inventory_detail_model.dart';
import 'inward_entry_form_screen.dart';
import 'inward_bill_view_screen.dart';

class InwardManagementDashboardScreen extends StatefulWidget {
  const InwardManagementDashboardScreen({super.key});

  @override
  State<InwardManagementDashboardScreen> createState() => _InwardManagementDashboardScreenState();
}

class _InwardManagementDashboardScreenState extends State<InwardManagementDashboardScreen> {
  final List<InwardMovementModel> _mockItems = [
    InwardMovementModel(
      id: 'INW-7701',
      vehicleType: 'Dumper / Truck',
      vehicleNumber: 'GJ01XY5521',
      vehicleCapacity: '12 Tons',
      transporterName: 'Surat Logistics',
      driverName: 'Amit Singh',
      driverMobile: '9876543210',
      driverLicense: 'DL-GJ-001',
      materialName: 'Sand',
      category: MaterialCategory.sand,
      quantity: 10.5,
      unit: 'tons',
      photoProofs: [],
      ratePerUnit: 1200,
      transportCharges: 5000,
      taxPercentage: 18,
      totalAmount: 20760,
      status: InwardStatus.pendingApproval,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    InwardMovementModel(
      id: 'INW-7698',
      vehicleType: 'Tractor',
      vehicleNumber: 'GJ05ZZ1234',
      vehicleCapacity: '3 Tons',
      transporterName: 'Local Transport',
      driverName: 'Kishore Kumar',
      driverMobile: '9123456789',
      driverLicense: 'DL-GJ-005',
      materialName: 'Bricks',
      category: MaterialCategory.bricks,
      quantity: 5000,
      unit: 'units',
      photoProofs: [],
      ratePerUnit: 7,
      transportCharges: 2000,
      taxPercentage: 12,
      totalAmount: 41440,
      status: InwardStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      approvedBy: 'Admin',
      approvedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Inward Logistics',
      actions: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InwardEntryFormScreen())),
          icon: const Icon(Icons.add_circle_rounded, color: Colors.white),
        ),
      ],
      children: [
        _buildDashboardSummary(),

        const ProfessionalSectionHeader(
          title: 'Strategic Verification',
          subtitle: 'Movements awaiting administrative approval',
        ),
        _buildMovementList(InwardStatus.pendingApproval),

        const ProfessionalSectionHeader(
          title: 'Immutable Audit Trail',
          subtitle: 'Verified and completed inward deliveries',
        ),
        _buildMovementList(InwardStatus.approved),

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
        useGlass: true,
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(val, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 4),
            Text(title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementList(InwardStatus filter) {
    final items = _mockItems.where((x) => x.status == filter).toList();
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: EmptyState(
          icon: filter == InwardStatus.pendingApproval ? Icons.fact_check_rounded : Icons.history_rounded,
          title: filter == InwardStatus.pendingApproval ? 'No Pending Approvals' : 'No History Records',
          message: 'Strategic logistics pipeline is clean.',
          useGlass: true,
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
              useGlass: true,
              padding: EdgeInsets.zero,
              child: InkWell(
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
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.vehicleNumber} • ${item.driverName}',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600),
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
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
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
