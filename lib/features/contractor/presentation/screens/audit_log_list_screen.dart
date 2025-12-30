import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class AuditLogListScreen extends StatefulWidget {
  const AuditLogListScreen({super.key});

  @override
  State<AuditLogListScreen> createState() => _AuditLogListScreenState();
}

class _AuditLogListScreenState extends State<AuditLogListScreen> {
  String _q = '';

  final _items = const [
    ('Backup blocks used', 'BU-3004', 'Today 02:15 PM', UiStatus.low),
    ('Worker payment approved', 'PAY-1102', 'Yesterday 05:40 PM', UiStatus.approved),
    ('Inventory threshold changed', 'INV-0201', 'Yesterday 11:05 AM', UiStatus.pending),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _items.where((x) => ('${x.$1} ${x.$2} ${x.$3}').toLowerCase().contains(_q.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(hint: 'Search audit logs...', onChanged: (v) => setState(() => _q = v)),
          const SectionHeader(title: 'Timeline', subtitle: 'Critical actions (UI-only)'),
          ...filtered.map((x) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.shield_rounded, color: cs.primary),
                    title: Text(x.$1, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text('${x.$3}\nRef: ${x.$2}'),
                    isThreeLine: true,
                    trailing: StatusChip(status: x.$4),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open audit detail: ${x.$2} (next step)')),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
