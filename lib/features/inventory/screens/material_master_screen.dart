import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/features/inventory/screens/add_edit_item_screen.dart';
import 'package:construction_app/features/inventory/screens/item_detail_screen.dart';

class MaterialMasterScreen extends StatefulWidget {
  const MaterialMasterScreen({super.key});

  @override
  State<MaterialMasterScreen> createState() => _MaterialMasterScreenState();
}

class _MaterialMasterScreenState extends State<MaterialMasterScreen> {
  String _searchQuery = '';
  String? _selectedSubType;
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
      final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLowStock = !_showLowStockOnly || m.isLowStock;
      final matchesSubType = _selectedSubType == null || m.subType == _selectedSubType;
      return matchesSearch && matchesLowStock && matchesSubType;
    }).toList();

    final subTypes = siteMaterials.map((m) => m.subType).where((s) => s.isNotEmpty).toSet().toList()..sort();
    final totalStockValue = siteMaterials.fold<double>(0, (sum, m) => sum + (m.currentStock * m.purchasePrice));
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bcSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SmartConstructionSliverAppBar(
            title: 'Materials',
            subtitle: activeSite != null ? 'Catalog: ${activeSite.name}' : 'Catalog & Inventory',
            category: 'INVENTORY MANAGEMENT',
            actions: [
              _buildSummaryActionBox(totalStockValue, siteMaterials.length, fmt),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              child: Container(
                color: bcSurface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    if (subTypes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildFilterSection(subTypes),
                    ],
                  ],
                ),
              ),
              height: subTypes.isNotEmpty ? 130 : 80,
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () => repo.refresh(),
          color: bcAmber,
          child: repo.isLoading 
              ? const Center(child: CircularProgressIndicator(color: bcAmber))
              : materials.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      physics: const BouncingScrollPhysics(),
                      itemCount: materials.length,
                      itemBuilder: (_, i) => _MaterialItemCard(
                        material: materials[i],
                        fmt: fmt,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ItemDetailScreen(materialId: materials[i].id)),
                          );
                        },
                      ),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditItemScreen()));
        },
        backgroundColor: bcAmber,
        foregroundColor: bcNavy,
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.2)),
      ),
    );
  }

  Widget _buildSummaryActionBox(double value, int count, NumberFormat fmt) {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bcNavyMid.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bcAmber.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(fmt.format(value), 
            style: const TextStyle(color: bcAmber, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
          Text('$count items', 
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 62, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 14),
          const Text('No items found', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          const Text('Your catalog items will appear here', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: bcBorder.withValues(alpha: 0.6)),
              boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                const SizedBox(width: 12),
                            Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 15, color: bcNavy, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      hintText: 'Search materials...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
                      isDense: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => setState(() => _showLowStockOnly = !_showLowStockOnly),
          child: Container(
            height: 56, width: 90,
            decoration: BoxDecoration(
              color: _showLowStockOnly ? bcDanger.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _showLowStockOnly ? bcDanger : bcBorder.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_rounded, size: 16, color: _showLowStockOnly ? bcDanger : bcTextSecondary),
                const SizedBox(width: 6),
                Text('STOCK', style: TextStyle(color: _showLowStockOnly ? bcDanger : bcTextSecondary, fontWeight: FontWeight.w900, fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(List<String> subTypes) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSubTypeChip('ALL ITEMS', null),
          ...subTypes.map((s) => _buildSubTypeChip(s.toUpperCase(), s)),
        ],
      ),
    );
  }

  Widget _buildSubTypeChip(String label, String? value) {
    final isActive = _selectedSubType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedSubType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? bcNavy : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? bcNavy : bcBorder.withValues(alpha: 0.8)),
          boxShadow: [if (isActive) BoxShadow(color: bcNavy.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: isActive ? Colors.white : bcTextSecondary,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.2,
          )),
        ),
      ),
    );
  }
}

class _MaterialItemCard extends StatelessWidget {
  final ConstructionMaterial material;
  final NumberFormat fmt;
  final VoidCallback onTap;

  const _MaterialItemCard({required this.material, required this.fmt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCritical = material.isLowStock;
    final statusColor = isCritical ? bcDanger : bcSuccess;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bcNavy.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: statusColor.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: bcBorder.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Hero(
                  tag: 'mat_img_${material.id}',
                  child: Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [statusColor.withValues(alpha: 0.1), statusColor.withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: statusColor.withValues(alpha: 0.15)),
                    ),
                    child: Center(
                      child: Text(
                        material.name[0].toUpperCase(),
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(material.name, 
                        style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.4)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          StatusPill(label: material.subType, color: statusColor),
                          const SizedBox(width: 10),
                          Icon(Icons.payments_outlined, color: bcTextSecondary.withValues(alpha: 0.6), size: 10),
                          const SizedBox(width: 4),
                          Text(
                            '${fmt.format(material.salePrice)}/${material.unitType}',
                            style: TextStyle(color: bcTextSecondary.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${material.currentStock.toStringAsFixed(0)}', 
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5, height: 1.0)),
                      Text(material.unitType.toUpperCase(), 
                        style: TextStyle(color: statusColor.withValues(alpha: 0.4), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
