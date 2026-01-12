import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/staggered_animation.dart';
import '../../app/ui/widgets/app_search_field.dart';
import '../../app/ui/widgets/empty_state.dart';
import '../../app/ui/widgets/status_chip.dart';
import '../../app/utils/feedback_helper.dart';
import 'models/inventory_detail_model.dart';
import 'inventory_form_screen.dart';
import 'inventory_material_detail_screen.dart';

class InventoryDetailManagementScreen extends StatefulWidget {
  const InventoryDetailManagementScreen({super.key});

  @override
  State<InventoryDetailManagementScreen> createState() => _InventoryDetailManagementScreenState();
}

class _InventoryDetailManagementScreenState extends State<InventoryDetailManagementScreen> {
  String _searchQuery = '';
  MaterialCategory? _filterCategory;
  StockStatus? _filterStatus;

  // Sample data
  final List<InventoryDetailModel> _materials = [
    InventoryDetailModel(
      id: '1',
      materialName: 'Portland Cement (OPC 53)',
      category: MaterialCategory.cement,
      totalQuantity: 500,
      consumedQuantity: 320,
      unit: 'Bags',
      lastUpdatedDate: DateTime(2025, 1, 11),
      lastUpdatedBy: 'Store Keeper Amit',
      reorderLevel: 100,
      costPerUnit: 450,
      supplierId: 'sup1',
      supplierName: 'ABC Cement Ltd',
      storageLocation: 'Warehouse A-1',
    ),
    InventoryDetailModel(
      id: '2',
      materialName: 'River Sand',
      category: MaterialCategory.sand,
      totalQuantity: 1200,
      consumedQuantity: 450,
      unit: 'Tons',
      lastUpdatedDate: DateTime(2025, 1, 10),
      lastUpdatedBy: 'Store Keeper Amit',
      reorderLevel: 200,
      costPerUnit: 850,
      supplierId: 'sup2',
      supplierName: 'Sand Supply Co',
      storageLocation: 'Outdoor Yard B',
    ),
    InventoryDetailModel(
      id: '3',
      materialName: 'TMT Steel Bars (12mm)',
      category: MaterialCategory.steel,
      totalQuantity: 2500,
      consumedQuantity: 2100,
      unit: 'Kg',
      lastUpdatedDate: DateTime(2025, 1, 12),
      lastUpdatedBy: 'Rajesh Kumar',
      reorderLevel: 500,
      costPerUnit: 65,
      supplierId: 'sup3',
      supplierName: 'Steel India Pvt Ltd',
      storageLocation: 'Warehouse A-2',
    ),
    InventoryDetailModel(
      id: '4',
      materialName: 'Red Bricks (Class A)',
      category: MaterialCategory.bricks,
      totalQuantity: 50000,
      consumedQuantity: 22000,
      unit: 'Pieces',
      lastUpdatedDate: DateTime(2025, 1, 9),
      lastUpdatedBy: 'Store Keeper Amit',
      reorderLevel: 10000,
      costPerUnit: 8,
      supplierId: 'sup4',
      supplierName: 'Brick Masters',
      storageLocation: 'Outdoor Yard A',
    ),
    InventoryDetailModel(
      id: '5',
      materialName: 'Aggregate 20mm',
      category: MaterialCategory.aggregate,
      totalQuantity: 800,
      consumedQuantity: 710,
      unit: 'Tons',
      lastUpdatedDate: DateTime(2025, 1, 11),
      lastUpdatedBy: 'Priya Sharma',
      reorderLevel: 150,
      costPerUnit: 650,
      supplierId: 'sup2',
      supplierName: 'Sand Supply Co',
      storageLocation: 'Outdoor Yard B',
    ),
    InventoryDetailModel(
      id: '6',
      materialName: 'Wall Paint (White)',
      category: MaterialCategory.paint,
      totalQuantity: 150,
      consumedQuantity: 45,
      unit: 'Liters',
      lastUpdatedDate: DateTime(2025, 1, 8),
      lastUpdatedBy: 'Store Keeper Amit',
      reorderLevel: 30,
      costPerUnit: 320,
      supplierId: 'sup5',
      supplierName: 'Paints & Coatings Ltd',
      storageLocation: 'Warehouse C-1',
    ),
  ];

  List<InventoryDetailModel> get _filteredMaterials {
    var filtered = _materials;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((material) {
        final query = _searchQuery.toLowerCase();
        return material.materialName.toLowerCase().contains(query) ||
            material.category.displayName.toLowerCase().contains(query) ||
            (material.storageLocation?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_filterCategory != null) {
      filtered = filtered.where((m) => m.category == _filterCategory).toList();
    }

    if (_filterStatus != null) {
      filtered = filtered.where((m) => m.stockStatus == _filterStatus).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final totalValue = _materials.fold<double>(
      0,
      (sum, m) => sum + (m.remainingStock * (m.costPerUnit ?? 0)),
    );
    
    return ProfessionalPage(
      title: 'Inventory Details',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMaterialDialog(context),
        backgroundColor: AppColors.deepBlue1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Material', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      children: [
        AppSearchField(
          hint: 'Search by material, category, or location...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),

        // Category Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', _filterCategory == null && _filterStatus == null, () {
                  setState(() {
                    _filterCategory = null;
                    _filterStatus = null;
                  });
                }),
                const SizedBox(width: 8),
                ...MaterialCategory.values.take(6).map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      '${category.icon} ${category.displayName}',
                      _filterCategory == category,
                      () => setState(() => _filterCategory = category),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Stock Status Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: StockStatus.values.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    '${status.icon} ${status.displayName}',
                    _filterStatus == status,
                    () => setState(() => _filterStatus = status),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Summary Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'MATERIALS',
                  '${_materials.length}',
                  Icons.category_rounded,
                  Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'LOW STOCK',
                  '${_materials.where((m) => m.isLowStock).length}',
                  Icons.warning_amber_rounded,
                  Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'STOCK VALUE',
                  '₹${(totalValue / 100000).toStringAsFixed(1)}L',
                  Icons.currency_rupee_rounded,
                  Colors.greenAccent,
                ),
              ),
            ],
          ),
        ),
        
        const ProfessionalSectionHeader(
          title: 'Material Inventory',
          subtitle: 'Real-time stock levels and consumption tracking',
        ),

        if (_filteredMaterials.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: EmptyState(
              icon: Icons.inventory_2_rounded,
              title: 'No Materials Found',
              message: 'Try adjusting your filters or add new materials.',
            ),
          )
        else
          ..._filteredMaterials.asMap().entries.map((entry) {
            final index = entry.key;
            final material = entry.value;
            
            return StaggeredAnimation(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ProfessionalCard(
                  useGlass: true,
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    onTap: () => _showMaterialDetails(context, material),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Material Icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(material.stockStatus).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: _getStatusColor(material.stockStatus).withOpacity(0.2)),
                                ),
                                child: Center(
                                  child: Text(
                                    material.category.icon,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Material Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      material.materialName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 17,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      material.category.displayName.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.4),
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status Badge
                              StatusChip(
                                status: material.stockStatus == StockStatus.adequate 
                                  ? UiStatus.ok 
                                  : material.stockStatus == StockStatus.warning 
                                    ? UiStatus.alert 
                                    : UiStatus.stop,
                                labelOverride: material.stockStatus.displayName.toUpperCase(),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Quantity Display
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildQuantityDisplay(
                                    'TOTAL',
                                    material.totalQuantity,
                                    material.unit,
                                    Colors.blueAccent,
                                  ),
                                ),
                                Container(height: 24, width: 1, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 8)),
                                Expanded(
                                  child: _buildQuantityDisplay(
                                    'CONSUMED',
                                    material.consumedQuantity,
                                    material.unit,
                                    Colors.orangeAccent,
                                  ),
                                ),
                                Container(height: 24, width: 1, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 8)),
                                Expanded(
                                  child: _buildQuantityDisplay(
                                    'STOCK',
                                    material.remainingStock,
                                    material.unit,
                                    Colors.greenAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Consumption Progress Bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'CONSUMPTION RATE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.3),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${material.consumptionPercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: material.consumptionPercentage > 80 ? Colors.orangeAccent : Colors.blueAccent,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: material.consumptionPercentage / 100,
                                  backgroundColor: Colors.white.withOpacity(0.05),
                                  valueColor: AlwaysStoppedAnimation(
                                    material.consumptionPercentage > 80 ? Colors.orangeAccent : Colors.blueAccent,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildDetailLabel(Icons.warehouse_rounded, 'LOCATION', material.storageLocation ?? 'N/A'),
                              const SizedBox(width: 16),
                              _buildDetailLabel(Icons.update_rounded, 'UPDATED', _formatDate(material.lastUpdatedDate)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? AppColors.deepBlue1 : Colors.white70,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityDisplay(String label, double value, String unit, Color color) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: Colors.white.withOpacity(0.3),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailLabel(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.3)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.3),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.adequate:
        return Colors.green;
      case StockStatus.warning:
        return Colors.orange;
      case StockStatus.lowStock:
        return Colors.red;
      case StockStatus.outOfStock:
        return Colors.red.shade900;
    }
  }

  List<Color> _getStatusGradient(StockStatus status) {
    final color = _getStatusColor(status);
    return [color.withOpacity(0.7), color];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddMaterialDialog(BuildContext context) async {
    final result = await Navigator.push<InventoryDetailModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const InventoryFormScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _materials.add(result);
      });
    }
  }

  void _showMaterialDetails(BuildContext context, InventoryDetailModel material) async {
    final result = await Navigator.push<InventoryDetailModel>(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryMaterialDetailScreen(material: material),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _materials.indexWhere((m) => m.id == material.id);
        if (index != -1) {
          _materials[index] = result;
        }
      });
    }
  }
}
