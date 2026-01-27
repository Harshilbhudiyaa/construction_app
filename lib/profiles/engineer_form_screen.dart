import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/mock_engineer_service.dart';
import 'package:construction_app/shared/widgets/confirm_dialog.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/utils/feedback_helper.dart';
import 'package:construction_app/profiles/engineer_model.dart';


class EngineerFormScreen extends StatefulWidget {
  final EngineerModel? engineer; // null for add, non-null for edit
  final EngineerRole? initialRole;
  final bool isSelfEdit;

  const EngineerFormScreen({
    super.key, 
    this.engineer, 
    this.initialRole,
    this.isSelfEdit = false,
  });

  @override
  State<EngineerFormScreen> createState() => _EngineerFormScreenState();
}

class _EngineerFormScreenState extends State<EngineerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _siteController;
  late final TextEditingController _customRoleController;
  
  late EngineerRole _selectedRole;
  late bool _isActive;
  late PermissionSet _permissions;

  @override
  void initState() {
    super.initState();
    
    final engineer = widget.engineer;
    _nameController = TextEditingController(text: engineer?.name ?? '');
    _emailController = TextEditingController(text: engineer?.email ?? '');
    _phoneController = TextEditingController(text: engineer?.phone ?? '');
    _siteController = TextEditingController(text: engineer?.assignedSite ?? '');
    _customRoleController = TextEditingController(text: engineer?.customRoleName ?? '');
    
    _selectedRole = engineer?.role ?? widget.initialRole ?? EngineerRole.worker;
    _isActive = engineer?.isActive ?? true;
    _permissions = engineer?.permissions ?? _selectedRole.mandatoryPermissions;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _siteController.dispose();
    _customRoleController.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    final hasData = _nameController.text.trim().isNotEmpty ||
        _emailController.text.trim().isNotEmpty ||
        _phoneController.text.trim().isNotEmpty;

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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.engineer != null;
    
    return ProfessionalPage(
      title: widget.isSelfEdit 
          ? 'My Profile' 
          : (isEditing ? 'Edit Personnel' : 'Add Personnel'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: StaggeredAnimation(
            index: 0,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfessionalCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Personal Information', Icons.person_outline_rounded),
                        const SizedBox(height: 24),
                        
                        HelpfulTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hintText: 'Enter full name',
                          icon: Icons.person_rounded,
                          helpText: 'Enter the complete name of the personnel',
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter a name';
                            if (value.length < 3) return 'Name must be at least 3 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        HelpfulTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hintText: 'engineer@example.com',
                          icon: Icons.email_rounded,
                          helpText: 'Enter a valid email address for communication',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!value.contains('@') || !value.contains('.')) return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        HelpfulTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hintText: '+91 98765 43210',
                          icon: Icons.phone_rounded,
                          helpText: 'Enter contact number with country code',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length < 10) return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                         HelpfulDropdown<EngineerRole>(
                          value: _selectedRole,
                          label: 'Role / Position',
                          icon: Icons.work_rounded,
                          readOnly: widget.isSelfEdit,
                          helpText: 'Select the role for this personnel',
                          items: EngineerRole.values,
                          labelMapper: (role) => role.displayName,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedRole = value;
                                // Auto-update permissions based on role if it's a new personnel
                                if (widget.engineer == null) {
                                  _permissions = value.mandatoryPermissions;
                                }
                              });
                            }
                          },
                        ),
                        if (_selectedRole == EngineerRole.other) ...[
                          const SizedBox(height: 20),
                          HelpfulTextField(
                            controller: _customRoleController,
                            label: 'Custom Role Name',
                            hintText: 'e.g., Security Guard, Driver',
                            icon: Icons.assignment_ind_rounded,
                            helpText: 'Specify the designation for this personnel',
                            validator: (value) {
                              if (_selectedRole == EngineerRole.other && (value == null || value.isEmpty)) {
                                return 'Please enter the role name';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Status Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                                  color: _isActive ? Colors.greenAccent : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Active Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      _isActive ? 'Personnel is currently active' : 'Personnel is temporarily disabled',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isActive,
                                onChanged: widget.isSelfEdit ? null : (value) => setState(() => _isActive = value),
                                activeColor: Colors.greenAccent,
                                activeTrackColor: Colors.greenAccent.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Permissions Section
                    ProfessionalCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Role-Based Permissions', Icons.security_rounded),
                        const SizedBox(height: 8),
                        Text(
                          'Toggle permissions to control what this personnel can access',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildPermissionToggle(
                          'Site Management',
                          Icons.location_city_rounded,
                          _permissions.siteManagement,
                          (value) => setState(() => _permissions = _permissions.copyWith(siteManagement: value)),
                        ),
                        _buildPermissionToggle(
                          'Worker Management',
                          Icons.groups_rounded,
                          _permissions.workerManagement,
                          (value) => setState(() => _permissions = _permissions.copyWith(workerManagement: value)),
                        ),
                        _buildPermissionToggle(
                          'Inventory Management',
                          Icons.inventory_2_rounded,
                          _permissions.inventoryManagement,
                          (value) => setState(() => _permissions = _permissions.copyWith(inventoryManagement: value)),
                        ),
                        _buildPermissionToggle(
                          'Machine Management',
                          Icons.precision_manufacturing_rounded,
                          _permissions.toolMachineManagement,
                          (value) => setState(() => _permissions = _permissions.copyWith(toolMachineManagement: value)),
                        ),
                        _buildPermissionToggle(
                          'Report Viewing',
                          Icons.analytics_rounded,
                          _permissions.reportViewing,
                          (value) => setState(() => _permissions = _permissions.copyWith(reportViewing: value)),
                        ),
                        _buildPermissionToggle(
                          'Approval & Verification',
                          Icons.verified_rounded,
                          _permissions.approvalVerification,
                          (value) => setState(() => _permissions = _permissions.copyWith(approvalVerification: value)),
                        ),
                        _buildPermissionToggle(
                          'Create Site',
                          Icons.add_location_rounded,
                          _permissions.createSite,
                          (value) => setState(() => _permissions = _permissions.copyWith(createSite: value)),
                        ),
                        _buildPermissionToggle(
                          'Edit Site',
                          Icons.edit_location_rounded,
                          _permissions.editSite,
                          (value) => setState(() => _permissions = _permissions.copyWith(editSite: value)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  HelpfulTextField(
                    label: 'Assigned Site',
                    controller: _siteController,
                    icon: Icons.location_on_rounded,
                    readOnly: widget.isSelfEdit,
                    hintText: 'e.g., Riverside Complex Block A',
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons (Hidden for Self-View)
                  if (!widget.isSelfEdit)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _handleBack,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                'Discard',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.blueAccent, AppColors.deepBlue3],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _saveEngineer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text(
                                  isEditing ? 'Update Changes' : 'Create Personnel',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildPermissionToggle(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.isSelfEdit ? null : () => onChanged(!value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: value ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: value ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: value ? FontWeight.w700 : FontWeight.w500,
                      color: value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: value,
                  onChanged: widget.isSelfEdit ? null : onChanged,
                  activeColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _saveEngineer() {
    if (_formKey.currentState!.validate()) {
      final engineer = EngineerModel(
        id: widget.engineer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        role: widget.isSelfEdit ? widget.engineer!.role : _selectedRole,
        permissions: widget.isSelfEdit ? widget.engineer!.permissions : _permissions,
        isActive: widget.isSelfEdit ? widget.engineer!.isActive : _isActive,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        assignedSite: _siteController.text.trim().isEmpty ? null : _siteController.text.trim(),
        customRoleName: _selectedRole == EngineerRole.other ? _customRoleController.text.trim() : null,
        createdAt: widget.engineer?.createdAt ?? DateTime.now(),
        lastLogin: widget.engineer?.lastLogin,
      );

      // In a real app, save to database here
      context.read<MockEngineerService>().addEngineer(engineer);

      FeedbackHelper.showSuccess(
        context,
        widget.engineer != null
            ? 'Personnel updated successfully!'
            : 'Personnel added successfully!',
      );
      
      Navigator.pop(context, engineer);
    }
  }

  Widget _sectionTitle(String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
