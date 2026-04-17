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

// ─── Unit Helpers ─────────────────────────────────────────────────────────────

const _kPurchaseUnits = ['kg', 'ltr', 'bag', 'box', 'pcs', 'nos', 'mtr', 'ton'];

String _unitLabel(String unit) {
  switch (unit) {
    case 'kg':  return 'KG';
    case 'ltr': return 'LTR';
    case 'bag': return 'BAG';
    case 'box': return 'BOX';
    case 'pcs': return 'PCS';
    case 'nos': return 'NOS';
    case 'mtr': return 'MTR';
    case 'ton': return 'TON';
    default:    return unit.toUpperCase();
  }
}

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
  bool optional = false,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(children: [
      Text(label, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
      if (optional) ...[
        const SizedBox(width: 6),
        const Text('optional', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
      ],
    ]),
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
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
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

// ─── Unit Selector Widget ─────────────────────────────────────────────────────

class _UnitSelector extends StatelessWidget {
  final String selectedUnit;
  final ValueChanged<String> onChanged;
  const _UnitSelector({required this.selectedUnit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Show compact unit chips
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Unit', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _kPurchaseUnits.map((u) {
            final isSelected = selectedUnit == u;
            return GestureDetector(
              onTap: () => onChanged(u),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? bcNavy : bcSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? bcNavy : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  _unitLabel(u),
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Bag Weight Helper ────────────────────────────────────────────────────────

Widget _bagWeightField(TextEditingController ctrl) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SizedBox(height: 12),
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bcAmber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.scale_rounded, color: bcAmber, size: 14),
            SizedBox(width: 6),
            Text('BAG WEIGHT', style: TextStyle(color: bcAmber, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ]),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13, color: bcNavy),
            decoration: InputDecoration(
              hintText: 'e.g. 50',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              suffixText: 'kg / bag',
              suffixStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: bcAmber, width: 2)),
            ),
          ),
        ],
      ),
    ),
  ],
);

// ─── Supplier Payment Sheet ───────────────────────────────────────────────────

class SupplierPaymentSheet extends StatefulWidget {
  final PartyModel supplier;
  final double pendingAmount;
  const SupplierPaymentSheet({super.key, required this.supplier, required this.pendingAmount});

  @override
  State<SupplierPaymentSheet> createState() => _SupplierPaymentSheetState();
}

class _SupplierPaymentSheetState extends State<SupplierPaymentSheet> {
  final _amountCtrl  = TextEditingController();
  final _remarksCtrl = TextEditingController();
  String _paymentMode = 'Cash';
  DateTime _paymentDate = DateTime.now();
  bool _submitting = false;

  static const _paymentModes = ['Cash', 'UPI', 'Bank Transfer', 'Cheque'];

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.pendingAmount.toStringAsFixed(0);
  }

  @override
  void dispose() { _amountCtrl.dispose(); _remarksCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return StockSheetWrapper(
      title: 'Pay Supplier',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Supplier info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bcNavy.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bcNavy.withValues(alpha: 0.08)),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: bcNavy, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(
                  widget.supplier.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.supplier.name, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 14)),
                Text('Due: ${fmt.format(widget.pendingAmount)}',
                    style: const TextStyle(color: bcDanger, fontWeight: FontWeight.w700, fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          // Amount
          stockSheetField('Payment Amount (₹)', _amountCtrl, hint: '0', keyboardType: TextInputType.number),
          const SizedBox(height: 14),

          // Payment Date
          stockDateSheetField('Payment Date', context, _paymentDate, (d) {
            if (d != null) setState(() => _paymentDate = d);
          }),
          const SizedBox(height: 14),

          // Payment mode
          const Text('Payment Mode', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _paymentModes.map((m) {
              final isSelected = _paymentMode == m;
              return GestureDetector(
                onTap: () => setState(() => _paymentMode = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? bcSuccess.withValues(alpha: 0.1) : bcSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? bcSuccess : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
                  ),
                  child: Text(
                    m,
                    style: TextStyle(
                      color: isSelected ? bcSuccess : const Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Remarks
          stockSheetField('Remarks', _remarksCtrl, hint: 'e.g. Partial payment, festival advance', optional: true),
          const SizedBox(height: 24),

          StockSubmitButton(label: 'Record Payment', submitting: _submitting, onTap: () => _submit(context)),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid payment amount')));
      return;
    }
    setState(() => _submitting = true);
    final stockRepo = context.read<StockEntryRepository>();
    await stockRepo.recordPaymentForSupplier(
      supplierId: widget.supplier.id,
      amount: amount,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment of ₹${amount.toStringAsFixed(0)} recorded'),
      backgroundColor: bcSuccess,
    ));
  }
}

// ─── Direct Entry Sheet ────────────────────────────────────────────────────────
// Mode A — Direct Entry  : user fills everything manually
// Mode B — From Inventory: select material → auto-fill name/unit/rate (read-only)
//                          only qty is entered; read-only fields have optional edit
class DirectEntrySheet extends StatefulWidget {
  final PartyModel? initialSupplier;
  final ConstructionMaterial? initialMaterial;
  const DirectEntrySheet({super.key, this.initialSupplier, this.initialMaterial});

  @override
  State<DirectEntrySheet> createState() => _DirectEntrySheetState();
}

class _DirectEntrySheetState extends State<DirectEntrySheet> {
  final _descCtrl      = TextEditingController();
  final _subtypeCtrl   = TextEditingController();
  final _qtyCtrl       = TextEditingController();
  final _rateCtrl      = TextEditingController();
  final _totalCtrl     = TextEditingController();
  final _paidCtrl      = TextEditingController();
  final _bagWeightCtrl = TextEditingController();

  ConstructionMaterial? _selectedMaterial;
  PartyModel?           _selectedSupplier;
  DateTime?             _dueDate;
  String                _unit    = 'pcs';
  bool                  _fromInventory = false;
  bool                  _submitting    = false;
  bool                  _autoTotal     = true;
  bool                  _unlockName    = false;
  bool                  _unlockRate    = false;

  @override
  void initState() {
    super.initState();
    _selectedSupplier = widget.initialSupplier;
    _selectedMaterial = widget.initialMaterial;
    if (_selectedMaterial != null) {
      _fromInventory = true;
      _fillFromMaterial(_selectedMaterial!);
    }
    _qtyCtrl.addListener(_recalc);
    _rateCtrl.addListener(_recalc);
  }

  void _fillFromMaterial(ConstructionMaterial m) {
    _descCtrl.text    = m.name;
    _subtypeCtrl.text = m.subType;
    _rateCtrl.text    = m.pricePerUnit > 0 ? m.pricePerUnit.toStringAsFixed(0) : '';
    _unit             = m.unitType.isNotEmpty ? m.unitType : 'pcs';
    _unlockName       = false;
    _unlockRate       = false;
    _autoTotal        = true;
    _recalc();
  }

  void _recalc() {
    if (!_autoTotal) return;
    final qty  = double.tryParse(_qtyCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    _totalCtrl.text = (qty > 0 && rate > 0) ? (qty * rate).toStringAsFixed(0) : '';
  }

  @override
  void dispose() {
    for (final c in [_descCtrl, _subtypeCtrl, _qtyCtrl, _rateCtrl, _totalCtrl, _paidCtrl, _bagWeightCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invRepo   = context.watch<InventoryRepository>();
    final partyRepo = context.watch<PartyRepository>();

    return StockSheetWrapper(
      title: 'Add Purchase Entry',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Mode toggle ────────────────────────────────────────────────
          if (widget.initialMaterial == null) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                _ModeTab(
                  label: 'Direct Entry',
                  icon: Icons.edit_note_rounded,
                  isActive: !_fromInventory,
                  onTap: () => setState(() {
                    _fromInventory   = false;
                    _selectedMaterial = null;
                    _descCtrl.clear();
                    _subtypeCtrl.clear();
                    _rateCtrl.clear();
                    _totalCtrl.clear();
                    _unit = 'pcs';
                  }),
                ),
                _ModeTab(
                  label: 'From Inventory',
                  icon: Icons.inventory_2_rounded,
                  isActive: _fromInventory,
                  onTap: () => setState(() => _fromInventory = true),
                ),
              ]),
            ),
            const SizedBox(height: 20),
          ],

          // ══════════════════════════════════════════════════════════
          // FROM INVENTORY MODE
          // ══════════════════════════════════════════════════════════
          if (_fromInventory) ...[
            if (widget.initialMaterial == null) ...[
              const StockSheetLabel('Select Material *'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: bcSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMaterial != null ? bcSuccess : const Color(0xFFE2E8F0),
                    width: _selectedMaterial != null ? 2 : 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ConstructionMaterial?>(
                    value: _selectedMaterial,
                    isExpanded: true,
                    isDense: true,
                    hint: const Text('Choose from catalog…', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    style: const TextStyle(color: bcNavy, fontSize: 13, fontWeight: FontWeight.w700),
                    items: invRepo.materials.map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(
                        '${m.name}${m.variant.isNotEmpty ? " · ${m.variant}" : ""}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    onChanged: (m) => setState(() { _selectedMaterial = m; if (m != null) _fillFromMaterial(m); }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              _LockedMaterialBanner(material: widget.initialMaterial!),
              const SizedBox(height: 16),
            ],

            if (_selectedMaterial != null) ...[
              _RecentRatesReference(
                materialId: _selectedMaterial!.id,
                onRateSelected: (rate) => setState(() {
                  _rateCtrl.text = rate.toStringAsFixed(0);
                  _unlockRate = true;
                  _autoTotal  = true;
                  _recalc();
                }),
              ),
              if (_selectedMaterial!.id.isNotEmpty) const SizedBox(height: 16),

              // Material name (auto-filled, read-only with optional edit)
              _ReadOnlyAutoField(
                label: 'Material Name',
                value: _selectedMaterial!.name,
                isUnlocked: _unlockName,
                controller: _descCtrl,
                onUnlock: () => setState(() => _unlockName = true),
              ),
              const SizedBox(height: 12),

              // Sub-type (always editable)
              stockSheetField('Grade / Sub-type', _subtypeCtrl,
                  hint: 'e.g. OPC 53, 12mm, Fe500', optional: true),
              const SizedBox(height: 12),

              // Unit — read-only from catalog
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Unit', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.lock_rounded, size: 12, color: Color(0xFF0EA5E9)),
                    const SizedBox(width: 8),
                    Text(_unit.toUpperCase(), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13)),
                    const Spacer(),
                    const Text('from catalog', style: TextStyle(color: Color(0xFF0EA5E9), fontSize: 10, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),

              // ── Qty — the primary input, large and prominent ───────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.edit_rounded, size: 14, color: bcSuccess),
                    SizedBox(width: 6),
                    Text('ENTER QUANTITY', style: TextStyle(color: bcSuccess, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                  ]),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    autofocus: _selectedMaterial != null,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: bcNavy),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      suffixText: _unit.toUpperCase(),
                      suffixStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // Rate (read-only unless unlocked)
              _ReadOnlyAutoField(
                label: 'Rate / ${_unitLabel(_unit)} (₹)',
                value: _rateCtrl.text.isNotEmpty ? '₹${_rateCtrl.text}' : 'Not set — tap Edit to add',
                isUnlocked: _unlockRate,
                controller: _rateCtrl,
                keyboardType: TextInputType.number,
                onUnlock: () => setState(() { _unlockRate = true; _autoTotal = true; }),
              ),
              if (_unit == 'bag') ...[_bagWeightField(_bagWeightCtrl)],
              const SizedBox(height: 12),

              // Auto-calculated total OR manual entry
              ListenableBuilder(
                listenable: _totalCtrl,
                builder: (_, __) => _totalCtrl.text.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: bcNavy.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        const Text('TOTAL AMOUNT', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5)),
                        const Spacer(),
                        Text('₹${_totalCtrl.text}', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 20)),
                      ]),
                    )
                  : stockSheetField('Total Amount (₹) *', _totalCtrl,
                      hint: 'Enter qty × rate or type directly',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() => _autoTotal = false)),
              ),
            ],
          ],

          // ══════════════════════════════════════════════════════════
          // DIRECT ENTRY MODE  — user fills everything
          // ══════════════════════════════════════════════════════════
          if (!_fromInventory) ...[
            stockSheetField('Item Name / Description *', _descCtrl,
                hint: 'e.g. Nails, Binding wire, GI wire'),
            const SizedBox(height: 14),
            _UnitSelector(selectedUnit: _unit, onChanged: (u) => setState(() => _unit = u)),
            if (_unit == 'bag') _bagWeightField(_bagWeightCtrl),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: stockSheetField(
                'Qty (${_unitLabel(_unit)})', _qtyCtrl,
                hint: '0', keyboardType: TextInputType.number, optional: true)),
              const SizedBox(width: 10),
              Expanded(child: stockSheetField(
                'Rate / ${_unitLabel(_unit)} (₹)', _rateCtrl,
                hint: '0', keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 12),
            stockSheetField('Total Amount (₹) *', _totalCtrl,
                hint: 'auto-calculated or enter directly',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() => _autoTotal = false)),
          ],

          const SizedBox(height: 16),

          // ── Supplier ─────────────────────────────────────────────
          const StockSheetLabel('Supplier *'),
          const SizedBox(height: 6),
          StockSupplierSelector(
            suppliers: partyRepo.suppliers,
            selected: _selectedSupplier,
            onSelected: (s) => setState(() => _selectedSupplier = s),
          ),
          const SizedBox(height: 12),

          // ── Paid & Due ────────────────────────────────────────────
          Row(children: [
            Expanded(child: stockSheetField('Paid (₹)', _paidCtrl,
                hint: '0', keyboardType: TextInputType.number, optional: true)),
            const SizedBox(width: 10),
            Expanded(child: stockDateSheetField('Due Date', context, _dueDate,
                (d) => setState(() => _dueDate = d))),
          ]),
          const SizedBox(height: 24),
          StockSubmitButton(label: 'Save Entry', submitting: _submitting, onTap: () => _submit(context)),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final desc  = _fromInventory ? (_selectedMaterial?.name ?? _descCtrl.text.trim()) : _descCtrl.text.trim();
    final qty   = double.tryParse(_qtyCtrl.text) ?? 0;
    final rate  = double.tryParse(_rateCtrl.text) ?? 0;
    final total = double.tryParse(_totalCtrl.text) ?? (qty > 0 && rate > 0 ? qty * rate : 0);
    final paid  = double.tryParse(_paidCtrl.text) ?? 0;
    final bagKg = double.tryParse(_bagWeightCtrl.text);

    if (_fromInventory && _selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a material from inventory')));
      return;
    }
    if (_fromInventory && qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quantity is required — please enter how much was received')));
      return;
    }
    if (!_fromInventory && desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter item name / description')));
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
    final effectiveQty = (qty > 0 ? qty : (rate > 0 && total > 0 ? total / rate : 1.0)).toDouble();

    final entry = StockEntryModel(
      id: const Uuid().v4(),
      siteId: context.read<SiteRepository>().selectedSiteId ?? '',
      supplierId: _selectedSupplier!.id,
      supplierName: _selectedSupplier!.name,
      materialId: _selectedMaterial?.id ?? '',
      materialName: desc,
      subType: _fromInventory
          ? (_subtypeCtrl.text.trim().isNotEmpty ? _subtypeCtrl.text.trim() : (_selectedMaterial?.subType ?? ''))
          : '',
      unit: _unit,
      quantity: effectiveQty,
      unitPrice: rate,
      totalAmount: total,
      paidAmount: paid,
      bagWeightKg: _unit == 'bag' ? bagKg : null,
      dueDate: _dueDate,
      entryDate: DateTime.now(),
      entryType: StockEntryType.directEntry,
      isInventoryItem: _fromInventory,
    );

    final stockRepo = context.read<StockEntryRepository>();
    await stockRepo.addEntry(entry);
    if (!mounted) return;

    if (_fromInventory && _selectedMaterial != null && effectiveQty > 0) {
      final invRepo = context.read<InventoryRepository>();
      await invRepo.updateMaterial(_selectedMaterial!.copyWith(
        currentStock: _selectedMaterial!.currentStock + effectiveQty,
        purchasePrice: rate > 0 ? rate : null,
        updatedAt: DateTime.now(),
      ));
      if (!mounted) return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Entry saved — ₹${total.toStringAsFixed(0)}'),
      backgroundColor: bcSuccess,
    ));
  }
}

// ── Read-only field with optional unlock ──────────────────────────────────────

class _ReadOnlyAutoField extends StatelessWidget {
  final String label;
  final String value;
  final bool isUnlocked;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final VoidCallback onUnlock;

  const _ReadOnlyAutoField({
    required this.label,
    required this.value,
    required this.isUnlocked,
    required this.controller,
    required this.onUnlock,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    if (isUnlocked) {
      return stockSheetField(label, controller, hint: value, keyboardType: keyboardType);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBAE6FD)),
        ),
        child: Row(children: [
          Expanded(child: Text(value, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13))),
          GestureDetector(
            onTap: onUnlock,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(6)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.edit_rounded, size: 11, color: Color(0xFF0284C7)),
                SizedBox(width: 4),
                Text('Edit', style: TextStyle(color: Color(0xFF0284C7), fontSize: 10, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
      ),
    ]);
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
            Expanded(child: stockSheetField('Bill Number', _billNoCtrl, hint: 'INV-001', optional: true)),
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
          stockSheetField('Amount Paid (₹)', _paidCtrl, hint: '0', keyboardType: TextInputType.number, optional: true),
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
    final siteId = context.read<SiteRepository>().selectedSiteId ?? '';
    final billId = const Uuid().v4();
    final paid   = double.tryParse(_paidCtrl.text) ?? 0;
    final bDate  = _billDate ?? DateTime.now();

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
      bagWeightKg: item.bagWeightKg,
      entryDate: bDate,
      entryType: StockEntryType.supplierBill,
      isInventoryItem: item.isInventoryItem,
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Bill saved successfully'),
      backgroundColor: bcSuccess,
    ));
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
  final double? bagWeightKg;
  final bool isInventoryItem;
  double get total => qty > 0 ? qty * rate : rate; // if qty=0 treat rate as total amount
  const _BillItem({
    required this.materialId,
    required this.name,
    required this.subtype,
    required this.unit,
    required this.qty,
    required this.rate,
    this.bagWeightKg,
    this.isInventoryItem = true,
  });
}

class _BillItemTile extends StatelessWidget {
  final _BillItem item;
  final VoidCallback onRemove;
  const _BillItemTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final directPurchase = !item.isInventoryItem;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: directPurchase ? const Color(0xFFF5F3FF) : const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: directPurchase ? const Color(0xFFDDD6FE) : const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: directPurchase ? const Color(0xFF8B5CF6).withValues(alpha: 0.1) : bcNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              directPurchase ? Icons.shopping_cart_rounded : Icons.inventory_2_rounded,
              size: 14,
              color: directPurchase ? const Color(0xFF8B5CF6) : bcNavy,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 12)),
            Text(
              item.qty > 0
                  ? '${item.qty} ${item.unit} × ₹${item.rate.toStringAsFixed(0)}'
                  : '₹${item.rate.toStringAsFixed(0)} (lump sum)',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
            if (item.unit == 'bag' && item.bagWeightKg != null)
              Text('${item.bagWeightKg} kg/bag', style: const TextStyle(color: bcAmber, fontSize: 10, fontWeight: FontWeight.w600)),
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
  bool   _fromInventory = false;
  String _unit = 'pcs';

  final _nameCtrl     = TextEditingController();
  final _qtyCtrl      = TextEditingController();
  final _rateCtrl     = TextEditingController();
  final _totalCtrl    = TextEditingController();
  final _bagWeightCtrl = TextEditingController();

  bool _autoTotal = true;

  @override
  void initState() {
    super.initState();
    _qtyCtrl.addListener(_recalc);
    _rateCtrl.addListener(_recalc);
  }

  void _recalc() {
    if (!_autoTotal) return;
    final qty  = double.tryParse(_qtyCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    if (qty > 0 && rate > 0) {
      _totalCtrl.text = (qty * rate).toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _qtyCtrl, _rateCtrl, _totalCtrl, _bagWeightCtrl]) c.dispose();
    super.dispose();
  }

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
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Mode toggle
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  _ModeTab(
                    label: 'Direct Purchase',
                    icon: Icons.shopping_cart_rounded,
                    isActive: !_fromInventory,
                    onTap: () => setState(() { _fromInventory = false; _mat = null; }),
                  ),
                  _ModeTab(
                    label: 'From Inventory',
                    icon: Icons.inventory_2_rounded,
                    isActive: _fromInventory,
                    onTap: () => setState(() => _fromInventory = true),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Inventory selector
              if (_fromInventory) ...[
                const StockSheetLabel('Select Material'),
                const SizedBox(height: 8),
                StockMaterialSelector(materials: widget.materials, selected: _mat, onSelected: (m) {
                  setState(() {
                    _mat = m;
                    if (m != null) {
                      _nameCtrl.text = m.name;
                      _rateCtrl.text = m.pricePerUnit.toStringAsFixed(0);
                      _unit = m.unitType;
                    }
                  });
                }),
                const SizedBox(height: 14),
              ],

              // Name
              stockSheetField(
                _fromInventory ? 'Sub-type / Notes' : 'Item Name *',
                _nameCtrl,
                hint: _fromInventory ? 'OPC 53, 12mm TMT' : 'e.g. Nails, PVC elbow 1"',
              ),
              const SizedBox(height: 14),

              // Unit selector
              _UnitSelector(selectedUnit: _unit, onChanged: (u) => setState(() => _unit = u)),

              // Bag weight
              if (_unit == 'bag') _bagWeightField(_bagWeightCtrl),
              const SizedBox(height: 14),

              // Qty & Rate
              Row(children: [
                Expanded(child: stockSheetField(
                  'Qty (${_unitLabel(_unit)})',
                  _qtyCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  optional: true,
                )),
                const SizedBox(width: 12),
                Expanded(child: stockSheetField(
                  'Rate (₹)',
                  _rateCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                )),
              ]),
              const SizedBox(height: 14),

              // Total override
              stockSheetField(
                'Total Amount (₹)',
                _totalCtrl,
                hint: 'auto or enter directly',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() => _autoTotal = false),
                optional: true,
              ),
            ],
          ),
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
                  final name  = _nameCtrl.text.trim();
                  final qty   = double.tryParse(_qtyCtrl.text) ?? 0;
                  final rate  = double.tryParse(_rateCtrl.text) ?? 0;
                  final total = double.tryParse(_totalCtrl.text) ?? (qty > 0 && rate > 0 ? qty * rate : 0);
                  final bagKg = double.tryParse(_bagWeightCtrl.text);

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter item name')));
                    return;
                  }
                  if (total <= 0 && rate <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter rate or total amount')));
                    return;
                  }

                  final effectiveTotal = total > 0 ? total : (qty > 0 ? qty * rate : rate);
                  final effectiveRate  = rate > 0 ? rate : (qty > 0 && effectiveTotal > 0 ? effectiveTotal / qty : effectiveTotal);

                  widget.onAdd(_BillItem(
                    materialId: _mat?.id ?? '',
                    name: name,
                    subtype: _mat?.subType ?? '',
                    unit: _unit,
                    qty: qty,
                    rate: effectiveRate,
                    bagWeightKg: _unit == 'bag' ? bagKg : null,
                    isInventoryItem: _fromInventory,
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
      paidAmount: amount,
      entryDate: DateTime.now(),
      entryType: StockEntryType.miscExpense,
      isInventoryItem: false,
    );
    await context.read<StockEntryRepository>().addEntry(entry);
    if (!mounted) return;
    Navigator.pop(context);
  }
}

// ─── Recent Rates Reference ────────────────────────────────────────────────────

class _RecentRatesReference extends StatelessWidget {
  final String? materialId;
  final ValueChanged<double> onRateSelected;
  const _RecentRatesReference({this.materialId, required this.onRateSelected});

  @override
  Widget build(BuildContext context) {
    if (materialId == null || materialId!.isEmpty) return const SizedBox.shrink();

    final stockRepo = context.watch<StockEntryRepository>();
    final entries = stockRepo.getEntriesForMaterial(materialId!)
        .where((e) => e.entryType != StockEntryType.miscExpense)
        .take(3)
        .toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECENT RATES (TAP TO USE)',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final e = entries[index];
              return InkWell(
                onTap: () => onRateSelected(e.unitPrice),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: bcAmber.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: bcAmber.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₹${e.unitPrice.toStringAsFixed(0)}',
                          style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 13)),
                      Text(
                        '${DateFormat('d MMM').format(e.entryDate)} • ${e.supplierName}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Reusable Helper Widgets ──────────────────────────────────────────────────

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _ModeTab({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isActive ? bcNavy : const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Flexible(child: Text(
                label,
                style: TextStyle(
                  color: isActive ? bcNavy : const Color(0xFF94A3B8),
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedMaterialBanner extends StatelessWidget {
  final ConstructionMaterial material;
  const _LockedMaterialBanner({required this.material});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bcNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bcNavy.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_rounded, size: 16, color: bcNavy),
          const SizedBox(width: 10),
          Text(
            material.name,
            style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const Spacer(),
          const Text('LOCKED', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
