import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';

class UnitPickerSheet extends StatefulWidget {
  final UnitType? initialUnit;
  const UnitPickerSheet({super.key, this.initialUnit});

  @override
  State<UnitPickerSheet> createState() => _UnitPickerSheetState();
}

class _UnitPickerSheetState extends State<UnitPickerSheet> {
  late UnitType _selectedUnit;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.initialUnit ?? UnitType.none;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUnits = UnitType.values.where((u) {
      if (u == UnitType.none) return false;
      final name = u.toString().split('.').last.toUpperCase();
      final label = u.label.toUpperCase();
      final search = _searchQuery.toUpperCase();
      return name.contains(search) || label.contains(search);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredUnits.length,
              itemBuilder: (context, index) {
                final unit = filteredUnits[index];
                final isSelected = _selectedUnit == unit;
                return ListTile(
                  leading: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? bcPrimary : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 10 : 0,
                        height: isSelected ? 10 : 0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: bcPrimary,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '${_getUnitFullName(unit)} - ${unit.label}',
                    style: TextStyle(
                      color: isSelected ? bcPrimary : bcNavy,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () => setState(() => _selectedUnit = unit),
                );
              },
            ),
          ),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Unit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: bcNavy),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: bcNavy),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Search Units',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedUnit),
          style: ElevatedButton.styleFrom(
            backgroundColor: bcPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            'CONFIRM',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  String _getUnitFullName(UnitType unit) {
    switch (unit) {
      case UnitType.nos: return 'Numbers';
      case UnitType.pcs: return 'Pieces';
      case UnitType.kgs: return 'Kilograms';
      case UnitType.bag: return 'Bags';
      case UnitType.wks: return 'Weeks';
      case UnitType.mon: return 'Month';
      case UnitType.yrs: return 'Years';
      case UnitType.bal: return 'Bale';
      case UnitType.bou: return 'Billion of Units';
      case UnitType.btl: return 'Bottles';
      case UnitType.box: return 'Box';
      case UnitType.bkl: return 'Buckles';
      case UnitType.bun: return 'Bunches';
      case UnitType.bdl: return 'Bundles';
      case UnitType.can: return 'Cans';
      case UnitType.cms: return 'Centimeters';
      case UnitType.ctn: return 'Cartons';
      case UnitType.dzn: return 'Dozens';
      case UnitType.gms: return 'Grams';
      case UnitType.grs: return 'Gross';
      case UnitType.klt: return 'Kiloliters';
      case UnitType.kms: return 'Kilometers';
      case UnitType.ltr: return 'Liters';
      case UnitType.mgm: return 'Milligrams';
      case UnitType.mlt: return 'Milliliters';
      case UnitType.mtr: return 'Meters';
      case UnitType.prs: return 'Pairs';
      case UnitType.qtl: return 'Quintal';
      case UnitType.rll: return 'Rolls';
      case UnitType.sqf: return 'Square Feet';
      case UnitType.sqm: return 'Square Meters';
      case UnitType.tne: return 'Metric Ton';
      case UnitType.unit: return 'Units';
      case UnitType.cft: return 'Cubic Feet';
      case UnitType.ton: return 'Tons';
      default: return unit.label;
    }
  }
}
