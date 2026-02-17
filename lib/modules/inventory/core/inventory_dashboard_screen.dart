import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';

import 'package:construction_app/modules/inventory/materials/screens/material_list_screen.dart';
import 'package:construction_app/modules/inventory/materials/screens/master_material_list_screen.dart';
import 'package:construction_app/modules/inventory/inward/screens/inward_management_dashboard_screen.dart';
import 'package:construction_app/modules/inventory/parties/screens/party_management_screen.dart';
import 'package:construction_app/modules/inventory/stock/screens/stock_outward_screen.dart';
import 'package:construction_app/modules/inventory/stock/screens/stock_transfer_screen.dart';
import 'package:construction_app/modules/inventory/stock/screens/stock_damage_screen.dart';
import 'package:construction_app/modules/inventory/stock/screens/material_request_screen.dart';
import 'package:construction_app/modules/inventory/approvals/approval_dashboard_screen.dart';
import 'reports_dashboard_screen.dart';
import 'package:construction_app/services/mock_inventory_service.dart';
import 'package:provider/provider.dart';

class InventoryDashboardScreen extends StatelessWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Inventory Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_forever_rounded),
          tooltip: 'Clear All Data',
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear All Data?'),
                content: const Text('This will permanently delete all inventory data. This action cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            );
            
            if (confirmed == true && context.mounted) {
              // Clear all data using mock service
              final inventoryService = context.read<MockInventoryService>();
              await inventoryService.clearAllData();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All inventory data cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
        ),
      ],
      children: [
        const SizedBox(height: 16),
        
        // Quick Stats Section
        const ProfessionalSectionHeader(
          title: 'Inventory Overview',
          subtitle: 'Real-time stock summary',
        ),
        _buildQuickStats(context),
        
        const SizedBox(height: 24),
        
        // Main Features Grid
        const ProfessionalSectionHeader(
          title: 'Material Management',
          subtitle: 'Manage your construction materials',
        ),
        _buildFeatureGrid(context),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final theme = Theme.of(context);
    final inventoryService = context.watch<MockInventoryService>();
    
    return StreamBuilder<List<dynamic>>(
      stream: inventoryService.getMaterialsStream(),
      builder: (context, materialSnapshot) {
        return StreamBuilder<List<dynamic>>(
          stream: inventoryService.getInwardLogsStream(),
          builder: (context, inwardSnapshot) {
            final materials = materialSnapshot.data ?? [];
            final inwardLogs = inwardSnapshot.data ?? [];
            
            // Calculate real-time stats
            final totalMaterials = materials.length;
            final activeCategories = materials.map((m) => m.category).toSet().length;
            final totalValue = materials.fold<double>(0, (sum, m) => sum + (m.totalAmount ?? 0));
            final pendingApprovals = inwardLogs.where((log) => log.status.toString().contains('pending')).length;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    context,
                    icon: Icons.inventory_2_rounded,
                    title: 'Total Materials',
                    value: '$totalMaterials',
                    color: theme.colorScheme.primary,
                  ),
                  _buildStatCard(
                    context,
                    icon: Icons.category_rounded,
                    title: 'Active Categories',
                    value: '$activeCategories',
                    color: Colors.blueAccent,
                  ),
                  _buildStatCard(
                    context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Total Value',
                    value: '₹${(totalValue / 100000).toStringAsFixed(1)}L',
                    color: Colors.greenAccent,
                  ),
                  _buildStatCard(
                    context,
                    icon: Icons.pending_actions_rounded,
                    title: 'Pending Approvals',
                    value: '$pendingApprovals',
                    color: Colors.orange,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.inventory_rounded,
            title: 'Stock Inventory',
            subtitle: 'View all materials',
            color: const Color(0xFF2196F3),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MaterialListScreen(isAdmin: true),
                ),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.add_box_rounded,
            title: 'Inward Entry',
            subtitle: 'Add new stock',
            color: const Color(0xFF4CAF50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InwardManagementDashboardScreen(),
                ),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.list_alt_rounded,
            title: 'Master Registry',
            subtitle: 'Material catalog',
            color: const Color(0xFF9C27B0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MasterMaterialListScreen(),
                ),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.business_rounded,
            title: 'Suppliers',
            subtitle: 'Manage parties',
            color: const Color(0xFFFF9800),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PartyManagementScreen(),
                ),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.remove_circle_outline,
            title: 'Stock Outward',
            subtitle: 'Material usage',
            color: const Color(0xFFE91E63),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StockOutwardScreen(),
                ),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.swap_horizontal_circle,
            title: 'Transfer',
            subtitle: 'Inter-site move',
            color: const Color(0xFF00BCD4),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StockTransferScreen(),
                ),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.warning_rounded,
            title: 'Damage/Waste',
            subtitle: 'Report loss',
            color: const Color(0xFFFF5722),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StockDamageScreen(),
                ),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.request_quote,
            title: 'Request',
            subtitle: 'Material request',
            color: const Color(0xFF3F51B5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MaterialRequestScreen(),
                ),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.approval,
            title: 'Approvals',
            subtitle: 'Pending requests',
            color: const Color(0xFF673AB7),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ApprovalDashboardScreen(),
                ),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.analytics,
            title: 'Reports',
            subtitle: 'Analytics',
            color: const Color(0xFF009688),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportsDashboardScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ProfessionalCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
