/// Receipt item widget.
///
/// Displays a single line item on a receipt with label and value.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';

/// A receipt line item widget.
class ReceiptItem extends StatelessWidget {
  const ReceiptItem({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.isBold = false,
    this.isHighlighted = false,
    this.isCopiable = false,
    this.onCopy,
  });

  /// The label text.
  final String label;

  /// The value text.
  final String value;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional icon color.
  final Color? iconColor;

  /// Whether the value should be bold.
  final bool isBold;

  /// Whether this item should be highlighted.
  final bool isHighlighted;

  /// Whether the value can be copied.
  final bool isCopiable;

  /// Optional callback when value is copied.
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: iconColor ??
                  (isDark ? Colors.grey[400] : AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
            ),
          ),
          Expanded(
            child: isCopiable
                ? GestureDetector(
                    onTap: () => _copyToClipboard(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isBold ? FontWeight.bold : FontWeight.w500,
                              color: isHighlighted
                                  ? AppColors.primaryBlue
                                  : theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.copy,
                          size: 14,
                          color: isDark ? Colors.grey[500] : AppColors.textHint,
                        ),
                      ],
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                      color: isHighlighted
                          ? AppColors.primaryBlue
                          : theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    onCopy?.call();
  }
}

/// A receipt divider.
class ReceiptDivider extends StatelessWidget {
  const ReceiptDivider({
    super.key,
    this.dashed = false,
  });

  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? Colors.grey[700] : Colors.grey[300];

    if (dashed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: List.generate(
            40,
            (index) => Expanded(
              child: Container(
                height: 1,
                color: index.isEven ? color : Colors.transparent,
              ),
            ),
          ),
        ),
      );
    }

    return Divider(
      color: color,
      height: 24,
    );
  }
}

/// A receipt total row with emphasized styling.
class ReceiptTotal extends StatelessWidget {
  const ReceiptTotal({
    super.key,
    required this.label,
    required this.amount,
    this.currency = 'KES',
    this.isLarge = true,
  });

  final String label;
  final double amount;
  final String currency;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : AppColors.textSecondary,
            ),
          ),
          Text(
            '$currency ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isLarge ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// A receipt header section.
class ReceiptHeader extends StatelessWidget {
  const ReceiptHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryBlue,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A receipt status badge.
class ReceiptStatusBadge extends StatelessWidget {
  const ReceiptStatusBadge({
    super.key,
    required this.status,
    this.isSuccess = true,
  });

  final String status;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
