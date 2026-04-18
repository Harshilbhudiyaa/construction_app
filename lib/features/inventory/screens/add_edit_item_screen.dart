import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/features/inventory/widgets/unit_picker_sheet.dart';

class AddEditItemScreen extends StatefulWidget {
  final String? materialId;
  const AddEditItemScreen({super.key, this.materialId});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl         = TextEditingController();
  final _brandCtrl        = TextEditingController();
  final _hsnCtrl          = TextEditingController();
  final _subTypeInputCtrl = TextEditingController();

  final List<_VariantEntry> _variants = [];
  final List<String> _subTypes = [];

  String _unit = 'pcs';
  double _taxPercent = 18.0;
  bool _includeTax = false;
  bool _isLoading = false;
  bool _showSubTypeInput = false;

  @override
  void initState() {
    super.initState();
    if (widget.materialId != null) {
      _loadExisting();
    } else {
      _variants.add(_VariantEntry());
    }
  }

  void _loadExisting() {
    final repo = context.read<InventoryRepository>();
    final m = repo.materials.firstWhere((e) => e.id == widget.materialId);
    _nameCtrl.text  = m.name;
    _brandCtrl.text = m.brand ?? '';
    _hsnCtrl.text   = m.hsnCode ?? '';
    _unit           = m.unitType;
    _taxPercent     = m.taxPercentage;
    _includeTax     = m.taxPercentage > 0;
    if (m.subType.isNotEmpty) {
      _subTypes.addAll(m.subType.split(' / ').map((s) => s.trim()).where((s) => s.isNotEmpty));
    }
    _variants.add(_VariantEntry(
      variantName: m.variant,
      stock: m.currentStock,
      rate: m.purchasePrice,
      limit: m.minimumStockLimit,
    ));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _hsnCtrl.dispose();
    _subTypeInputCtrl.dispose();
    for (var v in _variants) { v.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invRepo = context.watch<InventoryRepository>();
    final brands  = invRepo.materials.map((m) => m.brand ?? '').where((b) => b.isNotEmpty).toSet().toList();
    final isEdit  = widget.materialId != null;

    return Scaffold(
      backgroundColor: bcSurface,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Material' : 'New Material',
          style: const TextStyle(fontWeight: FontWeight.w900, color: bcNavy, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: bcNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          physics: const BouncingScrollPhysics(),
          children: [

            // ── SECTION: Identity ──────────────────────────────────────────
            _groupLabel('Material Identity', Icons.inventory_2_outlined),
            const SizedBox(height: 12),
            _buildLabeledField(
              label: 'Name *',
              child: TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                style: _inputTextStyle,
                decoration: _dec('e.g. TMT Steel Rod, OPC Cement'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
            ),
            const SizedBox(height: 12),
            _buildLabeledField(
              label: 'Brand',
              child: RawAutocomplete<String>(
                textEditingController: _brandCtrl,
                focusNode: FocusNode(),
                optionsBuilder: (v) => v.text.isEmpty
                    ? const Iterable<String>.empty()
                    : brands.where((b) => b.toLowerCase().contains(v.text.toLowerCase())),
                fieldViewBuilder: (_, ctrl, node, onSubmitted) => TextFormField(
                  controller: ctrl,
                  focusNode: node,
                  style: _inputTextStyle,
                  decoration: _dec('e.g. Ultratech, JSW'),
                ),
                optionsViewBuilder: (_, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(14),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260, maxHeight: 200),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: options.map((o) => ListTile(
                          dense: true,
                          title: Text(o, style: const TextStyle(fontWeight: FontWeight.w700, color: bcNavy, fontSize: 13)),
                          onTap: () => onSelected(o),
                        )).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── SECTION: Sub-types ─────────────────────────────────────────
            const SizedBox(height: 24),
            Row(
              children: [
                _groupLabel('Grade / Sub-type', Icons.label_outline_rounded),
                const Spacer(),
                if (!_showSubTypeInput)
                  GestureDetector(
                    onTap: () => setState(() => _showSubTypeInput = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: bcAmber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.add_rounded, color: bcAmber, size: 14),
                        SizedBox(width: 3),
                        Text('ADD', style: TextStyle(color: bcAmber, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                      ]),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSubTypeSection(),

            // ── SECTION: Unit ──────────────────────────────────────────────
            const SizedBox(height: 24),
            _groupLabel('Measurement Unit', Icons.scale_rounded),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final res = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => UnitPickerSheet(initialUnit: _unit),
                );
                if (res != null) setState(() => _unit = res);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.scale_rounded, color: bcAmber, size: 18),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Unit of Measurement',
                          style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                    Text(_unit.toUpperCase(),
                        style: const TextStyle(color: bcAmber, fontWeight: FontWeight.w900, fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
                  ],
                ),
              ),
            ),

            // ── SECTION: Taxation ──────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded, color: bcSuccess, size: 18),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Include GST',
                            style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                      Switch.adaptive(
                        value: _includeTax,
                        onChanged: (v) => setState(() => _includeTax = v),
                        activeTrackColor: bcSuccess,
                      ),
                    ],
                  ),
                  if (_includeTax) ...[
                    const Divider(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLabeledField(
                            label: 'GST %',
                            child: TextFormField(
                              initialValue: _taxPercent.toStringAsFixed(0),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _taxPercent = double.tryParse(v) ?? 18,
                              style: _inputTextStyle,
                              decoration: _dec('18'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildLabeledField(
                            label: 'HSN Code',
                            child: TextFormField(
                              controller: _hsnCtrl,
                              style: _inputTextStyle,
                              decoration: _dec('e.g. 7214'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── SECTION: Variants ──────────────────────────────────────────
            const SizedBox(height: 24),
            Row(
              children: [
                _groupLabel('Stock & Pricing', Icons.layers_outlined),
                const Spacer(),
                if (!isEdit)
                  GestureDetector(
                    onTap: () => setState(() => _variants.add(_VariantEntry())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: bcAmber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.add_rounded, color: bcAmber, size: 14),
                        SizedBox(width: 3),
                        Text('ADD VARIANT', style: TextStyle(color: bcAmber, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                      ]),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ..._variants.asMap().entries.map((e) => _buildVariantCard(e.key, e.value, isEdit)),

            // ── Submit ─────────────────────────────────────────────────────
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bcNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        isEdit ? 'Save Changes' : 'Create Material',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.3),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  static Widget _groupLabel(String label, IconData icon) => Row(
    children: [
      Icon(icon, size: 14, color: bcAmber),
      const SizedBox(width: 6),
      Text(label,
          style: const TextStyle(
            color: bcNavy,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 0.4,
          )),
    ],
  );

  // ── Labeled field wrapper ──────────────────────────────────────────────────

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.3,
              )),
        ),
        child,
      ],
    );
  }

  // ── Sub-type chips section ─────────────────────────────────────────────────

  Widget _buildSubTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_subTypes.isEmpty && !_showSubTypeInput)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
            ),
            child: const Row(
              children: [
                Icon(Icons.label_outline_rounded, color: Color(0xFFCBD5E1), size: 16),
                SizedBox(width: 10),
                Text('Optional — e.g. OPC 53, Fe500, Grade A',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
              ],
            ),
          ),
        if (_subTypes.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _subTypes.asMap().entries.map((e) => Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
              decoration: BoxDecoration(
                color: bcNavy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: bcNavy.withValues(alpha: 0.1)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(e.value, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _subTypes.removeAt(e.key)),
                  child: const Icon(Icons.close_rounded, size: 14, color: bcTextSecondary),
                ),
              ]),
            )).toList(),
          ),
        if (_showSubTypeInput) ...[
          if (_subTypes.isNotEmpty) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _subTypeInputCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: _inputTextStyle,
                  decoration: _dec('e.g. OPC 53, 12mm, Fe500').copyWith(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: bcAmber, width: 2),
                    ),
                  ),
                  onFieldSubmitted: (_) => _commitSubType(),
                ),
              ),
              const SizedBox(width: 8),
              _IconBtn(Icons.check_rounded, bcNavy, _commitSubType),
              const SizedBox(width: 6),
              _IconBtn(Icons.close_rounded, bcDanger, () => setState(() {
                _showSubTypeInput = false;
                _subTypeInputCtrl.clear();
              })),
            ],
          ),
        ],
      ],
    );
  }

  void _commitSubType() {
    final val = _subTypeInputCtrl.text.trim();
    setState(() {
      if (val.isNotEmpty) _subTypes.add(val);
      _subTypeInputCtrl.clear();
      _showSubTypeInput = false;
    });
  }

  // ── Variant card ───────────────────────────────────────────────────────────

  Widget _buildVariantCard(int index, _VariantEntry entry, bool isEdit) {
    final hint = _getVariantHint();
    final canRemove = _variants.length > 1 && !isEdit;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(color: bcNavy, borderRadius: BorderRadius.circular(6)),
                  child: Center(
                    child: Text('${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: entry.variantCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: bcNavy),
                    decoration: InputDecoration(
                      hintText: 'Variant name — $hint',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (canRemove)
                  GestureDetector(
                    onTap: () => setState(() => _variants.removeAt(index)),
                    child: const Icon(Icons.remove_circle_outline_rounded, color: bcDanger, size: 18),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 12, endIndent: 12),
          // Three numeric fields
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Row(
              children: [
                Expanded(child: _miniNumField('Opening Stock', entry.stockCtrl, suffix: _unit, color: bcNavy)),
                const SizedBox(width: 10),
                Expanded(child: _miniNumField('Purchase Rate', entry.rateCtrl, prefix: '₹', color: bcSuccess)),
                const SizedBox(width: 10),
                Expanded(child: _miniNumField('Min Alert', entry.limitCtrl, suffix: _unit, color: bcDanger)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniNumField(String label, TextEditingController ctrl, {
    Color color = bcNavy, String? prefix, String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 5),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: bcNavy),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
            prefixText: prefix != null ? '$prefix ' : null,
            suffixText: suffix?.toUpperCase(),
            prefixStyle: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
            suffixStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700),
            isDense: true,
            filled: true,
            fillColor: bcSurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: 1.5)),
          ),
        ),
      ],
    );
  }

  // ── Input decoration ───────────────────────────────────────────────────────

  static const TextStyle _inputTextStyle = TextStyle(fontSize: 14, color: bcNavy, fontWeight: FontWeight.w700);

  static InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.normal),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bcNavy, width: 2)),
  );

  String _getVariantHint() {
    final u = _unit.toLowerCase();
    if (['kg', 'kgs', 'ton'].contains(u)) return '12MM / 8MM';
    if (u == 'bag') return 'OPC / PPC / 53G';
    if (['sqft', 'sqm', 'cft'].contains(u)) return '2×2 / Size';
    if (u == 'ltr') return 'Shade / Color';
    if (u == 'mtr') return 'Width / Grade';
    if (u == 'box') return 'Size / Color';
    return 'Size / Model';
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final invRepo  = context.read<InventoryRepository>();
      final siteId   = context.read<SiteRepository>().selectedSiteId ?? 'S-001';
      final now      = DateTime.now();
      final name     = _nameCtrl.text.trim();
      final brand    = _brandCtrl.text.trim();
      final subType  = _subTypes.join(' / ');
      final hsn      = _hsnCtrl.text.trim();

      if (widget.materialId != null) {
        final v = _variants.first;
        await invRepo.updateMaterial(ConstructionMaterial(
          id: widget.materialId!,
          siteId: siteId,
          name: name,
          subType: subType,
          brand: brand,
          variant: v.variantCtrl.text.trim(),
          pricePerUnit: double.tryParse(v.rateCtrl.text) ?? 0,
          purchasePrice: double.tryParse(v.rateCtrl.text) ?? 0,
          salePrice: (double.tryParse(v.rateCtrl.text) ?? 0) * 1.1,
          unitType: _unit,
          currentStock: double.tryParse(v.stockCtrl.text) ?? 0,
          minimumStockLimit: double.tryParse(v.limitCtrl.text) ?? 0,
          hsnCode: hsn,
          gstPercentage: _includeTax ? _taxPercent : 0,
          updatedAt: now,
          createdAt: now,
        ));
      } else {
        for (final v in _variants) {
          await invRepo.addMaterial(ConstructionMaterial(
            id: const Uuid().v4(),
            siteId: siteId,
            name: name,
            subType: subType,
            brand: brand,
            variant: v.variantCtrl.text.trim(),
            pricePerUnit: double.tryParse(v.rateCtrl.text) ?? 0,
            purchasePrice: double.tryParse(v.rateCtrl.text) ?? 0,
            salePrice: (double.tryParse(v.rateCtrl.text) ?? 0) * 1.1,
            unitType: _unit,
            currentStock: double.tryParse(v.stockCtrl.text) ?? 0,
            minimumStockLimit: double.tryParse(v.limitCtrl.text) ?? 0,
            hsnCode: hsn,
            gstPercentage: _includeTax ? _taxPercent : 0,
            createdAt: now,
            updatedAt: now,
          ));
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ── Small icon button ──────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Icon(icon, color: color, size: 18),
    ),
  );
}

// ── Variant data holder ────────────────────────────────────────────────────────

class _VariantEntry {
  final TextEditingController variantCtrl = TextEditingController();
  final TextEditingController stockCtrl   = TextEditingController();
  final TextEditingController rateCtrl    = TextEditingController();
  final TextEditingController limitCtrl   = TextEditingController();

  _VariantEntry({String? variantName, double? stock, double? rate, double? limit}) {
    if (variantName != null) variantCtrl.text = variantName;
    if (stock  != null) stockCtrl.text = stock.toStringAsFixed(0);
    if (rate   != null) rateCtrl.text  = rate.toStringAsFixed(0);
    if (limit  != null) limitCtrl.text = limit.toStringAsFixed(0);
  }

  void dispose() {
    variantCtrl.dispose();
    stockCtrl.dispose();
    rateCtrl.dispose();
    limitCtrl.dispose();
  }
}
