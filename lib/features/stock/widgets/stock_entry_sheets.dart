import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/stock_entry_model.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/repositories/stock_entry_repository.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';

// ─── Shared Sheet Widgets ─────────────────────────────────────────────────────

class StockSheetWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  const StockSheetWrapper({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 20),
          child,
        ],
      )),
    );
  }
}

class StockSheetLabel extends StatelessWidget {
  final String label;
  const StockSheetLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) =>
      Text(label, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13));
}

Widget stockSheetField(String label, TextEditingController ctrl, {
  String? hint,
  TextInputType keyboardType = TextInputType.text,
  ValueChanged<String>? onChanged,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
    const SizedBox(height: 6),
    TextFormField(
      controller: ctrl, keyboardType: keyboardType, onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: bcNavy),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true, fillColor: bcSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bcAmber, width: 2)),
      ),
    ),
  ],
);

Widget stockDateSheetField(String label, BuildContext context, DateTime? value, ValueChanged<DateTime?> onChanged) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now().add(const Duration(days: 7)),
            firstDate: DateTime.now().subtract(const Duration(days: 30)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          onChanged(d);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: bcSurface, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded, color: Color(0xFF94A3B8), size: 14),
            const SizedBox(width: 8),
            Text(
              value != null ? DateFormat('d MMM yyyy').format(value) : 'Pick date',
              style: TextStyle(color: value != null ? bcNavy : const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      ),
    ]);

class StockSubmitButton extends StatelessWidget {
  final String label;
  final bool submitting;
  final VoidCallback onTap;
  const StockSubmitButton({super.key, required this.label, required this.submitting, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: submitting ? null : onTap,
      style: ElevatedButton.styleFrom(backgroundColor: bcNavy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      child: submitting
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
    ),
  );
}

class StockMaterialSelector extends StatelessWidget {
  final List<ConstructionMaterial> materials;
  final ConstructionMaterial? selected;
  final ValueChanged<ConstructionMaterial?> onSelected;
  const StockMaterialSelector({super.key, required this.materials, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(color: bcSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ConstructionMaterial?>(
          value: selected,
          isExpanded: true,
          isDense: true,
          hint: const Text('Select material (optional)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          style: const TextStyle(color: bcNavy, fontSize: 13, fontWeight: FontWeight.w600),
          items: [
            const DropdownMenuItem<ConstructionMaterial?>(value: null, child: Text('None / Custom', style: TextStyle(color: Color(0xFF94A3B8)))),
            ...materials.map((m) => DropdownMenuItem(value: m, child: Text(m.name, overflow: TextOverflow.ellipsis))),
          ],
          onChanged: onSelected,
        ),
      ),
    );
  }
}

class StockSupplierSelector extends StatelessWidget {
  final List<PartyModel> suppliers;
  final PartyModel? selected;
  final ValueChanged<PartyModel?> onSelected;
  final String? hint;
  const StockSupplierSelector({super.key, required this.suppliers, required this.selected, required this.onSelected, this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(color: bcSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PartyModel?>(
          value: selected,
          isExpanded: true,
          isDense: true,
          hint: Text(hint ?? 'Select supplier', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          style: const TextStyle(color: bcNavy, fontSize: 13, fontWeight: FontWeight.w600),
          items: [
            DropdownMenuItem<PartyModel?>(value: null, child: Text(hint ?? 'Select supplier', style: const TextStyle(color: Color(0xFF94A3B8)))),
            ...suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name, overflow: TextOverflow.ellipsis))),
          ],
          onChanged: onSelected,
        ),
      ),
    );
  }
}

// ─── Direct Entry Sheet ────────────────────────────────────────────────────────

class DirectEntrySheet extends StatefulWidget {
  final PartyModel? initialSupplier;
  final ConstructionMaterial? initialMaterial;
  const DirectEntrySheet({super.key, this.initialSupplier, this.initialMaterial});

  @override
  State<DirectEntrySheet> createState() => _DirectEntrySheetState();
}

class _DirectEntrySheetState extends State<DirectEntrySheet> {
  final _descCtrl  = TextEditingController();
  final _qtyCtrl   = TextEditingController();
  final _rateCtrl  = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _paidCtrl  = TextEditingController();

  ConstructionMaterial? _selectedMaterial;
  PartyModel?           _selectedSupplier;
  DateTime?             _dueDate;
  bool _submitting = false;

  bool _autoTotal = true; // when true, total = qty × rate

  @override
  void initState() {
    super.initState();
    _selectedSupplier = widget.initialSupplier;
    _selectedMaterial = widget.initialMaterial;
    if (_selectedMaterial != null) {
      _rateCtrl.text = _selectedMaterial!.pricePerUnit.toStringAsFixed(0);
      _descCtrl.text = _selectedMaterial!.name;
    }
    _qtyCtrl.addListener(_recalc);
    _rateCtrl.addListener(_recalc);
  }

  void _recalc() {
    if (!_autoTotal) return;
    final qty  = double.tryParse(_qtyCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    _totalCtrl.text = (qty * rate == 0) ? '' : (qty * rate).toStringAsFixed(0);
  }

  @override
  void dispose() {
    for (final c in [_descCtrl, _qtyCtrl, _rateCtrl, _totalCtrl, _paidCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invRepo   = context.watch<InventoryRepository>();
    final partyRepo = context.watch<PartyRepository>();

    return StockSheetWrapper(
      title: 'Direct Material Entry',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StockSheetLabel('Select Material'),
          const SizedBox(height: 6),
          StockMaterialSelector(
            materials: invRepo.materials,
            selected: _selectedMaterial,
            onSelected: (m) {
              setState(() {
                _selectedMaterial = m;
                if (m != null && _rateCtrl.text.isEmpty) {
                  _rateCtrl.text = m.pricePerUnit.toStringAsFixed(0);
                  _descCtrl.text = m.name;
                }
              });
            },
          ),
          const SizedBox(height: 12),

          stockSheetField('Description / Sub-type', _descCtrl, hint: 'e.g. OPC 53 Grade, 12mm TMT'),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: stockSheetField('Quantity', _qtyCtrl, hint: '100', keyboardType: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(child: stockSheetField('Unit Rate (₹)', _rateCtrl, hint: '450', keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),

          stockSheetField('Total Amount (₹)', _totalCtrl, hint: 'auto-calculated',
              keyboardType: TextInputType.number, onChanged: (_) => setState(() => _autoTotal = false)),
          const SizedBox(height: 12),

          const StockSheetLabel('Supplier *'),
          const SizedBox(height: 6),
          StockSupplierSelector(
            suppliers: partyRepo.suppliers,
            selected: _selectedSupplier,
            onSelected: (s) => setState(() => _selectedSupplier = s),
          ),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: stockSheetField('Amount Paid (₹)', _paidCtrl, hint: '0', keyboardType: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(child: stockDateSheetField('Due Date (optional)', context, _dueDate, (d) => setState(() => _dueDate = d))),
          ]),
          const SizedBox(height: 24),

          StockSubmitButton(label: 'Save Entry', submitting: _submitting, onTap: () => _submit(context)),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final desc = _descCtrl.text.trim();
    final total = double.tryParse(_totalCtrl.text) ?? 0;
    final qty   = double.tryParse(_qtyCtrl.text) ?? 0;
    final rate  = double.tryParse(_rateCtrl.text) ?? 0;
    final paid  = double.tryParse(_paidCtrl.text) ?? 0;

    if (desc.isEmpty && _selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a material or enter a description')));
      return;
    }
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Total amount must be greater than zero')));
      return;
    }
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a supplier')));
      return;
    }

    setState(() => _submitting = true);

    final entry = StockEntryModel(
      id: const Uuid().v4(),
      siteId: context.read<SiteRepository>().selectedSiteId ?? '',
      supplierId: _selectedSupplier!.id,
      supplierName: _selectedSupplier!.name,
      materialId: _selectedMaterial?.id ?? '',
      materialName: _selectedMaterial?.name ?? desc,
      subType: _selectedMaterial?.subType ?? desc,
      unit: _selectedMaterial?.unitType ?? 'unit',
      quantity: qty,
      unitPrice: rate,
      totalAmount: total,
      paidAmount: paid,
      dueDate: _dueDate,
      entryDate: DateTime.now(),
      entryType: StockEntryType.directEntry,
      isInventoryItem: true,
    );

    final stockRepo = context.read<StockEntryRepository>();
    await stockRepo.addEntry(entry);
    if (!mounted) return;

    if (_selectedMaterial != null) {
      final invRepo = context.read<InventoryRepository>();
      final updated = _selectedMaterial!.copyWith(
        currentStock: _selectedMaterial!.currentStock + qty,
        purchasePrice: rate > 0 ? rate : null,
        updatedAt: DateTime.now(),
      );
      await invRepo.updateMaterial(updated);
      if (!mounted) return;
    }

    Navigator.pop(context);
  }
}

// ─── Supplier Bill Sheet ───────────────────────────────────────────────────────

class SupplierBillSheet extends StatefulWidget {
  final PartyModel? initialSupplier;
  const SupplierBillSheet({super.key, this.initialSupplier});

  @override
  State<SupplierBillSheet> createState() => _SupplierBillSheetState();
}

class _SupplierBillSheetState extends State<SupplierBillSheet> {
  PartyModel? _supplier;
  final List<_BillItem> _items = [];
  final _billNoCtrl = TextEditingController();
  final _paidCtrl   = TextEditingController();
  DateTime? _billDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _supplier = widget.initialSupplier;
    _billDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final partyRepo = context.watch<PartyRepository>();
    final total = _items.fold(0.0, (s, i) => s + i.total);
    final fmt   = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return StockSheetWrapper(
      title: 'Supplier Bill Entry',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StockSheetLabel('Supplier *'),
          const SizedBox(height: 6),
          StockSupplierSelector(
            suppliers: partyRepo.suppliers,
            selected: _supplier,
            onSelected: (s) => setState(() => _supplier = s),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: stockSheetField('Bill Number (optional)', _billNoCtrl, hint: 'INV-2024-001')),
            const SizedBox(width: 10),
            Expanded(child: stockDateSheetField('Bill Date', context, _billDate, (d) => setState(() => _billDate = d))),
          ]),
          const SizedBox(height: 16),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const StockSheetLabel('ITEMS'),
            GestureDetector(
              onTap: _addItem,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: bcAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, color: bcAmber, size: 15),
                  SizedBox(width: 4),
                  Text('Add Item', style: TextStyle(color: bcAmber, fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 8),

          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: bcSurface, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('No items yet. Tap "Add Item" above.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
            ),

          ..._items.asMap().entries.map((e) => _BillItemTile(
            item: e.value,
            onRemove: () => setState(() => _items.removeAt(e.key)),
          )),

          if (_items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bcNavy.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('BILL TOTAL', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                  Text(fmt.format(total), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          stockSheetField('Amount Paid (₹)', _paidCtrl, hint: '0', keyboardType: TextInputType.number),
          const SizedBox(height: 24),
          StockSubmitButton(label: 'Save Bill', submitting: _submitting, onTap: () => _submit(context)),
        ],
      ),
    );
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (_) => _AddBillItemDialog(
        materials: context.read<InventoryRepository>().materials,
        onAdd: (item) => setState(() => _items.add(item)),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (_supplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a supplier')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }

    setState(() => _submitting = true);
    final siteId   = context.read<SiteRepository>().selectedSiteId ?? '';
    final billId   = const Uuid().v4();
    final paid     = double.tryParse(_paidCtrl.text) ?? 0;
    final bDate    = _billDate ?? DateTime.now();

    final entries = _items.map((item) => StockEntryModel(
      id: const Uuid().v4(),
      siteId: siteId,
      supplierId: _supplier!.id,
      supplierName: _supplier!.name,
      billId: billId,
      materialId: item.materialId,
      materialName: item.name,
      subType: item.subtype,
      unit: item.unit,
      quantity: item.qty,
      unitPrice: item.rate,
      totalAmount: item.total,
      paidAmount: 0,
      entryDate: bDate,
      entryType: StockEntryType.supplierBill,
      isInventoryItem: true,
    )).toList();

    final bill = SupplierBill(
      id: billId,
      siteId: siteId,
      supplierId: _supplier!.id,
      supplierName: _supplier!.name,
      items: entries,
      paidAmount: paid,
      billDate: bDate,
      billNumber: _billNoCtrl.text.trim().isEmpty ? null : _billNoCtrl.text.trim(),
    );

    await context.read<StockEntryRepository>().addBill(bill);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() { _billNoCtrl.dispose(); _paidCtrl.dispose(); super.dispose(); }
}

class _BillItem {
  final String materialId;
  final String name;
  final String subtype;
  final String unit;
  final double qty;
  final double rate;
  double get total => qty * rate;
  const _BillItem({required this.materialId, required this.name, required this.subtype, required this.unit, required this.qty, required this.rate});
}

class _BillItemTile extends StatelessWidget {
  final _BillItem item;
  final VoidCallback onRemove;
  const _BillItemTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 12)),
            Text('${item.qty} ${item.unit} × ₹${item.rate.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          ])),
          Text(fmt.format(item.total), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 13)),
          const SizedBox(width: 8),
          GestureDetector(onTap: onRemove, child: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 18)),
        ],
      ),
    );
  }
}

class _AddBillItemDialog extends StatefulWidget {
  final List<ConstructionMaterial> materials;
  final ValueChanged<_BillItem> onAdd;
  const _AddBillItemDialog({required this.materials, required this.onAdd});

  @override
  State<_AddBillItemDialog> createState() => _AddBillItemDialogState();
}

class _AddBillItemDialogState extends State<_AddBillItemDialog> {
  ConstructionMaterial? _mat;
  final _nameCtrl = TextEditingController();
  final _qtyCtrl  = TextEditingController();
  final _rateCtrl = TextEditingController();

  @override
  void dispose() { _nameCtrl.dispose(); _qtyCtrl.dispose(); _rateCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bcNavy.withValues(alpha: 0.03),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bcAmber.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.add_shopping_cart_rounded, color: bcAmber, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('Add Bill Item', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
      ),
      content: SizedBox(
        width: 400, // Makes it feel less "small"
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StockSheetLabel('Select Material (if applies)'),
            const SizedBox(height: 8),
            StockMaterialSelector(materials: widget.materials, selected: _mat, onSelected: (m) {
              setState(() {
                _mat = m;
                if (m != null) {
                  _nameCtrl.text = m.name;
                  _rateCtrl.text = m.pricePerUnit.toStringAsFixed(0);
                }
              });
            }),
            const SizedBox(height: 20),
            stockSheetField('Name / Description *', _nameCtrl, hint: 'e.g. 12mm Steel Bars'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: stockSheetField('Quantity *', _qtyCtrl, hint: '0', keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: stockSheetField('Unit Rate (₹)', _rateCtrl, hint: '0', keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameCtrl.text.trim();
                  final qty  = double.tryParse(_qtyCtrl.text) ?? 0;
                  final rate = double.tryParse(_rateCtrl.text) ?? 0;
                  if (name.isEmpty || qty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name and valid quantity')));
                    return;
                  }
                  widget.onAdd(_BillItem(
                    materialId: _mat?.id ?? '',
                    name: name, subtype: _mat?.subType ?? '',
                    unit: _mat?.unitType ?? 'unit', qty: qty, rate: rate,
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bcNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Add to Bill', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Misc Expense Sheet ───────────────────────────────────────────────────────

class MiscExpenseSheet extends StatefulWidget {
  final PartyModel? initialSupplier;
  const MiscExpenseSheet({super.key, this.initialSupplier});

  @override
  State<MiscExpenseSheet> createState() => _MiscExpenseSheetState();
}

class _MiscExpenseSheetState extends State<MiscExpenseSheet> {
  final _nameCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  PartyModel? _supplier;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _supplier = widget.initialSupplier;
  }

  @override
  void dispose() { _nameCtrl.dispose(); _amountCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final partyRepo = context.watch<PartyRepository>();

    return StockSheetWrapper(
      title: 'Misc / Petty Expense',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFF8B5CF6), size: 16),
              SizedBox(width: 8),
              Expanded(child: Text('This records an expense without affecting material inventory.', style: TextStyle(color: Color(0xFF6D28D9), fontSize: 11))),
            ]),
          ),
          const SizedBox(height: 14),
          stockSheetField('Expense Description *', _nameCtrl, hint: 'e.g. Binding wire, petty cash, transport'),
          const SizedBox(height: 12),
          stockSheetField('Amount (₹) *', _amountCtrl, hint: '0', keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          const StockSheetLabel('Paid To (optional)'),
          const SizedBox(height: 6),
          StockSupplierSelector(
            suppliers: partyRepo.parties,
            selected: _supplier,
            onSelected: (s) => setState(() => _supplier = s),
            hint: 'Select party (optional)',
          ),
          const SizedBox(height: 24),
          StockSubmitButton(label: 'Record Expense', submitting: _submitting, onTap: () => _submit(context)),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final name   = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (name.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in description and amount')));
      return;
    }
    setState(() => _submitting = true);
    final entry = StockEntryModel(
      id: const Uuid().v4(),
      siteId: context.read<SiteRepository>().selectedSiteId ?? '',
      supplierId: _supplier?.id ?? '',
      supplierName: _supplier?.name ?? 'Cash',
      materialId: '',
      materialName: name,
      subType: '',
      unit: '',
      quantity: 1,
      unitPrice: amount,
      totalAmount: amount,
      paidAmount: amount, // misc expenses are assumed fully paid
      entryDate: DateTime.now(),
      entryType: StockEntryType.miscExpense,
      isInventoryItem: false,
    );
    await context.read<StockEntryRepository>().addEntry(entry);
    if (!mounted) return;
    Navigator.pop(context);
  }
}
