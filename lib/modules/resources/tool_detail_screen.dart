import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/services/mock_tool_service.dart';
import 'package:construction_app/shared/widgets/confirm_dialog.dart';
import 'package:construction_app/utils/feedback_helper.dart';
import 'tool_model.dart';
import 'tool_form_screen.dart';

class ToolDetailScreen extends StatelessWidget {
  final String toolId;

  const ToolDetailScreen({super.key, required this.toolId});

  @override
  Widget build(BuildContext context) {
    return Consumer<MockToolService>(
      builder: (context, service, child) {
        final tool = service.tools.where((t) => t.id == toolId).firstOrNull;

        if (tool == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: Text('Tool not found', style: TextStyle(color: Theme.of(context).colorScheme.primary))),
          );
        }

        return ProfessionalPage(
          title: 'Asset Detail',
          actions: [
            IconButton(
              onPressed: () => _editTool(context, service, tool),
              icon: Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.primary),
            ),
            IconButton(
              onPressed: () => _deleteTool(context, service, tool),
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            ),
          ],
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Asset Header
                  ProfessionalCard(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                          ),
                          child: Center(child: Text(tool.type.icon, style: const TextStyle(fontSize: 40))),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tool.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.8)),
                              const SizedBox(height: 4),
                              Text(tool.type.displayName.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), letterSpacing: 0.5)),
                              const SizedBox(height: 12),
                              _buildConditionBadge(context, tool.condition),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'OPERATIONAL STATUS', Icons.analytics_rounded),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildMetricBox(context, 'TOTAL', '${tool.quantity}', Colors.blueAccent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricBox(context, 'READY', '${tool.availableQuantity}', Colors.greenAccent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricBox(context, 'IN USE', '${tool.inUseQuantity}', Colors.orangeAccent)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'ALLOCATION & LOGISTICS', Icons.location_history_rounded),
                  const SizedBox(height: 16),
                  
                  ProfessionalCard(
                    useGlass: true,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(context, Icons.location_on_rounded, 'Active Site', tool.assignedSiteName ?? 'Hub Repository'),
                        const Divider(height: 32),
                        _buildInfoRow(context, Icons.person_pin_circle_rounded, 'Responsible Engineer', tool.assignedEngineerName ?? 'Central Pool'),
                        const Divider(height: 32),
                        _buildInfoRow(context, Icons.task_alt_rounded, 'Primary Purpose', tool.usagePurpose),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'COMPLIANCE', Icons.fact_check_rounded),
                  const SizedBox(height: 16),
                  
                  ProfessionalCard(
                    useGlass: true,
                    padding: const EdgeInsets.all(20),
                    child: _buildInfoRow(
                      context,
                      Icons.calendar_today_rounded, 
                      'Last Safety Inspection', 
                      DateFormat('MMMM dd, yyyy').format(tool.lastInspectionDate),
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _editTool(context, service, tool),
                      icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                      label: const Text('EDIT ASSET DATA', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildMetricBox(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -1)),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionBadge(BuildContext context, ToolCondition condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(condition.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(condition.displayName.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Future<void> _editTool(BuildContext context, MockToolService service, ToolModel tool) async {
    final result = await Navigator.push<ToolModel>(
      context,
      MaterialPageRoute(builder: (_) => ToolFormScreen(tool: tool)),
    );
    if (result != null) service.updateTool(result);
  }

  Future<void> _deleteTool(BuildContext context, MockToolService service, ToolModel tool) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Decommission Asset',
      message: 'Are you sure you want to remove "${tool.name}" from the inventory? This action cannot be undone.',
      confirmText: 'Remove Asset',
      isDangerous: true,
    );
    if (confirmed == true) {
      service.deleteTool(tool.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
