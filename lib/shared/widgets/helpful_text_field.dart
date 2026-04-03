import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'info_tooltip.dart';
import 'package:construction_app/core/theme/design_system.dart';

/// An enhanced text field with user-friendly features like tooltips,
/// character counters, and better validation feedback
/// Updated for Construction Theme 🏗️
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

  final bool useGlass; // Kept for API compatibility, but ignored
  final bool readOnly;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

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
    this.enabled = true,
    this.onChanged,
    this.onTap,
  });


  @override
  State<HelpfulTextField> createState() => _HelpfulTextFieldState();
}

class _HelpfulTextFieldState extends State<HelpfulTextField> {
  bool _isFocused = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    // Construction Theme Colors
    const labelColor = DesignSystem.charcoalBlack;
    const fillColor = DesignSystem.surfaceWhite;
    const borderColor = Color(0xFFE0E0E0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row with tooltip
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
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
          child: Focus(
            onFocusChange: (focused) {
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _isFocused = focused);
                    if (!focused && widget.validator != null) {
                      // Validate on blur
                      setState(() {
                        _errorText = widget.validator!(widget.controller.text);
                      });
                    }
                  }
                });
              }
            },
            child: TextFormField(
              enabled: widget.enabled,
              onTap: widget.onTap,
              readOnly: widget.readOnly,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              validator: widget.validator,
              style: const TextStyle(
                color: DesignSystem.textPrimary,
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
                hintStyle: const TextStyle(
                  color: DesignSystem.textSecondary,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                prefixIcon: widget.icon != null
                    ? Icon(
                        widget.icon,
                        size: 20,
                        color: _isFocused
                            ? DesignSystem.constructionYellow
                            : DesignSystem.steelGrey,
                      )
                    : null,
                prefixText: widget.prefixText,
                prefixStyle: const TextStyle(color: DesignSystem.textPrimary),
                suffixText: widget.suffixText,
                suffixStyle: const TextStyle(color: DesignSystem.textPrimary),
                suffixIcon: widget.suffixIcon,
                filled: true,
                fillColor: fillColor,
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
                  borderSide: const BorderSide(color: DesignSystem.error, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: DesignSystem.error, width: 2),
                ),
                errorText: _errorText,
                errorStyle: const TextStyle(color: DesignSystem.error),
                counterText: widget.showCharacterCount ? null : '',
                counterStyle: const TextStyle(color: DesignSystem.textSecondary),
              ),
            ),
          ),
        ),

        // Help text
        if (widget.helpText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.helpText!,
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
