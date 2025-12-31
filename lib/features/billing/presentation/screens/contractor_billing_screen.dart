import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class ContractorBillingScreen extends StatelessWidget {
  const ContractorBillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Contractor Billing',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _KpiTile(
                  title: 'Total Billed',
                  value: '₹45.2L',
                  icon: Icons.account_balance_rounded,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiTile(
                  title: 'Outstanding',
                  value: '₹3.8L',
                  icon: Icons.pending_rounded,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        const ProfessionalSectionHeader(
          title: 'Invoices',
          subtitle: 'Active and archived billing cycles',
        ),
        ...[
          ('Dec 2025', '₹8,45,000', 'Paid', 'IN-2025-012'),
          ('Nov 2025', '₹7,90,000', 'Paid', 'IN-2025-011'),
          ('Oct 2025', '₹8,15,000', 'Paid', 'IN-2025-010'),
          ('Sep 2025', '₹9,20,000', 'Paid', 'IN-2025-009'),
        ].map((bill) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ProfessionalCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.deepBlue1),
                ),
                title: Text(
                  bill.$1,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue1),
                ),
                subtitle: Text(
                  bill.$4,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bill.$2,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue1),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PAID',
                        style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                onTap: () {},
              ),
            ),
          );
        }),
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
