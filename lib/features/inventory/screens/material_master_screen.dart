import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
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

    return Scaffold(
      backgroundColor: bcSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SmartConstructionSliverAppBar(
            title: activeSite?.name ?? 'Materials',
            subtitle: activeSite != null ? 'Site Inventory Catalog' : 'Global Material Hub',
            category: 'INVENTORY MANAGEMENT',
            isFull: true,
            actions: [
              _buildSiteSelector(context, siteRepo),
            ],
            headerStats: [
              HeroStatPill(
                label: 'VALUATION',
                value: '₹${totalStockValue.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_rounded,
                color: bcAmber,
              ),
              HeroStatPill(
                label: 'LOW STOCK',
                value: '$lowStockCount',
                icon: Icons.warning_amber_rounded,
                color: bcDanger,
                showBorder: _showLowStockOnly,
                onTap: () => setState(() => _showLowStockOnly = !_showLowStockOnly),
              ),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              child: Container(
                color: bcSurface,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _FilterTab(
                          label: 'ALL MATERIALS',
                          icon: Icons.inventory_2_rounded,
                          isActive: !_showLowStockOnly,
                          onTap: () => setState(() => _showLowStockOnly = false),
                        ),
                        const SizedBox(width: 12),
                        _FilterTab(
                          label: 'LOW STOCK',
                          icon: Icons.notification_important_rounded,
                          isActive: _showLowStockOnly,
                          onTap: () => setState(() => _showLowStockOnly = true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              height: 130,
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () => repo.refresh(),
          color: bcAmber,
          child: materials.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: materials.length,
                  itemBuilder: (_, i) => _MaterialItemCard(
                    material: materials[i],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailScreen(materialId: materials[i].id),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
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
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: bcNavy.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10)),
          BoxShadow(color: bcNavy.withValues(alpha: 0.02), blurRadius: 2, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: bcAmber, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 15, color: bcNavy, fontWeight: FontWeight.w700, letterSpacing: -0.2),
              decoration: const InputDecoration(
                hintText: 'Search material catalog...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bcNavy.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.tune_rounded, color: bcNavy, size: 18),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? bcNavy : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? bcNavy : const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: isActive ? [BoxShadow(color: bcNavy.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 6))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? bcAmber : bcTextSecondary),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : bcTextSecondary,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
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
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final isCritical = material.isLowStock;

    final stockHealth = material.currentStock / (material.minimumStockLimit > 0 ? material.minimumStockLimit * 2 : 100);
    final healthColor = isCritical ? bcDanger : (material.currentStock < material.minimumStockLimit * 1.5 ? bcAmber : bcSuccess);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: bcNavy.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: isCritical ? bcDanger.withValues(alpha: 0.2) : bcBorder.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: BlueprintGridPainter(gridSize: 20)),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'mat_img_${material.id}',
                          child: Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: bcSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: bcBorder.withValues(alpha: 0.5)),
                              boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: material.photoUrl != null
                                  ? Image.network(material.photoUrl!, fit: BoxFit.cover)
                                  : const Icon(Icons.inventory_2_rounded, color: Color(0xFF94A3B8), size: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(material.name, 
                                style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.8)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  StatusPill(label: material.subType, color: bcInfo),
                                  const SizedBox(width: 8),
                                  StatusPill(label: material.unitType, color: bcAmber),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(material.currentStock.toStringAsFixed(0), 
                                  style: TextStyle(color: isCritical ? bcDanger : bcNavy, fontWeight: FontWeight.w900, fontSize: 26, height: 1.1)),
                                const SizedBox(width: 4),
                                Text(material.unitType, 
                                  style: TextStyle(color: (isCritical ? bcDanger : bcNavy).withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w800)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('IN STOCK', 
                              style: TextStyle(color: (isCritical ? bcDanger : bcNavy).withValues(alpha: 0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('STOCK HEALTH', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            Text(isCritical ? 'CRITICAL' : 'OPTIMAL', style: TextStyle(color: healthColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: stockHealth.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: bcSurface,
                            valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: bcSurface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: bcBorder.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatColumn('UNIT RATE', fmt.format(material.salePrice), bcNavy),
                          _StatColumn('MIN LIMIT', material.minimumStockLimit.toStringAsFixed(0), bcTextSecondary),
                          _StatColumn('TOTAL VALUE', fmt.format(material.currentStock * material.purchasePrice), bcSuccess),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionBtn(
                            label: 'STOCK IN', 
                            icon: Icons.add_circle_outline_rounded, 
                            color: bcSuccess, 
                            onTap: () => _showStockIn(context, material)
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionBtn(
                            label: 'STOCK OUT', 
                            icon: Icons.remove_circle_outline_rounded, 
                            color: bcDanger, 
                            onTap: () => _showStockOut(context, material)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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


class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _SliverHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) => true;
}

class _StatColumn extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatColumn(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
    ],
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
