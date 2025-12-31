import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class WorkerEarningsDashboardScreen extends StatelessWidget {
  const WorkerEarningsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Earnings Overview',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                   Expanded(
                    child: _KpiTile(
                      title: 'Total Earned',
                      value: '₹3,450',
                      icon: Icons.paid_rounded,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiTile(
                      title: 'Total Paid',
                      value: '₹2,000',
                      icon: Icons.verified_user_rounded,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                   Expanded(
                    child: _KpiTile(
                      title: 'Pending',
                      value: '₹1,450',
                      icon: Icons.hourglass_bottom_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiTile(
                      title: 'This Month',
                      value: '₹9,200',
                      icon: Icons.calendar_month_rounded,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const ProfessionalSectionHeader(
          title: 'Earnings Breakdown',
          subtitle: 'Daily & Weekly statistics',
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: EmptyState(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Detailed breakdown coming soon',
            message: 'In the next update, you will be able to see exactly where your earnings come from.',
          ),
        ),
        
        const SizedBox(height: 32),
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
    return ProfessionalCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
