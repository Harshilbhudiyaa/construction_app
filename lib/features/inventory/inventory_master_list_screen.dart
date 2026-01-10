import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';

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
    final filtered = _items
        .where(
          (x) => ('${x.$1} ${x.$3}').toLowerCase().contains(_q.toLowerCase()),
        )
        .toList();

    return ProfessionalPage(
      title: 'Inventory Master',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add Material (next step)')),
        ),
        backgroundColor: AppColors.deepBlue1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Material', style: TextStyle(color: Colors.white)),
      ),
      children: [
        AppSearchField(
          hint: 'Search materials by name...',
          onChanged: (v) => setState(() => _q = v),
        ),
        const ProfessionalSectionHeader(
          title: 'Thresholds',
          subtitle: 'Stock monitoring and backup settings',
        ),
        ...filtered.map(
          (x) => Padding(
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
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: AppColors.deepBlue1,
                  ),
                ),
                title: Text(
                  x.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepBlue1,
                  ),
                ),
                subtitle: Text(
                  'Backup threshold: ${x.$2} ${x.$3}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
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
        const SizedBox(height: 100),
      ],
    );
  }
}

