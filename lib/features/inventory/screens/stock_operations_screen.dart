import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'stock_out_form_screen.dart';
import 'stock_transfer_screen.dart';
import 'stock_damage_screen.dart';
import 'material_request_screen.dart';

class StockOperationsScreen extends StatefulWidget {
  final double? initialQuantity;
  final String? initialPurpose;
  
  const StockOperationsScreen({
    super.key, 
    this.initialQuantity,
    this.initialPurpose,
  });

  @override
  State<StockOperationsScreen> createState() => _StockOperationsScreenState();
}

class _StockOperationsScreenState extends State<StockOperationsScreen> {
  @override
  Widget build(BuildContext context) {
    return ProfessionalBackground(
      child: DefaultTabController(
        length: 4,
        initialIndex: (widget.initialQuantity != null) ? 1 : 0,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SmartConstructionSliverAppBar(
                  title: 'Stock Operations',
                  subtitle: 'Execute material movements',
                  category: 'OPERATIONAL HUB',
                  isFull: false,
                  bottom: TabBar(
                    isScrollable: true,
                    indicatorColor: bcAmber,
                    indicatorWeight: 4,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: UnderlineTabIndicator(
                      borderSide: const BorderSide(color: bcAmber, width: 4),
                      insets: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    labelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.4),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    tabs: const [
                    Tab(
                      child: Row(
                        children: [
                          Icon(Icons.assignment_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Requisition'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(Icons.precision_manufacturing_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Consumption'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(Icons.local_shipping_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Logistics'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(Icons.gpp_maybe_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Incident'),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                const MaterialRequestScreen(showHeader: false),
                StockOutFormScreen(
                  initialQuantity: widget.initialQuantity,
                  initialPurpose: widget.initialPurpose,
                ),
                const StockTransferScreen(),
                const StockDamageScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


