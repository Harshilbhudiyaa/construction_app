import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/inventory_transaction.dart';
import 'package:construction_app/features/inventory/widgets/stock_in_sheet.dart';
import 'package:construction_app/features/inventory/widgets/stock_out_sheet.dart';

class ItemDetailScreen extends StatefulWidget {
  final String materialId;
  const ItemDetailScreen({super.key, required this.materialId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<InventoryRepository>();
    final material = repo.materials.firstWhere((m) => m.id == widget.materialId, orElse: () => repo.materials.first);

    final stockHealth = (material.currentStock / (material.minimumStockLimit * 2)).clamp(0.0, 1.0);
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bcSurface,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: bcNavy,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: bcAmber, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: bcAmber),
                    onPressed: () => _editItem(context),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Container(
                    color: bcNavy,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Hero(
                          tag: 'mat_img_${material.id}',
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 2),
                            ),
                            child: Center(
                              child: Text(material.name[0].toUpperCase(), 
                                  style: const TextStyle(color: bcAmber, fontSize: 48, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(material.name, 
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 32, 
                                fontWeight: FontWeight.w900, 
                                letterSpacing: -1.5, 
                                height: 1.0,
                                shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 10)],
                              )),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StatusPill(label: material.subType, color: bcInfo, onDark: true),
                            const SizedBox(width: 8),
                            StatusPill(label: material.unitType.toUpperCase(), color: bcAmber, onDark: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: bcSurface,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: const BorderSide(color: bcAmber, width: 4),
                      insets: const EdgeInsets.symmetric(horizontal: 60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    labelColor: bcNavy,
                    unselectedLabelColor: bcTextSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
                    tabs: const [
                      Tab(text: 'OVERVIEW'),
                      Tab(text: 'HISTORY'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(material: material, stockHealth: stockHealth),
                _TransactionsTab(
                  transactions: repo.transactions.where((t) => t.materialId == widget.materialId).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
                  unit: material.unitType,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: _FloatingActionDock(material: material),
          ),
        ],
      ),
    );
  }

  void _editItem(BuildContext context) {
    // Navigate to edit screen
  }
}

class _OverviewTab extends StatelessWidget {
  final ConstructionMaterial material;
  final double stockHealth;
  const _OverviewTab({required this.material, required this.stockHealth});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        Row(
          children: [
            Expanded(child: _miniFstat('CURRENT STOCK', '${material.currentStock.toStringAsFixed(0)} ${material.unitType}', bcSuccess)),
            const SizedBox(width: 12),
            _stockHealthIndicator(),
          ],
        ),
        const SizedBox(height: 28),
        _sectionHeader('PRICING & UNIT'),
        _detailTile(context, Icons.payments_rounded, 'Purchase Rate', '${fmt.format(material.purchasePrice)} / ${material.unitType}', bcAmber),
        _detailTile(context, Icons.sell_rounded, 'Sales Rate', '${fmt.format(material.salePrice)} / ${material.unitType}', bcInfo),
        const SizedBox(height: 28),
        _sectionHeader('MANAGEMENT DETAILS'),
        _detailTile(context, Icons.business_center_rounded, 'Brand / Manufacturer', (material.brand?.isEmpty ?? true) ? 'Not Specified' : material.brand!, bcNavyMid),
        _detailTile(context, Icons.location_on_rounded, 'Storage Location', material.storageLocation.isEmpty ? 'General Yard' : material.storageLocation, bcAmber),
        _detailTile(context, Icons.warning_amber_rounded, 'Minimum Threshold', '${material.minimumStockLimit.toStringAsFixed(0)} ${material.unitType}', bcDanger),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _stockHealthIndicator() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFF1F5F9)),
      boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50, height: 50,
              child: CircularProgressIndicator(
                value: stockHealth,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(stockHealth > 0.6 ? bcSuccess : (stockHealth > 0.3 ? bcAmber : bcDanger)),
              ),
            ),
            Text('${(stockHealth * 100).toInt()}%', 
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: bcNavy, letterSpacing: -0.5)),
          ],
        ),
        const SizedBox(height: 12),
        const Text('HEALTH', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    ),
  );

  Widget _miniFstat(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(24), 
      border: Border.all(color: const Color(0xFFF1F5F9)),
      boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
      ],
    ),
  );

  Widget _detailTile(BuildContext context, IconData icon, String label, String value, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFF1F5F9)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700)),
              Text(value, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4),
    child: Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.8)),
  );
}

class _TransactionsTab extends StatelessWidget {
  final List<InventoryTransaction> transactions;
  final String unit;
  const _TransactionsTab({required this.transactions, required this.unit});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Empty history', style: TextStyle(color: Color(0xFF94A3B8))));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: transactions.length,
      itemBuilder: (context, i) {
        final txn = transactions[i];
        final isIn = txn.type == TransactionType.inward;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isIn ? bcSuccess : bcDanger).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isIn ? Icons.south_west_rounded : Icons.north_east_rounded, 
                  color: isIn ? bcSuccess : bcDanger, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isIn ? 'Inventory Addition' : 'Stock Consumption', 
                    style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(DateFormat('dd MMM yyyy, hh:mm a').format(txn.timestamp), 
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${isIn ? '+' : '-'}${txn.quantity.toStringAsFixed(0)} $unit', 
                  style: TextStyle(color: isIn ? bcSuccess : bcDanger, fontWeight: FontWeight.w900, fontSize: 15)),
                Text('₹${(txn.rate ?? 0).toStringAsFixed(0)}', 
                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10, fontWeight: FontWeight.bold)),
              ]),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingActionDock extends StatelessWidget {
  final ConstructionMaterial material;
  const _FloatingActionDock({required this.material});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bcNavy.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.4), blurRadius: 25, offset: const Offset(0, 12))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showOut(context),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08), 
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text('USE STOCK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: bcAmber,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: () => _showIn(context),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.add_business_rounded, color: bcNavy, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIn(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => StockInSheet(materialId: material.id));
  }
  void _showOut(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => StockOutSheet(materialId: material.id));
  }
}
