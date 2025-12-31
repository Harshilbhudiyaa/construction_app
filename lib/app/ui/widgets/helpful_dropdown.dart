import 'package:flutter/material.dart';
import '../../theme/professional_theme.dart';
import 'info_tooltip.dart';

/// Enhanced dropdown with better UX
class HelpfulDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T)? labelMapper;
  final ValueChanged<T?> onChanged;
  final String? tooltipMessage;
  final String? helpText;
  final IconData? icon;

  const HelpfulDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelMapper,
    this.tooltipMessage,
    this.helpText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with tooltip
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
            if (tooltipMessage != null) ...[
              const SizedBox(width: 6),
              InfoTooltip(message: tooltipMessage!),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Dropdown
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          items: items.map((e) {
            return DropdownMenuItem<T>(
              value: e,
              child: Text(
                labelMapper?.call(e) ?? e.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.deepBlue1,
                width: 2,
              ),
            ),
          ),
        ),

        // Help text
        if (helpText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 14,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  helpText!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
