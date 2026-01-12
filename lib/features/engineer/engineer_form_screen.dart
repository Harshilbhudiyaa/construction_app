import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/helpful_text_field.dart';
import '../../app/ui/widgets/helpful_dropdown.dart';
import '../../app/ui/widgets/staggered_animation.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: StaggeredAnimation(
            index: 0,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfessionalCard(
                    useGlass: true,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        HelpfulTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hintText: 'Enter full name',
                          icon: Icons.person_rounded,
                          useGlass: true,
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
                          useGlass: true,
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
                          useGlass: true,
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
                          useGlass: true,
                          helpText: 'Select the role for this personnel',
                          items: EngineerRole.values,
                          labelMapper: (role) => role.displayName,
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedRole = value);
                          },
                        ),
                        const SizedBox(height: 24),

                        // Status Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                                    const Text(
                                      'Active Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _isActive ? 'Personnel is currently active' : 'Personnel is temporarily disabled',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isActive,
                                onChanged: (value) => setState(() => _isActive = value),
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
                    useGlass: true,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.security_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Role-Based Permissions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toggle permissions to control what this personnel can access',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
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

                  const SizedBox(height: 32),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: BorderSide(color: Colors.white.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
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
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                isEditing ? 'Update Changes' : 'Create Personnel',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: value ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.1),
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
                    color: value ? Colors.white : Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: value ? FontWeight.w700 : FontWeight.w500,
                      color: value ? Colors.white : Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.blueAccent.withOpacity(0.5),
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
