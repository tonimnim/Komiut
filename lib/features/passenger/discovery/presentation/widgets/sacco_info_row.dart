/// Sacco Info Row - Reusable info row widget.
///
/// A reusable row widget for displaying label-value pairs with an icon.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// A reusable info row widget for displaying label-value pairs.
///
/// Used in sacco detail screens to display contact information,
/// operating hours, and other key-value data.
///
/// ```dart
/// SaccoInfoRow(
///   icon: Icons.phone_outlined,
///   label: 'Phone',
///   value: '+254 700 000 000',
///   onTap: () => _makeCall(),
/// )
/// ```
class SaccoInfoRow extends StatelessWidget {
  /// Creates a SaccoInfoRow.
  const SaccoInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.iconColor,
    this.valueColor,
    this.showArrow = false,
  });

  /// The leading icon.
  final IconData icon;

  /// The label describing the value.
  final String label;

  /// The value to display.
  final String value;

  /// Callback when the row is tapped.
  final VoidCallback? onTap;

  /// Custom color for the icon.
  final Color? iconColor;

  /// Custom color for the value text.
  final Color? valueColor;

  /// Whether to show a trailing arrow icon.
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primaryBlue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          // Label and value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Trailing arrow
          if (showArrow || onTap != null)
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }
}
