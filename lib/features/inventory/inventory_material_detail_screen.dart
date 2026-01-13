import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/status_chip.dart';
import 'models/inventory_detail_model.dart';
import 'package:intl/intl.dart';
import 'inventory_form_screen.dart';

class InventoryMaterialDetailScreen extends StatelessWidget {
  final InventoryDetailModel material;

  const InventoryMaterialDetailScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Material Details',
      actions: [
        IconButton(
          onPressed: () => _editMaterial(context),
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              ProfessionalCard(
                useGlass: true,
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Center(
                        child: Text(
                          material.category.icon,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.materialName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStockStatusBadge(material.stockStatus),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _sectionTitle('Stock Analytics', Icons.analytics_rounded),
              const SizedBox(height: 16),
              _buildStockMetrics(material),
              
              const SizedBox(height: 24),
              ProfessionalCard(
                useGlass: true,
                padding: const EdgeInsets.all(24),
                child: _buildProgressBar(material),
              ),

              const SizedBox(height: 24),
              _sectionTitle('Logistics & Sourcing', Icons.business_rounded),
              const SizedBox(height: 16),
              ProfessionalCard(
                useGlass: true,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.business_rounded, 'Supplier', material.supplierName ?? 'Not Specified'),
                    const SizedBox(height: 20),
                    _buildInfoRow(Icons.warehouse_rounded, 'Storage Location', material.storageLocation ?? 'Main Warehouse'),
                    const SizedBox(height: 20),
                    _buildInfoRow(Icons.update_rounded, 'Last Sync', DateFormat('MMM dd, yyyy • hh:mm a').format(material.lastUpdatedDate)),
                    const SizedBox(height: 20),
                    _buildInfoRow(Icons.person_rounded, 'Admin Operator', material.lastUpdatedBy ?? 'System'),
                  ],
                ),
              ),

              if (material.metadata != null && material.metadata!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionTitle('Specific Specifications', Icons.tune_rounded),
                const SizedBox(height: 16),
                ProfessionalCard(
                  useGlass: true,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: material.metadata!.entries.map((e) {
                      String label = e.key;
                      // Format key to printable label
                      if (label == 'steelSize') label = 'Bar Diameter';
                      if (label == 'brickType') label = 'Brick/Block Type';
                      if (label == 'aggregateSize') label = 'Aggregate Size';
                      if (label == 'paintFinish') label = 'Paint Finish';
                      if (label == 'customCategory') label = 'Specific Type';

                      return Padding(
                        padding: EdgeInsets.only(bottom: e.key == material.metadata!.keys.last ? 0 : 20),
                        child: _buildInfoRow(Icons.label_important_rounded, label, e.value.toString()),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 48),
              Container(
                width: double.infinity,
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
                child: ElevatedButton.icon(
                  onPressed: () => _editMaterial(context),
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  label: const Text(
                    'Update Stock Levels',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatusBadge(StockStatus status) {
    Color color;
    switch (status) {
      case StockStatus.adequate: color = Colors.greenAccent; break;
      case StockStatus.warning: color = Colors.orangeAccent; break;
      case StockStatus.lowStock: color = Colors.redAccent; break;
      case StockStatus.outOfStock: color = Colors.red; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '${status.icon} ${status.displayName}',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStockMetrics(InventoryDetailModel material) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            'In Stock',
            material.totalQuantity.toString(),
            material.unit,
            Colors.blueAccent,
            Icons.inventory_2_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            'Consumed',
            material.consumedQuantity.toString(),
            material.unit,
            Colors.orangeAccent,
            Icons.outbox_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            'Available',
            material.remainingStock.toString(),
            material.unit,
            Colors.greenAccent,
            Icons.check_circle_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, String unit, Color color, IconData icon) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '${label.toUpperCase()}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildProgressBar(InventoryDetailModel material) {
    final percent = material.consumptionPercentage;
    final color = percent > 85 ? Colors.redAccent : (percent > 60 ? Colors.orangeAccent : Colors.greenAccent);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stock Utilization',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            FractionallySizedBox(
              widthFactor: (percent / 100).clamp(0.0, 1.0),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.5), color],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          percent > 85 
            ? 'CRITICAL: Stock nearly depleted. Action required.'
            : percent > 60 
              ? 'WARNING: Consumption rising. Monitor closely.'
              : 'HEALTHY: Resource levels are stable.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editMaterial(BuildContext context) async {
    final result = await Navigator.push<InventoryDetailModel>(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryFormScreen(material: material),
      ),
    );
    if (result != null && context.mounted) {
      Navigator.pop(context, result);
    }
  }
}
