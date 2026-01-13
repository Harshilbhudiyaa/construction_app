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

  final bool useGlass;
  final bool readOnly;

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
    this.useGlass = false,
    this.readOnly = false,
  });


  @override
  Widget build(BuildContext context) {
    final labelColor = useGlass ? Colors.white.withOpacity(0.9) : Colors.grey[600];
    final fillColor = useGlass ? Colors.white.withOpacity(0.08) : Colors.grey[50];
    final borderColor = useGlass ? Colors.white.withOpacity(0.3) : Colors.grey[200]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with tooltip
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: labelColor),
              const SizedBox(width: 6),
            ],
            Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: labelColor,
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
          onChanged: readOnly ? null : onChanged,
          dropdownColor: useGlass ? AppColors.deepBlue2 : Colors.white,
          style: TextStyle(
            color: useGlass ? Colors.white : AppColors.deepBlue1,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          items: items.map((e) {
            return DropdownMenuItem<T>(
              value: e,
              child: Text(
                labelMapper?.call(e) ?? e.toString(),
                style: TextStyle(
                  color: useGlass ? Colors.white : AppColors.deepBlue1,
                ),
              ),
            );
          }).toList(),
          iconEnabledColor: useGlass ? Colors.white : AppColors.deepBlue1,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: useGlass ? Colors.white : AppColors.deepBlue1,
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
                color: useGlass ? Colors.white.withOpacity(0.5) : Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  helpText!,
                  style: TextStyle(
                    fontSize: 11,
                    color: useGlass ? Colors.white.withOpacity(0.6) : Colors.grey[600],
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
