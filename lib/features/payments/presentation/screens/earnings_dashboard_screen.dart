import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import 'earnings_breakdown_screen.dart';
import 'payout_history_screen.dart';

class EarningsDashboardScreen extends StatelessWidget {
  const EarningsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const earned = 3450;
    const paid = 2000;
    const pending = 1450;

    return ProfessionalPage(
      title: 'Earnings',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: const [
              _KpiTile(
                title: 'Earned',
                value: '₹$earned',
                icon: Icons.paid_rounded,
                color: Colors.blue,
              ),
              _KpiTile(
                title: 'Paid',
                value: '₹$paid',
                icon: Icons.verified_rounded,
                color: Colors.green,
              ),
              _KpiTile(
                title: 'Pending',
                value: '₹$pending',
                icon: Icons.hourglass_bottom_rounded,
                color: Colors.orange,
              ),
              _KpiTile(
                title: 'This Month',
                value: '₹9,200',
                icon: Icons.calendar_month_rounded,
                color: Colors.purple,
              ),
            ],
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Latest Activity',
          subtitle: 'Most recent approved work session',
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Brick / Block Work',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepBlue1,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₹420 • Yesterday 6:10 PM',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  status: UiStatus.approved,
                  labelOverride: 'Approved',
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Quick Actions',
          subtitle: 'Detailed breakdown and history',
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.view_list_rounded, color: AppColors.deepBlue1),
              title: const Text(
                'Earnings Breakdown',
                style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue1),
              ),
              subtitle: const Text('Session-wise detailed logs'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EarningsBreakdownScreen(),
                ),
              ),
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.receipt_long_rounded, color: AppColors.deepBlue1),
              title: const Text(
                'Payout History',
                style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue1),
              ),
              subtitle: const Text('Bank transfers and status'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PayoutHistoryScreen(),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

