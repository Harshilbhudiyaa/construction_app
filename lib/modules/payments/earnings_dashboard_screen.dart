import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';

class EarningsDashboardScreen extends StatefulWidget {
  const EarningsDashboardScreen({super.key});

  @override
  State<EarningsDashboardScreen> createState() => _EarningsDashboardScreenState();
}

class _EarningsDashboardScreenState extends State<EarningsDashboardScreen> {
  final NumberFormat _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  String _searchQuery = '';
  String _activeTypeFilter = 'All';

  final List<Map<String, dynamic>> _allEarnings = [
    {'id': 'ERN-001', 'title': 'Standard Shift', 'desc': 'Site A • 8 Hours', 'amount': 850, 'status': UiStatus.ok, 'date': 'Today', 'type': 'Daily Wage', 'reference': 'LOG-9021'},
    {'id': 'ERN-002', 'title': 'Overtime Bonus', 'desc': 'Site A • 2 Hours', 'amount': 450, 'status': UiStatus.approved, 'date': 'Today', 'type': 'Overtime', 'reference': 'LOG-9021-OT'},
    {'id': 'ERN-003', 'title': 'Standard Shift', 'desc': 'Site A • 8 Hours', 'amount': 850, 'status': UiStatus.ok, 'date': 'Yesterday', 'type': 'Daily Wage', 'reference': 'LOG-8802'},
    {'id': 'ERN-004', 'title': 'Weekly Incentive', 'desc': 'Performance Award', 'amount': 1500, 'status': UiStatus.approved, 'date': '10 Jan', 'type': 'Incentive', 'reference': 'INC-2026-W2'},
    {'id': 'ERN-005', 'title': 'Standard Shift', 'desc': 'Site B • 8 Hours', 'amount': 850, 'status': UiStatus.ok, 'date': '09 Jan', 'type': 'Daily Wage', 'reference': 'LOG-7741'},
  ];

  List<Map<String, dynamic>> get _filteredEarnings {
    return _allEarnings.where((e) {
      final matchesSearch = e['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e['desc'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _activeTypeFilter == 'All' || e['type'] == _activeTypeFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'My Earnings',
      children: [
        _buildPersonalHeader(),
        
        const ProfessionalSectionHeader(
          title: 'Earnings Summary',
          subtitle: 'Personal cycle tracking',
        ),
        
        _buildEarningsKpis(),
        
        const ProfessionalSectionHeader(
          title: 'My Passbook',
          subtitle: 'Daily wage & bonus history',
        ),

        AppSearchField(
          hint: 'Search by title or description...',
          onChanged: (v) => setState(() => _searchQuery = v),
        ),

        _buildFilterChips(),
        
        _buildPersonalLedger(),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPersonalHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available for Withdrawal',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
          Text(
            _currency.format(14500),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NEXT: 15 JAN',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsKpis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _EarningsKpiTile(
            title: 'This Month',
            value: _currency.format(28000),
            icon: Icons.calendar_today_rounded,
            color: Colors.greenAccent,
            trend: '+12%',
          ),
          _EarningsKpiTile(
            title: 'Incentives',
            value: _currency.format(2500),
            icon: Icons.stars_rounded,
            color: Colors.orangeAccent,
            trend: '3 items',
          ),
          _EarningsKpiTile(
            title: 'Pending',
            value: _currency.format(4200),
            icon: Icons.history_toggle_off_rounded,
            color: Colors.blueAccent,
            trend: 'Verifying',
          ),
          _EarningsKpiTile(
            title: 'Total Paid',
            value: _currency.format(185000),
            icon: Icons.account_balance_rounded,
            color: Colors.purpleAccent,
            trend: 'All cycles',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Daily Wage', 'Overtime', 'Incentive'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final f = filters[index];
            final isSelected = _activeTypeFilter == f;
            return GestureDetector(
              onTap: () => setState(() => _activeTypeFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPersonalLedger() {
    final earnings = _filteredEarnings;
    
    if (earnings.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'No matching earnings found',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: earnings.length,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        final ex = earnings[index];
        return StaggeredAnimation(
          index: index,
          child: ProfessionalCard(
            padding: EdgeInsets.zero,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: InkWell(
              onTap: () => _showEarningsDetail(ex),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ex['type'] == 'Incentive' || ex['type'] == 'Overtime'
                            ? Icons.bolt_rounded : Icons.work_history_rounded,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex['title'] as String,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${ex['desc']} • ${ex['date']}',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currency.format(ex['amount']),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        StatusChip(status: ex['status'] as UiStatus),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEarningsDetail(Map<String, dynamic> ex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.7,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Earnings Detail', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(ex['id'], style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  StatusChip(status: ex['status']),
                ],
              ),
              const SizedBox(height: 32),
              _detailRow(context, 'Classification', ex['type']),
              _detailRow(context, 'Description', ex['desc']),
              _detailRow(context, 'Work Reference', ex['reference']),
              _detailRow(context, 'Timestamp', ex['date']),
              const Divider(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Earned', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(_currency.format(ex['amount']), style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Close Details', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _EarningsKpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _EarningsKpiTile({
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
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
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
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.05),
                      ),
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