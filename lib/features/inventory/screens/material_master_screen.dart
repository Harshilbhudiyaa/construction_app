import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/features/inventory/screens/add_edit_item_screen.dart';
import 'package:construction_app/features/inventory/screens/item_detail_screen.dart';
import 'package:construction_app/features/inventory/widgets/stock_in_sheet.dart';
import 'package:construction_app/features/inventory/widgets/stock_out_sheet.dart';

class MaterialMasterScreen extends StatefulWidget {
  const MaterialMasterScreen({super.key});

  @override
  State<MaterialMasterScreen> createState() => _MaterialMasterScreenState();
}

class _MaterialMasterScreenState extends State<MaterialMasterScreen> {
  String _searchQuery = '';
  bool _showLowStockOnly = false;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<InventoryRepository>();
    final siteRepo = context.watch<SiteRepository>();
    final activeSite = siteRepo.selectedSite;

    final siteMaterials = repo.materials
        .where((m) => activeSite == null || m.siteId == activeSite.id)
        .toList();

    final materials = siteMaterials.where((m) {
      final matchesSearch =
          m.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLowStock = !_showLowStockOnly || m.isLowStock;
      return matchesSearch && matchesLowStock;
    }).toList();

    final lowStockCount = siteMaterials.where((m) => m.isLowStock).length;
    final totalStockValue = siteMaterials.fold<double>(
        0, (sum, m) => sum + (m.currentStock * m.purchasePrice));

    return ProfessionalPage(
      title: activeSite?.name ?? 'Material Master',
      subtitle: activeSite != null
          ? 'Site Inventory Management'
          : 'Global Inventory Management',
      category: 'SmartConstruction STOCK',
      actions: [
        _buildSiteSelector(context, siteRepo),
      ],
      headerStats: [
        HeroStatPill(
          label: 'Stock Value',
          value: '₹ ${totalStockValue.toStringAsFixed(0)}',
          icon: Icons.account_balance_wallet_rounded,
          color: bcAmber,
          onTap: () {}, // Tactile feedback
        ),
        HeroStatPill(
          label: 'Low Stock',
          value: lowStockCount.toString(),
          icon: Icons.warning_amber_rounded,
          color: bcDanger,
          showBorder: _showLowStockOnly,
          onTap: () => setState(() => _showLowStockOnly = !_showLowStockOnly),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _TabItem(
                title: 'ALL ITEMS',
                isActive: !_showLowStockOnly,
                onTap: () => setState(() => _showLowStockOnly = false),
              ),
              const SizedBox(width: 24),
              _TabItem(
                title: 'LOW STOCK',
                isActive: _showLowStockOnly,
                onTap: () => setState(() => _showLowStockOnly = true),
              ),
            ],
          ),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MY ITEMS (${materials.length})',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: bcTextSecondary)),
                    const Icon(Icons.swap_vert_rounded,
                        size: 20, color: bcTextSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
        materials.isEmpty
            ? SliverFillRemaining(child: _buildEmptyState())
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => StaggeredAnimation(
                    index: index,
                    child: _MaterialItemCard(
                      material: materials[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailScreen(
                                materialId: materials[index].id),
                          ),
                        );
                      },
                    ),
                  ),
                  childCount: materials.length,
                ),
              ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditItemScreen()),
          );
        },
        backgroundColor: bcNavy,
        icon: const Icon(Icons.add_rounded, color: bcAmber),
        label: const Text('ADD PRODUCT',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSiteSelector(BuildContext context, SiteRepository siteRepo) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.business_rounded, color: bcAmber),
      tooltip: 'Switch Site',
      onSelected: (id) => siteRepo.selectSite(id),
      itemBuilder: (context) => siteRepo.sites
          .map((s) => PopupMenuItem(
                value: s.id,
                child: Row(
                  children: [
                    Icon(Icons.business_rounded,
                        size: 18,
                        color: siteRepo.selectedSiteId == s.id
                            ? bcAmber
                            : bcTextSecondary),
                    const SizedBox(width: 12),
                    Text(s.name,
                        style: TextStyle(
                          fontWeight: siteRepo.selectedSiteId == s.id
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: siteRepo.selectedSiteId == s.id
                              ? bcNavy
                              : bcTextPrimary,
                        )),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No items found'
                : 'No matches for "$_searchQuery"',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Search materials...',
        prefixIcon: const Icon(Icons.search_rounded, color: bcTextSecondary),
        suffixIcon: const Icon(Icons.tune_rounded, color: bcTextSecondary),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem(
      {required this.title, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.7),
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(
                height: 3,
                width: 60,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(2))),
          ],
        ],
      ),
    );
  }
}

class _MaterialItemCard extends StatelessWidget {
  final ConstructionMaterial material;
  final VoidCallback onTap;

  const _MaterialItemCard({required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: material.photoUrl != null
                        ? Image.network(material.photoUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: bcNavy,
                              letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Sale Price (₹)',
                                    style:
                                        TextStyle(fontSize: 10, color: Colors.grey)),
                                Text('₹ ${material.salePrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 14, color: bcNavy)),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Current Stock',
                                    style:
                                        TextStyle(fontSize: 10, color: Colors.grey)),
                                Text(
                                  material.currentStock.toStringAsFixed(0),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        material.isLowStock ? Colors.red : bcNavy,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _QuickActionButton(
                    label: '+ IN',
                    color: Colors.teal[700]!,
                    onTap: () => _showStockIn(context, material),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionButton(
                    label: '− OUT',
                    color: Colors.red[700]!,
                    onTap: () => _showStockOut(context, material),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStockIn(BuildContext context, ConstructionMaterial material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StockInSheet(materialId: material.id),
    );
  }

  void _showStockOut(BuildContext context, ConstructionMaterial material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StockOutSheet(materialId: material.id),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style:
              TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}
