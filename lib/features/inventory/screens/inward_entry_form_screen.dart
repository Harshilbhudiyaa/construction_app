import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';

class InwardEntryFormScreen extends StatefulWidget {
  final String? siteId;
  final String? preselectedMaterial;
  final InwardMovementModel? editingLog;
  const InwardEntryFormScreen({super.key, this.siteId, this.preselectedMaterial, this.editingLog});

  @override
  State<InwardEntryFormScreen> createState() => _InwardEntryFormScreenState();
}

class _InwardEntryFormScreenState extends State<InwardEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Material Selection
  final _materialNameCtrl = TextEditingController();
  String? _selectedMaterialId;
  String _unitType = 'bag';

  // Billing
  final _rateCtrl = TextEditingController();
  final _transportCtrl = TextEditingController(text: '0');
  final _taxCtrl = TextEditingController(text: '18');
  double _total = 0.0;
  final _qtyCtrl = TextEditingController();
  
  // Logistics
  String _vehicleType = 'Dumper / Truck';
  final _vehicleNoCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _transporterCtrl = TextEditingController();
  final _driverNameCtrl = TextEditingController();
  final _driverMobileCtrl = TextEditingController();

  // Proofs
  bool _photo1Captured = false;
  String? _photo1Path;
  String? _photo1Location;
  
  bool _photo2Captured = false;
  String? _photo2Path;
  String? _photo2Location;
  
  bool _photo3Captured = false;
  String? _photo3Path;
  String? _photo3Location;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.editingLog != null) {
      _loadEditingData();
    } else if (widget.preselectedMaterial != null) {
      _selectedMaterialId = widget.preselectedMaterial;
      // We'll set the name in first build or after repos are ready
    }
  }

  void _loadEditingData() {
    final log = widget.editingLog!;
    _materialNameCtrl.text = log.materialName;
    _selectedMaterialId = log.materialId;
    _qtyCtrl.text = log.quantity.toString();
    _unitType = log.unit;
    _rateCtrl.text = log.ratePerUnit.toString();
    _transportCtrl.text = log.transportCharges.toString();
    _taxCtrl.text = log.taxPercentage.toString();
    _vehicleNoCtrl.text = log.vehicleNumber;
    _capacityCtrl.text = log.vehicleCapacity;
    _transporterCtrl.text = log.transporterName;
    _driverNameCtrl.text = log.driverName;
    _driverMobileCtrl.text = log.driverMobile;
    _total = log.totalAmount;
    _vehicleType = log.vehicleType;
    
    for (var p in log.photoProofs) {
      if (p.stage == 'Departure') { _photo1Captured = true; _photo1Path = p.photoUrl; _photo1Location = p.locationTag; }
      if (p.stage == 'Arrival') { _photo2Captured = true; _photo2Path = p.photoUrl; _photo2Location = p.locationTag; }
      if (p.stage == 'Bill') { _photo3Captured = true; _photo3Path = p.photoUrl; _photo3Location = p.locationTag; }
    }
  }

  @override
  void dispose() {
    _materialNameCtrl.dispose();
    _vehicleNoCtrl.dispose();
    _capacityCtrl.dispose();
    _transporterCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverMobileCtrl.dispose();
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _transportCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    final transport = double.tryParse(_transportCtrl.text) ?? 0;
    final taxPercent = double.tryParse(_taxCtrl.text) ?? 0;

    final subtotal = (qty * rate) + transport;
    final tax = subtotal * (taxPercent / 100);
    setState(() {
      _total = subtotal + tax;
    });
  }

  Future<void> _capturePhoto(int photoNumber) async {
    try {
      String locationTag = 'Location Unavailable';
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition();
          locationTag = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        }
      } catch (e) { debugPrint('Loc error: $e'); }

      final XFile? photo = await _picker.pickImage(
        source: (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 70,
      );

      if (photo != null) {
        setState(() {
          if (photoNumber == 1) { _photo1Captured = true; _photo1Path = photo.path; _photo1Location = locationTag; }
          else if (photoNumber == 2) { _photo2Captured = true; _photo2Path = photo.path; _photo2Location = locationTag; }
          else if (photoNumber == 3) { _photo3Captured = true; _photo3Path = photo.path; _photo3Location = locationTag; }
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final partyRepo = context.watch<PartyRepository>();
    final invRepo   = context.watch<InventoryRepository>();
    final suppliers = partyRepo.parties.where((p) => p.category == PartyCategory.supplier).toList();
    final materials = invRepo.materials;

    if (_selectedMaterialId != null && _materialNameCtrl.text.isEmpty) {
      final m = materials.firstWhere((e) => e.id == _selectedMaterialId, orElse: () => materials.first);
      _materialNameCtrl.text = m.name;
      _unitType = m.unitType;
    }

    return Scaffold(
      backgroundColor: bcSurface,
      appBar: AppBar(
        title: const Text('Inward Entry', style: TextStyle(fontWeight: FontWeight.w900, color: bcNavy, fontSize: 17)),
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
            // ── SECTION: Logistics ──────────────────────────────────────────
            _groupLabel('Logistics Details', Icons.local_shipping_outlined),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                   Row(
                    children: [
                      Expanded(child: _buildLabeledField(
                        label: 'Vehicle Type',
                        child: _buildPickerRow(
                          value: _vehicleType,
                          onTap: () => _showPickerSheet('VEHICLE TYPE', ['Dumper / Truck', 'Tractor', 'Pick-up', 'Other'], (v) => _vehicleType = v),
                        ),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildLabeledField(
                        label: 'Number *',
                        child: TextFormField(
                          controller: _vehicleNoCtrl,
                          style: _inputTextStyle,
                          decoration: _dec('e.g. GJ01AB1234'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabeledField(
                    label: 'Supplier / Vendor *',
                    child: _buildPickerRow(
                      value: _transporterCtrl.text.isEmpty ? 'Select Supplier' : _transporterCtrl.text,
                      onTap: () => _showSupplierPicker(suppliers),
                      isHint: _transporterCtrl.text.isEmpty,
                    ),
                  ),
                  const SizedBox(height: 16),
                   Row(
                    children: [
                      Expanded(child: _buildLabeledField(
                        label: 'Driver Name',
                        child: TextFormField(
                          controller: _driverNameCtrl,
                          style: _inputTextStyle,
                          decoration: _dec('e.g. Rahul Singh'),
                        ),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildLabeledField(
                        label: 'Mobile',
                        child: TextFormField(
                          controller: _driverMobileCtrl,
                          keyboardType: TextInputType.phone,
                          style: _inputTextStyle,
                          decoration: _dec('10 digits'),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),

            // ── SECTION: Material ───────────────────────────────────────────
            const SizedBox(height: 24),
            _groupLabel('Material Identification', Icons.inventory_2_outlined),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildLabeledField(
                    label: 'Linked Catalog Item (Master)',
                    child: _buildPickerRow(
                      value: _selectedMaterialId != null 
                          ? materials.firstWhere((m) => m.id == _selectedMaterialId).name
                          : 'Not linked to Catalog',
                      onTap: () => _showMaterialPicker(materials),
                      isHint: _selectedMaterialId == null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildLabeledField(
                          label: 'Quantity Received',
                          child: TextFormField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            style: _inputTextStyle.copyWith(fontSize: 18, color: bcPrimary),
                            decoration: _dec('0').copyWith(suffixText: _unitType.toUpperCase()),
                            onChanged: (_) => _calculateTotal(),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _buildLabeledField(
                          label: 'Unit',
                          child: _buildPickerRow(
                            value: _unitType.toUpperCase(),
                            onTap: () => _showPickerSheet('SELECT UNIT', ['bag', 'kg', 'ton', 'mtr', 'cft', 'brass'], (v) => _unitType = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── SECTION: Proofs ─────────────────────────────────────────────
            const SizedBox(height: 24),
            _groupLabel('Mandatory Visual Proofs', Icons.camera_alt_outlined),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _photoCapturePill('Departure', _photo1Captured, () => _capturePhoto(1))),
                const SizedBox(width: 8),
                Expanded(child: _photoCapturePill('Arrival', _photo2Captured, () => _capturePhoto(2))),
                const SizedBox(width: 8),
                Expanded(child: _photoCapturePill('Bill/Inv', _photo3Captured, () => _capturePhoto(3))),
              ],
            ),

            // ── SECTION: Billing ────────────────────────────────────────────
            const SizedBox(height: 24),
            _groupLabel('Billing & Valuation', Icons.receipt_long_outlined),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildLabeledField(
                        label: 'Rate (₹)',
                        child: TextFormField(
                          controller: _rateCtrl,
                          keyboardType: TextInputType.number,
                          style: _inputTextStyle,
                          decoration: _dec('0'),
                          onChanged: (_) => _calculateTotal(),
                        ),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildLabeledField(
                        label: 'Transport (₹)',
                        child: TextFormField(
                          controller: _transportCtrl,
                          keyboardType: TextInputType.number,
                          style: _inputTextStyle,
                          decoration: _dec('0'),
                          onChanged: (_) => _calculateTotal(),
                        ),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildLabeledField(
                        label: 'Tax %',
                        child: TextFormField(
                          controller: _taxCtrl,
                          keyboardType: TextInputType.number,
                          style: _inputTextStyle,
                          decoration: _dec('18'),
                          onChanged: (_) => _calculateTotal(),
                        ),
                      )),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL PAYABLE', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                      Text('₹${NumberFormat('#,##,###').format(_total)}', style: const TextStyle(color: bcSuccess, fontWeight: FontWeight.w900, fontSize: 22)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // ── REDESIGNED HELPERS ─────────────────────────────────────────────────────

  Widget _groupLabel(String label, IconData icon) => Row(
    children: [
      Icon(icon, size: 14, color: bcAmber),
      const SizedBox(width: 6),
      Text(label.toUpperCase(), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8)),
    ],
  );

  Widget _buildLabeledField({required String label, required Widget child}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 6),
        child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 11)),
      ),
      child,
    ],
  );

  Widget _buildPickerRow({required String value, required VoidCallback onTap, bool isHint = false}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: bcSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: isHint ? FontWeight.w500 : FontWeight.w700, color: isHint ? const Color(0xFF94A3B8) : bcNavy))),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 18),
        ],
      ),
    ),
  );

  Widget _photoCapturePill(String label, bool isDone, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDone ? bcSuccess.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDone ? bcSuccess : const Color(0xFFE2E8F0), width: isDone ? 1.5 : 1),
      ),
      child: Column(
        children: [
           Icon(isDone ? Icons.check_circle_rounded : Icons.add_a_photo_rounded, color: isDone ? bcSuccess : const Color(0xFFCBD5E1), size: 24),
           const SizedBox(height: 8),
           Text(label, style: TextStyle(color: isDone ? bcSuccess : bcTextSecondary, fontWeight: FontWeight.w900, fontSize: 11)),
        ],
      ),
    ),
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint, filled: true, fillColor: bcSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bcNavy, width: 2)),
  );

  static const _inputTextStyle = TextStyle(fontSize: 14, color: bcNavy, fontWeight: FontWeight.w700);

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity, height: 56,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: bcNavy, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
      ),
      child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('SUBMIT INWARD ENTRY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
    ),
  );

  // ── PICKER SHEETS ──────────────────────────────────────────────────────────

  void _showPickerSheet(String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _SheetContainer(
        title: title,
        child: Column(
          children: options.map((o) => _SheetOption(label: o, onTap: () { setState(() => onSelect(o)); Navigator.pop(context); })).toList(),
        ),
      ),
    );
  }

  void _showSupplierPicker(List<PartyModel> suppliers) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _SheetContainer(
        title: 'SELECT SUPPLIER',
        child: SizedBox(
          height: 300,
          child: ListView(
            children: suppliers.map((s) => _SheetOption(label: s.name, onTap: () { setState(() => _transporterCtrl.text = s.name); Navigator.pop(context); })).toList(),
          ),
        ),
      ),
    );
  }

  void _showMaterialPicker(List<ConstructionMaterial> materials) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _SheetContainer(
        title: 'SELECT MATERIAL',
        child: SizedBox(
          height: 400,
          child: ListView(
            children: [
              _SheetOption(label: 'NONE / NEW MATERIAL', onTap: () { setState(() => _selectedMaterialId = null); Navigator.pop(context); }),
              ...materials.map((m) => _SheetOption(label: m.name, onTap: () { 
                setState(() { _selectedMaterialId = m.id; _materialNameCtrl.text = m.name; _unitType = m.unitType; }); 
                Navigator.pop(context); 
              })),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_photo1Captured || !_photo2Captured || !_photo3Captured) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All 3 photos are mandatory.'), backgroundColor: bcDanger));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final invRepo = context.read<InventoryRepository>();
      final auth    = context.read<AuthRepository>();
      final log = InwardMovementModel(
        id: widget.editingLog?.id ?? 'INW-${DateTime.now().millisecondsSinceEpoch % 10000}',
        vehicleType: _vehicleType, vehicleNumber: _vehicleNoCtrl.text,
        vehicleCapacity: _capacityCtrl.text, transporterName: _transporterCtrl.text,
        driverName: _driverNameCtrl.text, driverMobile: _driverMobileCtrl.text, driverLicense: '',
        materialId: _selectedMaterialId, materialName: _materialNameCtrl.text,
        quantity: double.tryParse(_qtyCtrl.text) ?? 0.0, unit: _unitType,
        photoProofs: [
          if (_photo1Path != null) InwardPhotoProof(photoUrl: _photo1Path!, stage: 'Departure', capturedAt: DateTime.now(), locationTag: _photo1Location ?? ''),
          if (_photo2Path != null) InwardPhotoProof(photoUrl: _photo2Path!, stage: 'Arrival', capturedAt: DateTime.now(), locationTag: _photo2Location ?? ''),
          if (_photo3Path != null) InwardPhotoProof(photoUrl: _photo3Path!, stage: 'Bill', capturedAt: DateTime.now(), locationTag: _photo3Location ?? ''),
        ],
        ratePerUnit: double.tryParse(_rateCtrl.text) ?? 0.0, transportCharges: double.tryParse(_transportCtrl.text) ?? 0.0,
        taxPercentage: double.tryParse(_taxCtrl.text) ?? 0.0, totalAmount: _total,
        siteId: widget.siteId ?? widget.editingLog?.siteId ?? 'S-001',
        createdAt: widget.editingLog?.createdAt ?? DateTime.now(), availableSizes: [],
      );
      if (widget.editingLog != null) {
        await invRepo.updateInwardLog(log);
      } else {
        await invRepo.saveInwardLog(log, recordedBy: auth.userName ?? 'Admin');
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _SheetContainer extends StatelessWidget {
  final String title;
  final Widget child;
  const _SheetContainer({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: bcBorder, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: bcNavy, letterSpacing: 1)),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _SheetOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SheetOption({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: bcNavy)),
    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
    onTap: onTap,
  );
}
