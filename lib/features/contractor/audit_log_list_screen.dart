import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';

class AuditLogListScreen extends StatefulWidget {
  const AuditLogListScreen({super.key});

  @override
  State<AuditLogListScreen> createState() => _AuditLogListScreenState();
}

class _AuditLogListScreenState extends State<AuditLogListScreen> {
  String _q = '';

  final _items = const [
    ('Block Usage Threshold Violation', 'SEC-9021', 'Today 02:15 PM', UiStatus.alert, 'Site Manager'),
    ('Heavy Machinery Access Granted', 'ACC-1102', 'Today 11:40 AM', UiStatus.ok, 'Eng. Rajesh'),
    ('Contractor Billing Discrepancy', 'FIN-0201', 'Yesterday 05:05 PM', UiStatus.pending, 'System Audit'),
    ('Worker Safety Checklist Bypass', 'SAF-3304', 'Yesterday 09:12 AM', UiStatus.low, 'Guard A-1'),
    ('Inventory Stock Multiplier Adjustment', 'ADM-0012', 'Dec 28, 04:30 PM', UiStatus.approved, 'Contractor Admin'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _items
        .where(
          (x) => ('${x.$1} ${x.$2} ${x.$3} ${x.$5}').toLowerCase().contains(
            _q.toLowerCase(),
          ),
        )
        .toList();

    return ProfessionalPage(
      title: 'Audit Log',
      children: [
        AppSearchField(
          hint: 'Search by reference, title, or actor...',
          onChanged: (v) => setState(() => _q = v),
        ),
        const ProfessionalSectionHeader(
          title: 'Administrative Timeline',
          subtitle: 'Secure immutable history of site events',
        ),
        ...filtered.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final x = entry.value;
            return StaggeredAnimation(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ProfessionalCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.deepBlue1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(
                        x.$4 == UiStatus.alert ? Icons.error_outline_rounded : Icons.shield_rounded,
                        color: x.$4 == UiStatus.alert ? Colors.red : AppColors.deepBlue1,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      x.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepBlue1,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${x.$3} • by ${x.$5}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Reference: ${x.$2}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: StatusChip(status: x.$4),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verifying Event Integrity: ${x.$2}...'),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

