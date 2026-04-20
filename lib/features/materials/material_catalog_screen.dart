import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/stock_entry_repository.dart';
import 'package:construction_app/core/routing/app_router.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/shared/widgets/responsive_layout.dart';

class MaterialCatalogScreen extends StatefulWidget {
  final bool initialInStockFilter;
  const MaterialCatalogScreen({super.key, this.initialInStockFilter = false});

  @override
  State<MaterialCatalogScreen> createState() => _MaterialCatalogScreenState();
}

class _MaterialCatalogScreenState extends State<MaterialCatalogScreen> {
  String _search = '';
  String? _selectedSubType;
  bool _onlyInStock = false;
  bool _isGrid = false;

  @override
  void initState() {
    super.initState();
    _onlyInStock = widget.initialInStockFilter == true;
    _isGrid = false; 
  }

  @override
  Widget build(BuildContext context) {
    final invRepo   = context.watch<InventoryRepository>();
    final siteRepo  = context.watch<SiteRepository>();
    final siteId    = siteRepo.selectedSiteId;
    final fmt       = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final materials = invRepo.materials.where((m) {
      final sId = siteId;
      final siteOk = (sId == null || m.siteId == sId || (m.siteId.isEmpty == true));
      final srchOk = (_search.isEmpty == true || m.name.toLowerCase().contains(_search.toLowerCase()));
      final stockOk = (_onlyInStock != true) || m.currentStock > 0;
      final subTypeOk = _selectedSubType == null || m.subType == _selectedSubType;
      return (siteOk == true) && (srchOk == true) && (stockOk == true) && (subTypeOk == true);
    }).toList();

    final totalStockValue = materials.fold<double>(0, (sum, m) => sum + (m.currentStock * (m.purchasePrice ?? 0)));
    final lowStockItems   = materials.where((m) => m.isLowStock == true).length;
    final subTypes = invRepo.materials
        .map((m) => m.subType)
        .where((s) => s != null && s.isNotEmpty == true)
        .toSet()
        .toList()
      ..sort();

    return Scaffold(
      backgroundColor: bcSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SmartConstructionSliverAppBar(
            title: 'Materials',
            subtitle: siteRepo.selectedSite != null ? 'Site Inventory: ${siteRepo.selectedSite!.name}' : 'Universal Catalog & Stock',
            category: 'INVENTORY MANAGEMENT',
            headerStats: [
              HeroStatPill(
                label: 'TOTAL VALUE',
                value: fmt.format(totalStockValue),
                icon: Icons.account_balance_wallet_rounded,
                color: bcAmber,
              ),
              HeroStatPill(
                label: 'ITEMS',
                value: '${materials.length}',
                icon: Icons.inventory_2_rounded,
                color: bcInfo,
              ),
              if (lowStockItems > 0)
                HeroStatPill(
                  label: 'LOW STOCK',
                  value: '$lowStockItems',
                  icon: Icons.warning_amber_rounded,
                  color: bcDanger,
                ),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              child: Container(
                color: bcSurface,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
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
                                    onChanged: (v) => setState(() => _search = v),
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
                        _InStockFilterPill(
                          active: (_onlyInStock == true),
                          onToggled: (v) => setState(() => _onlyInStock = (v == true)),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _isGrid = !_isGrid),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: (_isGrid == true) ? bcNavy : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: (_isGrid == true) ? bcNavy : bcBorder.withValues(alpha: 0.6)),
                              boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Icon(
                              (_isGrid == true) ? Icons.view_headline_rounded : Icons.grid_view_rounded,
                              color: (_isGrid == true) ? Colors.white : bcNavy,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subTypes.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: subTypes.length + 1,
                          itemBuilder: (context, i) {
                            final isAll = i == 0;
                            final sub = isAll ? null : subTypes[i - 1];
                            final isSelected = _selectedSubType == sub;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(isAll ? 'All Categories' : sub!),
                                selected: (isSelected == true),
                                onSelected: (v) => setState(() => _selectedSubType = v ? sub : null),
                                backgroundColor: Colors.white,
                                selectedColor: bcInfo.withValues(alpha: 0.15),
                                labelStyle: TextStyle(
                                  color: isSelected ? bcInfo : bcNavy.withValues(alpha: 0.7),
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: isSelected ? bcInfo : bcBorder.withValues(alpha: 0.5)),
                                ),
                                showCheckmark: false,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
        body: (materials.isEmpty == true)
            ? EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No Materials Found',
                message: (_search.isEmpty == true) ? 'Your items will appear here once added.' : 'Try a different search term.',
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: (_isGrid == true)
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: materials.length,
                        itemBuilder: (context, i) => _MaterialGridCard(
                          material: materials[i],
                          onTap: () => Navigator.pushNamed(context, AppRoutes.materialDetail, arguments: materials[i].id),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: materials.length,
                        itemBuilder: (context, i) => _MaterialCard(
                          material: materials[i],
                          onTap: () => Navigator.pushNamed(context, AppRoutes.materialDetail, arguments: materials[i].id),
                        ),
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addItem),
        backgroundColor: bcNavy,
        elevation: 6,
        label: const Text('ADD MATERIAL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, color: Colors.white)),
        icon: const Icon(Icons.add_rounded, color: bcAmber),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _InStockFilterPill extends StatelessWidget {
  final bool active;
  final ValueChanged<bool> onToggled;
  const _InStockFilterPill({required this.active, required this.onToggled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggled(!active),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 52,
        decoration: BoxDecoration(
          color: (active == true) ? bcSuccess.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (active == true) ? bcSuccess : bcBorder.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(active ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: active ? bcSuccess : bcBorder, size: 18),
            const SizedBox(width: 8),
            Text(
              'IN STOCK',
              style: TextStyle(color: active ? bcSuccess : bcNavy.withValues(alpha: 0.7), fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final ConstructionMaterial material;
  final VoidCallback onTap;
  const _MaterialCard({required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: bcBorder.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(Icons.inventory_2_rounded, size: 120, color: bcNavy),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: bcSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: bcBorder.withValues(alpha: 0.4)),
                      ),
                      child: Center(
                        child: Text(
                          material.name.isNotEmpty ? material.name.substring(0, 1).toUpperCase() : 'M',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: bcNavy),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.subType.toUpperCase(),
                            style: const TextStyle(color: bcInfo, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            material.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: bcNavy),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _Metric(material.currentStock.toStringAsFixed(1), material.unitType.toLowerCase(), Icons.warehouse_rounded, bcInfo),
                              const SizedBox(width: 20),
                              _Metric('₹${(material.purchasePrice ?? 0).toStringAsFixed(0)}', 'per ${material.unitType.toLowerCase()}', Icons.sell_rounded, bcAmber),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _SmallActionBtn(
                          icon: Icons.add_rounded, 
                          color: bcSuccess, 
                          onTap: () => Navigator.pushNamed(context, AppRoutes.stockOperations, arguments: {'purpose': 'Inward'})
                        ),
                        const SizedBox(height: 8),
                        _SmallActionBtn(
                          icon: Icons.remove_rounded, 
                          color: bcDanger, 
                          onTap: () => Navigator.pushNamed(context, AppRoutes.stockOut, arguments: material)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (material.isLowStock == true)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: bcDanger,
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
                    ),
                    child: const Text('LOW STOCK', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialGridCard extends StatelessWidget {
  final ConstructionMaterial material;
  final VoidCallback onTap;
  const _MaterialGridCard({required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: bcBorder.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: bcSurface, borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.inventory_2_rounded, size: 18, color: bcNavy.withValues(alpha: 0.7)),
                        ),
                        Row(
                          children: [
                            _SmallActionBtn(
                              icon: Icons.add_rounded, size: 24, color: bcSuccess, 
                              onTap: () => Navigator.pushNamed(context, AppRoutes.stockOperations, arguments: {'purpose': 'Inward'})
                            ),
                            const SizedBox(width: 4),
                            _SmallActionBtn(
                              icon: Icons.remove_rounded, size: 24, color: bcDanger, 
                              onTap: () => Navigator.pushNamed(context, AppRoutes.stockOut, arguments: material)
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      material.subType.toUpperCase(),
                      style: const TextStyle(color: bcInfo, fontSize: 8, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      material.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: bcNavy),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('STOCK', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.w700)),
                            Text('${material.currentStock.toStringAsFixed(0)} ${material.unitType}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: bcNavy)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('PRICE', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.w700)),
                            Text('₹${(material.purchasePrice ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: bcAmber)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (material.isLowStock == true)
                Positioned(
                  left: 0, bottom: 0, right: 0,
                  child: Container(
                    height: 4,
                    color: bcDanger,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String val;
  final String unit;
  final IconData icon;
  final Color color;
  const _Metric(this.val, this.unit, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: bcNavy, height: 1)),
            Text(unit.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }
}

class _SmallActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;
  const _SmallActionBtn({required this.icon, required this.color, required this.onTap, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(size / 3.2),
        ),
        child: Icon(icon, color: color, size: size * 0.6),
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverHeaderDelegate({required this.child});
  @override
  double get minExtent => 144; 
  @override
  double get maxExtent => 144;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) => true;
}
