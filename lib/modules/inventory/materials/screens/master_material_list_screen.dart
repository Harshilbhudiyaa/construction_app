// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/services/master_material_service.dart';
import 'package:construction_app/modules/inventory/materials/models/master_material_model.dart';
import 'package:construction_app/modules/inventory/materials/models/material_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

class MasterMaterialListScreen extends StatefulWidget {
  const MasterMaterialListScreen({super.key});

  @override
  State<MasterMaterialListScreen> createState() => _MasterMaterialListScreenState();
}

class _MasterMaterialListScreenState extends State<MasterMaterialListScreen> {
  final _service = MasterMaterialService();

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Material Registry',
      subtitle: 'Global Master Material List',
      actions: [
        IconButton(
          onPressed: () => _showAddMaterialDialog(context),
          icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.blueAccent),
        ),
      ],
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: ProfessionalSectionHeader(
            title: 'Available Materials',
            subtitle: 'Standardized materials for use across all sites',
          ),
        ),
        StreamBuilder<List<MasterMaterial>>(
          stream: _service.getMasterMaterialsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final materials = snapshot.data ?? [];
            if (materials.isEmpty) {
              return const EmptyState(
                icon: Icons.inventory_2_rounded,
                title: 'No materials registered',
                message: 'Add materials to the master list to start using them on sites.',
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final m = materials[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ProfessionalCard(
                    padding: const EdgeInsets.all(0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.deepBlue.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.deepBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: m.photoUrl != null && m.photoUrl!.isNotEmpty
                                ? (m.photoUrl!.startsWith('http') || kIsWeb
                                    ? Image.network(
                                        m.photoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(m.category.icon, color: AppColors.deepBlue, size: 24),
                                      )
                                    : Image.file(
                                        File(m.photoUrl!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(m.category.icon, color: AppColors.deepBlue, size: 24),
                                      ))
                                : Icon(m.category.icon, color: AppColors.deepBlue, size: 24),
                          ),
                        ),
                        title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${m.category == MaterialCategory.other ? (m.customCategoryName ?? 'Other') : m.category.displayName} • ${m.defaultUnit.label.toUpperCase()}',
                            style: TextStyle(color: AppColors.steelBlue.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent, size: 24),
                              onPressed: () => _showAddMaterialDialog(context, m),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                              onPressed: () => _service.deleteMasterMaterial(m.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showAddMaterialDialog(BuildContext context, [MasterMaterial? material]) {
    showDialog(
      context: context,
      builder: (context) => AddMasterMaterialDialog(material: material),
    );
  }
}

class AddMasterMaterialDialog extends StatefulWidget {
  final MasterMaterial? material;
  const AddMasterMaterialDialog({super.key, this.material});

  @override
  State<AddMasterMaterialDialog> createState() => _AddMasterMaterialDialogState();
}

class _AddMasterMaterialDialogState extends State<AddMasterMaterialDialog> {
  final _nameCtrl = TextEditingController();
  final _customCatCtrl = TextEditingController();
  MaterialCategory _selectedCategory = MaterialCategory.cement;
  UnitType _selectedUnit = UnitType.bag;
  String? _imagePath;
  final _service = MasterMaterialService();
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      _nameCtrl.text = widget.material!.name;
      _customCatCtrl.text = widget.material!.customCategoryName ?? '';
      _selectedCategory = widget.material!.category;
      _selectedUnit = widget.material!.defaultUnit;
      _imagePath = widget.material!.photoUrl;
    } else {
      _updateUnit();
    }
  }

  void _updateUnit() {
    setState(() {
      _selectedUnit = MasterMaterial.getAutoUnit(_selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final showCustomInput = _selectedCategory == MaterialCategory.other;

    return AlertDialog(
      title: const Text('Register Master Material'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.deepBlue.withValues(alpha: 0.2)),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _imagePath!.startsWith('http') || kIsWeb
                            ? Image.network(_imagePath!, fit: BoxFit.cover)
                            : Image.file(File(_imagePath!), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, color: AppColors.deepBlue),
                            const SizedBox(height: 4),
                            const Text('Photo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            HelpfulDropdown<MaterialCategory>(
              label: 'Material Category',
              value: _selectedCategory,
              items: MaterialCategory.values,
              labelMapper: (cat) => cat.displayName,
              onChanged: (cat) {
                if (cat != null) {
                  setState(() => _selectedCategory = cat);
                  _updateUnit();
                }
              },
            ),
            if (showCustomInput) ...[
              const SizedBox(height: 16),
              HelpfulTextField(
                label: 'Custom Category Name',
                controller: _customCatCtrl,
                hintText: 'e.g. Waterproofing',
              ),
            ],
            const SizedBox(height: 16),
            HelpfulTextField(
              label: 'Material Name',
              controller: _nameCtrl,
              hintText: 'e.g. ACC Suraksha Cement',
            ),
            const SizedBox(height: 16),
            HelpfulDropdown<UnitType>(
              label: 'Default Unit',
              value: _selectedUnit,
              items: UnitType.values,
              labelMapper: (unit) => unit.label,
              onChanged: (unit) {
                if (unit != null) setState(() => _selectedUnit = unit);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: () async {
            if (_nameCtrl.text.isEmpty) return;
            final m = MasterMaterial(
              id: 'MM-${DateTime.now().millisecondsSinceEpoch}',
              name: _nameCtrl.text,
              category: _selectedCategory,
              defaultUnit: _selectedUnit,
              customCategoryName: showCustomInput ? _customCatCtrl.text : null,
              photoUrl: _imagePath,
              createdAt: widget.material?.createdAt ?? DateTime.now(),
            );

            if (widget.material != null) {
              await _service.updateMasterMaterial(m);
            } else {
              await _service.addMasterMaterial(m);
            }
            
            if (mounted) Navigator.pop(context);
          },
          child: Text(widget.material != null ? 'UPDATE' : 'REGISTER'),
        ),
      ],
    );
  }
}
