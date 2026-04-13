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

class MaterialCatalogScreen extends StatefulWidget {
  final bool initialInStockFilter;
  const MaterialCatalogScreen({super.key, this.initialInStockFilter = false});

  @override
  State<MaterialCatalogScreen> createState() => _MaterialCatalogScreenState();
}

class _MaterialCatalogScreenState extends State<MaterialCatalogScreen> {
  String _search = '';
  String? _filter;
  bool _onlyInStock = false;

  @override
  void initState() {
    super.initState();
    _onlyInStock = widget.initialInStockFilter;
  }

  @override
  Widget build(BuildContext context) {
    final invRepo   = context.watch<InventoryRepository>();
    final siteRepo  = context.watch<SiteRepository>();
    final stockRepo = context.watch<StockEntryRepository>();
    final siteId    = siteRepo.selectedSiteId;
    final fmt       = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);


    final materials = invRepo.materials.where((m) {
      final sId = siteId;
      final siteOk = (sId == null || m.siteId == sId || m.siteId.isEmpty);
      final srchOk = (_search.isEmpty || 
          m.name.toLowerCase().contains(_search.toLowerCase()));
      final bool filterInStock = _onlyInStock;
      final stockOk = !filterInStock || m.currentStock > 0;
      
      return siteOk && srchOk && stockOk;
    }).toList();

    return Scaffold(
      backgroundColor: bcSurface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: bcNavy,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Materials', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        Text('Catalog & Inventory', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  _StockSummaryBadge(
                    label: '${materials.length} items',
                    value: fmt.format(materials.fold(0.0, (s, m) => s + m.totalAmount)),
                  ),
                ],
              ),
            ),

            // Search + Filter bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: bcSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              style: const TextStyle(fontSize: 13, color: bcNavy),
                              decoration: const InputDecoration(
                                hintText: 'Search materials…',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _InStockFilter(
                    active: _onlyInStock,
                    onToggled: (v) => setState(() => _onlyInStock = v),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: invRepo.isLoading
                  ? const Center(child: CircularProgressIndicator(color: bcAmber))
                  : materials.isEmpty
                      ? _emptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                          physics: const BouncingScrollPhysics(),
                          itemCount: materials.length,
                          itemBuilder: (_, i) => _MaterialCard(
                            material: materials[i],
                            stockRepo: stockRepo,
                            fmt: fmt,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.materialDetail,
                              arguments: materials[i].id,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMaterialSheet(context, siteId),
        backgroundColor: bcAmber,
        foregroundColor: bcNavy,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Material', style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 4,
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.layers_outlined, size: 64, color: Color(0xFFCBD5E1)),
        const SizedBox(height: 16),
        const Text('No materials yet', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Tap the button below to add your first material', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
      ],
    ),
  );

  void _showAddMaterialSheet(BuildContext context, String? siteId) {
    Navigator.pushNamed(context, AppRoutes.addItem);
  }
}

// ─── Material Card ─────────────────────────────────────────────────────────────

class _MaterialCard extends StatelessWidget {
  final ConstructionMaterial material;
  final StockEntryRepository stockRepo;
  final NumberFormat fmt;
  final VoidCallback onTap;
  const _MaterialCard({required this.material, required this.stockRepo, required this.fmt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final totalPurchased = stockRepo.getTotalQuantityForMaterial(material.id);
    final avgPrice       = stockRepo.getAvgPriceForMaterial(material.id);
    final isLowStock     = material.currentStock <= material.minimumStockLimit && material.minimumStockLimit > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLowStock ? bcDanger.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  // Category icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bcNavy.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: bcNavy, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(material.name,
                            style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 14)),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (material.variant.isNotEmpty) ...[
                                _Tag(material.variant, const Color(0xFF6366F1)),
                                const SizedBox(width: 6),
                              ],
                              if (material.subType.isNotEmpty) ...[
                                _Tag(material.subType, const Color(0xFF60A5FA)),
                                const SizedBox(width: 6),
                              ],
                              _Tag(material.unitType.toUpperCase(), const Color(0xFFA78BFA)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${material.currentStock.toStringAsFixed(material.currentStock.truncateToDouble() == material.currentStock ? 0 : 1)} ${material.unitType}',
                        style: TextStyle(
                          color: isLowStock ? bcDanger : bcNavy,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const Text('in stock', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bcSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatPair('Current Rate', '₹${material.pricePerUnit.toStringAsFixed(0)}'),
                  _StatPair(totalPurchased > 0 ? 'Avg Price' : 'Min Stock', totalPurchased > 0 ? '₹${avgPrice.toStringAsFixed(0)}' : material.minimumStockLimit.toStringAsFixed(0)),
                  _StatPair('Value', fmt.format(material.totalAmount)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 3),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w700)),
  );
}

class _StatPair extends StatelessWidget {
  final String label;
  final String value;
  const _StatPair(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 12)),
      Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.w500)),
    ],
  );
}



// ─── Stock Summary Badge ──────────────────────────────────────────────────────

class _StockSummaryBadge extends StatelessWidget {
  final String label;
  final String value;
  const _StockSummaryBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: bcAmber.withValues(alpha: 0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(color: bcAmber, fontWeight: FontWeight.w900, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    ),
  );
}

class _InStockFilter extends StatelessWidget {
  final bool active;
  final ValueChanged<bool> onToggled;
  const _InStockFilter({required this.active, required this.onToggled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggled(!active),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? bcAmber.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? bcAmber.withValues(alpha: 0.4) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 14, color: active ? bcAmber : const Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Text(
              'In Stock',
              style: TextStyle(
                color: active ? bcAmber : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _field(String label, TextEditingController ctrl, {
  String? hint,
  TextInputType keyboardType = TextInputType.text,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
    const SizedBox(height: 6),
    TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: bcNavy),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: bcSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bcAmber, width: 2)),
      ),
    ),
  ],
);

class _DropdownRow<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;
  const _DropdownRow({required this.value, required this.items, required this.labelBuilder, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: bcSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(labelBuilder(i)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
