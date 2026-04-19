import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/models/stock_entry_model.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/repositories/stock_entry_repository.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/features/stock/widgets/stock_entry_sheets.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _kNavy    = Color(0xFF0C2340);
const _kNavy2   = Color(0xFF143258);
const _kNavy3   = Color(0xFF1A3F6F);
const _kAmber   = Color(0xFFF59E0B);
const _kAmber2  = Color(0xFFD97706);
const _kSuccess = Color(0xFF10B981);
const _kDanger  = Color(0xFFEF4444);
const _kInfo    = Color(0xFF3B82F6);
const _kBg      = Color(0xFFF0F4F8);
const _kBorder  = Color(0xFFE2E8F0);
const _kText2   = Color(0xFF475569);
const _kSurface = Color(0xFFF8FAFC);

enum _HistoryFilter { all, paid, due }

// ─── Main Screen ──────────────────────────────────────────────────────────────
class SupplierDetailScreen extends StatefulWidget {
  final String supplierId;
  const SupplierDetailScreen({super.key, required this.supplierId});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final partyRepo       = context.watch<PartyRepository>();
    final stockRepo       = context.watch<StockEntryRepository>();
    final invRepo         = context.watch<InventoryRepository>();
    final supplier        = partyRepo.getPartyById(widget.supplierId);

    if (supplier == null) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: Text('Supplier not found')),
      );
    }

    final entries         = stockRepo.getEntriesForSupplier(widget.supplierId);
    final total           = stockRepo.getTotalPurchaseFromSupplier(widget.supplierId);
    final paid            = stockRepo.getTotalPaidToSupplier(widget.supplierId);
    final pending         = stockRepo.getPendingForSupplier(widget.supplierId);
    final stockValue      = stockRepo.getStockValueForSupplier(widget.supplierId, invRepo.materials);
    final materialSummary = _buildMaterialSummary(entries, invRepo);
    final fmt             = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final filteredEntries = entries.where((e) {
      if (_filter == _HistoryFilter.paid) return e.pendingAmount <= 0;
      if (_filter == _HistoryFilter.due)  return e.pendingAmount > 0;
      return true;
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _kAmber,
          foregroundColor: _kNavy,
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          onPressed: () => _showSheet(context, SupplierBillSheet(initialSupplier: supplier)),
          icon: const Icon(Icons.receipt_long_rounded, size: 18),
          label: const Text('Add Bill Entry',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, letterSpacing: -0.2)),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _HeroSection(
                supplier: supplier,
                total: total, paid: paid, pending: pending,
                stockValue: stockValue,
                entryCount: entries.length,
                materialCount: materialSummary.length,
                fmt: fmt,
                onEdit: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _SupplierEditSheet(supplier: supplier),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 100),
                child: Column(
                  children: [
                    _InfoCard(supplier: supplier),
                    const SizedBox(height: 12),
                    if (pending > 0) ...[
                      _PendingBanner(supplier: supplier, pending: pending, fmt: fmt),
                      const SizedBox(height: 12),
                    ],
                    _MaterialsCard(supplier: supplier, materialSummary: materialSummary, fmt: fmt),
                    const SizedBox(height: 12),
                    _HistoryCard(entries: filteredEntries, filter: _filter,
                        onFilterChanged: (f) => setState(() => _filter = f), fmt: fmt),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, Widget sheet) => showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => sheet,
  );

  static List<_MaterialSummary> _buildMaterialSummary(
      List<StockEntryModel> entries, InventoryRepository invRepo) {
    final Map<String, _MaterialSummaryBuilder> map = {};
    for (final e in entries) {
      if (e.entryType == StockEntryType.miscExpense) continue;
      final raw  = e.materialName.trim().isNotEmpty ? e.materialName.trim() : e.subType.trim();
      final name = raw.isEmpty ? 'Unnamed' : raw;
      final key  = '${e.materialId}|${name.toLowerCase()}|${e.unit.toLowerCase()}';
      final b    = map.putIfAbsent(key, () => _MaterialSummaryBuilder(
          materialId: e.materialId, name: name, unit: e.unit));
      b.totalQty    += e.quantity;
      b.totalAmount += e.totalAmount;
      b.entryCount  += 1;
      if (e.entryDate.isAfter(b.lastDate)) b.lastDate = e.entryDate;
    }
    return map.values.map((b) {
      final mat = b.materialId.isNotEmpty
          ? invRepo.materials.cast<dynamic>().firstWhere(
              (m) => m.id == b.materialId, orElse: () => null)
          : null;
      return _MaterialSummary(materialId: b.materialId, name: b.name, unit: b.unit,
          totalQty: b.totalQty, totalAmount: b.totalAmount, lastDate: b.lastDate,
          entryCount: b.entryCount, currentStock: mat?.currentStock);
    }).toList()..sort((a, b) => b.lastDate.compareTo(a.lastDate));
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
// Uses intrinsic Column height — no expandedHeight needed, no overflow.
class _HeroSection extends StatelessWidget {
  final PartyModel supplier;
  final double total, paid, pending, stockValue;
  final int entryCount, materialCount;
  final NumberFormat fmt;
  final VoidCallback onEdit;

  const _HeroSection({
    required this.supplier,
    required this.total, required this.paid, required this.pending,
    required this.stockValue, required this.entryCount, required this.materialCount,
    required this.fmt, required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_kNavy, _kNavy2, _kNavy3],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(top: -50, right: -40,
              child: Container(width: 200, height: 200,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.03)))),
          Positioned(bottom: 10, left: -50,
              child: Container(width: 160, height: 160,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: _kAmber.withValues(alpha: 0.04)))),

          Padding(
            padding: EdgeInsets.fromLTRB(16, top + 10, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(children: [
                  _HeroBtn(icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context)),
                  const Spacer(),
                  _HeroBtn(icon: Icons.edit_rounded, iconColor: _kAmber, onTap: onEdit),
                ]),
                const SizedBox(height: 16),

                // Profile row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Avatar(name: supplier.name),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(supplier.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w900,
                                fontSize: 20, letterSpacing: -0.5, height: 1.15,
                              )),
                          if (supplier.contactNumber?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(supplier.contactNumber!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12, fontWeight: FontWeight.w500,
                                )),
                          ],
                          const SizedBox(height: 6),
                          _ActiveBadge(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats
                _StatsRow(total: total, paid: paid, pending: pending, fmt: fmt),
                const SizedBox(height: 12),

                // Pills
                _PillsRow(
                  stockValue: stockValue, entryCount: entryCount,
                  materialCount: materialCount,
                  paymentTerms: supplier.paymentTerms, fmt: fmt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  const _HeroBtn({required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 18),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) => Container(
    width: 52, height: 52,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white.withValues(alpha: 0.12),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
    ),
    child: Center(
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'S',
          style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900,
            fontSize: 20, letterSpacing: -1,
          )),
    ),
  );
}

class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: _kSuccess.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _kSuccess.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6,
            decoration: const BoxDecoration(color: _kSuccess, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        const Text('Active Supplier',
            style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 0.2)),
      ],
    ),
  );
}

class _StatsRow extends StatelessWidget {
  final double total, paid, pending;
  final NumberFormat fmt;
  const _StatsRow({required this.total, required this.paid, required this.pending, required this.fmt});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    ),
    child: IntrinsicHeight(
      child: Row(children: [
        Expanded(child: _StatCell(label: 'Total Purchase', value: fmt.format(total), color: Colors.white)),
        _VDiv(),
        Expanded(child: _StatCell(label: 'Paid', value: fmt.format(paid), color: const Color(0xFF34D399))),
        _VDiv(),
        Expanded(child: _StatCell(label: 'Due', value: fmt.format(pending),
            color: pending > 0 ? const Color(0xFFF87171) : Colors.white70)),
      ]),
    ),
  );
}

class _StatCell extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    child: Column(children: [
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13.5, letterSpacing: -0.3)),
      const SizedBox(height: 3),
      Text(label, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 9.5,
              fontWeight: FontWeight.w600, letterSpacing: 0.3)),
    ]),
  );
}

class _VDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1, margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white.withValues(alpha: 0.1));
}

class _PillsRow extends StatelessWidget {
  final double stockValue;
  final int entryCount, materialCount;
  final String? paymentTerms;
  final NumberFormat fmt;
  const _PillsRow({required this.stockValue, required this.entryCount,
    required this.materialCount, required this.paymentTerms, required this.fmt});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    child: Row(children: [
      _Pill(icon: Icons.inventory_2_rounded,  label: 'Stock Value', value: fmt.format(stockValue), color: _kInfo),
      const SizedBox(width: 8),
      _Pill(icon: Icons.receipt_long_rounded, label: 'Entries',     value: '$entryCount',           color: _kAmber),
      const SizedBox(width: 8),
      _Pill(icon: Icons.category_rounded,     label: 'Materials',   value: '$materialCount',         color: Colors.white70),
      const SizedBox(width: 8),
      _Pill(icon: Icons.access_time_rounded,  label: 'Pay Terms',   value: paymentTerms ?? 'N/A',   color: const Color(0xFFA78BFA)),
    ]),
  );
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _Pill({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 9),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12.5)),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600)),
        ]),
      ],
    ),
  );
}

// ─── Shared Card Shell ────────────────────────────────────────────────────────
class _SCard extends StatelessWidget {
  final Widget child;
  const _SCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _kBorder),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16, offset: const Offset(0, 6))],
    ),
    child: child,
  );
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _SHeader({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: _kNavy.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: _kNavy, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: _kNavy, fontWeight: FontWeight.w900,
              fontSize: 16, letterSpacing: -0.2)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: _kText2, fontSize: 11.5, height: 1.4)),
        ],
      )),
    ],
  );
}

// ─── Supplier Info Card ───────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final PartyModel supplier;
  const _InfoCard({required this.supplier});

  @override
  Widget build(BuildContext context) => _SCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SHeader(
          title: 'Supplier Information',
          subtitle: 'Business details and payment preferences',
          icon: Icons.business_center_rounded,
        ),
        const SizedBox(height: 16),
        if (supplier.billingName?.trim().isNotEmpty == true)
          _InfoRow(icon: Icons.apartment_rounded, label: 'Bill Party', value: supplier.billingName!),
        _InfoRow(icon: Icons.payment_rounded, label: 'Payment Terms',
            value: supplier.paymentTerms ?? 'Not specified'),
        if (supplier.address?.trim().isNotEmpty == true)
          _InfoRow(icon: Icons.location_on_rounded, label: 'Address', value: supplier.address!),
        if (supplier.gstNumber?.trim().isNotEmpty == true)
          _InfoRow(icon: Icons.receipt_long_rounded, label: 'GST Number',
              value: supplier.gstNumber!, mono: true, isLast: true),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool mono, isLast;
  const _InfoRow({required this.icon, required this.label, required this.value,
    this.mono = false, this.isLast = false});

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: _kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: _kAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: _kAmber2, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _kText2, fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 0.2)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(
              color: _kNavy, fontSize: 13, fontWeight: FontWeight.w800, height: 1.35,
              fontFamily: mono ? 'monospace' : null, letterSpacing: mono ? 0.6 : null,
            )),
          ],
        )),
      ],
    ),
  );
}

// ─── Pending Payment Banner ───────────────────────────────────────────────────
class _PendingBanner extends StatelessWidget {
  final PartyModel supplier;
  final double pending;
  final NumberFormat fmt;
  const _PendingBanner({required this.supplier, required this.pending, required this.fmt});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [_kSuccess, Color(0xFF059669)],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: _kSuccess.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Pending Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.5)),
        ]),
        const SizedBox(height: 5),
        const Text('Outstanding due — tap below to clear',
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity, height: 48,
          child: ElevatedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
              builder: (_) => SupplierPaymentSheet(supplier: supplier, pendingAmount: pending),
            ),
            icon: const Icon(Icons.arrow_downward_rounded, size: 17),
            label: Text('Pay Due ${fmt.format(pending)}'),
            style: ElevatedButton.styleFrom(
              elevation: 0, backgroundColor: Colors.white, foregroundColor: _kSuccess,
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── Materials Card ───────────────────────────────────────────────────────────
class _MaterialsCard extends StatelessWidget {
  final PartyModel supplier;
  final List<_MaterialSummary> materialSummary;
  final NumberFormat fmt;
  const _MaterialsCard({required this.supplier, required this.materialSummary, required this.fmt});

  @override
  Widget build(BuildContext context) => _SCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SHeader(
          title: 'Materials',
          subtitle: 'Purchased from this supplier',
          icon: Icons.category_rounded,
        ),
        const SizedBox(height: 16),
        if (materialSummary.isEmpty)
          _EmptyState(icon: Icons.inventory_2_outlined, title: 'No material entries yet',
              subtitle: 'Use Add Bill to save the first purchase.')
        else
          ...materialSummary.asMap().entries.map((e) => Padding(
            padding: EdgeInsets.only(bottom: e.key < materialSummary.length - 1 ? 10 : 0),
            child: _MaterialTile(item: e.value, fmt: fmt),
          )),
      ],
    ),
  );
}

class _MaterialTile extends StatelessWidget {
  final _MaterialSummary item;
  final NumberFormat fmt;
  const _MaterialTile({required this.item, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final avg = item.totalQty > 0 ? item.totalAmount / item.totalQty : item.totalAmount;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: _kAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.inventory_2_rounded, color: _kAmber2, size: 18),
            ),
            const SizedBox(width: 11),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _kNavy, fontWeight: FontWeight.w900, fontSize: 13.5, letterSpacing: -0.1)),
                const SizedBox(height: 3),
                Text('Last: ${DateFormat('d MMM yyyy').format(item.lastDate)}',
                    style: const TextStyle(color: _kText2, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                  color: _kNavy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(9)),
              child: Text(item.unit.toUpperCase(),
                  style: const TextStyle(color: _kNavy, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5)),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _Metric(title: 'Purchased', value: '${_q(item.totalQty)} ${item.unit}'),
              _Metric(title: 'Amount',    value: fmt.format(item.totalAmount)),
              _Metric(title: 'Avg Rate',  value: fmt.format(avg)),
              _Metric(title: 'Entries',   value: '${item.entryCount}'),
              if (item.currentStock != null)
                _Metric(title: 'In Stock', value: '${_q(item.currentStock!)} ${item.unit}', hl: true),
            ],
          ),
        ],
      ),
    );
  }

  static String _q(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

class _Metric extends StatelessWidget {
  final String title, value;
  final bool hl;
  const _Metric({required this.title, required this.value, this.hl = false});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 90),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: hl ? _kSuccess.withValues(alpha: 0.06) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: hl ? _kSuccess.withValues(alpha: 0.2) : _kBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: hl ? _kSuccess : _kNavy, fontWeight: FontWeight.w900, fontSize: 12.5)),
        const SizedBox(height: 2),
        Text(title, style: TextStyle(color: hl ? _kSuccess : _kText2, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// ─── History Card ─────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final List<StockEntryModel> entries;
  final _HistoryFilter filter;
  final ValueChanged<_HistoryFilter> onFilterChanged;
  final NumberFormat fmt;
  const _HistoryCard({required this.entries, required this.filter,
    required this.onFilterChanged, required this.fmt});

  @override
  Widget build(BuildContext context) => _SCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SHeader(
          title: 'Purchase History',
          subtitle: 'All transactions from this supplier',
          icon: Icons.history_rounded,
        ),
        const SizedBox(height: 14),
        Row(
          children: _HistoryFilter.values.map((f) {
            final isLast = f == _HistoryFilter.due;
            return Expanded(child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 6),
              child: _FilterTab(
                label: f.name[0].toUpperCase() + f.name.substring(1),
                selected: filter == f,
                onTap: () => onFilterChanged(f),
              ),
            ));
          }).toList(),
        ),
        const SizedBox(height: 14),
        if (entries.isEmpty)
          _EmptyState(icon: Icons.receipt_long_outlined, title: 'No entries found',
              subtitle: 'Transactions appear here once bills are added.')
        else
          ...entries.asMap().entries.map((e) => Padding(
            padding: EdgeInsets.only(bottom: e.key < entries.length - 1 ? 9 : 0),
            child: _EntryTile(entry: e.value, fmt: fmt),
          )),
      ],
    ),
  );
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? _kNavy : _kSurface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: selected ? _kNavy : _kBorder),
      ),
      child: Text(label,
          style: TextStyle(color: selected ? Colors.white : _kText2, fontSize: 12, fontWeight: FontWeight.w700)),
    ),
  );
}

class _EntryTile extends StatelessWidget {
  final StockEntryModel entry;
  final NumberFormat fmt;
  const _EntryTile({required this.entry, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isPaid = entry.pendingAmount <= 0;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPaid ? _kBorder : _kDanger.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _entryColor(entry.entryType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_entryIcon(entry.entryType), color: _entryColor(entry.entryType), size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.materialName.isEmpty ? entry.subType : entry.materialName,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _kNavy, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: -0.1)),
              const SizedBox(height: 7),
              Wrap(spacing: 6, runSpacing: 5, children: [
                _Chip(icon: Icons.straighten_rounded,
                    text: '${_q(entry.quantity)} ${entry.unit}'),
                _Chip(icon: Icons.calendar_today_rounded,
                    text: DateFormat('d MMM yyyy').format(entry.entryDate)),
                _Chip(icon: Icons.currency_rupee_rounded,
                    text: fmt.format(entry.totalAmount)),
              ]),
            ],
          )),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: isPaid ? _kSuccess.withValues(alpha: 0.08) : _kDanger.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(isPaid ? 'PAID' : 'DUE',
                    style: TextStyle(color: isPaid ? _kSuccess : _kDanger, fontSize: 10,
                        fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                const SizedBox(height: 2),
                Text(isPaid ? 'Cleared' : fmt.format(entry.pendingAmount),
                    style: TextStyle(color: isPaid ? _kSuccess : _kDanger, fontSize: 11.5, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _q(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  Color _entryColor(StockEntryType t) {
    switch (t) {
      case StockEntryType.directEntry:  return _kAmber2;
      case StockEntryType.supplierBill: return _kInfo;
      case StockEntryType.miscExpense:  return const Color(0xFFA78BFA);
    }
  }

  IconData _entryIcon(StockEntryType t) {
    switch (t) {
      case StockEntryType.directEntry:  return Icons.add_box_rounded;
      case StockEntryType.supplierBill: return Icons.receipt_long_rounded;
      case StockEntryType.miscExpense:  return Icons.shopping_cart_outlined;
    }
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
        color: _kSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: _kText2),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: _kText2, fontSize: 10.5, fontWeight: FontWeight.w700)),
    ]),
  );
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
        color: _kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kBorder)),
    child: Column(children: [
      Container(width: 50, height: 50,
          decoration: BoxDecoration(color: _kNavy.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: _kNavy.withValues(alpha: 0.5), size: 24)),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(color: _kNavy, fontWeight: FontWeight.w900, fontSize: 14.5)),
      const SizedBox(height: 5),
      Text(subtitle, textAlign: TextAlign.center,
          style: const TextStyle(color: _kText2, fontSize: 12.5, height: 1.4)),
    ]),
  );
}

// ─── Data Models ──────────────────────────────────────────────────────────────
class _MaterialSummary {
  final String materialId, name, unit;
  final double totalQty, totalAmount;
  final DateTime lastDate;
  final int entryCount;
  final double? currentStock;
  const _MaterialSummary({required this.materialId, required this.name, required this.unit,
    required this.totalQty, required this.totalAmount, required this.lastDate,
    required this.entryCount, this.currentStock});
}

class _MaterialSummaryBuilder {
  final String materialId, name, unit;
  double totalQty = 0, totalAmount = 0;
  int entryCount = 0;
  DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(0);
  _MaterialSummaryBuilder({required this.materialId, required this.name, required this.unit});
}

// ─── Edit Sheet ───────────────────────────────────────────────────────────────
class _SupplierEditSheet extends StatefulWidget {
  final PartyModel supplier;
  const _SupplierEditSheet({required this.supplier});
  @override
  State<_SupplierEditSheet> createState() => _SupplierEditSheetState();
}

class _SupplierEditSheetState extends State<_SupplierEditSheet> {
  late final TextEditingController _name, _phone, _gst, _addr, _terms, _billing;
  bool _saving = false;

  static const _termOpts = ['On Delivery', 'Net 7 days', 'Net 15 days', 'Net 30 days', 'Credit Account'];

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _name    = TextEditingController(text: s.name);
    _phone   = TextEditingController(text: s.contactNumber ?? '');
    _gst     = TextEditingController(text: s.gstNumber ?? '');
    _addr    = TextEditingController(text: s.address ?? '');
    _terms   = TextEditingController(text: s.paymentTerms ?? '');
    _billing = TextEditingController(text: s.billingName ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _gst, _addr, _terms, _billing]) c.dispose();
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
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _kBorder, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 18),
            Row(children: [
              Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: _kNavy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.edit_rounded, color: _kNavy, size: 17)),
              const SizedBox(width: 12),
              const Text('Edit Supplier', style: TextStyle(color: _kNavy, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.3)),
            ]),
            const SizedBox(height: 20),
            _f('Supplier Name *', _name),
            const SizedBox(height: 10),
            _f('Bill Party (Legal Name)', _billing),
            const SizedBox(height: 10),
            _f('Phone Number', _phone, type: TextInputType.phone),
            const SizedBox(height: 10),
            _f('GST Number', _gst),
            const SizedBox(height: 10),
            _f('Address', _addr, lines: 2),
            const SizedBox(height: 14),
            const Text('Payment Terms', style: TextStyle(color: _kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7, runSpacing: 7,
              children: _termOpts.map((t) => GestureDetector(
                onTap: () => setState(() => _terms.text = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: _terms.text == t ? _kAmber.withValues(alpha: 0.1) : _kSurface,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _terms.text == t ? _kAmber : _kBorder),
                  ),
                  child: Text(t, style: TextStyle(
                    color: _terms.text == t ? _kAmber2 : _kText2,
                    fontSize: 11.5, fontWeight: FontWeight.w700,
                  )),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : () => _save(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavy, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Update Supplier',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _f(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text, int lines = 1}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _kNavy, fontWeight: FontWeight.w700, fontSize: 12.5)),
        const SizedBox(height: 5),
        TextFormField(
          controller: ctrl, keyboardType: type, maxLines: lines,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            fillColor: _kSurface, filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _kAmber, width: 1.5)),
          ),
        ),
      ]);

  Future<void> _save(BuildContext ctx) async {
    final n = _name.text.trim();
    if (n.isEmpty) return;
    setState(() => _saving = true);
    await ctx.read<PartyRepository>().updateParty(widget.supplier.copyWith(
      name: n,
      contactNumber: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      gstNumber:     _gst.text.trim().isEmpty   ? null : _gst.text.trim(),
      address:       _addr.text.trim().isEmpty   ? null : _addr.text.trim(),
      paymentTerms:  _terms.text.trim().isEmpty  ? null : _terms.text.trim(),
      billingName:   _billing.text.trim().isEmpty? null : _billing.text.trim(),
    ));
    if (ctx.mounted) Navigator.pop(ctx);
  }
}