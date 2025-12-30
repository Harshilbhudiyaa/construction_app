import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/section_header.dart';

class EngineersListScreen extends StatefulWidget {
  const EngineersListScreen({super.key});

  @override
  State<EngineersListScreen> createState() => _EngineersListScreenState();
}

class _EngineersListScreenState extends State<EngineersListScreen> {
  String _q = '';

  final _items = const [
    ('Engineer A', 'Site A', 'Day'),
    ('Engineer B', 'Site B', 'Day'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _items
        .where(
          (x) => ('${x.$1} ${x.$2} ${x.$3}').toLowerCase().contains(
            _q.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Engineers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add Engineer (next step)')),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(
            hint: 'Search engineers...',
            onChanged: (v) => setState(() => _q = v),
          ),
          const SectionHeader(
            title: 'List',
            subtitle: 'Engineers with site + shift (UI-only)',
          ),
          ...filtered.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.engineering_rounded, color: cs.primary),
                  title: Text(
                    e.$1,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text('${e.$2} • Shift: ${e.$3}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Open engineer: ${e.$1} (next step)'),
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
