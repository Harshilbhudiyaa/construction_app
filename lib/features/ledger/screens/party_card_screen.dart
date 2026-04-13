import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/shared/widgets/status_badge.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:provider/provider.dart';

class PartyCardScreen extends StatelessWidget {
  final PartyModel party;
  const PartyCardScreen({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    final inventoryService = context.read<InventoryRepository>();

    return StreamBuilder<List<ConstructionMaterial>>(
      stream: inventoryService.getMaterialsStream(),
      builder: (context, snapshot) {
        final allMaterials = snapshot.data ?? [];
        final partyMaterials = allMaterials.where((m) => m.partyId == party.id).toList();

        final totalBusiness = partyMaterials.fold(0.0, (sum, m) => sum + m.totalAmount);
        final totalPaid = partyMaterials.fold(0.0, (sum, m) => sum + m.paidAmount);
        final totalPending = partyMaterials.fold(0.0, (sum, m) => sum + m.pendingAmount);

        return Scaffold(
          body: ProfessionalBackground(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SmartConstructionSliverAppBar(
                  title: party.name,
                  subtitle: 'Detailed Supplier Ledger',
                  category: 'PARTIES MODULE',
                ),
              ],
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSummaryHeader(totalBusiness, totalPaid, totalPending),
                    const ProfessionalSectionHeader(
                      title: 'Supply History',
                      subtitle: 'All materials and stocks supplied by this party',
                    ),
                    if (partyMaterials.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: EmptyState(
                          icon: Icons.inventory_2_rounded,
                          title: 'No supplies found',
                          message: 'This party hasn\'t supplied any materials yet.',
                        ),
                      )
                    else
                      _buildMaterialsList(context, partyMaterials),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
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
              _buildSummaryCard('TOTAL BUSINESS', total, bcNavy),
              const SizedBox(width: 12),
              _buildSummaryCard('PAID AMOUNT', paid, bcSuccess),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard('PENDING BALANCE', pending, bcDanger, isWide: true),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color, {bool isWide = false}) {
    return Expanded(
      flex: 1,
      child: ProfessionalCard(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        useGlass: true,
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
              style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1),
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
            useGlass: true,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: bcNavy.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.foundation_rounded, color: bcNavy, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          'Stock: ${m.currentStock} ${m.unitType}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                      const SizedBox(height: 4),
                      StatusBadge(
                        label: m.pendingAmount <= 0 ? 'CLEARED' : 'PENDING',
                        type: m.pendingAmount <= 0 ? StatusBadgeType.success : StatusBadgeType.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


