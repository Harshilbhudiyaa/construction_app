import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/professional_theme.dart';
import 'info_tooltip.dart';

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
  final String? hintText;
  final bool obscureText;
  final int? maxLines;

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
    this.hintText,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  State<HelpfulTextField> createState() => _HelpfulTextFieldState();
}

class _HelpfulTextFieldState extends State<HelpfulTextField> {
  bool _isFocused = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
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
                color: Colors.grey[600],
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
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: (value) {
              // Clear error on change
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: widget.icon != null
                  ? Icon(
                      widget.icon,
                      size: 20,
                      color: _isFocused
                          ? AppColors.deepBlue1
                          : Colors.grey[400],
                    )
                  : null,
              prefixText: widget.prefixText,
              suffixText: widget.suffixText,
              filled: true,
              fillColor: _isFocused
                  ? AppColors.deepBlue1.withOpacity(0.03)
                  : Colors.grey[50],
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              errorText: _errorText,
              counterText: widget.showCharacterCount ? null : '',
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
