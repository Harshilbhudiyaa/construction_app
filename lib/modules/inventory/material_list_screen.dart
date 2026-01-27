import 'package:flutter/material.dart';
import 'dart:io';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/services/inventory_service.dart';
import 'models/material_model.dart';
import 'package:construction_app/modules/inventory/material_form_screen.dart';
import 'package:construction_app/modules/inventory/material_detail_screen.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';

class MaterialListScreen extends StatefulWidget {
  final bool isAdmin;
  final String? activeSiteId;
  const MaterialListScreen({super.key, this.isAdmin = false, this.activeSiteId});

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  final _inventoryService = InventoryService();
  String _searchQuery = '';
  MaterialCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Material Inventory',
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MaterialFormScreen(siteId: widget.activeSiteId)),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      children: [
        StreamBuilder<List<ConstructionMaterial>>(
          stream: _inventoryService.getMaterialsStream(siteId: widget.activeSiteId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Colors.blueAccent)));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
            }

            final materials = snapshot.data ?? [];
            final filteredMaterials = materials.where((m) {
              final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                   m.subType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                   m.availableSizes.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()));
              final matchesCategory = _selectedCategory == null || m.category == _selectedCategory;
              return matchesSearch && matchesCategory;
            }).toList();

            return Column(
              children: [
                _buildSummaryHeader(materials),
                _buildFilters(),
                const SizedBox(height: 16),
                if (filteredMaterials.isEmpty)
                  _buildEmptyState()
                else
                  _buildMaterialList(filteredMaterials),
              ],
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchField(
          hint: 'Search materials or types...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildCategoryChip(null, 'All Materials'),
              ...MaterialCategory.values.map((cat) => _buildCategoryChip(cat, cat.displayName)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(MaterialCategory? category, String label) {
    bool isSelected = _selectedCategory == category;
    IconData icon = category?.icon ?? Icons.all_inclusive_rounded;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = isSelected ? null : category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(List<ConstructionMaterial> materials) {
    final totalValue = materials.fold(0.0, (sum, m) => sum + m.totalAmount);
    final pendingValue = materials.fold(0.0, (sum, m) => sum + m.pendingAmount);
    final lowStockCount = materials.where((m) => m.currentStock < 50).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildSummaryCard(
                'SITE VALUE',
                '₹${(totalValue / 100000).toStringAsFixed(1)}L',
                Icons.account_balance_wallet_rounded,
                Colors.blueAccent,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                'PENDING',
                '₹${(pendingValue / 100000).toStringAsFixed(1)}L',
                Icons.pending_actions_rounded,
                Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProfessionalCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: EdgeInsets.zero,
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orangeAccent),
                const SizedBox(width: 12),
                Text(
                  '$lowStockCount items are low on stock',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialList(List<ConstructionMaterial> filteredMaterials) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredMaterials.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return StaggeredAnimation(
          index: index,
          child: _buildMaterialCard(filteredMaterials[index]),
        );
      },
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: ProfessionalCard(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        borderRadius: 20,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
                Text(
                  value,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(ConstructionMaterial material) {
    final bool isLowStock = material.currentStock < 50;
    
    return ProfessionalCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MaterialDetailScreen(materialId: material.id)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                child: _buildMaterialImage(material),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            material.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                        ),
                        if (widget.isAdmin) _buildAdminActions(material),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${material.category.displayName} • ${material.subType}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRICE / ${material.unitType.label.toUpperCase()}',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${material.pricePerUnit.toStringAsFixed(1)}',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'IN STOCK',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${material.currentStock} ${material.unitType.label}',
                                style: TextStyle(
                                  color: isLowStock ? Colors.orangeAccent : Colors.blueAccent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialImage(ConstructionMaterial material) {
    if (material.photoUrl == null) return _buildPlaceholderImage(material.category);
    
    final isNetwork = material.photoUrl!.startsWith('http') || material.photoUrl!.startsWith('blob:');
    return Image(
      image: isNetwork 
        ? NetworkImage(material.photoUrl!) as ImageProvider
        : FileImage(File(material.photoUrl!)),
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _buildPlaceholderImage(material.category),
    );
  }

  Widget _buildPlaceholderImage(MaterialCategory category) {
    return Container(
      color: const Color(0xFF1A237E).withOpacity(0.05),
      child: Center(
        child: Icon(category.icon, size: 36, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
    );
  }

  Widget _buildAdminActions(ConstructionMaterial material) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MaterialFormScreen(material: material)),
          ),
          child: Icon(Icons.edit_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _confirmDelete(material),
          child: const Icon(Icons.delete_rounded, size: 14, color: Colors.redAccent),
        ),
      ],
    );
  }

  void _confirmDelete(ConstructionMaterial material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Delete Material', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this material?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF78909C))),
          ),
          ElevatedButton(
            onPressed: () {
              _inventoryService.deleteMaterial(material.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Icon(Icons.inventory_2_rounded, size: 64, color: const Color(0xFF1A237E).withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            'Strategic reserves empty.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
