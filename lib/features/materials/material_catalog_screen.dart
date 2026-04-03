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
  const MaterialCatalogScreen({super.key});

  @override
  State<MaterialCatalogScreen> createState() => _MaterialCatalogScreenState();
}

class _MaterialCatalogScreenState extends State<MaterialCatalogScreen> {
  String _search = '';
  MaterialCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final invRepo   = context.watch<InventoryRepository>();
    final siteRepo  = context.watch<SiteRepository>();
    final stockRepo = context.watch<StockEntryRepository>();
    final siteId    = siteRepo.selectedSiteId;
    final fmt       = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final materials = invRepo.materials.where((m) {
      final siteOk = siteId == null || m.siteId == siteId || m.siteId.isEmpty;
      final catOk  = _filter == null || m.category == _filter;
      final srchOk = _search.isEmpty || m.name.toLowerCase().contains(_search.toLowerCase());
      return siteOk && catOk && srchOk;
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
                  _CategoryFilter(
                    selected: _filter,
                    onChanged: (c) => setState(() => _filter = c),
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
        Icon(Icons.layers_outlined, size: 64, color: const Color(0xFFCBD5E1)),
        const SizedBox(height: 16),
        const Text('No materials yet', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Tap the button below to add your first material', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
      ],
    ),
  );

  void _showAddMaterialSheet(BuildContext context, String? siteId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMaterialSheet(siteId: siteId ?? context.read<SiteRepository>().selectedSiteId ?? 'S-001'),
    );
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
                      color: _catColor(material.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_catIcon(material.category), color: _catColor(material.category), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(material.name,
                            style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 14)),
                        Row(
                          children: [
                            if (material.subType.isNotEmpty) ...[
                              _Tag(material.subType, const Color(0xFF60A5FA)),
                              const SizedBox(width: 6),
                            ],
                            _Tag(material.unitType.label, const Color(0xFFA78BFA)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${material.currentStock.toStringAsFixed(material.currentStock.truncateToDouble() == material.currentStock ? 0 : 1)} ${material.unitType.label}',
                        style: TextStyle(
                          color: isLowStock ? bcDanger : bcNavy,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text('in stock', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
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

  Color _catColor(MaterialCategory c) {
    // Only civilStructural exists currently — default handles future additions
    return const Color(0xFFF59E0B);
  }

  IconData _catIcon(MaterialCategory c) {
    return Icons.foundation_rounded;
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

// ─── Category Filter ──────────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  final MaterialCategory? selected;
  final ValueChanged<MaterialCategory?> onChanged;
  const _CategoryFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFilter(context),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected != null ? bcAmber.withValues(alpha: 0.1) : bcSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected != null ? bcAmber.withValues(alpha: 0.4) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list_rounded, color: selected != null ? bcAmber : const Color(0xFF94A3B8), size: 18),
            if (selected != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close_rounded, color: bcAmber, size: 14),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryFilterSheet(selected: selected, onChanged: (c) { onChanged(c); Navigator.pop(context); }),
    );
  }
}

class _CategoryFilterSheet extends StatelessWidget {
  final MaterialCategory? selected;
  final ValueChanged<MaterialCategory?> onChanged;
  const _CategoryFilterSheet({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Filter by Category', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 16),
          _FilterChip(label: 'All', selected: selected == null, onTap: () => onChanged(null)),
          ...MaterialCategory.values.map((c) =>
            _FilterChip(label: c.displayName, selected: selected == c, onTap: () => onChanged(c))),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? bcAmber.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? bcAmber : const Color(0xFFE2E8F0)),
        ),
        child: Text(label, style: TextStyle(color: selected ? bcAmber : bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
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

// ─── Add Material Bottom Sheet ────────────────────────────────────────────────

class _AddMaterialSheet extends StatefulWidget {
  final String siteId;
  const _AddMaterialSheet({required this.siteId});

  @override
  State<_AddMaterialSheet> createState() => _AddMaterialSheetState();
}

class _AddMaterialSheetState extends State<_AddMaterialSheet> {
  final _nameCtrl    = TextEditingController();
  final _subtypeCtrl = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _stockCtrl   = TextEditingController();
  MaterialCategory _category = MaterialCategory.civilStructural;
  UnitType _unit = UnitType.bag;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _subtypeCtrl.dispose();
    _priceCtrl.dispose(); _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Add Material', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 20),

            _field('Material Name *', _nameCtrl, hint: 'e.g. Cement, Steel TMT Bar'),
            const SizedBox(height: 12),
            _field('Sub-type / Grade', _subtypeCtrl, hint: 'e.g. OPC 53, 12mm, OPC 43'),
            const SizedBox(height: 12),

            // Category
            const Text('Category', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            _DropdownRow<MaterialCategory>(
              value: _category,
              items: MaterialCategory.values,
              labelBuilder: (c) => c.displayName,
              onChanged: (c) => setState(() => _category = c!),
            ),
            const SizedBox(height: 12),

            // Unit
            const Text('Unit', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            _DropdownRow<UnitType>(
              value: _unit,
              items: UnitType.values,
              labelBuilder: (u) => u.label,
              onChanged: (u) => setState(() => _unit = u!),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _field('Current Price (₹)', _priceCtrl, hint: '450', keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _field('In Stock', _stockCtrl, hint: '0', keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : () => _submit(context),
                icon: _submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_rounded),
                label: const Text('Save Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bcNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material name is required')));
      return;
    }
    setState(() => _submitting = true);
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final stock = double.tryParse(_stockCtrl.text) ?? 0;
    final material = ConstructionMaterial(
      id: const Uuid().v4(),
      siteId: widget.siteId,
      name: name,
      category: _category,
      subType: _subtypeCtrl.text.trim(),
      pricePerUnit: price,
      purchasePrice: price,
      salePrice: price,
      unitType: _unit,
      currentStock: stock,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await context.read<InventoryRepository>().addMaterial(material);
    if (context.mounted) Navigator.pop(context);
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
