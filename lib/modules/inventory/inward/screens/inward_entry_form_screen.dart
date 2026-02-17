import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/modules/inventory/inward/models/inward_movement_model.dart';
import 'package:construction_app/modules/inventory/materials/models/material_model.dart';
import 'package:construction_app/services/mock_inventory_service.dart';
import 'package:construction_app/services/master_material_service.dart';
import 'package:construction_app/modules/inventory/materials/models/master_material_model.dart';
import 'package:provider/provider.dart';

class InwardEntryFormScreen extends StatefulWidget {
  final String? siteId;
  final String? preselectedMaterial;
  const InwardEntryFormScreen({super.key, this.siteId, this.preselectedMaterial});

  @override
  State<InwardEntryFormScreen> createState() => _InwardEntryFormScreenState();
}

class _InwardEntryFormScreenState extends State<InwardEntryFormScreen> {

  final _formKey = GlobalKey<FormState>();
  late final MockInventoryService _inventoryService;
  final _masterService = MasterMaterialService();
  bool _isLoading = false;

  // Material Selection
  MaterialCategory _category = MaterialCategory.sand;
  String? _selectedMasterMaterialId;
  MasterMaterial? _selectedMasterMaterial;
  UnitType _unitType = UnitType.ton;
  final List<TextEditingController> _sizeCtrls = [];

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
  final _driverLicenseCtrl = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _inventoryService = context.read<MockInventoryService>();
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _capturePhoto(int photoNumber) async {
    try {
      // 1. Get Location
      String locationTag = 'Location Unavailable';
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition();
          locationTag = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        }
      } catch (e) {
        debugPrint('Location error: $e');
      }

      // 2. Capture Image (Gallery on web, Camera on mobile)
      // 2. Capture Image (Gallery on Windows, Camera on mobile)
      final XFile? photo = await _picker.pickImage(
        source: Platform.isWindows ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 70,
      );

      if (photo != null) {
        setState(() {
          if (photoNumber == 1) {
            _photo1Captured = true;
            _photo1Path = photo.path;
            _photo1Location = locationTag;
          } else if (photoNumber == 2) {
            _photo2Captured = true;
            _photo2Path = photo.path;
            _photo2Location = locationTag;
          } else if (photoNumber == 3) {
            _photo3Captured = true;
            _photo3Path = photo.path;
            _photo3Location = locationTag;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Photo $photoNumber captured at $locationTag')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }



  @override
  void dispose() {
    _vehicleNoCtrl.dispose();
    _capacityCtrl.dispose();
    _transporterCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverMobileCtrl.dispose();
    _driverLicenseCtrl.dispose();
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _transportCtrl.dispose();
    _taxCtrl.dispose();
    for (final c in _sizeCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onMasterMaterialChanged(MasterMaterial? mm) {
    if (mm == null) return;
    setState(() {
      _selectedMasterMaterialId = mm.id;
      _selectedMasterMaterial = mm;
      _category = mm.category;
      _unitType = mm.defaultUnit;
    });
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


  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMasterMaterialId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a material type')));
        return;
      }
      if (!_photo1Captured || !_photo2Captured || !_photo3Captured) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All 3 photos are mandatory.')));
        return;
      }
      setState(() => _isLoading = true);
      
      try {
        final log = InwardMovementModel(
          id: 'INW-${DateTime.now().millisecondsSinceEpoch % 10000}',
          vehicleType: _vehicleType,
          vehicleNumber: _vehicleNoCtrl.text,
          vehicleCapacity: _capacityCtrl.text,
          transporterName: _transporterCtrl.text,
          driverName: _driverNameCtrl.text,
          driverMobile: _driverMobileCtrl.text,
          driverLicense: _driverLicenseCtrl.text,
          materialName: _selectedMasterMaterial?.name ?? 'Unknown',
          category: _category,
          quantity: double.parse(_qtyCtrl.text),
          unit: _unitType.label,
          photoProofs: [
            if (_photo1Path != null) InwardPhotoProof(photoUrl: _photo1Path!, stage: 'Departure', capturedAt: DateTime.now(), locationTag: _photo1Location ?? ''),
            if (_photo2Path != null) InwardPhotoProof(photoUrl: _photo2Path!, stage: 'Arrival', capturedAt: DateTime.now(), locationTag: _photo2Location ?? ''),
            if (_photo3Path != null) InwardPhotoProof(photoUrl: _photo3Path!, stage: 'Bill', capturedAt: DateTime.now(), locationTag: _photo3Location ?? ''),
          ],
          ratePerUnit: double.parse(_rateCtrl.text),
          transportCharges: double.parse(_transportCtrl.text),
          taxPercentage: double.parse(_taxCtrl.text),
          totalAmount: _total,
          siteId: widget.siteId ?? 'S-001',
          createdAt: DateTime.now(),
          availableSizes: _sizeCtrls.map((c) => c.text).where((s) => s.isNotEmpty).toList(),
        );

        await _inventoryService.saveInwardLog(log);
        
        // Also update/add to ConstructionMaterial if needed? 
        // For now just logging inward is enough per existing logic.

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inward Entry submitted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Inward Entry',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: _isLoading 
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: Colors.blueAccent),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLogisticsSection(),
                      const SizedBox(height: 32),
                      _buildMaterialInformationSection(),
                      const SizedBox(height: 32),
                      _buildProofSection(),
                      const SizedBox(height: 32),
                      _buildBillingSection(),
                      const SizedBox(height: 48),
                      _buildActionBtn('SUBMIT INWARD ENTRY', _submit),
                      const SizedBox(height: 100),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Logistics Details', Icons.local_shipping_rounded),
        ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _subHeader('Vehicle Details', Icons.vibration_rounded),
              const SizedBox(height: 20),
              HelpfulDropdown<String>(
                label: 'Vehicle Type',
                value: _vehicleType,
                items: const ['Dumper / Truck', 'Tractor', 'Pick-up', 'Other'],
                onChanged: (v) => setState(() => _vehicleType = v!),
              ),
              const SizedBox(height: 16),
              HelpfulTextField(
                label: 'Vehicle Number',
                controller: _vehicleNoCtrl,
                hintText: 'e.g. GJ01AB1234',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: HelpfulTextField(
                      label: 'Capacity',
                      controller: _capacityCtrl,
                      hintText: 'e.g. 10 Tons',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HelpfulTextField(
                      label: 'Transporter',
                      controller: _transporterCtrl,
                      hintText: 'Company name',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _subHeader('Driver Details', Icons.person_pin_rounded),
              const SizedBox(height: 20),
              HelpfulTextField(
                label: 'Full Name',
                controller: _driverNameCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              HelpfulTextField(
                label: 'Mobile Number',
                controller: _driverMobileCtrl,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Material Information', Icons.inventory_2_rounded),
        ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelpfulDropdown<MaterialCategory>(
                label: 'Material Category',
                value: _category,
                useGlass: true,
                items: MaterialCategory.values,
                labelMapper: (cat) => cat.displayName,
                onChanged: (cat) {
                  if (cat != null) {
                    setState(() {
                      _category = cat;
                      _selectedMasterMaterialId = null;
                      _selectedMasterMaterial = null;
                      _unitType = MasterMaterial.getAutoUnit(cat);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<MasterMaterial>>(
                stream: _masterService.getMasterMaterialsStream(),
                builder: (context, snapshot) {
                  final allMaterials = snapshot.data ?? [];
                  final filteredMaterials = allMaterials.where((m) => m.category == _category).toList();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: HelpfulDropdown<String?>(
                          label: 'Material Type',
                          value: _selectedMasterMaterialId,
                          useGlass: true,
                          items: filteredMaterials.map((e) => e.id).toList(),
                          labelMapper: (id) => filteredMaterials.firstWhere((m) => m.id == id).name,
                          onChanged: (id) {
                            if (id != null) {
                              final mm = filteredMaterials.firstWhere((m) => m.id == id);
                              _onMasterMaterialChanged(mm);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 52,
                        margin: const EdgeInsets.only(bottom: 4),
                        child: IconButton.filled(
                          onPressed: _showAddInlineTypeDialog,
                          icon: const Icon(Icons.add_rounded, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: HelpfulTextField(
                      label: 'Quantity Delivered',
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      suffixText: _unitType.label,
                      useGlass: true,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              if (_category == MaterialCategory.steel) ...[
                const SizedBox(height: 24),
                _buildSizesSection(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'REBAR SIZES (mm)',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _sizeCtrls.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: const Text('ADD SIZE', style: TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF818CF8)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(_sizeCtrls.length, (index) {
            return SizedBox(
              width: 100,
              child: HelpfulTextField(
                label: 'Size',
                controller: _sizeCtrls[index],
                hintText: '8mm',
                useGlass: true,
                keyboardType: TextInputType.text,
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _sizeCtrls[index].dispose();
                      _sizeCtrls.removeAt(index);
                    });
                  },
                  child: const Icon(Icons.cancel_rounded, size: 16, color: Colors.redAccent),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProofSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Mandatory Proofs', Icons.camera_alt_rounded),
        ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Photos are automatically geo-tagged and time-stamped.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 11),
              ),
              const SizedBox(height: 24),
              _photoCaptureRow('Departure Photo', _photo1Location ?? 'Material loaded at source', _photo1Captured, () => _capturePhoto(1)),
              _photoCaptureRow('Arrival Photo', _photo2Location ?? 'Material at site gate', _photo2Captured, () => _capturePhoto(2)),
              _photoCaptureRow('Bill/Invoice Photo', _photo3Location ?? 'Physical copy proof', _photo3Captured, () => _capturePhoto(3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Billing Details', Icons.receipt_long_rounded),
        ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelpfulTextField(
                label: 'Rate Per Unit (₹)',
                controller: _rateCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              HelpfulTextField(
                label: 'Transport Charges (₹)',
                controller: _transportCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
              ),
              const SizedBox(height: 16),
              HelpfulTextField(
                label: 'Tax / GST (%)',
                controller: _taxCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
              ),
              Divider(height: 48, color: Theme.of(context).dividerColor.withOpacity(0.1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Payable', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    '₹${NumberFormat('#,##,###.##').format(_total)}',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddInlineTypeDialog() {
    final nameCtrl = TextEditingController();
    UnitType selectedUnit = MasterMaterial.getAutoUnit(_category);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HelpfulTextField(
                label: 'Type Name',
                controller: nameCtrl,
                hintText: _category == MaterialCategory.cement 
                    ? 'e.g. OPC 43, OPC 53, PPC' 
                    : _category == MaterialCategory.steel 
                        ? 'e.g. TMT, MS Rod' 
                        : 'e.g. Crushed Sand, River Sand',
                useGlass: true,
              ),
              const SizedBox(height: 16),
              HelpfulDropdown<UnitType>(
                label: 'Default Purchase Unit',
                value: selectedUnit,
                items: UnitType.values,
                labelMapper: (u) => u.label.toUpperCase(),
                onChanged: (u) {
                  if (u != null) setDialogState(() => selectedUnit = u);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  final newMM = MasterMaterial(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text,
                    category: _category,
                    defaultUnit: selectedUnit,
                    createdAt: DateTime.now(),
                  );
                  await _masterService.addMasterMaterial(newMM);
                  setState(() {
                    _selectedMasterMaterialId = newMM.id;
                    _onMasterMaterialChanged(newMM);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('ADD TYPE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 18),
        const SizedBox(width: 8),
        Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _photoCaptureRow(String title, String subtitle, bool isDone, VoidCallback onCapture) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onCapture,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDone ? Colors.greenAccent.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDone ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDone ? Colors.greenAccent.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(isDone ? Icons.check_circle_rounded : Icons.camera_alt_rounded, color: isDone ? Colors.greenAccent : Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 11)),
                  ],
                ),
              ),
              if (isDone)
                const StatusChip(status: UiStatus.approved, labelOverride: 'CAPTURED')
              else
                Icon(Icons.add_a_photo_rounded, color: Colors.blueAccent.withValues(alpha: 0.5), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blueAccent, AppColors.deepBlue3]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildSecondaryBtn(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.bold)),
    );
  }
}
