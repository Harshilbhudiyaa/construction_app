import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/services/inventory_service.dart';
import 'package:construction_app/modules/inventory/models/material_model.dart';
import 'package:construction_app/modules/inventory/models/party_model.dart';
import 'package:construction_app/modules/inventory/material_detail_screen.dart';

class PartyCardScreen extends StatelessWidget {
  final PartyModel party;
  const PartyCardScreen({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    final inventoryService = InventoryService();

    return StreamBuilder<List<ConstructionMaterial>>(
      stream: inventoryService.getMaterialsStream(),
      builder: (context, snapshot) {
        final allMaterials = snapshot.data ?? [];
        final partyMaterials = allMaterials.where((m) => m.partyId == party.id).toList();

        final totalBusiness = partyMaterials.fold(0.0, (sum, m) => sum + m.totalAmount);
        final totalPaid = partyMaterials.fold(0.0, (sum, m) => sum + m.paidAmount);
        final totalPending = partyMaterials.fold(0.0, (sum, m) => sum + m.pendingAmount);

        return ProfessionalPage(
          title: party.name,
          subtitle: 'Detailed Supplier Ledger',
          children: [
            _buildSummaryHeader(totalBusiness, totalPaid, totalPending),
            const ProfessionalSectionHeader(
              title: 'Supply History',
              subtitle: 'All materials and stocks supplied by this party',
            ),
            if (partyMaterials.isEmpty)
              const EmptyState(
                icon: Icons.inventory_2_rounded,
                title: 'No supplies found',
                message: 'This party hasn\'t supplied any materials yet.',
              )
            else
              _buildMaterialsList(context, partyMaterials),
          ],
        );
      },
    );
  }

  Widget _buildSummaryHeader(double total, double paid, double pending) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          Row(
            children: [
              _buildSummaryCard('TOTAL BUSINESS', total, Colors.blueAccent),
              const SizedBox(width: 12),
              _buildSummaryCard('PAID AMOUNT', paid, Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard('PENDING BALANCE', pending, Colors.redAccent, isWide: true),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color, {bool isWide = false}) {
    return Expanded(
      flex: isWide ? 1 : 1,
      child: ProfessionalCard(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₹${NumberFormat('#,##,###').format(value)}',
              style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF78909C), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList(BuildContext context, List<ConstructionMaterial> materials) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: materials.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final m = materials[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProfessionalCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MaterialDetailScreen(materialId: m.id))),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.deepBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(m.category.icon, color: AppColors.deepBlue, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            'Stock: ${m.currentStock} ${m.unitType.label}',
                            style: const TextStyle(color: AppColors.steelBlue, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${NumberFormat('#,##,###').format(m.totalAmount)}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        StatusChip(
                          status: m.pendingAmount <= 0 ? UiStatus.approved : UiStatus.pending,
                          labelOverride: m.pendingAmount <= 0 ? 'CLEARED' : 'PENDING',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
