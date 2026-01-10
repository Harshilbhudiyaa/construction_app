import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/info_tooltip.dart';
import '../../../../app/utils/feedback_helper.dart';

class EngineersListScreen extends StatefulWidget {
  const EngineersListScreen({super.key});

  @override
  State<EngineersListScreen> createState() => _EngineersListScreenState();
}

class _EngineersListScreenState extends State<EngineersListScreen> {
  String _q = '';

  final _items = const [
    ('Eng. Rajesh Khanna', 'Metropolis Heights', 'Day Shift', 'Site Lead'),
    ('Eng. Priya Sharma', 'Skyline Plaza', 'Day Shift', 'Senior Engineer'),
    ('Eng. Amit Patel', 'Oceanic View Site', 'Night Shift', 'Junior Engineer'),
    ('Eng. Vikram Singh', 'Metropolis Heights', 'Night Shift', 'Supervisor'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _items
        .where(
          (x) => ('${x.$1} ${x.$2} ${x.$3} ${x.$4}').toLowerCase().contains(
            _q.toLowerCase(),
          ),
        )
        .toList();

    return ProfessionalPage(
      title: 'Engineers',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add Engineer module coming soon...')),
        ),
        backgroundColor: AppColors.deepBlue1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Engineer', style: TextStyle(color: Colors.white)),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: AppSearchField(
                hint: 'Search by name, site, or role...',
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            const SizedBox(width: 8),
            InfoTooltip(
              message: 'Search across engineer names, assigned sites, shifts, and roles',
              icon: Icons.help_outline_rounded,
            ),
          ],
        ),
        const ProfessionalSectionHeader(
          title: 'Management Cadre',
          subtitle: 'Active site engineers and field supervisors',
        ),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: EmptyState(
              icon: Icons.engineering_rounded,
              title: 'No Engineers Found',
              message: 'Try adjusting your search or add new engineers to get started.',
            ),
          )
        else
          ...filtered.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final e = entry.value;
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
                        Icons.engineering_rounded,
                        color: AppColors.deepBlue1,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      e.$1,
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
                          '${e.$4} • ${e.$2}',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Shift: ${e.$3}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                      ],
                    ),
                    onTap: () => FeedbackHelper.showInfo(
                      context,
                      'Accessing profile: ${e.$1}',
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

