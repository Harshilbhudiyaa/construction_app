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
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _customCtrl = TextEditingController();
  bool _isCustom = false;

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
    _searchCtrl.dispose();
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUnits = standardUnits.where((u) {
      final search = _searchQuery.toUpperCase();
      return u.toUpperCase().contains(search);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ...filteredUnits.map((unit) {
                  final isSelected = !_isCustom && _selectedUnit == unit;
                  return ListTile(
                    leading: _buildRadio(isSelected),
                    title: Text(
                      unit.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? bcPrimary : bcNavy,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedUnit = unit;
                        _isCustom = false;
                      });
                    },
                  );
                }),
                
                // Custom Option
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isCustom ? bcPrimary.withValues(alpha: 0.05) : bcSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isCustom ? bcPrimary : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isCustom = true),
                          child: Row(
                            children: [
                              _buildRadio(_isCustom),
                              const SizedBox(width: 12),
                              const Text('CUSTOM UNIT', style: TextStyle(color: bcNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                        if (_isCustom) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _customCtrl,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Enter unit (e.g. bundle, box, etc.)',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            style: const TextStyle(fontSize: 14, color: bcNavy),
                            onChanged: (v) => setState(() => _selectedUnit = v),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildRadio(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? bcPrimary : Colors.grey.withValues(alpha: 0.5),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Unit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: bcNavy)),
              Text('Pick standard units or add custom', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: bcNavy),
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
          hintText: 'Search Standard Units',
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          filled: true,
          fillColor: bcSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final finalUnit = _isCustom ? _customCtrl.text.trim() : _selectedUnit;
    final isEnabled = finalUnit.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isEnabled ? () => Navigator.pop(context, finalUnit) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bcPrimary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: bcSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: const Text('CONFIRM SELECTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        ),
      ),
    );
  }
}
