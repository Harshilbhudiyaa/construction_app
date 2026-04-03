import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';

class LowStockAlertDialog extends StatelessWidget {
  final List<ConstructionMaterial> materials;
  final VoidCallback onAction;

  const LowStockAlertDialog({
    super.key,
    required this.materials,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: bcCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: bcDanger.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: bcDanger.withValues(alpha: 0.1),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildList(),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bcDanger.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bcDanger.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.priority_high_rounded, color: bcDanger, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'INVENTORY REPLENISHMENT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: bcDanger,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'CRITICAL STOCK ALERT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: bcNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: materials.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final m = materials[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bcSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bcDanger.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(m.category.icon, color: bcNavy.withValues(alpha: 0.3), size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: bcNavy),
                      ),
                      Text(
                        'Only ${m.currentStock} ${m.unitType.label} left',
                        style: const TextStyle(fontSize: 11, color: bcDanger, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAction();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: bcNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('PROCEED TO REPLENISH', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: bcDanger,
              minimumSize: const Size(double.infinity, 32),
            ),
            child: const Text('DISMISS FOR NOW', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
