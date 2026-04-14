import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/repositories/stock_entry_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/core/routing/app_router.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final partyRepo = context.watch<PartyRepository>();
    final stockRepo = context.watch<StockEntryRepository>();
    final invRepo   = context.watch<InventoryRepository>();

    final suppliers = partyRepo.suppliers.where((s) =>
        _search.isEmpty || s.name.toLowerCase().contains(_search.toLowerCase())).toList();

    final totalPending = suppliers.fold(0.0, (s, p) => s + stockRepo.getPendingForSupplier(p.id));
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bcSurface,
      appBar: AppBar(
        backgroundColor: bcNavy,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: bcSuccess),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Suppliers', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bcDanger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Due: ${fmt.format(totalPending)}',
                style: const TextStyle(color: bcDanger, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: _SearchBar(onChanged: (v) => setState(() => _search = v)),
          ),

          // List
          Expanded(
            child: partyRepo.isLoading
                ? const Center(child: CircularProgressIndicator(color: bcAmber))
                : suppliers.isEmpty
                    ? _emptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                        physics: const BouncingScrollPhysics(),
                        itemCount: suppliers.length,
                        itemBuilder: (_, i) {
                          final s = suppliers[i];
                          final pending    = stockRepo.getPendingForSupplier(s.id);
                          final total      = stockRepo.getTotalPurchaseFromSupplier(s.id);
                          final stockVal   = stockRepo.getStockValueForSupplier(s.id, invRepo.materials);
                          
                          return _SupplierCard(
                            supplier: s,
                            pending: pending,
                            totalPurchase: total,
                            stockValue: stockVal,
                            fmt: fmt,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.supplierDetail, arguments: s.id),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSupplierSheet(context),
        backgroundColor: bcAmber,
        foregroundColor: bcNavy,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Supplier', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.people_alt_outlined, size: 60, color: Color(0xFFCBD5E1)),
        const SizedBox(height: 14),
        const Text('No suppliers yet', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 6),
        const Text('Add your first supplier', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
      ],
    ),
  );

  void _showAddSupplierSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SupplierFormSheet(),
    );
  }
}

// ─── Supplier Card ─────────────────────────────────────────────────────────────

class _SupplierCard extends StatelessWidget {
  final PartyModel supplier;
  final double pending;
  final double totalPurchase;
  final double stockValue;
  final NumberFormat fmt;
  final VoidCallback onTap;

  const _SupplierCard({
    required this.supplier,
    required this.pending,
    required this.totalPurchase,
    required this.stockValue,
    required this.fmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPending = pending > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPending ? bcDanger.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: bcNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'S',
                  style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(supplier.name, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (supplier.contactNumber != null) ...[
                        const Icon(Icons.phone_rounded, size: 11, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 3),
                        Text(supplier.contactNumber!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        const SizedBox(width: 8),
                      ],
                      if (supplier.paymentTerms != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(4)),
                          child: Text(supplier.paymentTerms!, style: const TextStyle(color: Color(0xFF16A34A), fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: bcDanger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Due: ${fmt.format(pending)}', style: const TextStyle(color: bcDanger, fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                if (totalPurchase > 0) ...[
                  const SizedBox(height: 3),
                  Text('Total: ${fmt.format(totalPurchase)}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                ],
                if (stockValue > 0) ...[
                  const SizedBox(height: 2),
                  Text('Stock: ${fmt.format(stockValue)}', style: const TextStyle(color: bcInfo, fontWeight: FontWeight.w700, fontSize: 10)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Supplier Form Sheet ──────────────────────────────────────────────────────

class _SupplierFormSheet extends StatefulWidget {
  final PartyModel? existing;
  const _SupplierFormSheet({this.existing});

  @override
  State<_SupplierFormSheet> createState() => _SupplierFormSheetState();
}

class _SupplierFormSheetState extends State<_SupplierFormSheet> {
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _gstCtrl     = TextEditingController();
  final _addrCtrl    = TextEditingController();
  final _termsCtrl   = TextEditingController();
  final _billingNameCtrl = TextEditingController();
  bool _submitting = false;

  static const _paymentTermsOptions = ['On Delivery', 'Net 7 days', 'Net 15 days', 'Net 30 days', 'Credit Account'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final s = widget.existing!;
      _nameCtrl.text  = s.name;
      _phoneCtrl.text = s.contactNumber ?? '';
      _gstCtrl.text   = s.gstNumber ?? '';
      _addrCtrl.text  = s.address ?? '';
      _termsCtrl.text = s.paymentTerms ?? '';
      _billingNameCtrl.text = s.billingName ?? '';
    }
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
        color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(widget.existing == null ? 'Add Supplier' : 'Edit Supplier',
                style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 20),

            _field('Supplier Name *', _nameCtrl, hint: 'e.g. Ultratech Cement Ltd'),
            const SizedBox(height: 12),
            _field('Bill Party (Legal Name)', _billingNameCtrl, hint: 'e.g. Ultratech India Private Limited'),
            const SizedBox(height: 12),
            _field('Phone Number', _phoneCtrl, hint: '9876543210', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _field('GST Number (optional)', _gstCtrl, hint: '22AAAAA0000A1Z5'),
            const SizedBox(height: 12),
            _field('Address', _addrCtrl, hint: 'City, State'),
            const SizedBox(height: 12),

            const Text('Payment Terms', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _paymentTermsOptions.map((t) => GestureDetector(
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
                    fontSize: 11, fontWeight: FontWeight.w700,
                  )),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : () => _submit(context),
                icon: _submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_rounded),
                label: Text(widget.existing == null ? 'Save Supplier' : 'Update Supplier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bcNavy, foregroundColor: Colors.white,
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier name is required')));
      return;
    }
    setState(() => _submitting = true);
    final repo = context.read<PartyRepository>();
    if (widget.existing == null) {
      await repo.addParty(PartyModel(
        id: const Uuid().v4(),
        name: name,
        category: PartyCategory.supplier,
        contactNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        gstNumber: _gstCtrl.text.trim().isEmpty ? null : _gstCtrl.text.trim(),
        address: _addrCtrl.text.trim().isEmpty ? null : _addrCtrl.text.trim(),
        paymentTerms: _termsCtrl.text.trim().isEmpty ? null : _termsCtrl.text.trim(),
        billingName: _billingNameCtrl.text.trim().isEmpty ? null : _billingNameCtrl.text.trim(),
        createdAt: DateTime.now(),
      ));
    } else {
      await repo.updateParty(widget.existing!.copyWith(
        name: name,
        contactNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        gstNumber: _gstCtrl.text.trim().isEmpty ? null : _gstCtrl.text.trim(),
        address: _addrCtrl.text.trim().isEmpty ? null : _addrCtrl.text.trim(),
        paymentTerms: _termsCtrl.text.trim().isEmpty ? null : _termsCtrl.text.trim(),
        billingName: _billingNameCtrl.text.trim().isEmpty ? null : _billingNameCtrl.text.trim(),
      ));
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
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
            onChanged: onChanged,
            style: const TextStyle(fontSize: 13, color: bcNavy),
            decoration: const InputDecoration(
              hintText: 'Search suppliers…',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _field(String label, TextEditingController ctrl, {String? hint, TextInputType keyboardType = TextInputType.text}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl, keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: bcNavy),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          filled: true, fillColor: bcSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bcAmber, width: 2)),
        ),
      ),
    ]);
