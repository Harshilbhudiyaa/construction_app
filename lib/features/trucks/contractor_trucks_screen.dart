import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class ContractorTrucksScreen extends StatelessWidget {
  const ContractorTrucksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Truck Fleet Overview',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _KpiTile(
                  title: 'Total Trucks',
                  value: '14',
                  icon: Icons.local_shipping_rounded,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiTile(
                  title: 'In Transit',
                  value: '6',
                  icon: Icons.map_rounded,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        const ProfessionalSectionHeader(
          title: 'Fleet Status',
          subtitle: 'Real-time transit tracking & estimated arrival',
        ),
        ...[
          ('Truck #001', 'Delivering Aggregate', 'On Time', '3.4 km away'),
          ('Truck #005', 'Ready for Loading', 'Idle', 'At Site A'),
          ('Truck #012', 'In Transit', 'Delayed', '12 km away'),
          ('Truck #008', 'Delivering Bricks', 'On Time', '0.5 km away'),
        ].map((truck) {
          final isDelayed = truck.$3 == 'Delayed';
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
                  child: const Icon(Icons.local_shipping_rounded, color: AppColors.deepBlue1),
                ),
                title: Text(
                  truck.$1,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue1),
                ),
                subtitle: Text(
                  truck.$2,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      truck.$3,
                      style: TextStyle(
                        color: isDelayed ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      truck.$4,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
