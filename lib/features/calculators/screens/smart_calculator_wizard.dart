import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';

import 'package:construction_app/features/calculators/logic/calculation_engine.dart';
import 'package:construction_app/shared/widgets/calculator_widgets.dart';
import 'package:construction_app/core/routing/app_router.dart';
import 'package:construction_app/data/repositories/calculation_repository.dart';

enum CalculatorType {
  slab('Slab', Icons.layers_rounded, 'Concrete slab'),
  plaster('Plaster', Icons.format_paint_rounded, 'Wall/Ceiling'),
  brick('Brick', Icons.grid_view_rounded, 'Wall masonry'),
  tile('Tile', Icons.dashboard_customize_rounded, 'Area coverage'),
  area('Area', Icons.square_foot_rounded, 'Area calculator');

  final String label;
  final IconData icon;
  final String subtitle;
  const CalculatorType(this.label, this.icon, this.subtitle);
}

class ConcreteGrade {
  final String name;
  final double cement;
  final double sand;
  final double aggregate;
  const ConcreteGrade(this.name, this.cement, this.sand, this.aggregate);
}

const List<ConcreteGrade> concreteGrades = [
  ConcreteGrade('M10 (1:3:6)', 1, 3, 6),
  ConcreteGrade('M15 (1:2:4)', 1, 2, 4),
  ConcreteGrade('M20 (1:1.5:3)', 1, 1.5, 3),
  ConcreteGrade('M25 (1:1:2)', 1, 1, 2),
  ConcreteGrade('Custom Mix Ratio', 0, 0, 0),
];

// Steel presets
const List<double> rebarDiameters = [8, 10, 12, 16];
const List<double> rebarSpacingsMm = [150, 200, 250, 300];

class SmartCalculatorWizard extends StatefulWidget {
  final CalculatorType? initialType;
  const SmartCalculatorWizard({super.key, this.initialType});

  @override
  State<SmartCalculatorWizard> createState() => _SmartCalculatorWizardState();
}

class _SmartCalculatorWizardState extends State<SmartCalculatorWizard> {
  late CalculatorType _selectedType;
  bool _isMetric = true;
  ConcreteGrade? _selectedGrade; // null = not selected
  String? _aggSize; // null = not selected
  String _brickType = 'Standard (190mm)';
  String _mortarRatio = '1:6';
  String _plasterThick = '15mm';
  String _plasterRatio = '1:4';
  String _tileSize = '12"×12" (1×1 ft)';
  bool _useAdhesive = true;
  bool _showSteel = false;
  bool _hasCalculated = false; // results shown only after Calculate pressed

  // Steel state
  double _steelDiameterMm = 12;
  double _steelSpacingMm = 150;

  // Running total for Area
  double _areaTotal = 0;

  bool _showDebug = false;  // debug panel toggle

  final Map<String, double> aggFactorMap = {
    '10mm': 1.60,
    '20mm': 1.54,
    '25mm': 1.52,
    '40mm': 1.50,
  };

  // Dimension controllers — all blank initially
  final _lCtrl = TextEditingController();
  final _wCtrl = TextEditingController();
  final _tCtrl = TextEditingController();

  // Ratio controllers — blank initially
  final _cementRatio = TextEditingController();
  final _sandRatio = TextEditingController();
  final _aggregateRatio = TextEditingController();

  // Brick size controllers — values always in INCHES (displayed to user)
  // Internally converted: inches × 25.4 / 1000 = metres
  final _brickLCtrl = TextEditingController(text: '7.48');  // 190mm = 7.48 in
  final _brickWCtrl = TextEditingController(text: '3.54');  // 90mm  = 3.54 in
  final _brickHCtrl = TextEditingController(text: '3.54');  // 90mm  = 3.54 in

  // Tile controllers — values always in mm
  final _tileLCtrl = TextEditingController(text: '600');
  final _tileWCtrl = TextEditingController(text: '600');

  // Plaster custom thickness (mm)
  final _plasterThickCustom = TextEditingController();

  final _wastageCtrl = TextEditingController(text: '5');
  Map<String, String?> _errors = {};

  dynamic _result;
  SteelCalculationResult? _steelResult;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? CalculatorType.slab;
    // No auto-calculation — all inputs start blank
  }

  // ─── VALIDATION ──────────────────────────────────────────────────────────────

  bool _validate() {
    final errors = <String, String?>{};
    final l = double.tryParse(_lCtrl.text);
    final w = double.tryParse(_wCtrl.text);
    final t = double.tryParse(_tCtrl.text);

    if (_lCtrl.text.trim().isEmpty) {
      errors['length'] = 'Length is required';
    } else if (l == null || l <= 0) {
      errors['length'] = 'Length must be > 0';
    }
    if (_wCtrl.text.trim().isEmpty) {
      errors['width'] = 'Width is required';
    } else if (w == null || w <= 0) {
      errors['width'] = 'Width must be > 0';
    }

    if (_selectedType == CalculatorType.slab ||
        _selectedType == CalculatorType.brick) {
      if (_tCtrl.text.trim().isEmpty) {
        errors['thickness'] = 'Thickness is required';
      } else if (t == null || t <= 0) {
        errors['thickness'] = 'Thickness must be > 0';
      }
    }

    if (_selectedType == CalculatorType.slab) {
      if (_selectedGrade == null) errors['grade'] = 'Select a concrete grade';
      if (_aggSize == null) errors['aggsize'] = 'Select aggregate size';
      final c = double.tryParse(_cementRatio.text);
      final s = double.tryParse(_sandRatio.text);
      final a = double.tryParse(_aggregateRatio.text);
      if (_cementRatio.text.trim().isEmpty || c == null || c <= 0) errors['cement'] = 'Required (> 0)';
      if (_sandRatio.text.trim().isEmpty || s == null || s <= 0) errors['sand'] = 'Required (> 0)';
      if (_aggregateRatio.text.trim().isEmpty || a == null || a <= 0) errors['agg'] = 'Required (> 0)';
    }

    // Bug fix — Plaster: if custom thickness is selected but value is invalid, flag it
    if (_selectedType == CalculatorType.plaster) {
      final hasCustomToggle = _plasterThick == 'Custom' || _plasterThickCustom.text.trim().isNotEmpty;
      if (hasCustomToggle) {
        final customVal = double.tryParse(_plasterThickCustom.text);
        if (customVal == null || customVal <= 0) {
          errors['plasterThick'] = 'Enter a valid thickness in mm';
        }
      }
    }

    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  /// Returns true if all required inputs are filled (for button enable state)
  bool get _canCalculate {
    final l = double.tryParse(_lCtrl.text);
    final w = double.tryParse(_wCtrl.text);
    if (l == null || l <= 0 || w == null || w <= 0) return false;

    if (_selectedType == CalculatorType.slab || _selectedType == CalculatorType.brick) {
      final t = double.tryParse(_tCtrl.text);
      if (t == null || t <= 0) return false;
    }

    if (_selectedType == CalculatorType.slab) {
      if (_selectedGrade == null || _aggSize == null) return false;
      final c = double.tryParse(_cementRatio.text);
      final s = double.tryParse(_sandRatio.text);
      final a = double.tryParse(_aggregateRatio.text);
      if (c == null || c <= 0 || s == null || s <= 0 || a == null || a <= 0) return false;
    }

    // Bug fix — Brick: when Custom selected, all three brick dims must be valid
    if (_selectedType == CalculatorType.brick && _brickType == 'Custom') {
      final bL = double.tryParse(_brickLCtrl.text);
      final bW = double.tryParse(_brickWCtrl.text);
      final bH = double.tryParse(_brickHCtrl.text);
      if (bL == null || bL <= 0 || bW == null || bW <= 0 || bH == null || bH <= 0) return false;
    }

    // Bug fix — Tile: when Custom selected, tile dims must be valid
    if (_selectedType == CalculatorType.tile && _tileSize == 'Custom') {
      final tL = double.tryParse(_tileLCtrl.text);
      final tW = double.tryParse(_tileWCtrl.text);
      if (tL == null || tL <= 0 || tW == null || tW <= 0) return false;
    }

    return true;
  }

  String? _err(String key) => _errors[key];

  // ─── CALCULATION ─────────────────────────────────────────────────────────────

  /// Called on any input change — clears results so user must recalculate
  void _onInputChanged() {
    if (_hasCalculated) {
      setState(() {
        _hasCalculated = false;
        _result = null;
        _steelResult = null;
      });
    } else {
      setState(() {}); // refresh button state
    }
  }

  void _onGradeChanged(ConcreteGrade? grade) {
    if (grade == null) return;
    setState(() {
      _selectedGrade = grade;
      if (grade.name != 'Custom Mix Ratio') {
        // Pre-fill ratio fields from grade preset
        _cementRatio.text    = grade.cement.toString();
        _sandRatio.text      = grade.sand.toString();
        _aggregateRatio.text = grade.aggregate.toString();
      } else {
        // Clear: user must type custom values
        _cementRatio.clear();
        _sandRatio.clear();
        _aggregateRatio.clear();
      }
      _hasCalculated = false;
      _result = null;
      _steelResult = null;
    });
  }

  void _runCalculation() {
    final isMetric = _isMetric;
    final l = double.tryParse(_lCtrl.text) ?? 0.0;
    final w = double.tryParse(_wCtrl.text) ?? 0.0;
    final t = double.tryParse(_tCtrl.text) ?? 0.0;
    final wastage = double.tryParse(_wastageCtrl.text) ?? 5.0;

    switch (_selectedType) {
      case CalculatorType.slab:
        // Thickness: metric → metres already stored in controller
        //            imperial → controller holds inches; engine converts in→m
        final double thicknessForEngine = t; // engine handles unit based on isMetric
        _result = CalculationEngine.calculateConcrete(
          length: l, width: w, height: thicknessForEngine,
          cementRatio:    double.tryParse(_cementRatio.text)    ?? 1,
          sandRatio:      double.tryParse(_sandRatio.text)      ?? 1.5,
          aggregateRatio: double.tryParse(_aggregateRatio.text) ?? 3,
          isMetric:       isMetric,
          wastagePercent: wastage,
          dryVolumeFactor: aggFactorMap[_aggSize ?? '20mm'] ?? 1.54,
        );
        if (_showSteel) {
          final slabLm = isMetric ? l : l * 0.3048;
          final slabWm = isMetric ? w : w * 0.3048;
          _steelResult = CalculationEngine.calculateSteel(
            slabLengthM: slabLm,
            slabWidthM:  slabWm,
            diameterMm:  _steelDiameterMm,
            spacingMm:   _steelSpacingMm,
          );
        } else {
          _steelResult = null;
        }
        break;
      case CalculatorType.brick:
        // Standard IS brick: 190×90×90 mm
        double bL = 0.190, bW = 0.090, bH = 0.090;
        if (_brickType == 'Fly Ash (230mm)') {
          bL = 0.230; bW = 0.110; bH = 0.070;
        } else if (_brickType == 'AAC Block') {
          bL = 0.600; bW = 0.200; bH = 0.200;
        } else if (_brickType == 'Custom') {
          // Controllers hold values in INCHES — convert: inches × 25.4 / 1000 = metres
          final inchL = double.tryParse(_brickLCtrl.text) ?? 7.48;
          final inchW = double.tryParse(_brickWCtrl.text) ?? 3.54;
          final inchH = double.tryParse(_brickHCtrl.text) ?? 3.54;
          bL = inchL * 25.4 / 1000;
          bW = inchW * 25.4 / 1000;
          bH = inchH * 25.4 / 1000;
        }
        _result = CalculationEngine.calculateBricks(
          wallL: l,
          wallH: w,
          wallT: t,   // metric→metres, imperial→inches (engine converts)
          brickL: bL, brickW: bW, brickH: bH,
          mortarRatio: double.tryParse(_mortarRatio.split(':').last) ?? 6,
          wastagePercent: wastage,
          isMetric: isMetric,
        );
        _steelResult = null;
        break;
      case CalculatorType.plaster:
        // custom thickness: _plasterThickMmCtrl overrides toggle if filled
        final double plasterThickMm = _plasterThickCustom.text.trim().isNotEmpty
            ? (double.tryParse(_plasterThickCustom.text) ?? double.tryParse(_plasterThick.replaceAll('mm', '')) ?? 15)
            : (double.tryParse(_plasterThick.replaceAll('mm', '')) ?? 15);
        _result = CalculationEngine.calculatePlaster(
          areaL: l,
          areaW: w,
          thicknessMm: plasterThickMm,
          mortarRatio: double.tryParse(_plasterRatio.split(':').last) ?? 4,
          isMetric: isMetric,
          wastagePercent: 15,
        );
        _steelResult = null;
        break;
      case CalculatorType.tile:
        double tL = 0.3, tW = 0.3;
        if (_tileSize == '12”×12” (1×1 ft)') { tL = 0.3048; tW = 0.3048; }
        else if (_tileSize == '24”×24” (2×2 ft)') { tL = 0.6096; tW = 0.6096; }
        else if (_tileSize == '600×600 mm') { tL = 0.600; tW = 0.600; }
        else if (_tileSize == '300×300 mm') { tL = 0.300; tW = 0.300; }
        else if (_tileSize == '800×800 mm') { tL = 0.800; tW = 0.800; }
        else if (_tileSize == 'Custom') {
          // Custom tile: controllers hold mm values
          tL = (double.tryParse(_tileLCtrl.text) ?? 600) / 1000;
          tW = (double.tryParse(_tileWCtrl.text) ?? 600) / 1000;
        }
        _result = CalculationEngine.calculateTiles(
          areaL: l, areaW: w, tileL: tL, tileW: tW,
          wastagePercent: wastage,
          useAdhesive: _useAdhesive,
          isMetric: isMetric,
        );
        _steelResult = null;
        break;
      case CalculatorType.area:
        _result = l * w;
        _steelResult = null;
        break;
    }
  }

  void _calculate() {
    if (!_validate()) return;
    setState(() {
      _runCalculation();
      _hasCalculated = true;
    });
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 14),
                      _buildWorkTypeSelector(),
                      const SizedBox(height: 12),
                      _buildUnitToggle(),
                      const SizedBox(height: 16),
                      _buildInputs(),
                      const SizedBox(height: 12),
                      _buildCalculateButton(),
                      const SizedBox(height: 20),
                      _buildResultSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    if (!_hasCalculated) {
      return _buildEmptyResultPlaceholder();
    }
    return Column(
      children: [
        if (_result != null) _buildResultPanel(),
        if (_steelResult != null) ...[
          const SizedBox(height: 8),
          SteelResultCard(
            mainBars: _steelResult!.mainBars,
            distBars: _steelResult!.distributionBars,
            totalWeightKg: _steelResult!.totalWeightKg,
            rodsRequired: _steelResult!.rodsRequired,
            totalMainLengthM: _steelResult!.totalMainLengthM,
            totalDistLengthM: _steelResult!.totalDistLengthM,
            diameterMm: _steelResult!.diameterMm,
            spacingMm: _steelResult!.spacingMm,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyResultPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bcAmber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calculate_outlined, size: 32, color: bcAmber),
          ),
          const SizedBox(height: 16),
          const Text(
            'Results will appear here',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: bcNavy),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter all required inputs and press\nCALCULATE to see material estimates.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: bcTextSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: const BoxDecoration(
        color: bcNavy,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Civil Calculator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                Text(_selectedType.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              // ── Clear all dimension inputs ──
              _lCtrl.clear(); _wCtrl.clear(); _tCtrl.clear();
              // ── Clear ratio inputs ──
              _cementRatio.clear(); _sandRatio.clear(); _aggregateRatio.clear();
              // ── Clear extra inputs ──
              _plasterThickCustom.clear();
              _wastageCtrl.text = '5';
              // ── Reset selectors to defaults ──
              _selectedGrade = null;
              _aggSize       = null;
              _brickType     = 'Standard (190mm)';
              _mortarRatio   = '1:6';
              _plasterThick  = '15mm';
              _plasterRatio  = '1:4';
              _tileSize      = '12"×12" (1×1 ft)';
              _useAdhesive   = true;
              _showSteel     = false;
              _areaTotal     = 0;
              // ── Clear results and errors ──
              _errors        = {};
              _result        = null;
              _steelResult   = null;
              _hasCalculated = false;
              _showDebug     = false;
            }),
            icon: const Icon(Icons.refresh_rounded, color: bcAmber, size: 22),
            tooltip: 'Reset all inputs',
          ),
        ],
      ),
    );
  }

  // ─── WORK TYPE SELECTOR ───────────────────────────────────────────────────────

  Widget _buildWorkTypeSelector() {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: CalculatorType.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final type = CalculatorType.values[index];
          final isSelected = _selectedType == type;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedType = type;
              // Bug fix: clear input controllers when switching type
              // Old dimensions from a different module should not carry over
              _lCtrl.clear(); _wCtrl.clear(); _tCtrl.clear();
              _errors        = {};
              _result        = null;
              _steelResult   = null;
              _hasCalculated = false;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 108,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? bcNavy : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? bcAmber : bcBorder, width: isSelected ? 2 : 1),
                boxShadow: isSelected
                    ? [BoxShadow(color: bcNavy.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(type.icon, color: isSelected ? bcAmber : bcNavy, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    type.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : bcNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── UNIT TOGGLE ─────────────────────────────────────────────────────────────

  Widget _buildUnitToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bcBorder),
      ),
      child: Row(
        children: [
          Expanded(child: _unitBtn(true, 'METERS', Icons.straighten_rounded)),
          Container(width: 1, height: 40, color: bcBorder),
          Expanded(child: _unitBtn(false, 'FEET / INCH', Icons.square_foot_rounded)),
        ],
      ),
    );
  }

  Widget _unitBtn(bool metric, String label, IconData icon) {
    final active = _isMetric == metric;
    return GestureDetector(
      onTap: () => setState(() {
        _isMetric = metric;
        _errors = {};
        _result = null;
        _steelResult = null;
        _hasCalculated = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? bcAmber : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: active ? bcNavy : bcTextSecondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: active ? bcNavy : bcTextSecondary, fontWeight: active ? FontWeight.w900 : FontWeight.w600, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ─── INPUTS ───────────────────────────────────────────────────────────────────

  Widget _buildInputs() {
    switch (_selectedType) {
      case CalculatorType.slab:
        return _buildSlabInputs();
      case CalculatorType.brick:
        return _buildBrickInputs();
      case CalculatorType.plaster:
        return _buildPlasterInputs();
      case CalculatorType.tile:
        return _buildTileInputs();
      case CalculatorType.area:
        return _buildAreaInputs();
    }
  }

  Widget _buildSlabInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1️⃣ Dimensions card
        CalculatorSectionCard(
          title: '1️⃣  Dimensions',
          icon: Icons.square_foot_rounded,
          children: [
            CalculatorInputField(
              controller: _lCtrl, label: 'Length',
              suffix: _isMetric ? 'm' : 'ft',
              onChanged: _onInputChanged, errorText: _err('length'),
            ),
            const SizedBox(height: 14),
            CalculatorInputField(
              controller: _wCtrl, label: 'Width',
              suffix: _isMetric ? 'm' : 'ft',
              onChanged: _onInputChanged, errorText: _err('width'),
            ),
            const SizedBox(height: 14),
            CalculatorInputField(
              controller: _tCtrl, label: 'Thickness',
              suffix: _isMetric ? 'm' : 'in', step: 0.05,
              onChanged: _onInputChanged, errorText: _err('thickness'),
              helperText: _isMetric ? 'e.g. 0.125 m = 5 inch' : 'e.g. 5 = 5 inch',
            ),
            const SizedBox(height: 14),
            // Quick thickness presets
            Row(children: [
              _thickPreset('4"', 0.1016, 4.0),
              const SizedBox(width: 8),
              _thickPreset('5"', 0.127, 5.0),
              const SizedBox(width: 8),
              _thickPreset('6"', 0.1524, 6.0),
            ]),
          ],
        ),
        // 2️⃣ Concrete Grade card
        CalculatorSectionCard(
          title: '2️⃣  Concrete Grade',
          icon: Icons.grade_rounded,
          children: [
            _buildToggleList(
              concreteGrades.map((g) => g.name).toList(),
              _selectedGrade?.name ?? '',
              (v) { final g = concreteGrades.firstWhere((g) => g.name == v); _onGradeChanged(g); },
              label: 'Select Mix Grade',
            ),
            if (_errors['grade'] != null) ...[  
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.error_outline_rounded, size: 13, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(_errors['grade']!, style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w600)),
              ]),
            ],
            // Show auto-filled ratio info for presets
            if (_selectedGrade != null && _selectedGrade!.name != 'Custom Mix Ratio') ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bcAmber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: bcAmber.withValues(alpha: 0.25)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: bcAmber),
                  const SizedBox(width: 8),
                  Text(
                    'Mix: Cement ${_selectedGrade!.cement.toStringAsFixed(0)} : Sand ${_selectedGrade!.sand.toStringAsFixed(1)} : Agg ${_selectedGrade!.aggregate.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: bcNavy, fontWeight: FontWeight.w700),
                  ),
                ]),
              ),
            ],
          ],
        ),
        // 3️⃣ Aggregate Size
        _buildAggSizeSelector(),
        // 4️⃣ Mix Ratio — only shown for Custom grade
        if (_selectedGrade?.name == 'Custom Mix Ratio') _buildMixRatioCard(),
        // 5️⃣ Steel
        _buildSteelSection(),
      ],
    );
  }

  Widget _buildBrickInputs() {
    // Brick info — show mm AND inch equivalents for site reference
    String brickInfoMm   = '';
    String brickInfoInch = '';
    if (_brickType == 'Standard (190mm)') {
      brickInfoMm   = '190 × 90 × 90 mm';
      brickInfoInch = '7.48" × 3.54" × 3.54"';
    } else if (_brickType == 'Fly Ash (230mm)') {
      brickInfoMm   = '230 × 110 × 70 mm';
      brickInfoInch = '9.06" × 4.33" × 2.76"';
    } else if (_brickType == 'AAC Block') {
      brickInfoMm   = '600 × 200 × 200 mm';
      brickInfoInch = '23.6" × 7.87" × 7.87"';
    }
    final bool showBrickInfo = brickInfoMm.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1️⃣ Wall Dimensions
        CalculatorSectionCard(
          title: '1️⃣  Wall Dimensions',
          icon: Icons.square_foot_rounded,
          children: [
            CalculatorInputField(
              controller: _lCtrl, label: 'Length',
              suffix: _isMetric ? 'm' : 'ft',
              onChanged: _onInputChanged, errorText: _err('length'),
            ),
            const SizedBox(height: 14),
            CalculatorInputField(
              controller: _wCtrl, label: 'Height',
              suffix: _isMetric ? 'm' : 'ft',
              onChanged: _onInputChanged, errorText: _err('width'),
            ),
            const SizedBox(height: 14),
            CalculatorInputField(
              controller: _tCtrl, label: 'Wall Thickness',
              suffix: _isMetric ? 'm' : 'in',
              step: 0.05,
              onChanged: _onInputChanged, errorText: _err('thickness'),
              helperText: _isMetric ? 'e.g. 0.23 m = 9 inch' : 'e.g. 4.5 = 4.5 inch',
            ),
            const SizedBox(height: 12),
            // Common wall thickness presets
            Wrap(spacing: 8, runSpacing: 8, children: [
              _presetBtn('4.5"', () => setState(() { _tCtrl.text = _isMetric ? '0.115' : '4.5'; _onInputChanged(); }), _tCtrl.text == (_isMetric ? '0.115' : '4.5')),
              _presetBtn('9"',   () => setState(() { _tCtrl.text = _isMetric ? '0.23'  : '9.0'; _onInputChanged(); }), _tCtrl.text == (_isMetric ? '0.23'  : '9.0')),
              _presetBtn('13.5"', () => setState(() { _tCtrl.text = _isMetric ? '0.345' : '13.5'; _onInputChanged(); }), _tCtrl.text == (_isMetric ? '0.345' : '13.5')),
            ]),
          ],
        ),

        // 2️⃣ Brick Type
        CalculatorSectionCard(
          title: '2️⃣  Brick / Block Type',
          icon: Icons.grid_view_rounded,
          children: [
            _buildToggleList(
              ['Standard (190mm)', 'Fly Ash (230mm)', 'AAC Block', 'Custom'],
              _brickType,
              (v) => setState(() { _brickType = v; _onInputChanged(); }),
            ),
            // Info badge for preset — shows mm and inch equivalents
            if (showBrickInfo) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bcAmber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: bcAmber.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.straighten_rounded, size: 14, color: bcAmber),
                      const SizedBox(width: 8),
                      Text(brickInfoMm, style: const TextStyle(fontSize: 12, color: bcNavy, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.swap_horiz_rounded, size: 14, color: bcTextSecondary),
                      const SizedBox(width: 8),
                      Text(brickInfoInch, style: const TextStyle(fontSize: 11, color: bcTextSecondary, fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
              ),
            ],
            // Custom brick dims — user enters INCHES; engine converts internally
            if (_brickType == 'Custom') ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(child: Text(
                    'Enter dimensions in inches. Converted to mm internally.\n'  
                    'Example: Standard = 7.48 × 3.54 × 3.54 inches',
                    style: TextStyle(fontSize: 10.5, color: Colors.blue, fontWeight: FontWeight.w600, height: 1.45),
                  )),
                ]),
              ),
              const SizedBox(height: 10),
              CalculatorInputField(
                controller: _brickLCtrl,
                label: 'Brick Length',
                suffix: 'inch',
                helperText: 'e.g. 7.48 (Standard) / 9.06 (Fly Ash)',
                onChanged: _onInputChanged,
              ),
              const SizedBox(height: 10),
              CalculatorInputField(
                controller: _brickWCtrl,
                label: 'Brick Width',
                suffix: 'inch',
                helperText: 'e.g. 3.54 (Standard) / 4.33 (Fly Ash)',
                onChanged: _onInputChanged,
              ),
              const SizedBox(height: 10),
              CalculatorInputField(
                controller: _brickHCtrl,
                label: 'Brick Height',
                suffix: 'inch',
                helperText: 'e.g. 3.54 (Standard) / 2.76 (Fly Ash)',
                onChanged: _onInputChanged,
              ),
            ],
          ],
        ),

        // 3️⃣ Mortar Ratio
        CalculatorSectionCard(
          title: '3️⃣  Mortar Mix Ratio',
          icon: Icons.blender_rounded,
          children: [
            _buildToggleList(
              ['1:3', '1:4', '1:5', '1:6'],
              _mortarRatio,
              (v) => setState(() { _mortarRatio = v; _onInputChanged(); }),
              label: 'Cement : Sand',
            ),
            const SizedBox(height: 8),
            const Row(children: [
              Icon(Icons.info_outline_rounded, size: 12, color: bcTextSecondary),
              SizedBox(width: 6),
              Expanded(child: Text('1:6 is standard for ordinary brick masonry (IS 2212)', style: TextStyle(fontSize: 10, color: bcTextSecondary, fontStyle: FontStyle.italic))),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildPlasterInputs() {
    final bool useCustomThick = _plasterThickCustom.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1️⃣ Surface Dimensions
        CalculatorSectionCard(
          title: '1️⃣  Surface Area',
          icon: Icons.straighten_rounded,
          children: [
            CalculatorInputField(
              controller: _lCtrl, label: 'Height / Length',
              suffix: _isMetric ? 'm' : 'ft',
              onChanged: _onInputChanged, errorText: _err('length'),
            ),
            const SizedBox(height: 14),
            CalculatorInputField(
              controller: _wCtrl, label: 'Width',
              suffix: _isMetric ? 'm' : 'ft',
              onChanged: _onInputChanged, errorText: _err('width'),
            ),
          ],
        ),
        // 2️⃣ Thickness & Mix
        CalculatorSectionCard(
          title: '2️⃣  Plaster Thickness & Mix',
          icon: Icons.layers_rounded,
          children: [
            _buildToggleList(
              ['12mm', '15mm', '20mm', 'Custom'],
              useCustomThick ? 'Custom' : _plasterThick,
              (v) => setState(() {
                if (v == 'Custom') {
                  _plasterThickCustom.text = '';
                } else {
                  _plasterThick = v;
                  _plasterThickCustom.clear();
                }
                _onInputChanged();
              }),
            ),
            if (useCustomThick || (_plasterThick == 'Custom')) ...[
              const SizedBox(height: 12),
              CalculatorInputField(
                controller: _plasterThickCustom,
                label: 'Custom Thickness',
                suffix: 'mm',
                helperText: 'e.g. 18  (common for rough surfaces)',
                onChanged: _onInputChanged,
                errorText: _err('plasterThick'),
              ),
            ],
            const SizedBox(height: 14),
            _buildToggleList(
              ['1:3', '1:4', '1:5', '1:6'],
              _plasterRatio,
              (v) => setState(() { _plasterRatio = v; _onInputChanged(); }),
              label: 'Mix Ratio (C:S)',
            ),
            const SizedBox(height: 8),
            const Row(children: [
              Icon(Icons.info_outline_rounded, size: 12, color: bcTextSecondary),
              SizedBox(width: 6),
              Expanded(child: Text('1:4 is standard for external plaster, 1:6 for internal', style: TextStyle(fontSize: 10, color: bcTextSecondary, fontStyle: FontStyle.italic))),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildTileInputs() {
    // Tile info badge for preset
    String tileInfo = '';
    if (_tileSize == '12"×12" (1×1 ft)') {
      tileInfo = '304.8 × 304.8 mm';
    } else if (_tileSize == '24"×24" (2×2 ft)') {
      tileInfo = '609.6 × 609.6 mm';
    } else if (_tileSize == '600×600 mm') {
      tileInfo = '600 × 600 mm';
    } else if (_tileSize == '300×300 mm') {
      tileInfo = '300 × 300 mm';
    } else if (_tileSize == '800×800 mm') {
      tileInfo = '800 × 800 mm';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1️⃣ Room Dimensions
        CalculatorSectionCard(
          title: '1️⃣  Room Dimensions',
          icon: Icons.aspect_ratio_rounded,
          children: [
            CalculatorInputField(
              controller: _lCtrl, label: 'Length',
              suffix: _isMetric ? 'm' : 'ft',
              onChanged: _onInputChanged, errorText: _err('length'),
            ),
            const SizedBox(height: 14),
            CalculatorInputField(
              controller: _wCtrl, label: 'Width',
              suffix: _isMetric ? 'm' : 'ft',
              onChanged: _onInputChanged, errorText: _err('width'),
            ),
          ],
        ),
        // 2️⃣ Tile Selection
        CalculatorSectionCard(
          title: '2️⃣  Tile Size & Preset',
          icon: Icons.grid_3x3_rounded,
          children: [
            _buildToggleList(
              ['12"×12" (1×1 ft)', '24"×24" (2×2 ft)', '600×600 mm', '300×300 mm', '800×800 mm', 'Custom'],
              _tileSize,
              (v) => setState(() { _tileSize = v; _onInputChanged(); }),
            ),
            if (tileInfo.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.grid_on_rounded, size: 14, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text('Size: $tileInfo', style: const TextStyle(fontSize: 12, color: bcNavy, fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
            // Custom tile: always in mm
            if (_tileSize == 'Custom') ...[
              const SizedBox(height: 12),
              const Row(children: [
                Icon(Icons.info_outline_rounded, size: 13, color: bcTextSecondary),
                SizedBox(width: 6),
                Text('Enter tile dimensions in mm', style: TextStyle(fontSize: 11, color: bcTextSecondary)),
              ]),
              const SizedBox(height: 10),
              CalculatorInputField(controller: _tileLCtrl, label: 'Tile Length', suffix: 'mm', onChanged: _onInputChanged),
              const SizedBox(height: 10),
              CalculatorInputField(controller: _tileWCtrl, label: 'Tile Width',  suffix: 'mm', onChanged: _onInputChanged),
            ],
          ],
        ),
        // 3️⃣ Fixing Method
        CalculatorSectionCard(
          title: '3️⃣  Fixing Method',
          icon: Icons.hardware_rounded,
          children: [
            _buildToggleList(
              ['Adhesive', 'Cement Mortar'],
              _useAdhesive ? 'Adhesive' : 'Cement Mortar',
              (v) => setState(() { _useAdhesive = v == 'Adhesive'; _onInputChanged(); }),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _useAdhesive ? Colors.blueAccent.withValues(alpha: 0.06) : Colors.orangeAccent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: (_useAdhesive ? Colors.blueAccent : Colors.orangeAccent).withValues(alpha: 0.25)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(_useAdhesive ? Icons.info_outline_rounded : Icons.layers_rounded, size: 13, color: _useAdhesive ? Colors.blueAccent : Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    _useAdhesive
                        ? 'Coverage: 1 bag (20 kg) = 45 sq ft'
                        : 'Cement mortar bed — 12mm thick',
                    style: TextStyle(
                      fontSize: 11,
                      color: _useAdhesive ? Colors.blue.shade700 : Colors.orange.shade800,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAreaInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CalculatorSectionCard(
          title: 'Dimensions',
          icon: Icons.straighten_rounded,
          children: [
            CalculatorInputField(controller: _lCtrl, label: 'Length', suffix: _isMetric ? 'm' : 'ft', onChanged: _onInputChanged, errorText: _err('length')),
            const SizedBox(height: 14),
            CalculatorInputField(controller: _wCtrl, label: 'Width', suffix: _isMetric ? 'm' : 'ft', onChanged: _onInputChanged, errorText: _err('width')),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => setState(() {
              final l = double.tryParse(_lCtrl.text) ?? 0;
              final w = double.tryParse(_wCtrl.text) ?? 0;
              _areaTotal += (l * w);
              _lCtrl.clear(); _wCtrl.clear();
              _onInputChanged();
            }),
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('ADD TO TOTAL AREA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: bcAmber, foregroundColor: bcNavy,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
        ),
        if (_areaTotal > 0) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => setState(() { _areaTotal = 0; _onInputChanged(); }),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('RESET TOTAL'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }

  // ─── STEEL SECTION ─────────────────────────────────────────────────────────

  Widget _buildSteelSection() {
    return CalculatorSectionCard(
      title: 'Steel Calculation',
      icon: Icons.hardware_rounded,
      accentColor: Colors.lightBlueAccent,
      children: [
        // Toggle switch
        Row(
          children: [
            const Expanded(child: Text('Include Rebar Estimation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: bcNavy))),
            Switch(
              value: _showSteel,
              thumbColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? bcAmber : Colors.white,
              ),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? bcAmber.withValues(alpha: 0.4) : Colors.grey.shade300,
              ),
              onChanged: (v) => setState(() { _showSteel = v; _runCalculation(); }),
            ),
          ],
        ),
        if (_showSteel) ...[
          const SizedBox(height: 14),
          // Bar Diameter
          const Text('BAR DIAMETER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: bcTextSecondary, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Row(
            children: rebarDiameters.map((d) {
              final selected = _steelDiameterMm == d;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() { _steelDiameterMm = d; _runCalculation(); }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? bcAmber : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? bcAmber : bcBorder),
                      boxShadow: selected ? [BoxShadow(color: bcAmber.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
                    ),
                    child: Text(
                      '${d.toInt()}mm',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: selected ? bcNavy : bcTextPrimary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Spacing
          const Text('C/C SPACING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: bcTextSecondary, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Row(
            children: rebarSpacingsMm.map((s) {
              final selected = _steelSpacingMm == s;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() { _steelSpacingMm = s; _runCalculation(); }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? Colors.lightBlueAccent : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? Colors.lightBlueAccent : bcBorder),
                      boxShadow: selected ? [BoxShadow(color: Colors.lightBlueAccent.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
                    ),
                    child: Text(
                      '${s.toInt()}mm',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: selected ? Colors.white : bcTextPrimary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 12, color: bcTextSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Slab area auto-used from dimensions above  •  W = D²/162 × L',
                  style: const TextStyle(fontSize: 10, color: bcTextSecondary, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ─── CALCULATE BUTTON ────────────────────────────────────────────────────────

  Widget _buildCalculateButton() {
    final canCalc = _canCalculate;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: canCalc
            ? [BoxShadow(color: bcNavy.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: canCalc ? _calculate : null,
        icon: Icon(Icons.calculate_rounded, size: 22, color: canCalc ? bcAmber : Colors.white38),
        label: Text(
          canCalc ? 'CALCULATE' : 'FILL ALL REQUIRED FIELDS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: canCalc ? 15 : 13,
            letterSpacing: 1,
            color: canCalc ? bcAmber : Colors.white38,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canCalc ? bcNavy : const Color(0xFFCBD5E1),
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  // ─── AGG SIZE ─────────────────────────────────────────────────────────────────

  Widget _buildAggSizeSelector() {
    return CalculatorSectionCard(
      title: '3️⃣  Aggregate Size',
      icon: Icons.grain_rounded,
      children: [
        Row(
          children: aggFactorMap.keys.map((size) {
            final isSelected = _aggSize == size;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _aggSize = size;
                  _hasCalculated = false;
                  _result = null;
                  _steelResult = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? bcAmber : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? bcAmber : bcBorder),
                  ),
                  child: Text(size, textAlign: TextAlign.center,
                    style: TextStyle(color: isSelected ? bcNavy : bcTextPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            );
          }).toList(),
        ),
        if (_errors['aggsize'] != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.error_outline_rounded, size: 13, color: Colors.redAccent),
            const SizedBox(width: 4),
            Text(_errors['aggsize']!, style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ]),
        ],
        const SizedBox(height: 10),
        const Row(children: [
          Icon(Icons.info_outline_rounded, size: 12, color: bcTextSecondary),
          SizedBox(width: 6),
          Expanded(child: Text('Aggregate size affects dry-mix factor', style: TextStyle(fontSize: 10, color: bcTextSecondary, fontStyle: FontStyle.italic))),
        ]),
      ],
    );
  }

  Widget _buildMixRatioCard({bool isPlaster = false}) {
    return CalculatorSectionCard(
      title: '4️⃣  Mix Ratio (Cement : Sand${isPlaster ? '' : ' : Agg.'})',
      icon: Icons.blender_rounded,
      children: [
        CalculatorInputField(controller: _cementRatio, label: 'Cement Parts', step: 0.5, onChanged: _onInputChanged, errorText: _err('cement')),
        const SizedBox(height: 12),
        CalculatorInputField(controller: _sandRatio, label: 'Sand Parts', step: 0.5, onChanged: _onInputChanged, errorText: _err('sand')),
        if (!isPlaster) ...[
          const SizedBox(height: 12),
          CalculatorInputField(controller: _aggregateRatio, label: 'Aggregate Parts', step: 0.5, onChanged: _onInputChanged, errorText: _err('agg')),
        ],
      ],
    );
  }

  Widget _buildToggleList(List<String> options, String current, Function(String) onSelect, {String? label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: bcTextSecondary, letterSpacing: 1.2)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = current == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? bcAmber : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? bcAmber : bcBorder),
                ),
                child: Text(opt, style: TextStyle(color: isSelected ? bcNavy : bcTextPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _presetBtn(String label, VoidCallback onTap, bool active) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? bcAmber : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? bcAmber : bcBorder),
        ),
        child: Text(label, style: TextStyle(color: active ? bcNavy : bcTextPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _thickPreset(String label, double metricVal, double imperialVal) {
    final active = _isMetric
        ? (double.tryParse(_tCtrl.text) == metricVal)
        : (double.tryParse(_tCtrl.text) == imperialVal);
    return _presetBtn(label, () => setState(() {
      _tCtrl.text = (_isMetric ? metricVal : imperialVal).toString();
      _onInputChanged(); // clear results so user must recalculate
    }), active);
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const Icon(Icons.bug_report_outlined, size: 12, color: Colors.white38),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w600)),
          ]),
          Text(value, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ─── RESULT PANEL ─────────────────────────────────────────────────────────────

  Widget _buildResultPanel() {
    final nf = NumberFormat('#,##0.##');
    String title = 'RESULT';
    List<Widget> items = [];
    List<Map<String, dynamic>> materialsForStock = [];

    if (_result is CalculationResult) {
      final r = _result as CalculationResult;
      title = '${_selectedType.label.toUpperCase()} ESTIMATE';
      items = [
        ResultIconItem(
          icon: Icons.square_foot_rounded,
          label: r.primaryLabel,
          value: '${nf.format(r.primaryValue)} ${r.primaryUnit}',
        ),
        const Divider(color: Colors.white10),
        ResultIconItem(icon: Icons.layers_rounded,  label: 'Cement',    value: '${nf.format(r.cementBags)} Bags', subValue: '50 kg/bag', isMain: true, color: bcAmber),
        ResultIconItem(icon: Icons.gradient_rounded, label: 'Sand',      value: '${nf.format(r.sandCFT)} CFT',   subValue: '≈ ${nf.format(r.sandTon)} Tons', isMain: true, color: Colors.lightBlueAccent),
      ];
      materialsForStock.add({'name': 'Cement', 'qty': r.cementBags, 'unit': 'bags'});
      materialsForStock.add({'name': 'Sand',   'qty': r.sandTon,    'unit': 'tons'});
      if (r.aggregateCFT != null) {
        items.add(ResultIconItem(icon: Icons.grain_rounded, label: 'Aggregate', value: '${nf.format(r.aggregateCFT!)} CFT', subValue: '≈ ${nf.format(r.aggregateTon!)} Tons', isMain: true, color: Colors.orangeAccent));
        materialsForStock.add({'name': 'Aggregate', 'qty': r.aggregateTon!, 'unit': 'tons'});
      }
      // 🔍 Debug panel rows (shown only when _showDebug is on)
      if (_showDebug) {
        items.addAll([
          const Divider(color: Colors.white10),
          _debugRow('Wet Volume',  '${nf.format(r.wetVolumeCFT)} CFT'),
          _debugRow('Dry Volume',  '${nf.format(r.dryVolumeCFT)} CFT  (incl. wastage)'),
        ]);
        if (_steelResult != null) {
          items.add(_debugRow('Total Steel Length', '${nf.format(_steelResult!.totalLengthM)} m'));
        }
      }
    } else if (_result is BrickCalculationResult) {
      final r = _result as BrickCalculationResult;
      title = 'BRICK WORK ESTIMATE';
      items = [
        ResultIconItem(icon: Icons.grid_view_rounded, label: 'Brick Count', value: '${nf.format(r.brickCount)} Pcs', isMain: true, color: Colors.deepOrangeAccent),
        const Divider(color: Colors.white10),
        ResultIconItem(icon: Icons.layers_rounded, label: 'Cement', value: '${nf.format(r.cementBags)} Bags', subValue: '50kg Bags', color: bcAmber),
        ResultIconItem(icon: Icons.gradient_rounded, label: 'Sand', value: '${nf.format(r.sandCFT)} CFT', subValue: '≈ ${nf.format(r.sandTon)} Tons', color: Colors.lightBlueAccent),
      ];
      materialsForStock.add({'name': 'Bricks', 'qty': r.brickCount.toDouble(), 'unit': 'pcs'});
      materialsForStock.add({'name': 'Cement', 'qty': r.cementBags, 'unit': 'bags'});
    } else if (_result is TileCalculationResult) {
      final r = _result as TileCalculationResult;
      title = 'TILE ESTIMATE';
      items = [ResultIconItem(icon: Icons.dashboard_rounded, label: 'Total Tiles', value: '${nf.format(r.tileCount)} Pcs', isMain: true, color: Colors.tealAccent), const Divider(color: Colors.white10)];
      if (r.adhesiveBags > 0) {
        items.add(ResultIconItem(icon: Icons.hardware_rounded, label: 'Adhesive', value: '${nf.format(r.adhesiveBags)} Bags', subValue: '20kg Bags', color: bcAmber));
        materialsForStock.add({'name': 'Adhesive', 'qty': r.adhesiveBags, 'unit': 'bags'});
      }
      if (r.cementBags > 0) {
        items.addAll([
          ResultIconItem(icon: Icons.layers_rounded, label: 'Cement', value: '${nf.format(r.cementBags)} Bags', color: bcAmber),
          ResultIconItem(icon: Icons.gradient_rounded, label: 'Sand', value: '${nf.format(r.sandCFT)} CFT', color: Colors.lightBlueAccent),
        ]);
        materialsForStock.add({'name': 'Cement', 'qty': r.cementBags, 'unit': 'bags'});
      }
      materialsForStock.add({'name': 'Tiles', 'qty': r.tileCount.toDouble(), 'unit': 'pcs'});
    } else if (_result is double) {
      final r = _result as double;
      title = 'AREA RESULT';
      items = [
        ResultIconItem(icon: Icons.square_foot_rounded, label: 'Current Area', value: '${nf.format(r)} ${_isMetric ? 'm²' : 'ft²'}', isMain: true, color: bcAmber),
        if (_areaTotal > 0) ...[
          const Divider(color: Colors.white10),
          ResultIconItem(icon: Icons.functions_rounded, label: 'Total Accumulated', value: '${nf.format(_areaTotal)} ${_isMetric ? 'm²' : 'ft²'}', subValue: 'Running Total', isMain: true, color: Colors.greenAccent),
        ],
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: bcNavy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.bar_chart_rounded, size: 16, color: bcAmber),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(color: bcAmber, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.1)),
                ]),
                Row(children: [
                  if (_result != null && _result is! double)
                    Text('${nf.format(double.tryParse(_wastageCtrl.text) ?? 5)}% wastage', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  // Debug toggle (slab only)
                  if (_result is CalculationResult) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showDebug = !_showDebug),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _showDebug ? bcAmber.withValues(alpha: 0.15) : Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _showDebug ? bcAmber.withValues(alpha: 0.4) : Colors.white24),
                        ),
                        child: Text('DEBUG', style: TextStyle(color: _showDebug ? bcAmber : Colors.white38, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...items,
                if (materialsForStock.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildStockIntegrationCard(materialsForStock),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _saveToHistory,
                    icon: const Icon(Icons.history_rounded, size: 16),
                    label: const Text('SAVE TO HISTORY', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockIntegrationCard(List<Map<String, dynamic>> materials) {
    return PremiumActionCard(
      title: 'Use this Calculation',
      subtitle: 'Apply ${materials.length} materials to stock',
      icon: Icons.inventory_2_rounded,
      color: bcAmber,
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: bcNavy,
            title: const Text('Confirm Application', style: TextStyle(color: bcAmber, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: materials.map((m) => ListTile(
                dense: true,
                title: Text(m['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                trailing: Text('${(m['qty'] as double).toStringAsFixed(2)} ${m['unit']}', style: const TextStyle(color: bcAmber, fontWeight: FontWeight.w900)),
              )).toList(),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.stockOperations,
                    arguments: {'quantity': materials[0]['qty'], 'purpose': 'Auto-calc: ${_selectedType.label}'});
                },
                style: ElevatedButton.styleFrom(backgroundColor: bcAmber, foregroundColor: bcNavy),
                child: const Text('APPLY STOCK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveToHistory() {
    final nf = NumberFormat('#,##0.##');
    String resultString = 'Calculation Saved';
    if (_result is CalculationResult) {
      resultString = '${nf.format((_result as CalculationResult).cementBags)} Bags Cement';
    } else if (_result is BrickCalculationResult) {
      resultString = '${nf.format((_result as BrickCalculationResult).brickCount)} Bricks';
    } else if (_result is TileCalculationResult) {
      resultString = '${nf.format((_result as TileCalculationResult).tileCount)} Tiles';
    } else if (_result is double) {
      resultString = '${nf.format(_result)} Area';
    }

    context.read<CalculationRepository>().saveCalculation(
      title: _selectedType.label,
      category: 'CIVIL',
      totalCost: 0,
      data: {
        'Type': _selectedType.label,
        'Dimensions': '${_lCtrl.text}x${_wCtrl.text}${_selectedType == CalculatorType.area ? '' : 'x${_tCtrl.text}'} (${_isMetric ? 'm' : 'ft'})',
        'Summary': resultString,
        'Timestamp': DateTime.now().toIso8601String(),
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to history ✓')));
  }
}
