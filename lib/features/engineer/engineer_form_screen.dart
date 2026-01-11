import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/helpful_text_field.dart';
import '../../app/ui/widgets/helpful_dropdown.dart';
import '../../app/utils/feedback_helper.dart';
import 'models/engineer_model.dart';

class EngineerFormScreen extends StatefulWidget {
  final EngineerModel? engineer; // null for add, non-null for edit

  const EngineerFormScreen({super.key, this.engineer});

  @override
  State<EngineerFormScreen> createState() => _EngineerFormScreenState();
}

class _EngineerFormScreenState extends State<EngineerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  
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
    
    _selectedRole = engineer?.role ?? EngineerRole.worker;
    _isActive = engineer?.isActive ?? true;
    _permissions = engineer?.permissions ?? const PermissionSet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.engineer != null;
    
    return ProfessionalPage(
      title: isEditing ? 'Edit Personnel' : 'Add Personnel',
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepBlue1,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                HelpfulTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'Enter full name',
                  icon: Icons.person_rounded,
                  helpText: 'Enter the complete name of the personnel',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                HelpfulTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'engineer@example.com',
                  icon: Icons.email_rounded,
                  helpText: 'Enter a valid email address for communication',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                HelpfulTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: '+91 98765 43210',
                  icon: Icons.phone_rounded,
                  helpText: 'Enter contact number with country code',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                HelpfulDropdown<EngineerRole>(
                  value: _selectedRole,
                  label: 'Role / Position',
                  icon: Icons.work_rounded,
                  helpText: 'Select the role for this personnel',
                  items: EngineerRole.values,
                  labelMapper: (role) => role.displayName,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Status Toggle
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.toggle_on_rounded, color: AppColors.deepBlue1),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: Text(
                          'Active Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepBlue1,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Permissions Section
                const Text(
                  'Role-Based Permissions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepBlue1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Toggle permissions to control what this personnel can access',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

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
                  'Tool & Machine Management',
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

                const SizedBox(height: AppSpacing.xl),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.deepBlue1),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.deepBlue1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveEngineer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepBlue1,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isEditing ? 'Update Personnel' : 'Add Personnel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: value ? Colors.green.withOpacity(0.05) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.green.withOpacity(0.3) : Colors.grey[300]!,
          ),
        ),
        child: CheckboxListTile(
          value: value,
          onChanged: (val) => onChanged(val ?? false),
          title: Row(
            children: [
              Icon(icon, size: 20, color: value ? Colors.green : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: value ? Colors.green[700] : Colors.grey[700],
                ),
              ),
            ],
          ),
          activeColor: Colors.green,
          controlAffinity: ListTileControlAffinity.trailing,
        ),
      ),
    );
  }

  void _saveEngineer() {
    if (_formKey.currentState!.validate()) {
      final engineer = EngineerModel(
        id: widget.engineer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        role: _selectedRole,
        permissions: _permissions,
        isActive: _isActive,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        createdAt: widget.engineer?.createdAt ?? DateTime.now(),
        lastLogin: widget.engineer?.lastLogin,
      );

      // In a real app, save to database here
      FeedbackHelper.showSuccess(
        context,
        widget.engineer != null
            ? 'Personnel updated successfully!'
            : 'Personnel added successfully!',
      );
      
      Navigator.pop(context, engineer);
    }
  }
}
