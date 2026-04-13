import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/stock_entry_repository.dart';
import 'package:construction_app/core/routing/app_router.dart';
import 'package:construction_app/features/stock/widgets/stock_entry_sheets.dart';
import 'package:construction_app/data/models/stock_entry_model.dart';

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

                ...entries.map((e) {
                  final hasSubType = e.subType.isNotEmpty && e.subType != material.name;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: bcNavy.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Date column
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: bcAmber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${e.entryDate.day}', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 16, height: 1)),
                                  Text(
                                    ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][e.entryDate.month].toUpperCase(),
                                    style: const TextStyle(color: bcAmber, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(e.supplierName, 
                                            style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 14),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
                                      const SizedBox(width: 8),
                                      _EntryTypeBadge(e.entryType),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  if (hasSubType)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(e.subType, style: const TextStyle(color: bcAmber, fontSize: 11, fontWeight: FontWeight.w700)),
                                    ),
                                  Text(
                                    '${fmtQty(e.quantity)} ${e.unit} @ ₹${e.unitPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TOTAL AMOUNT', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                Text(fmt.format(e.totalAmount), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 15)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: e.pendingAmount > 0 ? bcDanger.withValues(alpha: 0.08) : bcSuccess.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    e.pendingAmount > 0 ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                                    size: 14,
                                    color: e.pendingAmount > 0 ? bcDanger : bcSuccess,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    e.pendingAmount > 0 ? 'DUE: ${fmt.format(e.pendingAmount)}' : 'FULLY PAID',
                                    style: TextStyle(
                                      color: e.pendingAmount > 0 ? bcDanger : bcSuccess,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        if (e.remarks != null && e.remarks!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: bcSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.notes_rounded, size: 14, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.remarks!,
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),

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

class _EntryTypeBadge extends StatelessWidget {
  final StockEntryType type;
  const _EntryTypeBadge(this.type);

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (type) {
      case StockEntryType.directEntry:
        color = bcAmber;
        icon = Icons.bolt_rounded;
        break;
      case StockEntryType.supplierBill:
        color = const Color(0xFF6366F1); // Indigo
        icon = Icons.receipt_long_rounded;
        break;
      case StockEntryType.miscExpense:
        color = bcDanger;
        icon = Icons.money_off_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            type.displayName.toUpperCase(),
            style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
