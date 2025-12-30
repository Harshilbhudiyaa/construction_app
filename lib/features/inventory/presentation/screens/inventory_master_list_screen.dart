import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class InventoryMasterListScreen extends StatefulWidget {
  const InventoryMasterListScreen({super.key});

  @override
  State<InventoryMasterListScreen> createState() =>
      _InventoryMasterListScreenState();
}

class _InventoryMasterListScreenState extends State<InventoryMasterListScreen> {
  String _q = '';

  final _items = const [
    ('Cement (Bags)', 25, 'bags', UiStatus.ok),
    ('Sand', 5, 'tons', UiStatus.low),
    ('Steel Rod', 200, 'kg', UiStatus.ok),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _items
        .where(
          (x) => ('${x.$1} ${x.$3}').toLowerCase().contains(_q.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Master')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add Material (next step)')),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(
            hint: 'Search materials...',
            onChanged: (v) => setState(() => _q = v),
          ),
          const SectionHeader(
            title: 'Thresholds',
            subtitle: 'Backup/low-stock configuration (UI-only)',
          ),
          ...filtered.map(
            (x) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.inventory_2_rounded, color: cs.primary),
                  title: Text(
                    x.$1,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text('Backup threshold: ${x.$2} ${x.$3}'),
                  trailing: StatusChip(
                    status: x.$4,
                    labelOverride: x.$4 == UiStatus.low ? 'Needs Review' : 'OK',
                  ),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Edit threshold: ${x.$1} (next step)'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
