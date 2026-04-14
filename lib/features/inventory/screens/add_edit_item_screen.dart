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
  
  final _nameCtrl     = TextEditingController();
  final _brandCtrl    = TextEditingController();
  final _subTypeCtrl  = TextEditingController();
  final _hsnCtrl      = TextEditingController();
  
  final List<_VariantEntry> _variants = [];
  
  String _unit = 'pcs';
  double _taxPercent = 18.0;
  bool _includeTax = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.materialId != null) {
      _loadExisting();
    } else {
      _addVariant();
    }
  }

  void _loadExisting() {
    final repo = context.read<InventoryRepository>();
    final m = repo.materials.firstWhere((e) => e.id == widget.materialId);
    _nameCtrl.text     = m.name;
    _brandCtrl.text    = m.brand ?? '';
    _subTypeCtrl.text  = m.subType;
    _hsnCtrl.text      = m.hsnCode ?? '';
    _unit            = m.unitType;
    _taxPercent      = m.taxPercentage;
    _includeTax      = m.taxPercentage > 0;
    
    _variants.add(_VariantEntry(
      variantName: m.variant,
      stock: m.currentStock,
      rate: m.purchasePrice,
      limit: m.minimumStockLimit,
    ));
  }

  void _addVariant() {
    setState(() {
      _variants.add(_VariantEntry());
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _subTypeCtrl.dispose();
    _hsnCtrl.dispose();
    for (var v in _variants) { v.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invRepo = context.watch<InventoryRepository>();
    final brands = invRepo.materials.map((m) => m.brand ?? '').where((b) => b.isNotEmpty).toSet().toList();

    return Scaffold(
      backgroundColor: bcSurface,
      appBar: AppBar(
        title: Text(widget.materialId == null ? 'NEW PRODUCT' : 'EDIT PRODUCT', 
            style: const TextStyle(fontWeight: FontWeight.w900, color: bcNavy, fontSize: 16, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: bcNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          physics: const BouncingScrollPhysics(),
          children: [
            _SectionCard(
              title: 'BASIC CATALOG INFO',
              icon: Icons.info_outline_rounded,
              child: Column(
                children: [
                  _buildTextField('Material / Product Name *', _nameCtrl, 'e.g. TMT Steel Rod'),
                  const SizedBox(height: 16),
                  _buildAutocompleteField('Brand (Optional)', _brandCtrl, brands),
                  const SizedBox(height: 16),
                  _buildTextField('Sub-type / Quality', _subTypeCtrl, 'e.g. Grade 53'),
                ],
              ),
            ),

            _SectionCard(
              title: 'UNITS & TAXATION',
              icon: Icons.tune_rounded,
              child: Column(
                children: [
                  _buildUnitSelector(),
                  const SizedBox(height: 16),
                  _buildTaxToggle(),
                  if (_includeTax) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildNumberField('GST %', initialValue: _taxPercent.toString(), onChanged: (v) => _taxPercent = double.tryParse(v) ?? 18)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('HSN Code', _hsnCtrl, 'XXXX')),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            _SectionCard(
              title: 'INVENTORY VARIATIONS',
              icon: Icons.layers_outlined,
              trailing: widget.materialId == null ? GestureDetector(
                onTap: _addVariant,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: bcPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Row(children: [
                    Icon(Icons.add_rounded, color: bcPrimary, size: 16),
                    SizedBox(width: 4),
                    Text('ADD', style: TextStyle(color: bcPrimary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                  ]),
                ),
              ) : null,
              child: Column(
                children: [
                  ..._variants.asMap().entries.map((e) => _buildVariantEntry(e.key, e.value)),
                ],
              ),
            ),

            const SizedBox(height: 12),
            _buildSubmitButton(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label.toUpperCase(), style: const TextStyle(color: bcTextSecondary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
        ),
        TextFormField(
          controller: ctrl,
          style: const TextStyle(fontSize: 14, color: bcNavy, fontWeight: FontWeight.w700),
          decoration: _inputDecoration(hint),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildAutocompleteField(String label, TextEditingController ctrl, List<String> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label.toUpperCase(), style: const TextStyle(color: bcTextSecondary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
        ),
        RawAutocomplete<String>(
          textEditingController: ctrl,
          focusNode: FocusNode(),
          optionsBuilder: (TextEditingValue value) {
            if (value.text.isEmpty) return const Iterable<String>.empty();
            return suggestions.where((s) => s.toLowerCase().contains(value.text.toLowerCase()));
          },
          fieldViewBuilder: (context, controller, node, onSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: node,
              style: const TextStyle(fontSize: 14, color: bcNavy, fontWeight: FontWeight.w700),
              decoration: _inputDecoration('Search or type...'),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 200,
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (ctx, i) => ListTile(
                      title: Text(options.elementAt(i), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: bcNavy)),
                      onTap: () => onSelected(options.elementAt(i)),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVariantEntry(int index, _VariantEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bcSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bcBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: entry.variantCtrl,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: bcNavy),
                  decoration: InputDecoration(
                    hintText: 'VARIANT: ${_getVariantHint()}',
                    hintStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                    isDense: true, border: InputBorder.none,
                  ),
                ),
              ),
              if (_variants.length > 1 && widget.materialId == null)
                GestureDetector(
                  onTap: () => setState(() => _variants.removeAt(index)),
                  child: const Icon(Icons.delete_outline_rounded, color: bcDanger, size: 20),
                ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(child: _buildMiniNumField('OP. STOCK', entry.stockCtrl)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniNumField('OP. RATE', entry.rateCtrl)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniNumField('MIN LIMIT', entry.limitCtrl)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniNumField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: bcTextSecondary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: bcNavy, letterSpacing: -0.5),
          decoration: InputDecoration(
            isDense: true,
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: bcBorder.withValues(alpha: 0.6))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: bcBorder.withValues(alpha: 0.6))),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(String label, {required String initialValue, required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label.toUpperCase(), style: const TextStyle(color: bcTextSecondary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
        ),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, color: bcNavy, fontWeight: FontWeight.w700),
          decoration: _inputDecoration('%'),
        ),
      ],
    );
  }

  Widget _buildUnitSelector() {
    return GestureDetector(
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bcSurface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: bcBorder.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            const Icon(Icons.scale_rounded, color: bcAmber, size: 20),
            const SizedBox(width: 12),
            const Expanded(child: Text('BASE MEASUREMENT UNIT', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.2))),
            Text(_unit.toUpperCase(), style: const TextStyle(color: bcPrimary, fontWeight: FontWeight.w900, fontSize: 13)),
            const Icon(Icons.chevron_right_rounded, color: bcTextSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bcSurface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bcBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: bcSuccess, size: 20),
          const SizedBox(width: 12),
          const Expanded(child: Text('INCLUDE TAXATION (GST)', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.2))),
          Switch.adaptive(
            value: _includeTax,
            onChanged: (v) => setState(() => _includeTax = v),
            activeColor: bcSuccess,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: bcNavy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(widget.materialId == null ? 'CONFIRM & CREATE PRODUCT' : 'SAVE CHANGES', 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.normal),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: bcBorder.withValues(alpha: 0.6))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: bcBorder.withValues(alpha: 0.6))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: bcPrimary, width: 2)),
    );
  }

  String _getVariantHint() {
    final u = _unit.toLowerCase();
    if (['kgs', 'ton', 'mtr'].contains(u)) return '12MM / 8MM';
    if (u == 'bag') return 'OPC / 53G';
    if (['sqft', 'sqm', 'cft'].contains(u)) return '2X2 / SIZE';
    if (u == 'ltr') return 'SHADE / COLOR';
    return 'SIZE / MODEL';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final invRepo  = context.read<InventoryRepository>();
      final siteId   = context.read<SiteRepository>().selectedSiteId ?? 'S-001';
      final now      = DateTime.now();
      
      final name     = _nameCtrl.text.trim();
      final brand    = _brandCtrl.text.trim();
      final subType  = _subTypeCtrl.text.trim();
      final hsn      = _hsnCtrl.text.trim();
      
      if (widget.materialId != null) {
        final v = _variants.first;
        final updated = ConstructionMaterial(
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
        );
        await invRepo.updateMaterial(updated);
      } else {
        for (var v in _variants) {
          final m = ConstructionMaterial(
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
          );
          await invRepo.addMaterial(m);
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: bcBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Row(
              children: [
                Icon(icon, size: 16, color: bcAmber),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _VariantEntry {
  final TextEditingController variantCtrl = TextEditingController();
  final TextEditingController stockCtrl   = TextEditingController();
  final TextEditingController rateCtrl    = TextEditingController();
  final TextEditingController limitCtrl   = TextEditingController();

  _VariantEntry({String? variantName, double? stock, double? rate, double? limit}) {
    if (variantName != null) variantCtrl.text = variantName;
    if (stock != null) stockCtrl.text = stock.toStringAsFixed(0);
    if (rate != null) rateCtrl.text = rate.toStringAsFixed(0);
    if (limit != null) limitCtrl.text = limit.toStringAsFixed(0);
  }

  void dispose() {
    variantCtrl.dispose();
    stockCtrl.dispose();
    rateCtrl.dispose();
    limitCtrl.dispose();
  }
}
