/// Core engineering logic for Indian construction calculations.
///
/// Formula reference: IS 456:2000 and standard site practice.
class CalculationEngine {
  // ─── UNIT CONVERSIONS ────────────────────────────────────────────────────────
  static const double meterToFeet      = 3.28084;
  static const double feetToMeter      = 1 / meterToFeet;  // 0.3048
  static const double inchToMeter      = 0.0254;
  static const double m3ToCFT          = 35.3147;

  // ─── CONCRETE / MORTAR CONSTANTS ─────────────────────────────────────────────
  static const double mortarDryFactor  = 1.33;
  /// 1 bag cement (50 kg) = 0.035 m³  (IS standard — not 0.03540)
  static const double cementBagVolM3   = 0.035;

  // ─── MATERIAL DENSITIES ──────────────────────────────────────────────────────
  static const double sandDensityKgM3  = 1600; // kg/m³
  static const double aggDensityKgM3   = 1500; // kg/m³
  static const double kgToTon          = 0.001;

  // ─── AGGREGATE DRY-FACTOR MAP (IS) ──────────────────────────────────────────
  // 10mm→1.60  20mm→1.54  25mm→1.52  40mm→1.50
  static const Map<String, double> aggDryFactors = {
    '10mm': 1.60,
    '20mm': 1.54,
    '25mm': 1.52,
    '40mm': 1.50,
  };
  static double dryFactorForSize(String size) => aggDryFactors[size] ?? 1.54;

  // ─── STEEL CONSTANTS ─────────────────────────────────────────────────────────
  /// Standard rod = 12 m (Indian site practice)
  static const double standardRodLengthM = 12.0;
  /// Steel cutting wastage (IS site practice)
  static const double steelWastage = 1.05;

  // ═══════════════════════════════════════════════════════════════════════════════
  //  CONCRETE / SLAB CALCULATION
  // ═══════════════════════════════════════════════════════════════════════════════
  //
  //  IS Formula:
  //    Wet Volume  = L × W × T        (all in metres)
  //    Dry Volume  = Wet Volume × dryFactor
  //    Dry w/WTG   = Dry Volume × (1 + wastage%)   ← wastage applied on DRY
  //    CementVol   = DryWTG × (C / totalParts)
  //    Bags        = CementVol / 0.035 m³
  //    SandCFT     = SandVol × 35.3147
  //    AggCFT      = AggVol  × 35.3147
  //
  static CalculationResult calculateConcrete({
    required double length,
    required double width,
    required double height,       // metres (metric) OR inches (imperial)
    required double cementRatio,
    required double sandRatio,
    required double aggregateRatio,
    double quantity       = 1,
    double wastagePercent = 5,
    bool   isMetric       = true,
    double dryVolumeFactor = 1.54,
  }) {
    // Step 1 ── Convert all inputs to metres ─────────────────────────────────
    final double lM = isMetric ? length : length * feetToMeter;
    final double wM = isMetric ? width  : width  * feetToMeter;
    // Thickness: metric → metres already; imperial → UI sends inches
    final double tM = isMetric ? height : height * inchToMeter;

    // Step 2 ── Wet Volume (m³) ──────────────────────────────────────────────
    final double wetVol = lM * wM * tM * quantity;

    // Step 3 ── Dry Volume (multiply by agg-size factor, NOT including wastage) ─
    final double dryVol = wetVol * dryVolumeFactor;

    // Step 4 ── Apply 5% (+user wastage) on Dry Volume ───────────────────────
    final double dryVolW = dryVol * (1 + wastagePercent / 100);

    // Step 5 ── Split by mix ratio ────────────────────────────────────────────
    final double totalParts = cementRatio + sandRatio + aggregateRatio;
    final double cVol = (totalParts > 0) ? (cementRatio    / totalParts) * dryVolW : 0;
    final double sVol = (totalParts > 0) ? (sandRatio      / totalParts) * dryVolW : 0;
    final double aVol = (totalParts > 0) ? (aggregateRatio / totalParts) * dryVolW : 0;

    return CalculationResult(
      primaryLabel:   'Concrete Volume',
      primaryValue:   wetVol,
      primaryUnit:    'm³',
      wetVolumeCFT:   wetVol  * m3ToCFT,
      dryVolumeCFT:   dryVolW * m3ToCFT,
      cementBags:     cVol / cementBagVolM3,
      sandCFT:        sVol * m3ToCFT,
      sandTon:        sVol * sandDensityKgM3 * kgToTon,
      aggregateCFT:   aVol * m3ToCFT,
      aggregateTon:   aVol * aggDensityKgM3  * kgToTon,
      wastagePercent: wastagePercent,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  //  BRICK WORK CALCULATION  (IS site formula)
  // ═══════════════════════════════════════════════════════════════════════════════
  //
  //  BrickVolume      = L × W × H                        (brick dims in metres)
  //  EffectiveBrickVol = BrickVolume × 1.33              (mortar allowance factor)
  //  BricksPerM³      = 1 / EffectiveBrickVol
  //  BrickCount       = WallVolume × BricksPerM³ × 1.05  (+5% wastage)
  //
  //  Mortar volume    = WallVolume × 0.30               (30% of wall is mortar)
  //  Dry mortar vol   = MortarVol × 1.33
  //  Cement           = DryVol × [1 / (1+sandParts)]
  //  Sand             = DryVol × [sandParts / (1+sandParts)]
  //
  static BrickCalculationResult calculateBricks({
    required double wallL,
    required double wallH,
    required double wallT,
    required double brickL,       // metres
    required double brickW,       // metres
    required double brickH,       // metres
    required double mortarRatio,  // 1:X → pass X  (e.g. 6 for 1:6)
    double wastagePercent = 5,
    bool   isMetric       = true,
  }) {
    // ── Wall volume in m³ ──────────────────────────────────────────────────
    final double l = isMetric ? wallL : wallL * feetToMeter;
    final double h = isMetric ? wallH : wallH * feetToMeter;
    final double t = isMetric ? wallT : wallT * inchToMeter;  // thickness in inches → m
    final double wallVol = l * h * t;

    // ── Brick count (IS effective-volume method) ───────────────────────────
    final double brickVol         = brickL * brickW * brickH;        // pure brick m³
    final double effectiveBrickVol = brickVol * 1.33;                 // with mortar allowance
    final double bricksPerM3      = 1.0 / effectiveBrickVol;
    final int    brickCount       = (wallVol * bricksPerM3 * (1 + wastagePercent / 100)).ceil();

    // ── Mortar calculation ─────────────────────────────────────────────────
    final double mortarWetVol  = wallVol * 0.30;          // 30 % of wall volume
    final double mortarDryVol  = mortarWetVol * 1.33;     // dry volume factor
    final double totalParts    = 1 + mortarRatio;          // cement(1) + sand
    final double cVol          = (1 / totalParts)           * mortarDryVol;
    final double sVol          = (mortarRatio / totalParts) * mortarDryVol;

    return BrickCalculationResult(
      brickCount:     brickCount,
      wallVolume:     wallVol,
      cementBags:     cVol / cementBagVolM3,
      sandCFT:        sVol * m3ToCFT,
      sandTon:        sVol * sandDensityKgM3 * kgToTon,
      wastagePercent: wastagePercent,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  //  PLASTER CALCULATION  (IS site formula)
  // ═══════════════════════════════════════════════════════════════════════════════
  //
  //  WetVolume  = Area × Thickness(m)
  //  DryVolume  = WetVolume × 1.33
  //  DryVolWTG  = DryVolume × (1 + wastage%)    ← wastage on dry
  //  Cement     = DryVolWTG × [1 / totalParts]  → ÷ 0.035 = bags
  //  Sand       = DryVolWTG × [sandParts / totalParts] → × 35.3147 = CFT
  //
  static CalculationResult calculatePlaster({
    required double areaL,        // length (m or ft)
    required double areaW,        // width  (m or ft)
    required double thicknessMm,  // thickness in mm always
    required double mortarRatio,  // 1:X → pass X
    double wastagePercent = 15,
    bool   isMetric       = true,
  }) {
    final double lM  = isMetric ? areaL : areaL * feetToMeter;
    final double wM  = isMetric ? areaW : areaW * feetToMeter;
    final double realArea   = lM * wM;
    final double thicknessM = thicknessMm / 1000;
    final double wetVol     = realArea * thicknessM;
    final double dryVol     = wetVol * mortarDryFactor;                       // × 1.33
    final double dryVolW    = dryVol * (1 + wastagePercent / 100);            // + wastage

    final double totalParts = 1 + mortarRatio;
    final double cVol = (1 / totalParts)           * dryVolW;
    final double sVol = (mortarRatio / totalParts) * dryVolW;

    return CalculationResult(
      primaryLabel:   'Plaster Area',
      primaryValue:   realArea,
      primaryUnit:    'm²',
      wetVolumeCFT:   wetVol  * m3ToCFT,
      dryVolumeCFT:   dryVolW * m3ToCFT,
      cementBags:     cVol / cementBagVolM3,
      sandCFT:        sVol * m3ToCFT,
      sandTon:        sVol * sandDensityKgM3 * kgToTon,
      wastagePercent: wastagePercent,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  //  TILE CALCULATION
  // ═══════════════════════════════════════════════════════════════════════════════
  static TileCalculationResult calculateTiles({
    required double areaL,
    required double areaW,
    required double tileL,         // in metres
    required double tileW,         // in metres
    double wastagePercent     = 5,
    bool   isMetric           = true,
    bool   useAdhesive        = true,
    double mortarThicknessMm  = 12,
    double mortarRatio        = 4,
  }) {
    final double l = isMetric ? areaL : areaL * feetToMeter;
    final double w = isMetric ? areaW : areaW * feetToMeter;
    final double surfaceArea = l * w;

    final double tileArea  = tileL * tileW;
    final int count        = (tileArea > 0) ? (surfaceArea / tileArea).ceil() : 0;
    final int totalTiles   = (count * (1 + wastagePercent / 100)).ceil();

    double adhesiveBags = 0, cementBags = 0, sandCFT = 0, sandTon = 0;

    if (useAdhesive) {
      // 1 bag (20 kg) covers 45 sqft (IS site standard)
      final double sqFt = surfaceArea * 10.7639; // m² → sqft
      adhesiveBags = sqFt / 45.0;
    } else {
      final double bedVol    = surfaceArea * (mortarThicknessMm / 1000);
      final double dryVol    = bedVol * mortarDryFactor;
      final double totalR    = 1 + mortarRatio;
      final double cVol      = (1 / totalR) * dryVol;
      final double sVol      = (mortarRatio / totalR) * dryVol;
      cementBags = cVol / cementBagVolM3;
      sandCFT    = sVol * m3ToCFT;
      sandTon    = sVol * sandDensityKgM3 * kgToTon;
    }

    return TileCalculationResult(
      tileCount:      totalTiles,
      surfaceArea:    surfaceArea,
      adhesiveBags:   adhesiveBags,
      cementBags:     cementBags,
      sandCFT:        sandCFT,
      sandTon:        sandTon,
      wastagePercent: wastagePercent,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  //  STEEL (REBAR) CALCULATION  — IS 456:2000 site formula
  // ═══════════════════════════════════════════════════════════════════════════════
  //
  //  BarsAlongLength = (slabWidth  / spacing) + 1   → run along slab length
  //  BarsAlongWidth  = (slabLength / spacing) + 1   → run along slab width
  //  TotalLength     = (BarsAlongLength × slabLength) + (BarsAlongWidth × slabWidth)
  //  Weight          = (D² / 162) × TotalLength           (D in mm, L in m → kg)
  //  FinalWeight     = Weight × 1.05  (5 % cutting wastage)
  //  Rods            = ceil(TotalLength / 12 m)
  //
  static SteelCalculationResult calculateSteel({
    required double slabLengthM,
    required double slabWidthM,
    required double diameterMm,
    required double spacingMm,
    double coverMm = 25,
  }) {
    final double spacingM = spacingMm / 1000;

    // Number of bars in each direction (IS simple count — no cover reduction for estimation)
    final int mainBars = (spacingM > 0) ? (slabWidthM  / spacingM).ceil() + 1 : 0;
    final int distBars = (spacingM > 0) ? (slabLengthM / spacingM).ceil() + 1 : 0;

    final double totalMainLengthM = mainBars * slabLengthM;
    final double totalDistLengthM = distBars * slabWidthM;
    final double totalLengthM     = totalMainLengthM + totalDistLengthM;

    // IS weight formula: W = (D² / 162) × L
    final double weightRaw  = (diameterMm * diameterMm / 162.0) * totalLengthM;
    final double totalWeight = weightRaw * steelWastage; // +5% cutting wastage

    final int rodsRequired = (totalLengthM / standardRodLengthM).ceil();

    return SteelCalculationResult(
      mainBars:          mainBars,
      distributionBars:  distBars,
      totalMainLengthM:  totalMainLengthM,
      totalDistLengthM:  totalDistLengthM,
      totalLengthM:      totalLengthM,
      weightPerMeterKg:  diameterMm * diameterMm / 162.0,
      totalWeightKg:     totalWeight,
      rodsRequired:      rodsRequired,
      diameterMm:        diameterMm,
      spacingMm:         spacingMm,
    );
  }
}

// ─── RESULT MODELS ────────────────────────────────────────────────────────────

class CalculationResult {
  final String primaryLabel;
  final double primaryValue;
  final String primaryUnit;
  /// Wet volume in CFT (before dry factor) — for debug panel
  final double wetVolumeCFT;
  /// Dry volume in CFT (after dry factor + wastage) — for debug panel
  final double dryVolumeCFT;
  final double cementBags;
  final double sandCFT;
  final double sandTon;
  final double? aggregateCFT;
  final double? aggregateTon;
  final double wastagePercent;

  CalculationResult({
    required this.primaryLabel,
    required this.primaryValue,
    required this.primaryUnit,
    this.wetVolumeCFT  = 0,
    this.dryVolumeCFT  = 0,
    required this.cementBags,
    required this.sandCFT,
    required this.sandTon,
    this.aggregateCFT,
    this.aggregateTon,
    required this.wastagePercent,
  });
}

class BrickCalculationResult {
  final int    brickCount;
  final double wallVolume;
  final double cementBags;
  final double sandCFT;
  final double sandTon;
  final double wastagePercent;

  BrickCalculationResult({
    required this.brickCount,
    required this.wallVolume,
    required this.cementBags,
    required this.sandCFT,
    required this.sandTon,
    required this.wastagePercent,
  });
}

class TileCalculationResult {
  final int    tileCount;
  final double surfaceArea;
  final double adhesiveBags;
  final double cementBags;
  final double sandCFT;
  final double sandTon;
  final double wastagePercent;

  TileCalculationResult({
    required this.tileCount,
    required this.surfaceArea,
    required this.adhesiveBags,
    required this.cementBags,
    required this.sandCFT,
    required this.sandTon,
    required this.wastagePercent,
  });
}

class SteelCalculationResult {
  final int    mainBars;
  final int    distributionBars;
  final double totalMainLengthM;
  final double totalDistLengthM;
  final double totalLengthM;
  final double weightPerMeterKg;
  final double totalWeightKg;
  final int    rodsRequired;
  final double diameterMm;
  final double spacingMm;

  SteelCalculationResult({
    required this.mainBars,
    required this.distributionBars,
    required this.totalMainLengthM,
    required this.totalDistLengthM,
    required this.totalLengthM,
    required this.weightPerMeterKg,
    required this.totalWeightKg,
    required this.rodsRequired,
    required this.diameterMm,
    required this.spacingMm,
  });
}
