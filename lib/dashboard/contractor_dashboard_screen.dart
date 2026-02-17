import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/services/mock_inventory_service.dart';
import 'package:construction_app/services/auth_service.dart';
import 'package:construction_app/shared/search/material_search_delegate.dart';

class ContractorDashboardScreen extends StatefulWidget {
  final void Function(int tabIndex) onNavigateTo;

  const ContractorDashboardScreen({super.key, required this.onNavigateTo});

  @override
  State<ContractorDashboardScreen> createState() => _ContractorDashboardScreenState();
}

class _ContractorDashboardScreenState extends State<ContractorDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Command Center',
      actions: [
        IconButton(
          onPressed: () => context.read<AuthService>().logout(),
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
      floatingActionButton: _QuickAddFab(
        isExpanded: _isFabExpanded,
        onToggle: _toggleFab,
        controller: _fabController,
        onNavigateTo: widget.onNavigateTo,
      ),
      children: [
        _buildGreeting(),
        _buildQuickSearch(),

        const SizedBox(height: 24),
        _buildKPIs(context),
        
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        const SizedBox(height: 12),
        _buildQuickActionsGrid(),

        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        const SizedBox(height: 12),
        _buildRecentActivity(context),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildQuickSearch() {
    return GestureDetector(
      onTap: () {
        showSearch(
          context: context,
          delegate: MaterialSearchDelegate(context),
        );
      },
      child: AbsorbPointer(
        child: AppSearchField(
          hint: 'Search everything...',
          onChanged: (v) {},
        ),
      ),
    );
  }

  Widget _buildKPIs(BuildContext context) {
    final inventoryService = context.watch<MockInventoryService>();
    
    return StreamBuilder<List<dynamic>>(
      stream: inventoryService.getMaterialsStream(),
      builder: (context, materialSnapshot) {
        // Calculate stats
        final materials = materialSnapshot.data ?? [];
        final totalValue = materials.fold<double>(0, (sum, m) => sum + (m.totalAmount ?? 0));
        final lowStock = materials.where((m) => (m.currentStock) < 10).length; // Mock logic
        
        return SizedBox(
          height: 140, // Fixed height for horizontal scroll
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildKPICard(
                title: 'Total Stock Value',
                value: '₹${(totalValue / 100000).toStringAsFixed(2)}L',
                icon: Icons.account_balance_wallet_rounded,
                color: DesignSystem.success,
                trend: '+12% vs last month',
              ),
              const SizedBox(width: 12),
              _buildKPICard(
                title: 'Low Stock Items',
                value: '$lowStock',
                icon: Icons.warning_rounded,
                color: DesignSystem.warning,
                trend: 'Needs attention',
                isAlert: lowStock > 0,
              ),
              const SizedBox(width: 12),
              _buildKPICard(
                title: 'Active Sites',
                value: '3',
                icon: Icons.location_city_rounded,
                color: DesignSystem.electricBlue,
                trend: 'Running smoothly',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    bool isAlert = false,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.deepNavy.withOpacity(0.05), // Light background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? color.withOpacity(0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              if (isAlert) 
                Icon(Icons.circle, size: 8, color: color),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: DesignSystem.deepNavy)),
              Text(title, style: TextStyle(fontSize: 12, color: DesignSystem.deepNavy.withOpacity(0.6), fontWeight: FontWeight.w600)),
            ],
          ),
          Text(
            trend,
            style: TextStyle(
              fontSize: 10, 
              color: isAlert ? color : DesignSystem.success,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuickActionButton(
            label: 'Add Material',
            icon: Icons.add_box_rounded,
            color: DesignSystem.royalBlue,
            onTap: () => widget.onNavigateTo(1), // Inventory
          ),
          _buildQuickActionButton(
            label: 'New Inward',
            icon: Icons.move_to_inbox_rounded,
            color: DesignSystem.success,
            onTap: () => widget.onNavigateTo(2), // Inward
          ),
          _buildQuickActionButton(
            label: 'Issue Stock',
            icon: Icons.upload_rounded,
            color: DesignSystem.warning,
             onTap: () => widget.onNavigateTo(3), // Stock Ops
          ),
           _buildQuickActionButton(
            label: 'Add Supplier',
            icon: Icons.person_add_rounded,
            color: DesignSystem.info,
            onTap: () => widget.onNavigateTo(5), // Suppliers
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  
  Widget _buildRecentActivity(BuildContext context) {
      // Mock Data for now
      return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) {
              return Card(
                  elevation: 0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: DesignSystem.deepNavy.withOpacity(0.1),
                          child: Icon(Icons.history, color: DesignSystem.deepNavy, size: 16),
                      ),
                      title: Text('Material Inward #${1001 + index}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: const Text('Cement - 50 Bags received'),
                      trailing: Text('2m ago', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  ),
              );
          },
      );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;
    if (hour < 12) {
      greeting = 'Good Morning';
      icon = Icons.light_mode_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      icon = Icons.wb_sunny_rounded;
    } else {
      greeting = 'Good Evening';
      icon = Icons.nightlight_round;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, Admin',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: DesignSystem.deepNavy),
                ),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          CircleAvatar(
             backgroundColor: DesignSystem.deepNavy.withOpacity(0.1),
             child: Icon(icon, color: DesignSystem.deepNavy),
          )
        ],
      ),
    );
  }
}

class _QuickAddFab extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final AnimationController controller;
   final void Function(int tabIndex) onNavigateTo;

  const _QuickAddFab({
    required this.isExpanded,
    required this.onToggle,
    required this.controller,
    required this.onNavigateTo,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onToggle,
      backgroundColor: DesignSystem.deepNavy,
      child: Icon(isExpanded ? Icons.close : Icons.add, color: Colors.white),
    );
  }
}

