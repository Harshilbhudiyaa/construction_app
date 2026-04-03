import 'package:flutter/material.dart';
import 'info_tooltip.dart';
import 'package:construction_app/core/theme/design_system.dart';

/// Enhanced dropdown with better UX
/// Updated for Construction Theme 🏗️
class HelpfulDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T)? labelMapper;
  final ValueChanged<T?> onChanged;
  final String? tooltipMessage;
  final String? helpText;
  final IconData? icon;
  final String? Function(T?)? validator;

  final bool useGlass; // Kept for API compatibility, but ignored
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
    this.validator,
    this.useGlass = false,
    this.readOnly = false,
  });


  @override
  Widget build(BuildContext context) {
    const labelColor = DesignSystem.charcoalBlack;
    const borderColor = Color(0xFFE0E0E0);
    const fillColor = DesignSystem.surfaceWhite;

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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: labelColor,
                letterSpacing: 0.5,
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<T>(
            initialValue: value,
            onChanged: readOnly ? null : onChanged,
            validator: validator,
            isExpanded: true,
            dropdownColor: DesignSystem.surfaceWhite,
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            style: const TextStyle(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            items: items.map((e) {
              return DropdownMenuItem<T>(
                value: e,
                child: Text(
                  labelMapper?.call(e) ?? e.toString(),
                  style: const TextStyle(
                    color: DesignSystem.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: DesignSystem.steelGrey),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: fillColor,
              contentPadding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: DesignSystem.constructionYellow,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: DesignSystem.error),
              ),
            ),
          ),
        ),

        // Help text
        if (helpText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  helpText!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
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
