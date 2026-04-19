import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/models/stock_entry_model.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/repositories/stock_entry_repository.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/features/stock/widgets/stock_entry_sheets.dart';

/// Supplier detail: premium supplier profile, stock overview, purchase history, and quick pay.
class SupplierDetailScreen extends StatelessWidget {
  final String supplierId;
  const SupplierDetailScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context) {
    final partyRepo = context.watch<PartyRepository>();
    final stockRepo = context.watch<StockEntryRepository>();
    final invRepo = context.watch<InventoryRepository>();

    final supplier = partyRepo.getPartyById(supplierId);
    if (supplier == null) {
      return const Scaffold(body: Center(child: Text('Supplier not found')));
    }

    final entries = stockRepo.getEntriesForSupplier(supplierId);
    final total = stockRepo.getTotalPurchaseFromSupplier(supplierId);
    final paid = stockRepo.getTotalPaidToSupplier(supplierId);
    final pending = stockRepo.getPendingForSupplier(supplierId);
    final stockValue = stockRepo.getStockValueForSupplier(supplierId, invRepo.materials);
    final materialSummary = _buildMaterialSummary(entries, invRepo);

    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            backgroundColor: bcNavy,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, color: bcAmber),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _SupplierEditSheet(supplier: supplier),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bcNavy,
                      Color(0xFF143A63),
                      Color(0xFF1E4D78),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withValues(alpha: 0.14),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                              ),
                              child: Center(
                                child: Text(
                                  supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'S',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    supplier.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    supplier.contactNumber?.trim().isNotEmpty == true
                                        ? supplier.contactNumber!
                                        : 'Supplier account overview',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _HeroStat(title: 'Total Purchase', value: fmt.format(total), accent: Colors.white)),
                              _divider(),
                              Expanded(child: _HeroStat(title: 'Paid', value: fmt.format(paid), accent: bcSuccess)),
                              _divider(),
                              Expanded(child: _HeroStat(title: 'Due', value: fmt.format(pending), accent: pending > 0 ? bcDanger : Colors.white70)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _GlassPill(icon: Icons.inventory_2_rounded, label: 'Stock Value', value: fmt.format(stockValue), color: bcInfo),
                              const SizedBox(width: 10),
                              _GlassPill(icon: Icons.shopping_bag_rounded, label: 'Entries', value: '${entries.length}', color: bcAmber),
                              const SizedBox(width: 10),
                              _GlassPill(icon: Icons.category_rounded, label: 'Materials', value: '${materialSummary.length}', color: Colors.white70),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(
                            title: 'Supplier Information',
                            subtitle: 'Business details and payment preferences',
                            icon: Icons.business_center_rounded,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            runSpacing: 12,
                            children: [
                              if (supplier.billingName?.trim().isNotEmpty == true)
                                _InfoTile(icon: Icons.apartment_rounded, label: 'Bill Party', value: supplier.billingName!),
                              _InfoTile(icon: Icons.payment_rounded, label: 'Payment Terms', value: supplier.paymentTerms ?? 'Not specified'),
                              if (supplier.address?.trim().isNotEmpty == true)
                                _InfoTile(icon: Icons.location_on_rounded, label: 'Address', value: supplier.address!),
                              if (supplier.gstNumber?.trim().isNotEmpty == true)
                                _InfoTile(icon: Icons.receipt_long_rounded, label: 'GST Number', value: supplier.gstNumber!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (pending > 0) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              bcSuccess.withValues(alpha: 0.96),
                              const Color(0xFF1FA971),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: bcSuccess.withValues(alpha: 0.22),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.payments_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Pending Payment Available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Outstanding due: ${fmt.format(pending)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => SupplierPaymentSheet(
                                    supplier: supplier,
                                    pendingAmount: pending,
                                  ),
                                ),
                                icon: const Icon(Icons.account_balance_wallet_rounded),
                                label: Text('Pay Due ${fmt.format(pending)}'),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.white,
                                  foregroundColor: bcSuccess,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: _SectionHeader(
                                  title: 'Material Section',
                                  subtitle: 'Materials already purchased from this supplier',
                                  icon: Icons.category_rounded,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => SupplierBillSheet(initialSupplier: supplier),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bcNavy,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Add Bill'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (materialSummary.isEmpty)
                            _EmptyStateCard(
                              icon: Icons.inventory_2_outlined,
                              title: 'No material entries yet',
                              subtitle: 'Use Add Bill to save the first purchase for this supplier.',
                            )
                          else
                            ...materialSummary.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MaterialSummaryTile(item: item, fmt: fmt),
                            )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(
                            title: 'Purchase History',
                            subtitle: 'Latest transactions from this supplier',
                            icon: Icons.history_rounded,
                          ),
                          const SizedBox(height: 16),
                          if (entries.isEmpty)
                            const _EmptyStateCard(
                              icon: Icons.receipt_long_outlined,
                              title: 'No purchase history found',
                              subtitle: 'Transactions will appear here once bills are added.',
                            )
                          else
                            ...entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _EntryTile(entry: e, fmt: fmt),
                            )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: bcAmber,
        foregroundColor: bcNavy,
        elevation: 8,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => SupplierBillSheet(initialSupplier: supplier),
        ),
        icon: const Icon(Icons.receipt_long_rounded),
        label: const Text(
          'Add Bill Entry',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 40,
    color: Colors.white.withValues(alpha: 0.12),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );

  static List<_MaterialSummary> _buildMaterialSummary(
      List<StockEntryModel> entries,
      InventoryRepository invRepo,
      ) {
    final Map<String, _MaterialSummaryBuilder> grouped = {};

    for (final entry in entries) {
      if (entry.entryType == StockEntryType.miscExpense) continue;
      final rawName = entry.materialName.trim().isNotEmpty
          ? entry.materialName.trim()
          : entry.subType.trim();
      final name = rawName.isEmpty ? 'Unnamed Material' : rawName;
      final key = '${entry.materialId}|${name.toLowerCase()}|${entry.unit.toLowerCase()}';
      final builder = grouped.putIfAbsent(
        key,
            () => _MaterialSummaryBuilder(
          materialId: entry.materialId,
          name: name,
          unit: entry.unit,
        ),
      );
      builder.totalQty += entry.quantity;
      builder.totalAmount += entry.totalAmount;
      builder.entryCount += 1;
      if (entry.entryDate.isAfter(builder.lastDate)) {
        builder.lastDate = entry.entryDate;
      }
    }

    final items = grouped.values.map((b) {
      final material = b.materialId.isNotEmpty
          ? _findMaterialById(invRepo, b.materialId)
          : null;
      return _MaterialSummary(
        materialId: b.materialId,
        name: b.name,
        unit: b.unit,
        totalQty: b.totalQty,
        totalAmount: b.totalAmount,
        lastDate: b.lastDate,
        entryCount: b.entryCount,
        currentStock: material?.currentStock,
      );
    }).toList();

    items.sort((a, b) => b.lastDate.compareTo(a.lastDate));
    return items;
  }

  static dynamic _findMaterialById(InventoryRepository invRepo, String materialId) {
    for (final material in invRepo.materials) {
      if (material.id == materialId) return material;
    }
    return null;
  }
}

class _HeroStat extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;
  const _HeroStat({required this.title, required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _GlassPill({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12.5)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _SectionHeader({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bcNavy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: bcNavy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: bcNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bcAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: bcAmber, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: bcNavy, fontSize: 13, fontWeight: FontWeight.w800, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyStateCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bcNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: bcNavy, size: 26),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _MaterialSummaryTile extends StatelessWidget {
  final _MaterialSummary item;
  final NumberFormat fmt;
  const _MaterialSummaryTile({required this.item, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final avgRate = item.totalQty > 0 ? (item.totalAmount / item.totalQty) : item.totalAmount;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bcAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: bcAmber),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 14.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last purchase: ${DateFormat('d MMM yyyy').format(item.lastDate)}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: bcNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.unit.toUpperCase(),
                  style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniMetric(title: 'Purchased', value: '${item.totalQty.toStringAsFixed(item.totalQty % 1 == 0 ? 0 : 2)} ${item.unit}'),
              _MiniMetric(title: 'Amount', value: fmt.format(item.totalAmount)),
              _MiniMetric(title: 'Avg Rate', value: fmt.format(avgRate)),
              _MiniMetric(title: 'Entries', value: '${item.entryCount}'),
              if (item.currentStock != null)
                _MiniMetric(title: 'Current Stock', value: '${item.currentStock!.toStringAsFixed(item.currentStock! % 1 == 0 ? 0 : 2)} ${item.unit}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String title;
  final String value;
  const _MiniMetric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 13)),
          const SizedBox(height: 3),
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final StockEntryModel entry;
  final NumberFormat fmt;
  const _EntryTile({required this.entry, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final hasPending = entry.pendingAmount > 0;
    final isPaid = !hasPending;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasPending ? bcDanger.withValues(alpha: 0.22) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _entryColor(entry.entryType).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_entryIcon(entry.entryType), color: _entryColor(entry.entryType), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.materialName.isEmpty ? entry.subType : entry.materialName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _HistoryChip(
                      icon: Icons.straighten_rounded,
                      text: '${entry.quantity.toStringAsFixed(entry.quantity % 1 == 0 ? 0 : 2)} ${entry.unit}',
                    ),
                    _HistoryChip(
                      icon: Icons.calendar_today_rounded,
                      text: DateFormat('d MMM yyyy').format(entry.entryDate),
                    ),
                    _HistoryChip(
                      icon: Icons.currency_rupee_rounded,
                      text: fmt.format(entry.totalAmount),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isPaid ? bcSuccess.withValues(alpha: 0.1) : bcDanger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isPaid ? 'Paid' : 'Due',
                  style: TextStyle(
                    color: isPaid ? bcSuccess : bcDanger,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPaid ? 'Cleared' : fmt.format(entry.pendingAmount),
                  style: TextStyle(
                    color: isPaid ? bcSuccess : bcDanger,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _entryColor(StockEntryType t) {
    switch (t) {
      case StockEntryType.directEntry:
        return bcAmber;
      case StockEntryType.supplierBill:
        return const Color(0xFF60A5FA);
      case StockEntryType.miscExpense:
        return const Color(0xFFA78BFA);
    }
  }

  IconData _entryIcon(StockEntryType t) {
    switch (t) {
      case StockEntryType.directEntry:
        return Icons.add_box_rounded;
      case StockEntryType.supplierBill:
        return Icons.receipt_long_rounded;
      case StockEntryType.miscExpense:
        return Icons.shopping_cart_outlined;
    }
  }
}

class _HistoryChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HistoryChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Color(0xFF475569), fontSize: 10.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MaterialSummary {
  final String materialId;
  final String name;
  final String unit;
  final double totalQty;
  final double totalAmount;
  final DateTime lastDate;
  final int entryCount;
  final double? currentStock;

  const _MaterialSummary({
    required this.materialId,
    required this.name,
    required this.unit,
    required this.totalQty,
    required this.totalAmount,
    required this.lastDate,
    required this.entryCount,
    this.currentStock,
  });
}

class _MaterialSummaryBuilder {
  final String materialId;
  final String name;
  final String unit;
  double totalQty = 0;
  double totalAmount = 0;
  int entryCount = 0;
  DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(0);

  _MaterialSummaryBuilder({
    required this.materialId,
    required this.name,
    required this.unit,
  });
}

// ─── Inline Edit Sheet ────────────────────────────────────────────────────────

class _SupplierEditSheet extends StatefulWidget {
  final PartyModel supplier;
  const _SupplierEditSheet({required this.supplier});
  @override
  State<_SupplierEditSheet> createState() => _SupplierEditSheetState();
}

class _SupplierEditSheetState extends State<_SupplierEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _gstCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _termsCtrl;
  late final TextEditingController _billingNameCtrl;
  bool _submitting = false;

  static const _termOptions = ['On Delivery', 'Net 7 days', 'Net 15 days', 'Net 30 days', 'Credit Account'];

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _nameCtrl = TextEditingController(text: s.name);
    _phoneCtrl = TextEditingController(text: s.contactNumber ?? '');
    _gstCtrl = TextEditingController(text: s.gstNumber ?? '');
    _addrCtrl = TextEditingController(text: s.address ?? '');
    _termsCtrl = TextEditingController(text: s.paymentTerms ?? '');
    _billingNameCtrl = TextEditingController(text: s.billingName ?? '');
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _gstCtrl, _addrCtrl, _termsCtrl, _billingNameCtrl]) {
      c.dispose();
    }
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Edit Supplier', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 20),
            _ef('Supplier Name *', _nameCtrl),
            const SizedBox(height: 10),
            _ef('Bill Party (Legal Name)', _billingNameCtrl),
            const SizedBox(height: 10),
            _ef('Phone Number', _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            _ef('GST Number', _gstCtrl),
            const SizedBox(height: 10),
            _ef('Address', _addrCtrl),
            const SizedBox(height: 10),
            const Text('Payment Terms', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _termOptions
                  .map(
                    (t) => GestureDetector(
                  onTap: () => setState(() => _termsCtrl.text = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _termsCtrl.text == t ? bcAmber.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _termsCtrl.text == t ? bcAmber : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        color: _termsCtrl.text == t ? bcAmber : const Color(0xFF475569),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : () => _save(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bcNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Supplier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ef(String label, TextEditingController ctrl, {TextInputType keyboardType = TextInputType.text}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 5),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: bcNavy),
        decoration: InputDecoration(
          fillColor: const Color(0xFFF8FAFC),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bcAmber, width: 2)),
        ),
      ),
    ],
  );

  Future<void> _save(BuildContext context) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _submitting = true);
    await context.read<PartyRepository>().updateParty(widget.supplier.copyWith(
      name: name,
      contactNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      gstNumber: _gstCtrl.text.trim().isEmpty ? null : _gstCtrl.text.trim(),
      address: _addrCtrl.text.trim().isEmpty ? null : _addrCtrl.text.trim(),
      paymentTerms: _termsCtrl.text.trim().isEmpty ? null : _termsCtrl.text.trim(),
      billingName: _billingNameCtrl.text.trim().isEmpty ? null : _billingNameCtrl.text.trim(),
    ));
    if (context.mounted) Navigator.pop(context);
  }
}
