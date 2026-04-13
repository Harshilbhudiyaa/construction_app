import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';

class TactileMaterialSelector extends StatelessWidget {
  final ConstructionMaterial? selectedMaterial;
  final VoidCallback onTap;
  final bool showSyncButton;
  final Color themeColor;
  final String label;
  final String subLabel;
  final String? techTag;

  const TactileMaterialSelector({
    super.key,
    required this.selectedMaterial,
    required this.onTap,
    this.showSyncButton = true,
    this.themeColor = bcAmber,
    this.label = 'Select Construction Material',
    this.subLabel = 'Tap to browse inventory',
    this.techTag,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedMaterial != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.7, 1.0],
            colors: [
              Colors.white,
              const Color(0xFFF1F5F9),
              themeColor.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(color: themeColor.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: bcNavy.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Industrial Corner Accent
            Positioned(
              top: -10,
              right: -10,
              child: Transform.rotate(
                angle: 0.785, // 45 degrees
                child: Container(
                  width: 40,
                  height: 12,
                  color: themeColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            Row(
              children: [
                // Selected Material Icon Module
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: bcNavy.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.15),
                        blurRadius: 1,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                    child: Center(
                    child: Icon(
                      Icons.foundation_rounded, 
                      color: themeColor, 
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (techTag != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            techTag!.toUpperCase(),
                            style: TextStyle(
                              color: themeColor.withValues(alpha: 0.6),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      Text(
                        selectedMaterial!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900, 
                          fontSize: 19,
                          color: bcNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.analytics_outlined, color: themeColor, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              'STOCK: ${selectedMaterial!.currentStock} ${selectedMaterial!.unitType}'.toUpperCase(),
                              style: TextStyle(
                                color: themeColor, 
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                fontFamily: 'monospace', // Technical font
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (showSyncButton)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bcNavy.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: bcNavy.withValues(alpha: 0.05)),
                        ),
                        child: const Icon(Icons.sync_rounded, color: bcNavy, size: 24),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFF8FAFC),
            ],
          ),
          border: Border.all(
            color: bcNavy.withValues(alpha: 0.12), 
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: themeColor.withValues(alpha: 0.1)),
              ),
              child: Icon(Icons.add_circle_outline_rounded, size: 40, color: themeColor),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: bcNavy, 
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subLabel,
              style: TextStyle(
                color: bcNavy.withValues(alpha: 0.4),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
