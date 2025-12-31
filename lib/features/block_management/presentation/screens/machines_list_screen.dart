import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';

class MachinesListScreen extends StatefulWidget {
  const MachinesListScreen({super.key});

  @override
  State<MachinesListScreen> createState() => _MachinesListScreenState();
}

class _MachinesListScreenState extends State<MachinesListScreen> {
  String _q = '';

  final _items = const [
    ('BM-01', 'Semi Automatic', 'Hollow Block', 1250, UiStatus.ok),
    ('BM-02', 'Fully Automatic', 'Solid Block', 3400, UiStatus.ok),
    ('BM-03', 'Manual Press', 'Interlock', 450, UiStatus.pending),
    ('BM-04', 'Semi Automatic', 'Solid Block', 0, UiStatus.alert),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _items
        .where(
          (x) => ('${x.$1} ${x.$2} ${x.$3}').toLowerCase().contains(
            _q.toLowerCase(),
          ),
        )
        .toList();

    return ProfessionalPage(
      title: 'Machines',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asset Registration module coming soon...')),
        ),
        backgroundColor: AppColors.deepBlue1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Machine', style: TextStyle(color: Colors.white)),
      ),
      children: [
        AppSearchField(
          hint: 'Search by ID or block type...',
          onChanged: (v) => setState(() => _q = v),
        ),
        const ProfessionalSectionHeader(
          title: 'Plant Operations',
          subtitle: 'Live status of block production hardware',
        ),
        ...filtered.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final m = entry.value;
            return StaggeredAnimation(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ProfessionalCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.deepBlue1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(
                        Icons.precision_manufacturing_rounded,
                        color: AppColors.deepBlue1,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      '${m.$1} • ${m.$2}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepBlue1,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Primary: ${m.$3}',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Today: ${m.$4} units produced',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: StatusChip(
                      status: m.$5,
                      labelOverride: m.$5 == UiStatus.ok 
                        ? 'Running' 
                        : m.$5 == UiStatus.alert ? 'Down' : 'Idle',
                    ),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Analyzing Telemetry for ${m.$1}...'),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

