import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/services/master_material_service.dart';
import 'models/master_material_model.dart';
import 'models/material_model.dart';

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
                            AppColors.deepBlue.withOpacity(0.05),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.deepBlue,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: AppColors.deepBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Icon(m.category.icon, color: Colors.white, size: 24),
                        ),
                        title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${m.category == MaterialCategory.other ? (m.customCategoryName ?? 'Other') : m.category.displayName} • ${m.defaultUnit.label.toUpperCase()}',
                            style: TextStyle(color: AppColors.steelBlue.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                          onPressed: () => _service.deleteMasterMaterial(m.id),
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

  void _showAddMaterialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMasterMaterialDialog(),
    );
  }
}

class AddMasterMaterialDialog extends StatefulWidget {
  const AddMasterMaterialDialog({super.key});

  @override
  State<AddMasterMaterialDialog> createState() => _AddMasterMaterialDialogState();
}

class _AddMasterMaterialDialogState extends State<AddMasterMaterialDialog> {
  final _nameCtrl = TextEditingController();
  final _customCatCtrl = TextEditingController();
  MaterialCategory _selectedCategory = MaterialCategory.cement;
  UnitType _selectedUnit = UnitType.bag;
  final _service = MasterMaterialService();

  @override
  void initState() {
    super.initState();
    _updateUnit();
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
              createdAt: DateTime.now(),
            );
            await _service.addMasterMaterial(m);
            if (mounted) Navigator.pop(context);
          },
          child: const Text('REGISTER'),
        ),
      ],
    );
  }
}
