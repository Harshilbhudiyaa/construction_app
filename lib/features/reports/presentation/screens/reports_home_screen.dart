import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import 'worker_productivity_report_screen.dart';
import 'material_usage_report_screen.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Reports',
      children: [
        const ProfessionalSectionHeader(
          title: 'Analytics',
          subtitle: 'Business intelligence and insights',
        ),
        ...[
          (
            'Worker Productivity',
            'Output per shift analysis',
            Icons.trending_up_rounded
          ),
          (
            'Material Usage',
            'Cement, sand, and aggregate tracking',
            Icons.inventory_2_rounded
          ),
          (
            'Block Production',
            'Daily machine output vs targets',
            Icons.precision_manufacturing_rounded
          ),
          (
            'Truck Delays',
            'Logistics and turnaround time',
            Icons.local_shipping_rounded
          ),
          (
            'Payments Summary',
            'Total payouts vs budgets',
            Icons.payments_rounded
          ),
        ].map((r) {
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
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(r.$3, color: AppColors.deepBlue1, size: 24),
                ),
                title: Text(
                  r.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepBlue1,
                  ),
                ),
                subtitle: Text(
                  r.$2,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () {
                  if (r.$1 == 'Worker Productivity') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkerProductivityReportScreen(),
                      ),
                    );
                  } else if (r.$1 == 'Material Usage') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MaterialUsageReportScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Generating ${r.$1} report...')),
                    );
                  }
                },
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}

