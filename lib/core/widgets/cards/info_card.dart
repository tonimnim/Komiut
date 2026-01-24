/// InfoCard - Information display card.
///
/// A card for displaying labeled information with icon.
library;

import 'package:flutter/material.dart';

import 'app_card.dart';

/// A card for displaying information with icon and label.
class InfoCard extends StatelessWidget {
  /// Creates an InfoCard.
  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.subtitle,
    this.trailing,
  });

  /// Title/label text.
  final String title;

  /// Main value text.
  final String value;

  /// Optional leading icon.
  final IconData? icon;

  /// Icon background color.
  final Color? iconColor;

  /// Card background color.
  final Color? backgroundColor;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Optional subtitle text.
  final String? subtitle;

  /// Optional trailing widget.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null && trailing == null)
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }
}
