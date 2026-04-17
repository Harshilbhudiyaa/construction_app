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

/// Supplier detail: purchase history, balance tracker, and quick pay.
class SupplierDetailScreen extends StatelessWidget {
  final String supplierId;
  const SupplierDetailScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context) {
    final partyRepo = context.watch<PartyRepository>();
    final stockRepo = context.watch<StockEntryRepository>();

    final supplier = partyRepo.getPartyById(supplierId);
    if (supplier == null) {
      return const Scaffold(body: Center(child: Text('Supplier not found')));
    }

    final entries  = stockRepo.getEntriesForSupplier(supplierId);
    final total    = stockRepo.getTotalPurchaseFromSupplier(supplierId);
    final paid     = stockRepo.getTotalPaidToSupplier(supplierId);
    final pending  = stockRepo.getPendingForSupplier(supplierId);
    
    // Calculate Supplier's Stock Value
    final invRepo    = context.watch<InventoryRepository>();
    final stockValue = stockRepo.getStockValueForSupplier(supplierId, invRepo.materials);
    
    final fmt      = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bcSurface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: bcNavy,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: bcAmber),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _SupplierEditSheet(supplier: supplier),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: bcNavy,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                          child: Center(child: Text(supplier.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(supplier.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                          if (supplier.contactNumber != null)
                            Text(supplier.contactNumber!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ])),
                      ]),
                      const SizedBox(height: 16),
                      // 4 balance pills in a scrollable row to avoid overflow
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        clipBehavior: Clip.none,
                        child: Row(children: [
                          _BalancePill('Total', fmt.format(total), Colors.white70),
                          const SizedBox(width: 8),
                          _BalancePill('Paid', fmt.format(paid), bcSuccess),
                          const SizedBox(width: 8),
                          _BalancePill('Due', fmt.format(pending), pending > 0 ? bcDanger : Colors.white70),
                          const SizedBox(width: 8),
                          _BalancePill('In Stock', fmt.format(stockValue), bcInfo),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(children: [
                    if (supplier.billingName != null) ...[
                      _InfoRow(Icons.business_rounded, 'Bill Party', supplier.billingName!),
                      const Divider(height: 14),
                    ],
                    _InfoRow(Icons.payment_rounded, 'Payment Terms', supplier.paymentTerms ?? 'Not specified'),
                    if (supplier.address != null) ...[
                      const Divider(height: 14),
                      _InfoRow(Icons.location_on_rounded, 'Address', supplier.address!),
                    ],
                    if (supplier.gstNumber != null) ...[
                      const Divider(height: 14),
                      _InfoRow(Icons.receipt_rounded, 'GST Number', supplier.gstNumber!),
                    ],
                  ]),
                ),

                const SizedBox(height: 16),

                // Quick Pay button (only when pending > 0)
                if (pending > 0) ...[
                  SizedBox(
                    width: double.infinity, height: 50,
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
                      icon: const Icon(Icons.payments_rounded),
                      label: Text('Pay Due: ${fmt.format(pending)}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bcSuccess, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Quick Actions
                const Text('QUICK ACTIONS', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.4)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _DetailMethodCard(
                    icon: Icons.add_circle_rounded, color: bcAmber, title: 'Add\nMaterial',
                    onTap: () => showModalBottomSheet(
                      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                      builder: (_) => DirectEntrySheet(initialSupplier: supplier),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _DetailMethodCard(
                    icon: Icons.receipt_long_rounded, color: const Color(0xFF60A5FA), title: 'Add\nBill Entry',
                    onTap: () => showModalBottomSheet(
                      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                      builder: (_) => SupplierBillSheet(initialSupplier: supplier),
                    ),
                  )),
                ]),
                const SizedBox(height: 24),

                // Purchase history
                const Text('PURCHASE HISTORY', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.4)),
                const SizedBox(height: 10),

                if (entries.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Text('No purchases from this supplier yet.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ),

                ...entries.map((e) => _EntryTile(entry: e, fmt: fmt)),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

}

// ─── Detail Method Card ──────────────────────────────────────────────────────

class _DetailMethodCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  const _DetailMethodCard({required this.icon, required this.color, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 12, height: 1.2))),
      ]),
    ),
  );
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _BalancePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BalancePill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4))),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
    const SizedBox(width: 8),
    Text('$label: ', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
    Expanded(child: Text(value, style: const TextStyle(color: bcNavy, fontSize: 12, fontWeight: FontWeight.w700), maxLines: 2)),
  ]);
}

class _EntryTile extends StatelessWidget {
  final StockEntryModel entry;
  final NumberFormat fmt;
  const _EntryTile({required this.entry, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final hasPending = entry.pendingAmount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasPending ? bcDanger.withValues(alpha: 0.2) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _entryColor(entry.entryType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_entryIcon(entry.entryType), color: _entryColor(entry.entryType), size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.materialName.isEmpty ? entry.subType : entry.materialName,
                style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              '${entry.quantity} ${entry.unit}  •  ${_dateStr(entry.entryDate)}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
            ),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(fmt.format(entry.totalAmount), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 12)),
            if (hasPending)
              Text('Due ${fmt.format(entry.pendingAmount)}', style: const TextStyle(color: bcDanger, fontSize: 9.5, fontWeight: FontWeight.w700)),
            if (!hasPending)
              const Text('Paid ✓', style: TextStyle(color: bcSuccess, fontSize: 9.5, fontWeight: FontWeight.w700)),
          ]),
        ],
      ),
    );
  }

  String _dateStr(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Color _entryColor(StockEntryType t) {
    switch (t) {
      case StockEntryType.directEntry:  return bcAmber;
      case StockEntryType.supplierBill: return const Color(0xFF60A5FA);
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

// ─── Inline Edit Sheet ────────────────────────────────────────────────────────
// Duplicated here to avoid cross-importing private classes from supplier_list_screen.

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
    _nameCtrl  = TextEditingController(text: s.name);
    _phoneCtrl = TextEditingController(text: s.contactNumber ?? '');
    _gstCtrl   = TextEditingController(text: s.gstNumber ?? '');
    _addrCtrl  = TextEditingController(text: s.address ?? '');
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
        color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
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
            Wrap(spacing: 8, runSpacing: 6, children: _termOptions.map((t) => GestureDetector(
              onTap: () => setState(() => _termsCtrl.text = t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _termsCtrl.text == t ? bcAmber.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _termsCtrl.text == t ? bcAmber : const Color(0xFFE2E8F0)),
                ),
                child: Text(t, style: TextStyle(
                  color: _termsCtrl.text == t ? bcAmber : const Color(0xFF475569),
                  fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            )).toList()),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : () => _save(context),
                style: ElevatedButton.styleFrom(backgroundColor: bcNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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

  Widget _ef(String label, TextEditingController ctrl, {TextInputType keyboardType = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 5),
        TextFormField(
          controller: ctrl, keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, color: bcNavy),
          decoration: InputDecoration(
            fillColor: const Color(0xFFF8FAFC), filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bcAmber, width: 2)),
          ),
        ),
      ]);

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
