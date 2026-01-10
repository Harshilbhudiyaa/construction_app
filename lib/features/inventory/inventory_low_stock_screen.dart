import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class InventoryLowStockScreen extends StatefulWidget {
  const InventoryLowStockScreen({super.key});

  @override
  State<InventoryLowStockScreen> createState() =>
      _InventoryLowStockScreenState();
}

class _InventoryLowStockScreenState extends State<InventoryLowStockScreen> {
  String _query = '';
  String _range = 'This Week';

  final _items = <LowStockItem>[
    const LowStockItem(
      name: 'Cement (Bags)',
      current: 18,
      threshold: 25,
      unit: 'bags',
    ),
    const LowStockItem(name: 'Sand', current: 2, threshold: 5, unit: 'tons'),
    const LowStockItem(
      name: 'Steel Rod',
      current: 120,
      threshold: 200,
      unit: 'kg',
    ),
  ];

  List<LowStockItem> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((x) => x.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Low Stock Alerts',
      children: [
        AppSearchField(
          hint: 'Search material name...',
          onChanged: (v) => setState(() => _query = v),
        ),
        
        const ProfessionalSectionHeader(
          title: 'Range Filters',
          subtitle: 'Historical depletion view',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Today', 'This Week', 'This Month'].map((r) {
                final selected = _range == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(r),
                    selected: selected,
                    onSelected: (_) => setState(() => _range = r),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.deepBlue1 : Colors.white,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Alerts',
          subtitle: 'Items below defined thresholds',
        ),

        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: EmptyState(
              icon: Icons.warning_amber_rounded,
              title: 'No low stock items',
              message: 'All items are above threshold.',
            ),
          )
        else
          ..._filtered.map((x) {
            final ratio = (x.current / x.threshold).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ProfessionalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              x.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepBlue1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Material Category: Construction',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const StatusChip(
                          status: UiStatus.low,
                          labelOverride: 'Critical',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Stock: ${x.current} ${x.unit}',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepBlue1),
                        ),
                        Text(
                          'Threshold: ${x.threshold} ${x.unit}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratio,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.orange, Colors.redAccent],
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Restock request for ${x.name}')),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.deepBlue1,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                        label: const Text('Restock Request'),
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

class LowStockItem {
  final String name;
  final int current;
  final int threshold;
  final String unit;

  const LowStockItem({
    required this.name,
    required this.current,
    required this.threshold,
    required this.unit,
  });
}
