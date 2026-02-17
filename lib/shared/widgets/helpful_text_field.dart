import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'info_tooltip.dart';
import 'package:construction_app/shared/theme/design_system.dart';

/// An enhanced text field with user-friendly features like tooltips,
/// character counters, and better validation feedback
class HelpfulTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? helpText;
  final String? tooltipMessage;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCharacterCount;
  final String? prefixText;
  final String? suffixText;
  final Widget? suffixIcon;
  final String? hintText;
  final bool obscureText;
  final int? maxLines;

  final bool useGlass;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const HelpfulTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.keyboardType,
    this.validator,
    this.helpText,
    this.tooltipMessage,
    this.maxLength,
    this.inputFormatters,
    this.showCharacterCount = false,
    this.prefixText,
    this.suffixText,
    this.suffixIcon,
    this.hintText,
    this.obscureText = false,
    this.maxLines = 1,
    this.useGlass = false,
    this.readOnly = false,
    this.onChanged,
  });


  @override
  State<HelpfulTextField> createState() => _HelpfulTextFieldState();
}

class _HelpfulTextFieldState extends State<HelpfulTextField> {
  bool _isFocused = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;


    final labelColor = colorScheme.onSurface;
    final fillColor = widget.useGlass 
        ? DesignSystem.glassColor(isDark)
        : (_isFocused ? colorScheme.primary.withValues(alpha: 0.03) : (isDark ? const Color(0xFF1E293B) : Colors.grey[50]));
    final borderColor = widget.useGlass
        ? DesignSystem.glassBorder(isDark)
        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200]!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row with tooltip
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
            if (widget.tooltipMessage != null) ...[
              const SizedBox(width: 6),
              InfoTooltip(message: widget.tooltipMessage!),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Text field with focus management
        Focus(
          onFocusChange: (focused) {
            setState(() => _isFocused = focused);
            if (!focused && widget.validator != null) {
              // Validate on blur
              setState(() {
                _errorText = widget.validator!(widget.controller.text);
              });
            }
          },
          child: TextFormField(
            readOnly: widget.readOnly,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            onChanged: (value) {
              // Clear error on change
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              prefixIcon: widget.icon != null
                  ? Icon(
                      widget.icon,
                      size: 20,
                      color: _isFocused
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                    )
                  : null,
              prefixText: widget.prefixText,
              prefixStyle: TextStyle(color: colorScheme.onSurface),
              suffixText: widget.suffixText,
              suffixStyle: TextStyle(color: colorScheme.onSurface),
              suffixIcon: widget.suffixIcon,
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
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
              errorText: _errorText,
              errorStyle: const TextStyle(color: Colors.redAccent),
              counterText: widget.showCharacterCount ? null : '',
              counterStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ),
        ),


        // Help text
        if (widget.helpText != null) ...[
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
                  widget.helpText!,
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
