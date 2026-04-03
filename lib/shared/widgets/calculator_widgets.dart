import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:intl/intl.dart';

/// A premium, user-friendly input specifically for calculators.
/// Includes increment/decrement buttons, validation state, and error display.
class CalculatorInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final double step;
  final VoidCallback? onChanged;
  final String? errorText;
  final String? helperText;

  const CalculatorInputField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix = '',
    this.step = 1.0,
    this.onChanged,
    this.errorText,
    this.helperText,
  });

  void _adjust(double delta) {
    final val = double.tryParse(controller.text) ?? 0.0;
    final newValue = (val + delta).clamp(0.0, double.infinity);
    // Format to 3 decimal places to avoid floating point noise
    controller.text = newValue.toStringAsFixed(newValue.truncateToDouble() == newValue ? 0 : 3);
    if (onChanged != null) onChanged!();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError ? Colors.redAccent : bcBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: hasError ? Colors.redAccent : bcTextSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: hasError ? Colors.red.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: hasError ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ? Colors.redAccent.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildAdjustBtn(Icons.remove_rounded, () => _adjust(-step)),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => onChanged?.call(),
                  decoration: InputDecoration(
                    suffixText: suffix,
                    suffixStyle: const TextStyle(
                      color: bcTextSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: hasError ? Colors.redAccent : bcNavy,
                  ),
                ),
              ),
              _buildAdjustBtn(Icons.add_rounded, () => _adjust(step)),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 5),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 12, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(
                  errorText!,
                  style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        else if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 5),
            child: Text(
              helperText!,
              style: const TextStyle(fontSize: 11, color: bcTextSecondary),
            ),
          ),
      ],
    );
  }

  Widget _buildAdjustBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, size: 20, color: bcAmber),
        ),
      ),
    );
  }
}

/// A grouping card for calculator inputs.
class CalculatorSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? accentColor;

  const CalculatorSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? bcAmber;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bcBorder.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: bcNavy.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: bcSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: bcBorder.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: bcNavy,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// A visual result item with an icon.
class ResultIconItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final bool isMain;
  final Color? color;

  const ResultIconItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    this.isMain = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? (isMain ? bcAmber : Colors.white);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: activeColor.withValues(alpha: 0.9)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: activeColor.withValues(alpha: 0.65),
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMain ? 19 : 15,
                    fontWeight: FontWeight.w900,
                    color: activeColor,
                  ),
                ),
                if (subValue != null)
                  Text(
                    subValue!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: activeColor.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Steel / Rebar result card with direction breakdown
class SteelResultCard extends StatelessWidget {
  final int mainBars;
  final int distBars;
  final double totalWeightKg;
  final int rodsRequired;
  final double totalMainLengthM;
  final double totalDistLengthM;
  final double diameterMm;
  final double spacingMm;

  const SteelResultCard({
    super.key,
    required this.mainBars,
    required this.distBars,
    required this.totalWeightKg,
    required this.rodsRequired,
    required this.totalMainLengthM,
    required this.totalDistLengthM,
    required this.diameterMm,
    required this.spacingMm,
  });

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0.##');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2340), Color(0xFF0D1525)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2340).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.hardware_rounded, size: 18, color: Color(0xFFFFB300)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STEEL ESTIMATE',
                      style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
                    ),
                    Text(
                      'Ø${nf.format(diameterMm)}mm @ ${nf.format(spacingMm)}mm c/c',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Summary pills
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Expanded(child: _summaryPill('TOTAL WEIGHT', '${nf.format(totalWeightKg)} kg', const Color(0xFFFFB300), Icons.monitor_weight_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _summaryPill('RODS (40 ft)', '$rodsRequired rods', Colors.lightGreenAccent, Icons.linear_scale_rounded)),
              ],
            ),
          ),
          // Direction breakdown
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                _directionRow(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Main Bars (→ along Length)',
                  bars: mainBars,
                  lengthM: totalMainLengthM,
                  color: Colors.lightBlueAccent,
                ),
                const SizedBox(height: 10),
                _directionRow(
                  icon: Icons.swap_vert_rounded,
                  label: 'Dist. Bars (↑ along Width)',
                  bars: distBars,
                  lengthM: totalDistLengthM,
                  color: Colors.purpleAccent,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10),
                ),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 12, color: Colors.white38),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Weight = (D² / 162) × L(m)  •  Standard rod = 40 ft (12.19 m)',
                        style: const TextStyle(fontSize: 10, color: Colors.white38, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color.withValues(alpha: 0.7), letterSpacing: 1.1)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _directionRow({
    required IconData icon,
    required String label,
    required int bars,
    required double lengthM,
    required Color color,
  }) {
    final nf = NumberFormat('#,##0.##');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color.withValues(alpha: 0.8))),
                Text('${nf.format(lengthM)} m total length', style: const TextStyle(fontSize: 10, color: Colors.white38)),
              ],
            ),
          ),
          Text('$bars bars', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

/// A sticky summary bar for the bottom of the screen.
class StickyResultSummary extends StatelessWidget {
  final String primaryValue;
  final String primaryLabel;
  final String? secondaryValue;
  final String? secondaryLabel;
  final VoidCallback onSave;

  const StickyResultSummary({
    super.key,
    required this.primaryValue,
    required this.primaryLabel,
    this.secondaryValue,
    this.secondaryLabel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bcNavy,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: bcNavy.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primaryLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: bcAmber.withValues(alpha: 0.6),
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    primaryValue,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: bcAmber,
                    ),
                  ),
                ],
              ),
            ),
            if (secondaryValue != null) ...[
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    secondaryLabel?.toUpperCase() ?? '',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    secondaryValue!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
            ],
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: bcAmber,
                foregroundColor: bcNavy,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Row(
                children: [
                  Icon(Icons.save_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('SAVE', style: TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

