import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Operations Analytics',
      children: [
        _buildPeriodSelector(),
        
        const ProfessionalSectionHeader(
          title: 'Core Efficiency',
          subtitle: 'Real-time performance distribution',
        ),
        
        _buildAnalyticsKpiGrid(),
        
        const ProfessionalSectionHeader(
          title: 'Productivity Distribution',
          subtitle: 'Daily output performance analysis',
        ),
        
        _buildProductivityChart(),
        
        const ProfessionalSectionHeader(
          title: 'Resource Allocation',
          subtitle: 'Material consumption & utility',
        ),
        
        _buildMaterialAllocationChart(),
        
        const ProfessionalSectionHeader(
          title: 'Operational Precision',
          subtitle: 'Logistics and delivery performance',
        ),
        
        _buildLogisticsMetrics(),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: ['Day', 'Week', 'Month'].map((period) {
            final isSelected = _selectedPeriod == period;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPeriod = period),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAnalyticsKpiGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _AnalyticsKpiTile(
            title: 'Productivity',
            value: '87.4%',
            icon: Icons.speed_rounded,
            color: Colors.greenAccent,
            trend: '+5.2%',
          ),
          _AnalyticsKpiTile(
            title: 'Personnel',
            value: '142',
            icon: Icons.groups_3_rounded,
            color: Colors.blueAccent,
            trend: 'Active',
          ),
          _AnalyticsKpiTile(
            title: 'Efficiency',
            value: '94.1%',
            icon: Icons.bolt_rounded,
            color: Colors.orangeAccent,
            trend: 'Optimal',
          ),
          _AnalyticsKpiTile(
            title: 'Precision',
            value: '22ms',
            icon: Icons.query_builder_rounded,
            color: Colors.purpleAccent,
            trend: 'Avg Latency',
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityChart() {
    return StaggeredAnimation(
      index: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ProfessionalCard(
          padding: const EdgeInsets.all(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Production (Units)',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.more_vert_rounded, color: Colors.white.withOpacity(0.3)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.deepBlue1,
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.round()}%',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                days[value.toInt() % days.length],
                                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (i) {
                      final rand = math.Random(i + 100);
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: 40 + rand.nextDouble() * 50,
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.blueAccent.withOpacity(0.3)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            width: 14,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialAllocationChart() {
    return StaggeredAnimation(
      index: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ProfessionalCard(
          padding: const EdgeInsets.all(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resources Used',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Text('Q4 Data', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 45,
                    sections: [
                      PieChartSectionData(color: Colors.blueAccent, value: 35, title: '35%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      PieChartSectionData(color: Colors.orangeAccent, value: 25, title: '25%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      PieChartSectionData(color: Colors.purpleAccent, value: 20, title: '20%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      PieChartSectionData(color: Colors.greenAccent, value: 20, title: '20%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildModernLegend(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernLegend() {
    final legends = [
      ('Cement', Colors.blueAccent),
      ('Aggregate', Colors.orangeAccent),
      ('Steel', Colors.purpleAccent),
      ('Man-Hours', Colors.greenAccent),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: legends.map((leg) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: leg.$2, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(leg.$1, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLogisticsMetrics() {
    return Column(
      children: [
        _buildMetricSummaryCard('Avg Turnaround Time', '14.2 Hours', Icons.timer_outlined, Colors.orangeAccent),
        _buildMetricSummaryCard('Success Rate', '99.8%', Icons.verified_user_outlined, Colors.greenAccent),
        _buildMetricSummaryCard('Fleet Utilization', '84%', Icons.local_shipping_outlined, Colors.blueAccent),
      ],
    );
  }

  Widget _buildMetricSummaryCard(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ProfessionalCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsKpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _AnalyticsKpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      padding: EdgeInsets.zero,
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Text(
                  trend,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
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
              title.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 16,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateDummySpots(),
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
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

  List<FlSpot> _generateDummySpots() {
    final rand = math.Random(title.hashCode);
    return List.generate(6, (i) => FlSpot(i.toDouble(), rand.nextDouble() * 5));
  }
}
