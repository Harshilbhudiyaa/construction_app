import 'package:flutter/material.dart';
import 'info_tooltip.dart';
import 'package:construction_app/shared/theme/design_system.dart';

/// Enhanced dropdown with better UX
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
    this.validator,
    this.useGlass = false,
    this.readOnly = false,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final labelColor = colorScheme.onSurface;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    final glassBorder = DesignSystem.glassBorder(isDark);
    final glassFill = DesignSystem.glassColor(isDark);

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
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white70 : Colors.black87,
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
        DropdownButtonFormField<T>(
          value: value,
          onChanged: readOnly ? null : onChanged,
          validator: validator,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : colorScheme.surface,
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          style: TextStyle(
            color: isDark ? Colors.white : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          items: items.map((e) {
            return DropdownMenuItem<T>(
              value: e,
              child: Text(
                labelMapper?.call(e) ?? e.toString(),
                style: TextStyle(
                  color: isDark ? Colors.white : colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
          iconEnabledColor: isDark ? Colors.white38 : colorScheme.primary,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: useGlass 
                  ? glassFill
                  : (isDark ? const Color(0xFF1E293B) : colorScheme.surface),
              contentPadding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: useGlass 
                      ? glassBorder
                      : borderColor
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: useGlass 
                      ? glassBorder 
                      : borderColor
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.5),
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
                color: useGlass ? Colors.white.withValues(alpha: 0.5) : Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  helpText!,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
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
