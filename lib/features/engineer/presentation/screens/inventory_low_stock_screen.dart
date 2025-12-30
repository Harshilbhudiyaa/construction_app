import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class InventoryLowStockScreen extends StatefulWidget {
  const InventoryLowStockScreen({super.key});

  @override
  State<InventoryLowStockScreen> createState() => _InventoryLowStockScreenState();
}

class _InventoryLowStockScreenState extends State<InventoryLowStockScreen> {
  String _query = '';
  String _range = 'This Week';

  final _items = <LowStockItem>[
    const LowStockItem(name: 'Cement (Bags)', current: 18, threshold: 25, unit: 'bags'),
    const LowStockItem(name: 'Sand', current: 2, threshold: 5, unit: 'tons'),
    const LowStockItem(name: 'Steel Rod', current: 120, threshold: 200, unit: 'kg'),
  ];

  List<LowStockItem> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((x) => x.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Low Stock')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(
            hint: 'Search material name...',
            onChanged: (v) => setState(() => _query = v),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Today', 'This Week', 'This Month'].map((r) {
                final selected = _range == r;
                return ChoiceChip(
                  label: Text(r),
                  selected: selected,
                  onSelected: (_) => setState(() => _range = r),
                );
              }).toList(),
            ),
          ),
          const SectionHeader(title: 'Items', subtitle: 'Below threshold (UI-only)'),
          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: const EmptyState(
                icon: Icons.warning_amber_rounded,
                title: 'No low stock items',
                message: 'All items are above threshold.',
              ),
            )
          else
            ..._filtered.map((x) {
              final ratio = (x.current / x.threshold).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Expanded(child: Text('Low Stock Item', style: TextStyle(fontWeight: FontWeight.w900))),
                            StatusChip(status: UiStatus.low, labelOverride: 'Low'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(x.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(
                          'Current: ${x.current} ${x.unit} • Threshold: ${x.threshold} ${x.unit}',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: ratio,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Restock request for ${x.name} (next UI step)')),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart_rounded),
                            label: const Text('Restock'),
                          ),
                        ),
                      ],
                    ),
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
