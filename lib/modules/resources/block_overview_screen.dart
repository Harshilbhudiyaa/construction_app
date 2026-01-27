import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';

import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';

class BlockOverviewScreen extends StatefulWidget {
  const BlockOverviewScreen({super.key});

  @override
  State<BlockOverviewScreen> createState() => _BlockOverviewScreenState();
}

class _BlockOverviewScreenState extends State<BlockOverviewScreen> {
  String _query = '';

  final List<BlockItem> _blocks = [
    BlockItem(id: "B-201", name: "Sector A - Foundation", progress: 0.85, status: UiStatus.ok, yield: "1.2K", machine: "JCB-04", machineType: "Excavator"),
    BlockItem(id: "B-202", name: "Sector B - Columns", progress: 0.45, status: UiStatus.pending, yield: "0.8K", machine: "CRANE-01", machineType: "Crane"),
    BlockItem(id: "B-203", name: "Sector C - Slabs", progress: 0.12, status: UiStatus.stop, yield: "0.2K", machine: "MIXER-09", machineType: "Mixer"),
    BlockItem(id: "B-204", name: "Parking Level 1", progress: 0.95, status: UiStatus.ok, yield: "2.1K", machine: "JCB-02", machineType: "Excavator"),
  ];


  List<BlockItem> get _filtered => _blocks
      .where((b) => b.name.toLowerCase().contains(_query.toLowerCase()) || b.id.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Production Ledger',
      actions: [
        IconButton(
          onPressed: _showAddBlockDialog,
          icon: const Icon(Icons.add_box_rounded, color: Colors.white),
        ),

      ],
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppSearchField(
            hint: 'Search blocks or sectors...',
            useGlass: true,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Site Progress',
          subtitle: 'Active block yield and machine utilization',
        ),

        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: Text(
                'No blocks match your search',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final block = _filtered[index];
              return StaggeredAnimation(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildBlockCard(block),
                ),
              );
            },
          ),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBlockCard(BlockItem block) {
    return ProfessionalCard(
      useGlass: true,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(block.id, style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 2),
                      Text(block.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                    ],
                  ),
                  StatusChip(status: block.status),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetric('YIELD', block.yield, Icons.analytics_rounded),
                  _buildMetric('MACHINE', '${block.machine}${block.machineType != null ? " (${block.machineType})" : ""}', Icons.settings_suggest_rounded),
                  _buildMetric('COMPLETION', '${(block.progress * 100).toInt()}%', Icons.speed_rounded),
                ],
              ),

              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: block.progress,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: block.progress > 0.8 ? Colors.greenAccent : (block.progress > 0.3 ? Colors.orangeAccent : Colors.redAccent),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepBlue2,
        title: const Text('Add Block Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Sector/Block Name',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: AppColors.deepBlue1,
                items: ['Block Machine B-200', 'JCB-04', 'CRANE-01', 'MIXER-09']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (_) {},
                decoration: InputDecoration(
                  labelText: 'Assign Machine',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('ADD')),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: Colors.white.withOpacity(0.4)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class BlockItem {
  final String id;
  final String name;
  final double progress;
  final UiStatus status;
  final String yield;
  final String machine;
  final String? machineType;

  BlockItem({
    required this.id,
    required this.name,
    required this.progress,
    required this.status,
    required this.yield,
    required this.machine,
    this.machineType,
  });
}

