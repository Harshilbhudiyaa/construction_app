import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/staggered_animation.dart';
import '../../app/ui/widgets/app_search_field.dart';
import '../../app/ui/widgets/empty_state.dart';
import '../../app/utils/feedback_helper.dart';
import 'models/tool_model.dart';
import 'tool_form_screen.dart';
import 'tool_detail_screen.dart';

class ToolsManagementScreen extends StatefulWidget {
  const ToolsManagementScreen({super.key});

  @override
  State<ToolsManagementScreen> createState() => _ToolsManagementScreenState();
}

class _ToolsManagementScreenState extends State<ToolsManagementScreen> {
  String _searchQuery = '';
  ToolType? _filterType;

  // Sample data
  final List<ToolModel> _tools = [
    ToolModel(
      id: '1',
      name: 'Electric Drill Set',
      type: ToolType.powerTool,
      usagePurpose: 'Drilling holes in concrete and wood',
      assignedSiteId: 'site1',
      assignedSiteName: 'Metropolis Heights',
      assignedEngineerId: 'eng1',
      assignedEngineerName: 'Rajesh Kumar',
      quantity: 5,
      availableQuantity: 2,
      condition: ToolCondition.good,
      lastInspectionDate: DateTime(2025, 1, 5),
    ),
    ToolModel(
      id: '2',
      name: 'Safety Helmets',
      type: ToolType.safetyEquipment,
      usagePurpose: 'Worker head protection',
      quantity: 50,
      availableQuantity: 18,
      condition: ToolCondition.excellent,
      lastInspectionDate: DateTime(2025, 1, 10),
    ),
    ToolModel(
      id: '3',
      name: 'Measuring Tape (50m)',
      type: ToolType.measuringTool,
      usagePurpose: 'Site measurements and layout',
      assignedSiteId: 'site2',
      assignedSiteName: 'Skyline Plaza',
      quantity: 10,
      availableQuantity: 7,
      condition: ToolCondition.good,
      lastInspectionDate: DateTime(2024, 12, 20),
    ),
    ToolModel(
      id: '4',
      name: 'Welding Machine',
      type: ToolType.weldingEquipment,
      usagePurpose: 'Steel fabrication and welding',
      assignedSiteId: 'site1',
      assignedSiteName: 'Metropolis Heights',
      quantity: 3,
      availableQuantity: 1,
      condition: ToolCondition.fair,
      lastInspectionDate: DateTime(2024, 12, 15),
    ),
    ToolModel(
      id: '5',
      name: 'Ladder (Extension)',
      type: ToolType.ladderScaffold,
      usagePurpose: 'Height access for construction',
      quantity: 8,
      availableQuantity: 3,
      condition: ToolCondition.good,
      lastInspectionDate: DateTime(2025, 1, 1),
    ),
    ToolModel(
      id: '6',
      name: 'Paint Spray Gun',
      type: ToolType.paintingTool,
      usagePurpose: 'Surface painting and finishing',
      quantity: 6,
      availableQuantity: 6,
      condition: ToolCondition.excellent,
      lastInspectionDate: DateTime(2025, 1, 8),
    ),
  ];

  List<ToolModel> get _filteredTools {
    var filtered = _tools;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((tool) {
        final query = _searchQuery.toLowerCase();
        return tool.name.toLowerCase().contains(query) ||
            tool.type.displayName.toLowerCase().contains(query) ||
            tool.usagePurpose.toLowerCase().contains(query);
      }).toList();
    }

    if (_filterType != null) {
      filtered = filtered.where((t) => t.type == _filterType).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Tools & Equipment',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddToolDialog(context),
        backgroundColor: AppColors.deepBlue1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Tool', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      children: [
        AppSearchField(
          hint: 'Search by tool name, type, or purpose...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),

        // Type Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', _filterType == null, () {
                  setState(() => _filterType = null);
                }),
                const SizedBox(width: 8),
                ...ToolType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      '${type.icon} ${type.displayName}',
                      _filterType == type,
                      () => setState(() => _filterType = type),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Stats Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Tools',
                  '${_tools.length}',
                  Icons.build_rounded,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Total Units',
                  '${_tools.fold<int>(0, (sum, tool) => sum + tool.quantity)}',
                  Icons.inventory_rounded,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'In Use',
                  '${_tools.fold<int>(0, (sum, tool) => sum + tool.inUseQuantity)}',
                  Icons.handyman_rounded,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ),
        
        const ProfessionalSectionHeader(
          title: 'Equipment Inventory',
          subtitle: 'Track tools and equipment allocation',
        ),

        if (_filteredTools.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: EmptyState(
              icon: Icons.build_rounded,
              title: 'No Tools Found',
              message: 'Try adjusting your filters or add new tools.',
            ),
          )
        else
          ..._filteredTools.asMap().entries.map((entry) {
            final index = entry.key;
            final tool = entry.value;
            final utilizationPercent = (tool.inUseQuantity / tool.quantity * 100).round();
            
            return StaggeredAnimation(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ProfessionalCard(
                  child: InkWell(
                    onTap: () => _showToolDetails(context, tool),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Tool Icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _getConditionGradient(tool.condition),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    tool.type.icon,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Tool Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tool.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: AppColors.deepBlue1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tool.type.displayName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Condition Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getConditionColor(tool.condition).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getConditionColor(tool.condition).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tool.condition.icon,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      tool.condition.displayName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _getConditionColor(tool.condition),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          Text(
                            tool.usagePurpose,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          
                          // Quantity Information
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuantityInfo(
                                  'Total',
                                  tool.quantity.toString(),
                                  Colors.blue,
                                ),
                              ),
                              Expanded(
                                child: _buildQuantityInfo(
                                  'Available',
                                  tool.availableQuantity.toString(),
                                  Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _buildQuantityInfo(
                                  'In Use',
                                  tool.inUseQuantity.toString(),
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Utilization Bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Utilization',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$utilizationPercent%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.deepBlue1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: utilizationPercent / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation(
                                    utilizationPercent > 80 ? Colors.orange : Colors.blue,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                          
                          if (tool.assignedSiteName != null || tool.assignedEngineerName != null) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            if (tool.assignedSiteName != null)
                              _buildDetailItem(
                                Icons.location_on_rounded,
                                'Assigned Site',
                                tool.assignedSiteName!,
                              ),
                            if (tool.assignedEngineerName != null) ...[
                              const SizedBox(height: 8),
                              _buildDetailItem(
                                Icons.person_rounded,
                                'Assigned To',
                                tool.assignedEngineerName!,
                              ),
                            ],
                          ],
                          
                          const SizedBox(height: 8),
                          _buildDetailItem(
                            Icons.verified_rounded,
                            'Last Inspection',
                            _formatDate(tool.lastInspectionDate),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.deepBlue1,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepBlue1 : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.deepBlue1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _getConditionColor(ToolCondition condition) {
    switch (condition) {
      case ToolCondition.excellent:
        return Colors.green;
      case ToolCondition.good:
        return Colors.blue;
      case ToolCondition.fair:
        return Colors.orange;
      case ToolCondition.poor:
        return Colors.red;
      case ToolCondition.needsRepair:
        return Colors.red.shade700;
    }
  }

  List<Color> _getConditionGradient(ToolCondition condition) {
    final color = _getConditionColor(condition);
    return [color.withOpacity(0.7), color];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddToolDialog(BuildContext context) async {
    final result = await Navigator.push<ToolModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const ToolFormScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _tools.add(result);
      });
    }
  }

  void _showToolDetails(BuildContext context, ToolModel tool) async {
    final result = await Navigator.push<ToolModel>(
      context,
      MaterialPageRoute(
        builder: (context) => ToolDetailScreen(tool: tool),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _tools.indexWhere((t) => t.id == tool.id);
        if (index != -1) {
          _tools[index] = result;
        }
      });
    }
  }
}
