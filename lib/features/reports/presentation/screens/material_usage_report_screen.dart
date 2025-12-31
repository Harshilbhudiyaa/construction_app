import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class MaterialUsageReportScreen extends StatefulWidget {
  const MaterialUsageReportScreen({super.key});

  @override
  State<MaterialUsageReportScreen> createState() => _MaterialUsageReportScreenState();
}

class _MaterialUsageReportScreenState extends State<MaterialUsageReportScreen> {
  String _selectedPeriod = 'Month';

  final List<MaterialUsageData> _materials = [
    MaterialUsageData(
      name: 'Cement',
      unit: 'bags',
      consumed: 2450,
      threshold: 200,
      stock: 680,
      wastage: 2.3,
      color: Colors.blue,
    ),
    MaterialUsageData(
      name: 'Sand',
      unit: 'tons',
      consumed: 145,
      threshold: 15,
      stock: 42,
      wastage: 1.8,
      color: Colors.orange,
    ),
    MaterialUsageData(
      name: 'Steel',
      unit: 'kg',
      consumed: 8420,
      threshold: 500,
      stock: 1850,
      wastage: 0.9,
      color: Colors.purple,
    ),
    MaterialUsageData(
      name: 'Bricks',
      unit: 'units',
      consumed: 45200,
      threshold: 5000,
      stock: 12400,
      wastage: 3.2,
      color: Colors.red,
    ),
    MaterialUsageData(
      name: 'Aggregates',
      unit: 'tons',
      consumed: 98,
      threshold: 10,
      stock: 28,
      wastage: 1.2,
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Material Usage Report',
      children: [
        // Period Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: ['Week', 'Month', 'Quarter'].map((period) {
                final isSelected = _selectedPeriod == period;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = period),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.deepBlue1 : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        period,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Consumption Overview',
          subtitle: 'Total material usage',
        ),

        // Consumption Pie Chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 60,
                            sections: _materials.map((material) {
                              final percentage = (material.consumed / 
                                  _materials.fold<double>(0, (sum, m) => sum + m.consumed)) * 100;
                              return PieChartSectionData(
                                value: material.consumed.toDouble(),
                                title: '${percentage.toStringAsFixed(0)}%',
                                color: material.color,
                                radius: 70,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _materials.fold<double>(0, (sum, m) => sum + m.consumed)
                                  .toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepBlue1,
                              ),
                            ),
                            Text(
                              'Total Units',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _materials.map((material) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: material.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            material.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Material Details',
          subtitle: 'Stock levels and wastage',
        ),

        // Material Detail Cards
        ..._materials.map((material) => _buildMaterialCard(material)),

        const ProfessionalSectionHeader(
          title: 'Consumption Trend',
          subtitle: 'Weekly usage pattern',
        ),

        // Line Chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 500,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[200],
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final weeks = ['W1', 'W2', 'W3', 'W4'];
                            if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  weeks[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 3,
                    minY: 0,
                    maxY: 3000,
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 2100),
                          FlSpot(1, 2450),
                          FlSpot(2, 2200),
                          FlSpot(3, 2650),
                        ],
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withValues(alpha: 0.1),
                        ),
                      ),
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 1800),
                          FlSpot(1, 2100),
                          FlSpot(2, 1950),
                          FlSpot(3, 2300),
                        ],
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.orange.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Export Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting material usage report...')),
              );
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Export Report'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deepBlue1,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMaterialCard(MaterialUsageData material) {
    final stockPercentage = (material.stock / material.threshold) * 100;
    final isLowStock = stockPercentage < 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ProfessionalCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: material.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: material.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.deepBlue1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Unit: ${material.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            'LOW',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatColumn(
                      'Consumed',
                      NumberFormat('#,###').format(material.consumed),
                      material.unit,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      'Current Stock',
                      NumberFormat('#,###').format(material.stock),
                      material.unit,
                      isLowStock ? Colors.red : Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      'Wastage',
                      '${material.wastage}%',
                      '',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: stockPercentage / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(
                    isLowStock ? Colors.red : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Stock at ${stockPercentage.toStringAsFixed(0)}% of threshold',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class MaterialUsageData {
  final String name;
  final String unit;
  final double consumed;
  final double threshold;
  final double stock;
  final double wastage;
  final Color color;

  MaterialUsageData({
    required this.name,
    required this.unit,
    required this.consumed,
    required this.threshold,
    required this.stock,
    required this.wastage,
    required this.color,
  });
}
