import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:intl/intl.dart';

class ReportFilterBar extends StatelessWidget {
  final DateTimeRange? dateRange;
  final MaterialCategory? selectedCategory;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(MaterialCategory?) onCategoryChanged;
  final VoidCallback onClearFilters;

  const ReportFilterBar({
    super.key,
    required this.dateRange,
    required this.selectedCategory,
    required this.onDateRangeChanged,
    required this.onCategoryChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final rangeText = dateRange == null 
        ? 'Select Date Range' 
        : '${dateFormat.format(dateRange!.start)} - ${dateFormat.format(dateRange!.end)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bcCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Date Picker Trigger
            _buildFilterChip(
              context,
              label: rangeText,
              icon: Icons.calendar_today_rounded,
              isActive: dateRange != null,
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: bcNavy,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: bcNavy,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) onDateRangeChanged(picked);
              },
            ),
            const SizedBox(width: 12),
            // Category Dropdown
            _buildCategorySelector(context),
            const SizedBox(width: 12),
            if (dateRange != null || selectedCategory != null)
              IconButton(
                onPressed: onClearFilters,
                icon: const Icon(Icons.refresh_rounded, color: bcDanger, size: 20),
                tooltip: 'Clear Filters',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, {
    required String label,
    required IconData icon,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? bcNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isActive ? bcNavy : const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: isActive ? Colors.white : const Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return PopupMenuButton<MaterialCategory?>(
      onSelected: onCategoryChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All Categories')),
        ...MaterialCategory.values.map(
          (c) => PopupMenuItem(value: c, child: Text(c.displayName)),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedCategory != null ? bcNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selectedCategory != null ? bcNavy : const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectedCategory?.icon ?? Icons.category_rounded,
              size: 16,
              color: selectedCategory != null ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              selectedCategory?.displayName ?? 'All Categories',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selectedCategory != null ? Colors.white : const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: selectedCategory != null ? Colors.white : const Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}
