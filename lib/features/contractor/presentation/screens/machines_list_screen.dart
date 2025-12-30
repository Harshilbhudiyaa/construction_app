import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class MachinesListScreen extends StatefulWidget {
  const MachinesListScreen({super.key});

  @override
  State<MachinesListScreen> createState() => _MachinesListScreenState();
}

class _MachinesListScreenState extends State<MachinesListScreen> {
  String _q = '';

  final _items = const [
    ('BM-01', 'Semi Automatic', 'Hollow', UiStatus.ok),
    ('BM-02', 'Manual', 'Solid', UiStatus.pending),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _items.where((x) => ('${x.$1} ${x.$2} ${x.$3}').toLowerCase().contains(_q.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Machines')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Machine (next step)'))),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(hint: 'Search machines...', onChanged: (v) => setState(() => _q = v)),
          const SectionHeader(title: 'List', subtitle: 'Block machines snapshot (UI-only)'),
          ...filtered.map((m) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.precision_manufacturing_rounded, color: cs.primary),
                    title: Text('${m.$1} • ${m.$2}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text('${m.$3} blocks'),
                    trailing: StatusChip(status: m.$4, labelOverride: m.$4 == UiStatus.ok ? 'Running' : 'Idle'),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open machine: ${m.$1} (next step)'))),
                  ),
                ),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
