import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class PaymentsDashboardScreen extends StatelessWidget {
  const PaymentsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI-only demo values
    const pending = 12;
    const paid = 48;
    const failed = 2;
    const totalThisMonth = '₹4.85L';

    return ProfessionalPage(
      title: 'Payments',
      children: [
        // KPI grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: const [
                  Expanded(
                    child: _KpiTile(
                      title: 'Pending',
                      value: '$pending',
                      icon: Icons.pending_actions_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _KpiTile(
                      title: 'Paid',
                      value: '$paid',
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _KpiTile(
                      title: 'Failed',
                      value: '$failed',
                      icon: Icons.error_rounded,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _KpiTile(
                      title: 'Month Total',
                      value: totalThisMonth,
                      icon: Icons.payments_rounded,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Recent Payouts',
          subtitle: 'Audit trail for worker salaries',
        ),

        ...[
          (name: 'Ramesh Kumar', amount: '₹12,450', status: 'Paid', date: '28 Dec'),
          (name: 'Suresh Singh', amount: '₹8,900', status: 'Pending', date: '29 Dec'),
          (name: 'Mahesh Babu', amount: '₹15,000', status: 'Failed', date: '27 Dec'),
          (name: 'Amit Shah', amount: '₹6,700', status: 'Paid', date: '26 Dec'),
        ].map((p) {
          final statusColor = p.status == 'Paid'
              ? Colors.green
              : (p.status == 'Failed' ? Colors.red : Colors.orange);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ProfessionalCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.deepBlue1.withOpacity(0.1),
                  child: Text(
                    p.name[0],
                    style: const TextStyle(
                      color: AppColors.deepBlue1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepBlue1,
                  ),
                ),
                subtitle: Text(
                  '${p.date} • ${p.status}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Text(
                  p.amount,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: statusColor,
                  ),
                ),
                onTap: () {},
              ),
            ),
          );
        }),
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue1,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}


