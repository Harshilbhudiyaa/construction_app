import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'stock_outward_screen.dart';
import 'stock_transfer_screen.dart';
import 'stock_damage_screen.dart';
import 'material_request_screen.dart';

class StockOperationsScreen extends StatefulWidget {
  const StockOperationsScreen({super.key});

  @override
  State<StockOperationsScreen> createState() => _StockOperationsScreenState();
}

class _StockOperationsScreenState extends State<StockOperationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We wrap individual screens in a way that respects the tab view
    // Since screens might be Scaffolds, we need to handle that.
    // However, ProfessionalPage is a Scaffold. Nested Scaffolds are okay but might double app bars.
    // Ideally, these screens should be refactored to be widgets, not full pages.
    // For now, I'll use a TabBarView.
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Operations', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: DesignSystem.electricBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: DesignSystem.electricBlue,
          tabs: const [
            Tab(text: 'Outward', icon: Icon(Icons.remove_circle_outline)),
            Tab(text: 'Transfer', icon: Icon(Icons.swap_horizontal_circle)),
            Tab(text: 'Damage', icon: Icon(Icons.warning_amber_rounded)),
            Tab(text: 'Requests', icon: Icon(Icons.request_quote)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          StockOutwardScreen(), // Hopefully these handle being nested or we need to strip their Scaffold
          StockTransferScreen(),
          StockDamageScreen(),
          MaterialRequestScreen(),
        ],
      ),
    );
  }
}
