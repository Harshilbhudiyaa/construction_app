import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LowStockAlertsWidget extends StatefulWidget {
  const LowStockAlertsWidget({super.key});

  @override
  State<LowStockAlertsWidget> createState() => _LowStockAlertsWidgetState();
}

class _LowStockAlertsWidgetState extends State<LowStockAlertsWidget>
    with SingleTickerProviderStateMixin {
  bool _collapsed = false;


  @override
  Widget build(BuildContext context) {
    final inventoryService = Provider.of<InventoryRepository>(context);

    return StreamBuilder<List<ConstructionMaterial>>(
      stream: inventoryService.getMaterialsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final lowStockMaterials = snapshot.data!
            .where((m) => m.currentStock <= m.minimumStockLimit)
            .toList();

        if (lowStockMaterials.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bcDanger.withValues(alpha: 0.08), bcDanger.withValues(alpha: 0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: bcDanger.withValues(alpha: 0.35), width: 1.2),
            ),
            child: Column(
              children: [
                // Header / Toggle Row
                GestureDetector(
                  onTap: () => setState(() => _collapsed = !_collapsed),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: bcDanger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.warning_amber_rounded,
                              color: bcDanger, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'LOW STOCK ALERT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: bcDanger,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                '${lowStockMaterials.length} material${lowStockMaterials.length > 1 ? 's' : ''} below minimum threshold',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _collapsed ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: const Icon(Icons.keyboard_arrow_up_rounded,
                              color: bcDanger, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expandable content
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _collapsed
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            Divider(
                                height: 1,
                                color: bcDanger.withValues(alpha: 0.2),
                                thickness: 1),
                            ...lowStockMaterials.map((material) {
                              final remaining = material.currentStock;
                              final minimum = material.minimumStockLimit;
                              final pct = minimum > 0
                                  ? (remaining / minimum).clamp(0.0, 1.0)
                                  : 0.0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: bcDanger.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.inventory_2_rounded,
                                          size: 14,
                                          color: bcDanger),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            material.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                              color: bcNavy,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: pct,
                                              minHeight: 4,
                                              backgroundColor:
                                                  bcDanger.withValues(alpha: 0.1),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                pct < 0.3
                                                    ? bcDanger
                                                    : bcAmber,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${remaining.toStringAsFixed(0)} ${material.unitType}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                            color: bcDanger,
                                          ),
                                        ),
                                        Text(
                                          'Min: ${minimum.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 4),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

