/// AppDropdown - Dropdown selector component.
///
/// A dropdown field for selecting from a list of options.
library;

import 'package:flutter/material.dart';

/// A dropdown field for selecting from options.
class AppDropdown<T> extends StatelessWidget {
  /// Creates an AppDropdown.
  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.itemBuilder,
  });

  /// List of items to select from.
  final List<T> items;

  /// Currently selected value.
  final T? value;

  /// Callback when selection changes.
  final void Function(T?)? onChanged;

  /// Label displayed above dropdown.
  final String? label;

  /// Hint text when no selection.
  final String? hint;

  /// Validation function.
  final String? Function(T?)? validator;

  /// Whether the dropdown is enabled.
  final bool enabled;

  /// Icon to display before dropdown.
  final IconData? prefixIcon;

  /// Custom builder for dropdown items.
  final Widget Function(T)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: itemBuilder?.call(item) ?? Text(item.toString()),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          ),
          isExpanded: true,
        ),
      ],
    );
  }
}
