import 'package:flutter/material.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class ContractorAlertsScreen extends StatelessWidget {
  const ContractorAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      (
        title: 'Low Inventory Alert',
        message: 'Cement stock is below 20 bags at Site A.',
        time: '10 mins ago',
        type: 'Inventory',
        isUrgent: true,
      ),
      (
        title: 'Late Clock-in',
        message: '3 workers haven\'t clocked in today.',
        time: '1 hour ago',
        type: 'HR',
        isUrgent: false,
      ),
      (
        title: 'Payment Pending',
        message: 'Outstanding balance for ABC Suppliers.',
        time: '3 hours ago',
        type: 'Finance',
        isUrgent: false,
      ),
      (
        title: 'Report Request',
        message: 'Weekly progress report is ready for review.',
        time: 'Yesterday',
        type: 'Field',
        isUrgent: false,
      ),
    ];

    return ProfessionalPage(
      title: 'Alerts & Notifications',
      children: [
        const ProfessionalSectionHeader(
          title: 'Recent Activity',
          subtitle: 'Stay updated with site operations',
        ),
        ...alerts.map((alert) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ProfessionalCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (alert.isUrgent ? Colors.red : AppColors.deepBlue1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      alert.isUrgent ? Icons.warning_amber_rounded : Icons.notifications_active_rounded,
                      color: alert.isUrgent ? Colors.red : AppColors.deepBlue1,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              alert.type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: alert.isUrgent ? Colors.red : AppColors.deepBlue2,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              alert.time,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepBlue1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.message,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 32),
      ],
    );
  }
}
