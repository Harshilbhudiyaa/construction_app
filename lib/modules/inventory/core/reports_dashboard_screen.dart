import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Reports & Analytics',
      children: [
        const ProfessionalSectionHeader(
          title: 'Inventory Reports',
          subtitle: 'View and export detailed reports',
        ),
        
        _buildReportGrid(context),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildReportGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        _buildReportCard(
          context,
          icon: Icons.assessment,
          title: 'Stock Report',
          subtitle: 'Current inventory',
          color: const Color(0xFF2196F3),
          onTap: () => _showReport(context, 'Stock Report'),
        ),
        _buildReportCard(
          context,
          icon: Icons.trending_down,
          title: 'Usage Report',
          subtitle: 'Material consumption',
          color: const Color(0xFFE91E63),
          onTap: () => _showReport(context, 'Usage Report'),
        ),
        _buildReportCard(
          context,
          icon: Icons.shopping_cart,
          title: 'Purchase Report',
          subtitle: 'Procurement details',
          color: const Color(0xFF4CAF50),
          onTap: () => _showReport(context, 'Purchase Report'),
        ),
        _buildReportCard(
          context,
          icon: Icons.people,
          title: 'Supplier Report',
          subtitle: 'Vendor analysis',
          color: const Color(0xFFFF9800),
          onTap: () => _showReport(context, 'Supplier Report'),
        ),
        _buildReportCard(
          context,
          icon: Icons.warning,
          title: 'Damage Report',
          subtitle: 'Loss & wastage',
          color: const Color(0xFFFF5722),
          onTap: () => _showReport(context, 'Damage Report'),
        ),
        _buildReportCard(
          context,
          icon: Icons.receipt_long,
          title: 'Bill Report',
          subtitle: 'Invoice summary',
          color: const Color(0xFF9C27B0),
          onTap: () => _showReport(context, 'Bill Report'),
        ),
      ],
    );
  }

  Widget _buildReportCard(
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReport(BuildContext context, String reportType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reportType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select date range and export options'),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Generating $reportType...')),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.file_download),
              label: const Text('Export as PDF'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
