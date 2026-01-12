import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/staggered_animation.dart';
import '../../app/ui/widgets/status_chip.dart';
import '../../app/ui/widgets/professional_page.dart';

class EarningsDashboardScreen extends StatefulWidget {
  const EarningsDashboardScreen({super.key});

  @override
  State<EarningsDashboardScreen> createState() => _EarningsDashboardScreenState();
}

class _EarningsDashboardScreenState extends State<EarningsDashboardScreen> {
  final NumberFormat _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

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
          title: 'Passbook',
          subtitle: 'Daily wage & bonus history',
        ),
        
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
              color: Colors.white.withOpacity(0.7),
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
                style: const TextStyle(
                  color: Colors.white,
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

  Widget _buildPersonalLedger() {
    final transactions = [
      {'title': 'Standard Shift', 'desc': 'Site A • 8 Hours', 'amount': 850, 'status': UiStatus.ok, 'date': 'Today'},
      {'title': 'Overtime Bonus', 'desc': 'Site A • 2 Hours', 'amount': 450, 'status': UiStatus.approved, 'date': 'Today'},
      {'title': 'Standard Shift', 'desc': 'Site A • 8 Hours', 'amount': 850, 'status': UiStatus.ok, 'date': 'Yesterday'},
      {'title': 'Weekly Incentive', 'desc': 'Performance Award', 'amount': 1500, 'status': UiStatus.approved, 'date': '10 Jan'},
      {'title': 'Standard Shift', 'desc': 'Site B • 8 Hours', 'amount': 850, 'status': UiStatus.ok, 'date': '09 Jan'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return StaggeredAnimation(
          index: index,
          child: ProfessionalCard(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tx['title'].toString().contains('Overtime') || tx['title'].toString().contains('Incentive')
                        ? Icons.bolt_rounded : Icons.work_history_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${tx['desc']} • ${tx['date']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
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
                      _currency.format(tx['amount']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    StatusChip(status: tx['status'] as UiStatus),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
