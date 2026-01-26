/// AppListTile - Consolidated list tile component.
///
/// A flexible list tile widget for consistent list items.
library;

import 'package:flutter/material.dart';

/// A flexible list tile component.
class AppListTile extends StatelessWidget {
  /// Creates an AppListTile.
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingIconBackground,
    this.showChevron = false,
    this.dense = false,
    this.enabled = true,
    this.selected = false,
    this.contentPadding,
  });

  /// Primary text.
  final String title;

  /// Secondary text.
  final String? subtitle;

  /// Leading widget.
  final Widget? leading;

  /// Trailing widget.
  final Widget? trailing;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Leading icon (if no leading widget provided).
  final IconData? leadingIcon;

  /// Leading icon color.
  final Color? leadingIconColor;

  /// Leading icon background color.
  final Color? leadingIconBackground;

  /// Whether to show trailing chevron.
  final bool showChevron;

  /// Whether to use dense layout.
  final bool dense;

  /// Whether the tile is enabled.
  final bool enabled;

  /// Whether the tile is selected.
  final bool selected;

  /// Custom content padding.
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? leadingWidget = leading;
    if (leadingWidget == null && leadingIcon != null) {
      final bgColor =
          leadingIconBackground ?? theme.colorScheme.primary.withValues(alpha: 0.1);
      final iconColor = leadingIconColor ?? theme.colorScheme.primary;

      leadingWidget = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          leadingIcon,
          color: iconColor,
          size: 20,
        ),
      );
    }

    Widget? trailingWidget = trailing;
    if (trailingWidget == null && showChevron && onTap != null) {
      trailingWidget = Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      );
    }

    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      leading: leadingWidget,
      trailing: trailingWidget,
      onTap: enabled ? onTap : null,
      dense: dense,
      enabled: enabled,
      selected: selected,
      contentPadding: contentPadding,
    );
  }
}
