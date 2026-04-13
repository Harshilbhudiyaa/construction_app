import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/features/inventory/screens/add_edit_item_screen.dart';
import 'package:construction_app/features/inventory/widgets/stock_in_sheet.dart';
import 'package:construction_app/features/inventory/widgets/stock_out_sheet.dart';
import 'package:intl/intl.dart';

class ItemDetailScreen extends StatelessWidget {
  final String materialId;
  const ItemDetailScreen({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryRepository>(
      builder: (context, repo, child) {
        final material = repo.materials.firstWhere((m) => m.id == materialId);
        final profitData = repo.getWeeklyProfitData(materialId);
        final totalProfit = profitData['totalProfit'] ?? 0.0;
        final transactions = repo.transactions.where((t) => t.materialId == materialId).toList();

        return Scaffold(
          backgroundColor: bcSurface,
          body: CustomScrollView(
            slivers: [
              SmartConstructionSliverAppBar(
                title: material.name,
                subtitle: material.unitType.toUpperCase(),
                category: 'MATERIAL DETAILS',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: bcAmber, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddEditItemScreen(materialId: materialId)),
                      );
                    },
                  ),
                ],
                headerStats: [
                  HeroStatPill(
                    label: 'Current Stock',
                    value: '${material.currentStock.toStringAsFixed(0)} ${material.unitType}',
                    icon: Icons.inventory_2_rounded,
                    color: material.isLowStock ? bcDanger : bcSuccess,
                    showBorder: false,
                    onTap: () {}, // Tactile feedback
                  ),
                  HeroStatPill(
                    label: 'Sale Price',
                    value: '₹ ${material.salePrice.toStringAsFixed(0)}',
                    icon: Icons.sell_rounded,
                    color: bcInfo,
                    onTap: () {}, // Tactile feedback
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Pricing & Stock'),
                      const SizedBox(height: 12),
                      _buildStatsGrid(material),
                      const SizedBox(height: 32),
                      const SteelBeamDivider(),
                      const SizedBox(height: 16),
                      _buildSectionHeader("This Week's Performance"),
                      const SizedBox(height: 12),
                      _buildProfitSection(totalProfit),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Transaction History'),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              _buildSliverTransactionList(transactions),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
          bottomNavigationBar: _buildBottomActions(context, material),
        );
      },
    );
  }


  Widget _buildStatsGrid(ConstructionMaterial material) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pricing & Stock', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(label: 'Sale Price', value: '₹ ${material.salePrice.toStringAsFixed(0)}'),
              _StatItem(label: 'Purchase Price', value: '₹ ${material.purchasePrice.toStringAsFixed(0)}'),
              _StatItem(label: 'Tax Included', value: material.taxIncluded ? 'Yes' : 'No'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatItem(label: 'Current Stock', value: '${material.currentStock.toStringAsFixed(0)} ${material.unitType}'),
              _StatItem(label: 'Stock Value', value: '₹ ${(material.currentStock * material.purchasePrice).toStringAsFixed(0)}'),
              _StatItem(label: 'Low Stock At', value: '${material.minimumStockLimit.toStringAsFixed(0)} ${material.unitType}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitSection(double totalProfit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bcBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.trending_up_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profit (This Week)', style: TextStyle(color: bcTextSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Based on sale vs purchase', style: TextStyle(color: bcTextSecondary, fontSize: 10)),
            ],
          ),
          const Spacer(),
          Text(
            '₹ ${totalProfit.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.green, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverTransactionList(List transactions) {
    if (transactions.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Text('No transactions yet', style: TextStyle(color: bcTextSecondary)),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final txn = transactions.reversed.toList()[index];
          final isIn = txn.type.toString().contains('inward');
          return Container(
            margin: const EdgeInsets.only(bottom: 1),
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isIn ? Colors.teal : Colors.red).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isIn ? Colors.teal : Colors.red,
                  size: 20,
                ),
              ),
              title: Text(
                isIn ? 'Stock In' : 'Stock Out',
                style: const TextStyle(fontWeight: FontWeight.bold, color: bcNavy, fontSize: 14),
              ),
              subtitle: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(txn.timestamp),
                style: const TextStyle(fontSize: 11, color: bcTextSecondary),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIn ? '+' : '-'}${txn.quantity.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isIn ? Colors.teal : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Rate: ₹${txn.rate.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 10, color: bcTextSecondary),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: transactions.length,
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, ConstructionMaterial material) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => StockOutSheet(materialId: material.id),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red[700]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('STOCK OUT', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => StockInSheet(materialId: material.id),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('STOCK IN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: bcTextSecondary),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: bcNavy)),
        ],
      ),
    );
  }
}
