import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/staggered_animation.dart';
import '../../app/ui/widgets/status_chip.dart';
import '../../app/ui/widgets/professional_page.dart';

class PaymentsDashboardScreen extends StatefulWidget {
  const PaymentsDashboardScreen({super.key});

  @override
  State<PaymentsDashboardScreen> createState() => _PaymentsDashboardScreenState();
}

class _PaymentsDashboardScreenState extends State<PaymentsDashboardScreen> {
  final NumberFormat _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Financial Settlements',
      children: [
        _buildFinancialOverview(),
        
        const ProfessionalSectionHeader(
          title: 'Liquidity Metrics',
          subtitle: 'Real-time disbursement capacity',
        ),
        
        _buildKpiGrid(),
        
        const ProfessionalSectionHeader(
          title: 'Recent Ledger',
          subtitle: 'Verification & settlement history',
        ),
        
        _buildTransactionLedger(),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFinancialOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Outflow',
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
                _currency.format(1248500),
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
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '+12.5%',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
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

  Widget _buildKpiGrid() {
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
          _PaymentKpiTile(
            title: 'Pending Appr.',
            value: _currency.format(85200),
            icon: Icons.pending_actions_rounded,
            color: Colors.orangeAccent,
            trend: '12 items',
          ),
          _PaymentKpiTile(
            title: 'Ready to Pay',
            value: _currency.format(14000),
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.blueAccent,
            trend: '5 items',
          ),
          _PaymentKpiTile(
            title: 'Settled Today',
            value: _currency.format(256000),
            icon: Icons.check_circle_rounded,
            color: Colors.greenAccent,
            trend: 'All sites',
          ),
          _PaymentKpiTile(
            title: 'Failed/Hold',
            value: _currency.format(4500),
            icon: Icons.error_outline_rounded,
            color: Colors.redAccent,
            trend: 'Action Reqd',
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionLedger() {
    final transactions = [
      {'name': 'Arjun Singh', 'type': 'Worker', 'amount': 12500, 'status': UiStatus.approved, 'date': 'Today'},
      {'name': 'Mehta Construction', 'type': 'Vendor', 'amount': 450000, 'status': UiStatus.pending, 'date': '2h ago'},
      {'name': 'Rajesh Verma', 'type': 'Engineer', 'amount': 8500, 'status': UiStatus.ok, 'date': 'Yesterday'},
      {'name': 'Suresh Kumar', 'type': 'Worker', 'amount': 15000, 'status': UiStatus.rejected, 'date': '12 Jan'},
      {'name': 'Material Logistics', 'type': 'Logistics', 'amount': 22500, 'status': UiStatus.ok, 'date': '11 Jan'},
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
                    tx['type'] == 'Worker' ? Icons.engineering_rounded : 
                    tx['type'] == 'Vendor' ? Icons.business_rounded : Icons.person_rounded,
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
                        tx['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${tx['type']} • ${tx['date']}',
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

class _PaymentKpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _PaymentKpiTile({
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
