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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              ProfessionalCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                gradient: const LinearGradient(
                  colors: [AppColors.deepBlue1, AppColors.deepBlue3],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          material.category.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.materialName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          StatusChip(
                            status: material.stockStatus == StockStatus.adequate
                              ? UiStatus.ok
                              : material.stockStatus == StockStatus.warning
                                ? UiStatus.alert
                                : UiStatus.stop,
                            labelOverride: material.stockStatus.displayName.toUpperCase(),
                          ),
                          const SizedBox(height: 8),
                          _buildStockStatusBadge(material.stockStatus),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Stock Analytics'),
              ProfessionalCard(
                child: Column(
                  children: [
                    _buildStockMetrics(material),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 15),
                    _buildProgressBar(material),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Logistics & Procurement'),
              ProfessionalCard(
                child: Column(
                  children: [
                    _buildInfoRow(Icons.business_rounded, 'Supplier', material.supplierName ?? 'Not Specified'),
                    const Divider(height: 20),
                    _buildInfoRow(Icons.warehouse_rounded, 'Storage', material.storageLocation ?? 'Main Warehouse'),
                    const Divider(height: 20),
                    _buildInfoRow(Icons.update_rounded, 'Last Update', DateFormat('MMM dd, yyyy').format(material.lastUpdatedDate)),
                    const Divider(height: 20),
                    _buildInfoRow(Icons.person_rounded, 'Updated By', material.lastUpdatedBy ?? 'System'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _editMaterial(context),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Update Stock levels'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.deepBlue1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetric('Total', material.totalQuantity.toString(), material.unit, Colors.blue),
        _buildMetric('Consumed', material.consumedQuantity.toString(), material.unit, Colors.orange),
        _buildMetric('Remaining', material.remainingStock.toString(), material.unit, Colors.green),
      ],
    );
  }

  Widget _buildMetric(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        Text(
          '$label ($unit)',
          style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProgressBar(InventoryDetailModel material) {
    final percent = material.consumptionPercentage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Utilization', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepBlue1)),
            Text('${percent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepBlue1)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(percent > 85 ? Colors.red : (percent > 60 ? Colors.orange : Colors.green)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.deepBlue1.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.deepBlue1, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.deepBlue1,
                  fontWeight: FontWeight.bold,
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
