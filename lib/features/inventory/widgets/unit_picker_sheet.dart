import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';

class UnitPickerSheet extends StatefulWidget {
  final String? initialUnit;
  const UnitPickerSheet({super.key, this.initialUnit});

  @override
  State<UnitPickerSheet> createState() => _UnitPickerSheetState();
}

class _UnitPickerSheetState extends State<UnitPickerSheet> {
  late String _selectedUnit;
  final TextEditingController _customCtrl = TextEditingController();
  bool _isCustom = false;

  // Primary quick-pick chips shown at the top
  static const _primaryUnits = ['kg', 'ltr', 'bag', 'box', 'pcs'];

  // All remaining standard units shown in the lower grid
  static final _moreUnits = standardUnits.where((u) => !_primaryUnits.contains(u)).toList();

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.initialUnit ?? '';
    if (_selectedUnit.isNotEmpty && !standardUnits.contains(_selectedUnit)) {
      _isCustom = true;
      _customCtrl.text = _selectedUnit;
    }
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _pick(String unit) {
    setState(() {
      _selectedUnit = unit;
      _isCustom = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final finalUnit = _isCustom ? _customCtrl.text.trim() : _selectedUnit;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ──────────────────────────────────────────────
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ───────────────────────────────────────────────────
          Row(children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Select Unit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: bcNavy)),
                SizedBox(height: 2),
                Text('Pick a unit or enter custom', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ]),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: bcNavy),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Primary quick chips ──────────────────────────────────────
          const Text(
            'COMMON UNITS',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          Row(children: _primaryUnits.map((u) {
            final isSelected = !_isCustom && _selectedUnit == u;
            return Expanded(
              child: GestureDetector(
                onTap: () => _pick(u),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? bcNavy : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? bcNavy : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(children: [
                    Icon(
                      _unitIcon(u),
                      size: 18,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      u.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : bcNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ]),
                ),
              ),
            );
          }).toList()),
          const SizedBox(height: 20),

          // ── More units ───────────────────────────────────────────────
          const Text(
            'MORE UNITS',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moreUnits.map((u) {
              final isSelected = !_isCustom && _selectedUnit == u;
              return GestureDetector(
                onTap: () => _pick(u),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? bcNavy : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? bcNavy : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    u.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : bcNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Custom unit ──────────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _isCustom = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isCustom ? bcNavy.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isCustom ? bcNavy.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
                  width: _isCustom ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.edit_rounded, size: 15, color: _isCustom ? bcNavy : const Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Text(
                      'OTHER / CUSTOM UNIT',
                      style: TextStyle(
                        color: _isCustom ? bcNavy : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ]),
                  if (_isCustom) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customCtrl,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(fontSize: 14, color: bcNavy, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'e.g. BUNDLE, ROLL, DRUM',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bcAmber, width: 2)),
                      ),
                      onChanged: (v) => setState(() => _selectedUnit = v.toLowerCase()),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Confirm button ────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: finalUnit.isNotEmpty ? () => Navigator.pop(context, finalUnit) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: bcNavy,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                finalUnit.isNotEmpty ? 'USE ${finalUnit.toUpperCase()}' : 'SELECT A UNIT',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _unitIcon(String unit) {
    switch (unit) {
      case 'kg':  return Icons.scale_rounded;
      case 'ltr': return Icons.water_drop_rounded;
      case 'bag': return Icons.shopping_bag_rounded;
      case 'box': return Icons.inventory_2_rounded;
      case 'pcs': return Icons.grid_view_rounded;
      default:    return Icons.straighten_rounded;
    }
  }
}
