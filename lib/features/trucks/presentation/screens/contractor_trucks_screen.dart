import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/kpi_card.dart';
import '../../../../app/ui/widgets/section_header.dart';

class ContractorTrucksScreen extends StatelessWidget {
  const ContractorTrucksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Truck Fleet Overview')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(
                  child: KpiCard(
                    title: 'Total Trucks',
                    value: '14',
                    icon: Icons.local_shipping_rounded,
                  ),
                ),
                Expanded(
                  child: KpiCard(
                    title: 'In Transit',
                    value: '6',
                    icon: Icons.map_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(
            title: 'Fleet Status',
            subtitle: 'Real-time transit tracking',
          ),
          ...[
            ('Truck #001', 'Delivering Aggregate', 'On Time', '3.4 km away'),
            ('Truck #005', 'Ready for Loading', 'Idle', 'At Site A'),
            ('Truck #012', 'In Transit', 'Delayed', '12 km away'),
            ('Truck #008', 'Delivering Bricks', 'On Time', '0.5 km away'),
          ].map((truck) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.local_shipping_rounded),
                  title: Text(
                    truck.$1,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(truck.$2),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        truck.$3,
                        style: TextStyle(
                          color: truck.$3 == 'Delayed' ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(truck.$4, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  onTap: () {},
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
