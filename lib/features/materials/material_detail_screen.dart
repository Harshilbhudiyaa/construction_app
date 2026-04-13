import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/stock_entry_repository.dart';
import 'package:construction_app/core/routing/app_router.dart';
import 'package:construction_app/features/stock/widgets/stock_entry_sheets.dart';

/// Material detail screen showing stock stats and full purchase history.
class MaterialDetailScreen extends StatelessWidget {
  final String materialId;
  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    final invRepo   = context.watch<InventoryRepository>();
    final stockRepo = context.watch<StockEntryRepository>();

    final material = invRepo.materials.firstWhere(
      (m) => m.id == materialId,
      orElse: () => ConstructionMaterial(
        id: '', siteId: '', name: 'Unknown',
        subType: '',
        pricePerUnit: 0, purchasePrice: 0, salePrice: 0, unitType: 'unit',
        currentStock: 0, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
    );

    if (material.id.isEmpty) {
      return const Scaffold(body: Center(child: Text('Material not found')));
    }

    final entries    = stockRepo.getEntriesForMaterial(materialId);
    final totalPurch = stockRepo.getTotalQuantityForMaterial(materialId);
    final avgPrice   = stockRepo.getAvgPriceForMaterial(materialId);
    final totalSpend = entries.fold(0.0, (s, e) => s + e.totalAmount);
    final fmt        = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final fmtQty     = (double d) => d.toStringAsFixed(d.truncateToDouble() == d ? 0 : 2);
    final isLow      = material.currentStock <= material.minimumStockLimit && material.minimumStockLimit > 0;

    return Scaffold(
      backgroundColor: bcSurface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: bcNavy,
            leading: const BackButton(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.editItem, arguments: materialId),
                tooltip: 'Edit Material',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                onPressed: () => _confirmDelete(context, invRepo, material),
                tooltip: 'Delete Material',
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: bcNavy,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bcAmber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.inventory_2_rounded, color: bcAmber, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(material.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, height: 1.1)),
                          if (material.subType.isNotEmpty)
                            Text(material.subType, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ])),
                      ]),
                      const SizedBox(height: 16),
                      // Stock badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isLow ? bcDanger.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isLow ? bcDanger.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(children: [
                          Icon(isLow ? Icons.warning_rounded : Icons.inventory_2_rounded,
                              color: isLow ? bcDanger : bcAmber, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Current Stock: ${fmtQty(material.currentStock)} ${material.unitType}',
                            style: TextStyle(color: isLow ? bcDanger : Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          if (isLow) ...[
                            const SizedBox(width: 6),
                            const Text('LOW', style: TextStyle(color: bcDanger, fontWeight: FontWeight.w900, fontSize: 10)),
                          ],
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Stats Row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCol('Current Rate', '₹${material.pricePerUnit.toStringAsFixed(0)}/${material.unitType}'),
                  _VSep(),
                  _StatCol('Avg Buy Price', avgPrice > 0 ? '₹${avgPrice.toStringAsFixed(0)}' : '—'),
                  _VSep(),
                  _StatCol('Total Spend', fmt.format(totalSpend)),
                  _VSep(),
                  _StatCol('Total Purchased', '${fmtQty(totalPurch)} ${material.unitType}'),
                ],
              ),
            ),
          ),

          // ── History ──────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('PURCHASE HISTORY', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.4)),
                const SizedBox(height: 10),

                if (entries.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Text('No purchase history. Use Stock Entry to record purchases.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ),

                ...entries.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      // Date column
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: bcAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('${e.entryDate.day}', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 14, height: 1)),
                          Text(
                            ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][e.entryDate.month],
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.supplierName, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13)),
                        Text('${fmtQty(e.quantity)} ${e.unit}',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(fmt.format(e.totalAmount), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 13)),
                        if (e.pendingAmount > 0)
                          Text('Due ${fmt.format(e.pendingAmount)}', style: const TextStyle(color: bcDanger, fontSize: 10, fontWeight: FontWeight.w700)),
                        if (e.pendingAmount == 0)
                          const Text('Paid ✓', style: TextStyle(color: bcSuccess, fontSize: 10, fontWeight: FontWeight.w700)),
                      ]),
                    ],
                  ),
                )),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAddStock(context, material),
        backgroundColor: bcNavy,
        label: const Text('Add Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_box_rounded, color: Colors.white),
      ),
    );
  }

  void _showQuickAddStock(BuildContext context, ConstructionMaterial material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DirectEntrySheet(initialMaterial: material),
    );
  }

  void _confirmDelete(BuildContext context, InventoryRepository repo, ConstructionMaterial material) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Material?', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to delete "${material.name}"? This action cannot be undone.', 
            style: const TextStyle(color: bcTextSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: bcTextSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              await repo.deleteMaterial(material.id);
              if (context.mounted) Navigator.pop(context); // Back to catalog
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${material.name} deleted'), backgroundColor: bcNavy),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: bcDanger, foregroundColor: Colors.white),
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  const _StatCol(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 13)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
  ]);
}

class _VSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 38, color: const Color(0xFFE2E8F0));
}
