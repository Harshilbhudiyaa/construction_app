import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'models/inward_movement_model.dart';
import 'models/material_model.dart';
import 'package:construction_app/services/inventory_service.dart';

class InwardEntryFormScreen extends StatefulWidget {
  final String? siteId;
  final String? preselectedMaterial;
  const InwardEntryFormScreen({super.key, this.siteId, this.preselectedMaterial});

  @override
  State<InwardEntryFormScreen> createState() => _InwardEntryFormScreenState();
}

class _InwardEntryFormScreenState extends State<InwardEntryFormScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _inventoryService = InventoryService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedMaterial != null) {
      _material = widget.preselectedMaterial!;
      _unit = _material.toLowerCase().contains('cement') ? 'bags' : _material.toLowerCase().contains('brick') ? 'units' : 'tons';
    }

    _materialItems = ['Sand', 'Cement', 'Steel', 'Aggregate', 'Bricks'];
    if (widget.preselectedMaterial != null && !_materialItems.contains(widget.preselectedMaterial)) {
      _materialItems.insert(0, widget.preselectedMaterial!);
    }
  }

  // Step 1: Logistics
  String _vehicleType = 'Dumper / Truck';
  final _vehicleNoCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _transporterCtrl = TextEditingController();
  final _driverNameCtrl = TextEditingController();
  final _driverMobileCtrl = TextEditingController();
  final _driverLicenseCtrl = TextEditingController();

  // Step 2: Material & Photos
  String _material = 'Sand';
  MaterialCategory _category = MaterialCategory.sand;
  final _qtyCtrl = TextEditingController();
  String _unit = 'tons';
  
  late final List<String> _materialItems;

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
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
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

  // Step 3: Billing
  final _rateCtrl = TextEditingController();
  final _transportCtrl = TextEditingController(text: '0');
  final _taxCtrl = TextEditingController(text: '18');
  double _total = 0.0;

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

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (!_photo1Captured || !_photo2Captured || !_photo3Captured) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All 3 photos are mandatory before proceeding.')),
        );
        return;
      }
      if (_formKey.currentState!.validate()) {
        _calculateTotal();
        setState(() => _currentStep++);
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
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
          materialName: _material,
          category: _category,
          quantity: double.parse(_qtyCtrl.text),
          unit: _unit,
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
        );

        await _inventoryService.saveInwardLog(log);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inward Entry submitted for approval.'),
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
        _buildStepperHeader(),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: _isLoading 
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: Colors.blueAccent),
                    ),
                  )
                : _buildCurrentStepView(),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStepperHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepIndicator(0, 'Logistics', Icons.local_shipping_rounded),
          _stepConnector(_currentStep > 0),
          _stepIndicator(1, 'Proof', Icons.add_a_photo_rounded),
          _stepConnector(_currentStep > 1),
          _stepIndicator(2, 'Billing', Icons.receipt_long_rounded),
        ],
      ),
    );
  }

  Widget _stepIndicator(int index, String label, IconData icon) {
    bool isActive = _currentStep == index;
    bool isCompleted = _currentStep > index;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? Colors.blueAccent : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.1),
              width: 2,
            ),
            boxShadow: isActive ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 12)] : [],
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : icon,
            color: isActive || isCompleted ? Colors.white : Colors.white38,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _stepConnector(bool isDone) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
      decoration: BoxDecoration(
        color: isDone ? Colors.blueAccent : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0: return _buildLogisticsStep();
      case 1: return _buildProofStep();
      case 2: return _buildBillingStep();
      default: return Container();
    }
  }

  Widget _buildLogisticsStep() {
    return Column(
      children: [
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
              const SizedBox(height: 16),
              HelpfulTextField(
                label: 'License Number',
                controller: _driverLicenseCtrl,
                hintText: 'Optional',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildActionBtn('NEXT: PROOFS & MATERIAL', _nextStep),
      ],
    );
  }

  Widget _buildProofStep() {
    return Column(
      children: [
        ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _subHeader('Material Inward', Icons.inventory_2_rounded),
              const SizedBox(height: 20),
              HelpfulDropdown<String>(
                label: 'Select Material',
                value: _material,
                items: _materialItems,
                onChanged: (v) => setState(() {
                  _material = v!;
                  _unit = _material.toLowerCase().contains('cement') ? 'bags' : _material.toLowerCase().contains('brick') ? 'units' : 'tons';
                }),
              ),
              const SizedBox(height: 16),
              HelpfulTextField(
                label: 'Quantity Delivered',
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              _subHeader('Mandatory Proofs', Icons.camera_alt_rounded),
              const SizedBox(height: 8),
              Text(
                'Photos are automatically geo-tagged and time-stamped.',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
              const SizedBox(height: 24),
              _photoCaptureRow('Departure Photo', _photo1Location ?? 'Material loaded at source', _photo1Captured, () => _capturePhoto(1)),
              _photoCaptureRow('Arrival Photo', _photo2Location ?? 'Material at site gate', _photo2Captured, () => _capturePhoto(2)),
              _photoCaptureRow('Bill/Invoice Photo', _photo3Location ?? 'Physical copy proof', _photo3Captured, () => _capturePhoto(3)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildSecondaryBtn('BACK', () => setState(() => _currentStep--))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildActionBtn('NEXT: BILLING DETAILS', _nextStep)),
          ],
        ),
      ],
    );
  }

  Widget _buildBillingStep() {
    return Column(
      children: [
        ProfessionalCard(
          useGlass: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _subHeader('Financial Calculation', Icons.calculate_rounded),
              const SizedBox(height: 24),
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
              const Divider(height: 48, color: Colors.white10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Payable', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    '₹${NumberFormat('#,##,###.##').format(_total)}',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildSecondaryBtn('BACK', () => setState(() => _currentStep--))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildActionBtn('SUBMIT FOR APPROVAL', _submit)),
          ],
        ),
      ],
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
            color: isDone ? Colors.greenAccent.withOpacity(0.05) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDone ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDone ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(isDone ? Icons.check_circle_rounded : Icons.camera_alt_rounded, color: isDone ? Colors.greenAccent : Colors.white70),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                  ],
                ),
              ),
              if (isDone)
                const StatusChip(status: UiStatus.approved, labelOverride: 'CAPTURED')
              else
                Icon(Icons.add_a_photo_rounded, color: Colors.blueAccent.withOpacity(0.5), size: 18),
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
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
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
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
    );
  }
}
