import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/features/inventory/widgets/unit_picker_sheet.dart';

// ── Category data ─────────────────────────────────────────────────────────────
class _Category {
  final String label;
  final IconData icon;
  final Color color;
  const _Category(this.label, this.icon, this.color);
}

const _categories = [
  _Category('Cement',    Icons.circle_outlined,            Color(0xFF94A3B8)),
  _Category('Steel',     Icons.linear_scale_rounded,        Color(0xFF6366F1)),
  _Category('Bricks',    Icons.grid_view_rounded,           Color(0xFFEF4444)),
  _Category('Wood',      Icons.forest_rounded,              Color(0xFF92400E)),
  _Category('Paint',     Icons.format_paint_rounded,        Color(0xFF10B981)),
  _Category('Electrical',Icons.bolt_rounded,                Color(0xFFF59E0B)),
  _Category('Plumbing',  Icons.plumbing_rounded,            Color(0xFF3B82F6)),
  _Category('Sand',      Icons.landscape_rounded,           Color(0xFFD97706)),
  _Category('Stone',     Icons.terrain_rounded,             Color(0xFF64748B)),
  _Category('Other',     Icons.category_rounded,            Color(0xFF8B5CF6)),
];

// ─────────────────────────────────────────────────────────────────────────────

class AddEditItemScreen extends StatefulWidget {
  final String? materialId;
  const AddEditItemScreen({super.key, this.materialId});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen>
    with TickerProviderStateMixin {
  final _formKey            = GlobalKey<FormState>();
  final _nameCtrl           = TextEditingController();
  final _brandCtrl          = TextEditingController();
  final _hsnCtrl            = TextEditingController();
  final _subTypeInputCtrl   = TextEditingController();
  final _nameFocus          = FocusNode();

  final List<_VariantEntry> _variants     = [];
  final List<String>        _subTypes     = [];

  String  _unit             = 'pcs';
  double  _taxPercent       = 18.0;
  bool    _includeTax       = false;
  bool    _isLoading        = false;
  bool    _showSubTypeInput = false;
  int     _categoryIndex    = 9; // 'Other' default

  late AnimationController _headerAnim;
  late AnimationController _submitAnim;
  late Animation<double>   _headerSlide;
  late Animation<double>   _submitScale;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _submitAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _headerSlide = Tween(begin: -30.0, end: 0.0)
        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
    _submitScale = Tween(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _submitAnim, curve: Curves.easeInOut));
    _headerAnim.forward();

    if (widget.materialId != null) {
      _loadExisting();
    } else {
      _variants.add(_VariantEntry());
    }
  }

  void _loadExisting() {
    final repo = context.read<InventoryRepository>();
    final m    = repo.materials.firstWhere((e) => e.id == widget.materialId);
    _nameCtrl.text  = m.name;
    _brandCtrl.text = m.brand ?? '';
    _hsnCtrl.text   = m.hsnCode ?? '';
    _unit           = m.unitType;
    _taxPercent     = m.taxPercentage;
    _includeTax     = m.taxPercentage > 0;
    if (m.subType.isNotEmpty) {
      _subTypes.addAll(
          m.subType.split(' / ').map((s) => s.trim()).where((s) => s.isNotEmpty));
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
    _nameFocus.dispose();
    _headerAnim.dispose();
    _submitAnim.dispose();
    for (var v in _variants) { v.dispose(); }
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final invRepo = context.watch<InventoryRepository>();
    final brands  = invRepo.materials
        .map((m) => m.brand ?? '')
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();
    final isEdit  = widget.materialId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(isEdit),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Category ─────────────────────────────────────────────
                  _sectionCard(
                    step: 1,
                    title: 'Category',
                    subtitle: 'What type of material is this?',
                    icon: Icons.category_outlined,
                    child: _buildCategoryPicker(),
                  ),
                  const SizedBox(height: 16),

                  // ── Identity ─────────────────────────────────────────────
                  _sectionCard(
                    step: 2,
                    title: 'Material Identity',
                    subtitle: 'Name, brand and sub-grades',
                    icon: Icons.inventory_2_outlined,
                    child: Column(
                      children: [
                        _labeledField(
                          label: 'Material Name',
                          required: true,
                          child: TextFormField(
                            controller: _nameCtrl,
                            focusNode: _nameFocus,
                            textCapitalization: TextCapitalization.words,
                            style: _inputStyle,
                            decoration: _dec(
                              'e.g. TMT Steel Rod, OPC Cement',
                              icon: Icons.inventory_2_rounded,
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _labeledField(
                          label: 'Brand',
                          child: RawAutocomplete<String>(
                            textEditingController: _brandCtrl,
                            focusNode: FocusNode(),
                            optionsBuilder: (v) => v.text.isEmpty
                                ? const Iterable<String>.empty()
                                : brands.where(
                                    (b) => b.toLowerCase().contains(v.text.toLowerCase())),
                            fieldViewBuilder: (_, ctrl, node, onSubmit) => TextFormField(
                              controller: ctrl,
                              focusNode: node,
                              style: _inputStyle,
                              decoration: _dec('e.g. Ultratech, JSW', icon: Icons.business_rounded),
                            ),
                            optionsViewBuilder: (_, onSelected, options) => Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.white,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 260, maxHeight: 200),
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    children: options.map((o) => ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.business_rounded, size: 16, color: bcAmber),
                                      title: Text(o,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700, color: bcNavy, fontSize: 13)),
                                      onTap: () => onSelected(o),
                                    )).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSubTypeSection(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Measurement ───────────────────────────────────────────
                  _sectionCard(
                    step: 3,
                    title: 'Measurement & Tax',
                    subtitle: 'Unit type and GST settings',
                    icon: Icons.scale_outlined,
                    child: Column(
                      children: [
                        _buildUnitSelector(),
                        const SizedBox(height: 12),
                        _buildTaxCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Stock & Pricing ───────────────────────────────────────
                  _sectionCard(
                    step: 4,
                    title: 'Stock & Pricing',
                    subtitle: 'Opening quantity, rate, and alert levels',
                    icon: Icons.layers_outlined,
                    trailing: !isEdit
                        ? _addButton(
                            label: 'ADD VARIANT',
                            onTap: () => setState(() => _variants.add(_VariantEntry())),
                          )
                        : null,
                    child: Column(
                      children: [
                        ..._variants.asMap().entries.map(
                            (e) => _buildVariantCard(e.key, e.value, isEdit)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Submit ────────────────────────────────────────────────
                  _buildSubmitButton(isEdit),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sliver Header ─────────────────────────────────────────────────────────

  Widget _buildSliverHeader(bool isEdit) {
    final cat = _categories[_categoryIndex];
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      stretch: true,
      backgroundColor: bcNavy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: bcAmber, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bcNavy,
                      const Color(0xFF1E293B),
                      cat.color.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: BlueprintGridPainter(opacity: 0.08),
              ),
            ),
            AnimatedBuilder(
              animation: _headerSlide,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _headerSlide.value),
                child: child,
              ),
              child: Opacity(
                opacity: _headerAnim.value.clamp(0.0, 1.0),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: bcAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: bcAmber.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  isEdit ? 'EDIT MATERIAL' : 'NEW MATERIAL',
                                  style: const TextStyle(
                                    color: bcAmber,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isEdit ? 'Edit Material' : 'Add Material',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isEdit
                                    ? 'Update details for this material'
                                    : 'Add a new material to your inventory',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: cat.color.withValues(alpha: 0.4), width: 2),
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Card ──────────────────────────────────────────────────────────

  Widget _sectionCard({
    required int step,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bcNavy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [bcNavy, Color(0xFF334155)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: const TextStyle(
                        color: bcAmber,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            color: bcNavy,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          )),
                      Text(subtitle,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  // ── Category Picker ───────────────────────────────────────────────────────

  Widget _buildCategoryPicker() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat    = _categories[i];
          final active = _categoryIndex == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _categoryIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 70,
              decoration: BoxDecoration(
                color: active ? cat.color.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? cat.color : const Color(0xFFE2E8F0),
                  width: active ? 2 : 1,
                ),
                boxShadow: active
                    ? [BoxShadow(color: cat.color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: active ? cat.color.withValues(alpha: 0.18) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cat.icon, color: active ? cat.color : const Color(0xFF94A3B8), size: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.label,
                    style: TextStyle(
                      color: active ? cat.color : const Color(0xFF64748B),
                      fontSize: 9.5,
                      fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Sub-type Section ──────────────────────────────────────────────────────

  Widget _buildSubTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.label_rounded, size: 13, color: Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            const Text(
              'GRADES / SUB-TYPES',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            if (!_showSubTypeInput)
              _addButton(
                label: 'ADD',
                onTap: () => setState(() => _showSubTypeInput = true),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Empty state or chips
        if (_subTypes.isEmpty && !_showSubTypeInput)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  style: BorderStyle.solid),
            ),
            child: const Row(children: [
              Icon(Icons.add_circle_outline_rounded, color: Color(0xFFCBD5E1), size: 16),
              SizedBox(width: 10),
              Text('Optional — e.g. OPC 53, Fe500, Grade A',
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
            ]),
          ),

        if (_subTypes.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _subTypes.asMap().entries.map((e) => _SubTypeChip(
              label: e.value,
              onDelete: () => setState(() => _subTypes.removeAt(e.key)),
            )).toList(),
          ),

        if (_showSubTypeInput) ...[
          if (_subTypes.isNotEmpty) const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _subTypeInputCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: _inputStyle,
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
            _SmallActionBtn(icon: Icons.check_rounded, color: bcNavy, onTap: _commitSubType),
            const SizedBox(width: 6),
            _SmallActionBtn(
              icon: Icons.close_rounded,
              color: bcDanger,
              onTap: () => setState(() {
                _showSubTypeInput = false;
                _subTypeInputCtrl.clear();
              }),
            ),
          ]),
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

  // ── Unit Selector ─────────────────────────────────────────────────────────

  Widget _buildUnitSelector() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
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
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bcAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.scale_rounded, color: bcAmber, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Unit of Measurement',
                    style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 14)),
                Text('Tap to change unit',
                    style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bcNavy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _unit.toUpperCase(),
              style: const TextStyle(
                color: bcAmber,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
        ]),
      ),
    );
  }

  // ── Tax Card ──────────────────────────────────────────────────────────────

  Widget _buildTaxCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _includeTax
            ? bcSuccess.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _includeTax
              ? bcSuccess.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bcSuccess.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: _includeTax ? bcSuccess : const Color(0xFF94A3B8),
                size: 16,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GST / Tax',
                      style: TextStyle(
                          color: bcNavy, fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(
                    _includeTax ? 'Tax included in pricing' : 'No tax applied',
                    style: TextStyle(
                      color: _includeTax ? bcSuccess : const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _includeTax,
              onChanged: (v) => setState(() => _includeTax = v),
              activeColor: bcSuccess,
              activeTrackColor: bcSuccess.withValues(alpha: 0.3),
            ),
          ]),
        ),
        if (_includeTax) ...[
          Divider(height: 1, color: bcSuccess.withValues(alpha: 0.15)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(children: [
              Expanded(
                child: _labeledField(
                  label: 'GST %',
                  child: TextFormField(
                    initialValue: _taxPercent.toStringAsFixed(0),
                    keyboardType: TextInputType.number,
                    style: _inputStyle,
                    decoration: _dec('18', icon: Icons.percent_rounded),
                    onChanged: (v) => _taxPercent = double.tryParse(v) ?? 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledField(
                  label: 'HSN Code',
                  child: TextFormField(
                    controller: _hsnCtrl,
                    style: _inputStyle,
                    decoration: _dec('e.g. 7214', icon: Icons.qr_code_rounded),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  // ── Variant Card ──────────────────────────────────────────────────────────

  Widget _buildVariantCard(int index, _VariantEntry entry, bool isEdit) {
    final hint      = _getVariantHint();
    final canRemove = _variants.length > 1 && !isEdit;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: bcNavy,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: entry.variantCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: bcNavy,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. $hint',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w400,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: bcNavy, width: 1.5),
                    ),
                  ),
                ),
              ),
              if (canRemove)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _variants.removeAt(index));
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                ),
            ]),
          ),

          // ── Three fields ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(child: _miniField(
                label: 'Opening Stock',
                ctrl: entry.stockCtrl,
                suffix: _unit,
              )),
              const SizedBox(width: 12),
              Expanded(child: _miniField(
                label: 'Purchase Rate',
                ctrl: entry.rateCtrl,
                prefix: '₹',
              )),
              const SizedBox(width: 12),
              Expanded(child: _miniField(
                label: 'Min Alert',
                ctrl: entry.limitCtrl,
                suffix: _unit,
              )),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _miniField({
    required String label,
    required TextEditingController ctrl,
    String sublabel = '',
    Color accentColor = bcNavy,
    String? prefix,
    String? suffix,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: bcNavy,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 16,
            ),
            prefixText: prefix != null ? '$prefix ' : null,
            suffixText: suffix?.toUpperCase(),
            prefixStyle: const TextStyle(
              color: bcNavy,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
            suffixStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            isDense: false,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: bcNavy, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Submit Button ─────────────────────────────────────────────────────────

  Widget _buildSubmitButton(bool isEdit) {
    return AnimatedBuilder(
      animation: _submitScale,
      builder: (_, child) =>
          Transform.scale(scale: _submitScale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _submitAnim.forward(),
        onTapUp: (_) async {
          await _submitAnim.reverse();
          if (!_isLoading) _submit();
        },
        onTapCancel: () => _submitAnim.reverse(),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [bcNavy, Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: bcNavy.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child:
                        CircularProgressIndicator(color: bcAmber, strokeWidth: 2.5),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEdit ? Icons.save_rounded : Icons.add_rounded,
                      color: bcAmber,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEdit ? 'Save Changes' : 'Create Material',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _labeledField({
    required String label,
    required Widget child,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Row(children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 3),
              const Text('*', style: TextStyle(color: bcDanger, fontWeight: FontWeight.w900, fontSize: 12)),
            ],
          ]),
        ),
        child,
      ],
    );
  }

  Widget _addButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bcAmber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: bcAmber.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add_rounded, color: bcAmber, size: 14),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(
                  color: bcAmber,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.5)),
        ]),
      ),
    );
  }

  static const TextStyle _inputStyle =
      TextStyle(fontSize: 16, color: bcNavy, fontWeight: FontWeight.w600);

  static InputDecoration _dec(String hint, {IconData? icon}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: Color(0xFFCBD5E1), fontSize: 15, fontWeight: FontWeight.normal),
        prefixIcon: icon != null
            ? Icon(icon, size: 22, color: const Color(0xFFCBD5E1))
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: bcNavy, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: bcDanger, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: bcDanger, width: 2)),
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

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final invRepo = context.read<InventoryRepository>();
      final siteId  = context.read<SiteRepository>().selectedSiteId ?? 'S-001';
      final now     = DateTime.now();
      final name    = _nameCtrl.text.trim();
      final brand   = _brandCtrl.text.trim();
      final subType = _subTypes.join(' / ');
      final hsn     = _hsnCtrl.text.trim();

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
      if (mounted) {
        HapticFeedback.heavyImpact();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: bcDanger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ── Sub-type Chip ─────────────────────────────────────────────────────────────

class _SubTypeChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;
  const _SubTypeChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bcNavy.withValues(alpha: 0.08), bcNavy.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bcNavy.withValues(alpha: 0.15)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.label_rounded, size: 12, color: bcNavy),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                color: bcNavy, fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF94A3B8).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, size: 12, color: Color(0xFF64748B)),
          ),
        ),
      ]),
    );
  }
}

// ── Small Action Button ───────────────────────────────────────────────────────

class _SmallActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: color, size: 18),
    ),
  );
}

// ── Variant Entry ─────────────────────────────────────────────────────────────

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
