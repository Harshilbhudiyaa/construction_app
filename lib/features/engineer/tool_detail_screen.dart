import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import 'models/tool_model.dart';
import 'package:intl/intl.dart';
import 'tool_form_screen.dart';

class ToolDetailScreen extends StatelessWidget {
  final ToolModel tool;

  const ToolDetailScreen({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Tool Details',
      actions: [
        IconButton(
          onPressed: () => _editTool(context),
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              ProfessionalCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                gradient: const LinearGradient(
                  colors: [AppColors.deepBlue2, AppColors.deepBlue3],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          tool.type.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tool.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            tool.type.displayName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildConditionBadge(tool.condition),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Stock & Allocation'),
              ProfessionalCard(
                child: Column(
                  children: [
                    _buildStockRow(tool),
                    const Divider(height: 30),
                    _buildInfoRow(Icons.location_on_rounded, 'Site Assignment', tool.assignedSiteName ?? 'Warehouse'),
                    const Divider(height: 20),
                    _buildInfoRow(Icons.engineering_rounded, 'Assigned Engineer', tool.assignedEngineerName ?? 'Generic Pool'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Technical Specifications'),
              ProfessionalCard(
                child: Column(
                  children: [
                    _buildInfoRow(Icons.description_rounded, 'Purpose', tool.usagePurpose),
                    const Divider(height: 20),
                    _buildInfoRow(
                      Icons.verified_user_rounded,
                      'Last Inspection',
                      DateFormat('MMM dd, yyyy').format(tool.lastInspectionDate),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _editTool(context),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Update Repository'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.deepBlue1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConditionBadge(ToolCondition condition) {
    Color color;
    switch (condition) {
      case ToolCondition.excellent: color = Colors.greenAccent; break;
      case ToolCondition.good: color = Colors.lightGreenAccent; break;
      case ToolCondition.fair: color = Colors.orangeAccent; break;
      case ToolCondition.poor: color = Colors.deepOrangeAccent; break;
      case ToolCondition.needsRepair: color = Colors.redAccent; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '${condition.icon} ${condition.displayName}',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStockRow(ToolModel tool) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStockItem('Total', tool.quantity.toString(), Colors.blue),
        _buildStockItem('Available', tool.availableQuantity.toString(), Colors.green),
        _buildStockItem('In Use', tool.inUseQuantity.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildStockItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.deepBlue1.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.deepBlue1, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.deepBlue1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editTool(BuildContext context) async {
    final result = await Navigator.push<ToolModel>(
      context,
      MaterialPageRoute(
        builder: (context) => ToolFormScreen(tool: tool),
      ),
    );
    if (result != null && context.mounted) {
      Navigator.pop(context, result);
    }
  }
}
