import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:geolocator/geolocator.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/core/theme/design_system.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/widgets/status_badge.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

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
  late final InventoryRepository _inventoryService;
  bool _isLoading = false;
  // Material Selection
  final _materialNameCtrl = TextEditingController();
  String? _selectedMaterialId; // Specific ConstructionMaterial ID
  String _unitType = 'bag';
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
    _inventoryService = context.read<InventoryRepository>();
    if (widget.editingLog != null) {
      _loadEditingData();
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
    _driverLicenseCtrl.text = log.driverLicense;
    
    _total = log.totalAmount;
    _vehicleType = log.vehicleType;
    
    // sizes
    for (var s in log.availableSizes) {
      _sizeCtrls.add(TextEditingController(text: s));
    }
    
    // Photos
    for (var p in log.photoProofs) {
      if (p.stage == 'Departure') { _photo1Captured = true; _photo1Path = p.photoUrl; _photo1Location = p.locationTag; }
      if (p.stage == 'Arrival') { _photo2Captured = true; _photo2Path = p.photoUrl; _photo2Location = p.locationTag; }
      if (p.stage == 'Bill') { _photo3Captured = true; _photo3Path = p.photoUrl; _photo3Location = p.locationTag; }
    }
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

      // 2. Capture Image (Gallery on Web/Windows, Camera on Mobile)
      final XFile? photo = await _picker.pickImage(
        source: (kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS) 
            ? ImageSource.gallery 
            : ImageSource.camera,
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
    _materialNameCtrl.dispose();
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
      if (_materialNameCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter material name')));
        return;
      }
      if (!_photo1Captured || !_photo2Captured || !_photo3Captured) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All 3 photos are mandatory.')));
        return;
      }
      setState(() => _isLoading = true);
      
      try {
        final log = InwardMovementModel(
          id: widget.editingLog?.id ?? 'INW-${DateTime.now().millisecondsSinceEpoch % 10000}',
          vehicleType: _vehicleType,
          vehicleNumber: _vehicleNoCtrl.text,
          vehicleCapacity: _capacityCtrl.text,
          transporterName: _transporterCtrl.text,
          driverName: _driverNameCtrl.text,
          driverMobile: _driverMobileCtrl.text,
          driverLicense: _driverLicenseCtrl.text,
          materialId: _selectedMaterialId,
          materialName: _materialNameCtrl.text,
          quantity: double.parse(_qtyCtrl.text),
          unit: _unitType,
          photoProofs: [
            if (_photo1Path != null) InwardPhotoProof(photoUrl: _photo1Path!, stage: 'Departure', capturedAt: DateTime.now(), locationTag: _photo1Location ?? ''),
            if (_photo2Path != null) InwardPhotoProof(photoUrl: _photo2Path!, stage: 'Arrival', capturedAt: DateTime.now(), locationTag: _photo2Location ?? ''),
            if (_photo3Path != null) InwardPhotoProof(photoUrl: _photo3Path!, stage: 'Bill', capturedAt: DateTime.now(), locationTag: _photo3Location ?? ''),
          ],
          ratePerUnit: double.parse(_rateCtrl.text),
          transportCharges: double.parse(_transportCtrl.text),
          taxPercentage: double.parse(_taxCtrl.text),
          totalAmount: _total,
          siteId: widget.siteId ?? widget.editingLog?.siteId ?? 'S-001',
          createdAt: widget.editingLog?.createdAt ?? DateTime.now(),
          availableSizes: _sizeCtrls.map((c) => c.text).where((s) => s.isNotEmpty).toList(),
        );

        if (widget.editingLog != null) {
          await _inventoryService.updateInwardLog(log);
        } else {
          final auth = context.read<AuthRepository>();
          await _inventoryService.saveInwardLog(log, recordedBy: auth.userName ?? 'System');
        }
        
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
                      child: CircularProgressIndicator(color: DesignSystem.constructionYellow),
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
          useGlass: false,
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
                    child: Consumer<PartyRepository>(
                      builder: (context, partyRepo, child) {
                        final suppliers = partyRepo.parties.where((p) => p.category == PartyCategory.supplier).toList();
                        return HelpfulDropdown<PartyModel?>(
                          label: 'Supplier / Vendor *',
                          value: null, // We'll map the name back or use an ID
                          items: [null, ...suppliers],
                          labelMapper: (p) => p?.name ?? 'Other / Custom',
                          onChanged: (p) {
                            if (p != null) {
                              setState(() => _transporterCtrl.text = p.name);
                            }
                          },
                        );
                      },
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
          useGlass: false,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<InventoryRepository>(
                builder: (context, repo, child) {
                  final filteredMaterials = repo.materials;
                  
                  return HelpfulDropdown<ConstructionMaterial?>(
                    label: 'Catalog Material (Master)',
                    value: _selectedMaterialId != null 
                        ? filteredMaterials.firstWhere((m) => m.id == _selectedMaterialId, orElse: () => filteredMaterials.first)
                        : null,
                    items: [null, ...filteredMaterials],
                    labelMapper: (m) => m == null ? 'New / Not in Master' : m.name,
                    onChanged: (m) {
                      setState(() {
                        if (m != null) {
                          _selectedMaterialId = m.id;
                          _materialNameCtrl.text = m.name;
                          _unitType = m.unitType;
                        } else {
                          _selectedMaterialId = null;
                        }
                      });
                    },
                  );
                }
              ),
              const SizedBox(height: 16),
              HelpfulTextField(
                label: 'Material Name / Type',
                controller: _materialNameCtrl,
                hintText: 'e.g. Ultratech Cement, 10mm Steel, etc.',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              HelpfulDropdown<String>(
                label: 'Unit',
                value: _unitType,
                items: standardUnits,
                labelMapper: (u) => u.toUpperCase(),
                onChanged: (u) {
                  if (u != null) setState(() => _unitType = u);
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<ConstructionMaterial>>(
                stream: _inventoryService.getMaterialsStream(siteId: widget.siteId),
                builder: (context, snapshot) {
                  final siteMaterials = snapshot.data ?? [];
                  if (siteMaterials.isEmpty) return const SizedBox.shrink();

                  return HelpfulDropdown<String?>(
                    label: 'Associate with Existing Stock (Optional)',
                    value: _selectedMaterialId,
                    useGlass: false,
                    items: [null, ...siteMaterials.map((e) => e.id)],
                    labelMapper: (id) {
                      if (id == null) return 'None (New Stock Item)';
                      final m = siteMaterials.firstWhere((m) => m.id == id);
                      return '${m.name} - ${m.brand}';
                    },
                    onChanged: (id) {
                      setState(() {
                        _selectedMaterialId = id;
                        if (id != null) {
                          final m = siteMaterials.firstWhere((m) => m.id == id);
                          _materialNameCtrl.text = m.name;

                          _unitType = m.unitType;
                        }
                      });
                    },
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
                      suffixText: _unitType,
                      useGlass: false,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Invalid number';
                        if (n <= 0) return 'Must be positive';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              // Simplified UI: Removed presets and dynamic size section for now to restore build
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicSizeGradeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SIZE / GRADE / VARIANT',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _sizeCtrls.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: const Text('ADD CUSTOM', style: TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(foregroundColor: DesignSystem.constructionYellow),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(_sizeCtrls.length, (index) {
            return SizedBox(
              width: 140,
              child: HelpfulTextField(
                label: 'Selected',
                controller: _sizeCtrls[index],
                hintText: 'e.g. 8mm',
                useGlass: false,
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
          useGlass: false,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Photos are automatically geo-tagged and time-stamped.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11),
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
          useGlass: false,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelpfulTextField(
                label: 'Rate Per Unit (₹)',
                controller: _rateCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = double.tryParse(v);
                  if (n == null) return 'Invalid number';
                  if (n <= 0) return 'Must be positive';
                  return null;
                },
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
              Divider(height: 48, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignSystem.constructionYellow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: DesignSystem.charcoalBlack, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: DesignSystem.charcoalBlack,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }


  Widget _subHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: DesignSystem.constructionYellow, size: 18),
        const SizedBox(width: 8),
        Text(title.toUpperCase(), style: const TextStyle(color: DesignSystem.charcoalBlack, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
            color: isDone ? Colors.greenAccent.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDone ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDone ? Colors.greenAccent.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(isDone ? Icons.check_circle_rounded : Icons.camera_alt_rounded, color: isDone ? Colors.greenAccent : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: DesignSystem.charcoalBlack, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),
                  ],
                ),
              ),
              if (isDone)
                const StatusBadge(label: 'CAPTURED', type: StatusBadgeType.success)
              else
                Icon(Icons.add_a_photo_rounded, color: DesignSystem.constructionYellow.withValues(alpha: 0.5), size: 18),
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
        color: DesignSystem.constructionYellow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: DesignSystem.charcoalBlack, letterSpacing: 1)),
      ),
    );
  }
}


