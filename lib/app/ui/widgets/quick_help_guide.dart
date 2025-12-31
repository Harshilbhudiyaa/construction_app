import 'package:flutter/material.dart';
import '../../theme/professional_theme.dart';

/// A quick help guide widget that shows helpful tips to users
class QuickHelpGuide extends StatelessWidget {
  final String title;
  final List<HelpItem> items;
  final bool isExpanded;

  const QuickHelpGuide({
    super.key,
    required this.title,
    required this.items,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.deepBlue1.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.deepBlue1.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.tips_and_updates_rounded,
            color: AppColors.deepBlue1,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue1,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.icon,
                        size: 18,
                        color: AppColors.deepBlue1.withOpacity(0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpItem {
  final IconData icon;
  final String title;
  final String description;

  const HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
