import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';

/// Smart autocomplete field with suggestions
class SmartAutocomplete extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> suggestions;
  final IconData? icon;
  final String? hintText;
  final String? tooltipMessage;
  final ValueChanged<String>? onSelected;
  final String? Function(String?)? validator;

  const SmartAutocomplete({
    super.key,
    required this.label,
    required this.controller,
    required this.suggestions,
    this.icon,
    this.hintText,
    this.tooltipMessage,
   this.onSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
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
              Tooltip(
                message: tooltipMessage!,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.deepBlue1.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Autocomplete field
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return suggestions.where((option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          onSelected: (selection) {
            controller.text = selection;
            onSelected?.call(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              validator: validator,
              onEditingComplete: onEditingComplete,
              decoration: InputDecoration(
                isDense: true,
                hintText: hintText,
                prefixIcon: icon != null
                    ? Icon(icon, size: 20, color: AppColors.deepBlue1)
                    : null,
                suffixIcon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.grey[400],
                ),
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
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.deepBlue1.withOpacity(0.2)),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: index < options.length - 1
                                  ? BorderSide(color: Colors.grey[200]!)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
