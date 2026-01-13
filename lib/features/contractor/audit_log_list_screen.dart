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
            final isAlert = x.$4 == UiStatus.alert;
            
            return StaggeredAnimation(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ProfessionalCard(
                  useGlass: true,
                  padding: const EdgeInsets.all(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(isAlert ? 0.15 : 0.08),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verifying Event Integrity: ${x.$2}...'),
                        backgroundColor: AppColors.deepBlue1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (isAlert ? Colors.redAccent : Colors.blueAccent).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (isAlert ? Colors.redAccent : Colors.blueAccent).withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            isAlert ? Icons.error_outline_rounded : Icons.shield_rounded,
                            color: isAlert ? Colors.redAccent : Colors.blueAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                x.$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${x.$3} • by ${x.$5}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'REF: ${x.$2}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusChip(status: x.$4),
                      ],
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

