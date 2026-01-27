import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/widgets/confirm_dialog.dart';
import 'package:construction_app/utils/input_formatters.dart';
import 'package:construction_app/utils/feedback_helper.dart';
import 'package:construction_app/services/mock_worker_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:construction_app/services/auth_service.dart';
import 'package:construction_app/services/approval_service.dart';
import 'package:construction_app/governance/approvals/models/action_request.dart';
import 'package:construction_app/profiles/worker_types.dart';
import 'package:construction_app/services/mock_notification_service.dart';

class WorkerFormScreen extends StatefulWidget {
  final Worker? initial;
  final String? currentSiteId;

  const WorkerFormScreen({super.key, this.initial, this.currentSiteId});

  @override
  State<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends State<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.initial?.name ?? '',
  );
  late final TextEditingController _phoneCtrl = TextEditingController(
    text: widget.initial?.phone ?? '',
  );
  late final TextEditingController _rateCtrl = TextEditingController(
    text: (widget.initial?.rateAmount ?? 800).toString(),
  );

  String _skill = (kSkills.contains('Mason') ? 'Mason' : kSkills.first);
  WorkerShift _shift = WorkerShift.day;
  PayRateType _rateType = PayRateType.perDay;
  WorkerStatus _status = WorkerStatus.active;
  String? _photoUrl;
  bool _isLoading = false;
  late List<String> _workTypes = [];

  @override
  void initState() {
    super.initState();
    final w = widget.initial;
    if (w != null) {
      _skill = w.skill;
      _shift = w.shift;
      _rateType = w.rateType;
      _status = w.status;
      _photoUrl = w.photoUrl;
      _workTypes = List<String>.from(w.assignedWorkTypes);
    } else {
      _workTypes = [
        'Concrete Work',
        'Brick / Block Work',
      ].where(kWorkTypes.contains).toList();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _toggleWorkType(String wt) {
    setState(() {
      if (_workTypes.contains(wt)) {
        _workTypes.remove(wt);
      } else {
        _workTypes.add(wt);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      FeedbackHelper.showWarning(
        context,
        'Please fill in all required fields correctly',
      );
      return;
    }
    
    if (_workTypes.isEmpty) {
      FeedbackHelper.showWarning(
        context,
        'Please select at least one work type for this worker',
      );
      return;
    }

    final rateText = _rateCtrl.text.trim().replaceAll(RegExp(r'[^\d.]'), '');
    final rate = num.tryParse(rateText);
    if (rate == null || rate <= 0) {
      FeedbackHelper.showError(
        context,
        'Please enter a valid pay rate greater than zero',
      );
      return;
    }

    final isEdit = widget.initial != null;
    final id =
        widget.initial?.id ??
        'WK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    setState(() => _isLoading = true);

    final worker = Worker(
      id: id,
      siteId: widget.currentSiteId ?? widget.initial?.siteId,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), ''),
      skill: _skill,
      shift: _shift,
      rateType: _rateType,
      rateAmount: rate,
      status: _status,
      photoUrl: _photoUrl,
      assignedWorkTypes: List<String>.from(_workTypes),
    );

    try {
      final authService = context.read<AuthService>();
      final isEngineer = authService.userRole == 'engineer';

      if (isEngineer) {
        final approvalService = context.read<ApprovalService>();
        final notificationService = context.read<MockNotificationService>();
        await Future.delayed(const Duration(milliseconds: 1500));
        approvalService.submitRequest(ActionRequest(
          id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
          siteId: worker.siteId ?? 'S-001',
          requesterId: authService.userId ?? 'unknown',
          requesterName: 'Engineer',
          entityType: 'worker',
          action: isEdit ? ActionType.edit : ActionType.add,
          payload: worker.copyWith(id: id).toJson(),
          createdAt: DateTime.now(),
        ), notificationService: notificationService);

        if (!mounted) return;
        FeedbackHelper.showSuccess(
          context,
          'Your request to ${isEdit ? "update" : "register"} ${worker.name} has been submitted to Admin for approval.',
        );
        Navigator.pop(context);
        return;
      }

      final service = context.read<MockWorkerService>();
      await Future.delayed(const Duration(milliseconds: 1000));
      if (isEdit) {
        service.updateWorker(worker);
      } else {
        service.addWorker(worker);
      }

      if (!mounted) return;
      FeedbackHelper.showSuccess(
        context,
        isEdit 
            ? '✓ ${worker.name}\'s profile has been updated successfully'
            : '✓ ${worker.name} has been added to your workforce',
      );
      Navigator.pop(context, worker);
    } catch (e) {
      if (mounted) {
        FeedbackHelper.showError(context, 'Failed to save worker details: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleBack() async {
    final hasData = _nameCtrl.text.trim().isNotEmpty ||
        _phoneCtrl.text.trim().isNotEmpty ||
        _rateCtrl.text.trim() != '800';

    if (!hasData) {
      Navigator.pop(context);
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Discard Changes?',
      message: 'You have unsaved changes. Are you sure you want to go back without saving?',
      confirmText: 'Discard',
      cancelText: 'Keep Editing',
      icon: Icons.warning_rounded,
      iconColor: Colors.orange,
      isDangerous: true,
    );

    if (confirmed && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _showImageOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile Photo',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildImageOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                if (_photoUrl != null)
                  _buildImageOption(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remove',
                    color: Colors.redAccent,
                    onTap: () {
                      setState(() => _photoUrl = null);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final themeColor = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: themeColor, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      setState(() => _photoUrl = pickedFile.path);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Stack(
      children: [
        ProfessionalPage(
          title: isEdit ? 'Update Profile' : 'Register Workforce',
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildImageSection(),
                  const SizedBox(height: 32),
                  ProfessionalCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(context, 'Core Identity', Icons.person_search_rounded),
                          const SizedBox(height: 24),
                          HelpfulTextField(
                            label: 'Full Name',
                            controller: _nameCtrl,
                            icon: Icons.person_rounded,
                            hintText: 'e.g., Ramesh Kumar',
                            tooltipMessage: 'Enter the worker\'s full legal name as per official documents',
                            helpText: 'First name and surname',
                            inputFormatters: [NameFormatter()],
                            validator: (v) => (v ?? '').trim().isEmpty ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 20),
                          HelpfulTextField(
                            label: 'Phone Number',
                            controller: _phoneCtrl,
                            icon: Icons.phone_android_rounded,
                            hintText: 'e.g., 9876543210',
                            keyboardType: TextInputType.phone,
                            tooltipMessage: 'Primary contact number for work notifications and payments',
                            helpText: '10-digit mobile number',
                            inputFormatters: [PhoneNumberFormatter()],
                            validator: (v) {
                              final t = (v ?? '').trim();
                              if (t.isEmpty) return 'Phone number is required';
                              final digits = t.replaceAll(RegExp(r'\D'), '');
                              if (digits.length < 10) return 'Enter a valid 10-digit phone number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          HelpfulDropdown<String>(
                            label: 'Primary Skill',
                            value: _skill,
                            items: kSkills,
                            icon: Icons.engineering_rounded,
                            tooltipMessage: 'Main area of expertise and work specialization',
                            helpText: 'Select the worker\'s primary skill set',
                            onChanged: (v) => setState(() => _skill = v!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfessionalCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(context, 'Employment & Pay', Icons.payments_rounded),
                        const SizedBox(height: 24),
                        HelpfulDropdown<WorkerShift>(
                          label: 'Assigned Shift',
                          value: _shift,
                          items: WorkerShift.values,
                          labelMapper: shiftLabel,
                          icon: Icons.access_time_rounded,
                          tooltipMessage: 'Work shift timing - affects scheduling and availability',
                          helpText: 'Day shift: 6 AM - 6 PM, Night shift: 6 PM - 6 AM',
                          onChanged: (v) => setState(() => _shift = v!),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: HelpfulDropdown<PayRateType>(
                                label: 'Rate Type',
                                value: _rateType,
                                items: PayRateType.values,
                                labelMapper: rateTypeLabel,
                                icon: Icons.speed_rounded,
                                tooltipMessage: 'Payment calculation basis',
                                helpText: 'How compensation is calculated',
                                onChanged: (v) => setState(() => _rateType = v!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: HelpfulTextField(
                                label: 'Amount (₹)',
                                controller: _rateCtrl,
                                icon: Icons.currency_rupee_rounded,
                                hintText: '800',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                tooltipMessage: 'Pay rate amount in Indian Rupees',
                                helpText: 'Standard rate',
                                inputFormatters: [CurrencyFormatter()],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        HelpfulDropdown<WorkerStatus>(
                          label: 'System Status',
                          value: _status,
                          items: WorkerStatus.values,
                          labelMapper: statusLabel,
                          icon: Icons.verified_user_rounded,
                          tooltipMessage: 'Current availability in the system',
                          onChanged: (v) => setState(() => _status = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfessionalCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(context, 'Competencies', Icons.fact_check_rounded),
                        const SizedBox(height: 8),
                        Text(
                          'Select assigned task categories for this worker',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: kWorkTypes.map((wt) {
                            final selected = _workTypes.contains(wt);
                            return GestureDetector(
                              onTap: () => _toggleWorkType(wt),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      selected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                      size: 16,
                                      color: selected ? Colors.white : Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      wt,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleBack,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Discard',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              isEdit ? 'Update Details' : 'Finalize Registration',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 4),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Processing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.15), width: 2),
                image: _photoUrl != null
                    ? DecorationImage(
                        image: _photoUrl!.startsWith('http')
                            ? NetworkImage(_photoUrl!) as ImageProvider
                            : FileImage(File(_photoUrl!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _photoUrl == null
                  ? Icon(Icons.person_rounded, size: 60, color: Theme.of(context).colorScheme.primary.withOpacity(0.2))
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 22, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _photoUrl == null ? 'ADD PROFILE PHOTO' : 'CHANGE PHOTO',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
