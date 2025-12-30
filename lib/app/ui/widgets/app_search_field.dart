import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

class AppSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const AppSearchField({
    super.key,
    this.hint = 'Search',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded),
        ),
      ),
    );
  }
}
