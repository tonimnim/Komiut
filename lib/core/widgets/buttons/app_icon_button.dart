/// AppIconButton - Icon-only button component.
///
/// A button that displays only an icon, useful for toolbars
/// and compact action buttons.
library;

import 'package:flutter/material.dart';

/// Size presets for icon buttons.
enum IconButtonSize {
  /// Small icon button (32x32).
  small,

  /// Medium icon button (40x40).
  medium,

  /// Large icon button (48x48).
  large,
}

/// An icon-only button with optional badge.
class AppIconButton extends StatelessWidget {
  /// Creates an AppIconButton.
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = IconButtonSize.medium,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.badge,
    this.isLoading = false,
  });

  /// The icon to display.
  final IconData icon;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Size preset for the button.
  final IconButtonSize size;

  /// Tooltip text.
  final String? tooltip;

  /// Icon color.
  final Color? color;

  /// Background color (for filled variant).
  final Color? backgroundColor;

  /// Optional badge count to display.
  final int? badge;

  /// Whether to show loading indicator.
  final bool isLoading;

  double get _size {
    switch (size) {
      case IconButtonSize.small:
        return 32;
      case IconButtonSize.medium:
        return 40;
      case IconButtonSize.large:
        return 48;
    }
  }

  double get _iconSize {
    switch (size) {
      case IconButtonSize.small:
        return 18;
      case IconButtonSize.medium:
        return 24;
      case IconButtonSize.large:
        return 28;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = isLoading
        ? SizedBox(
            width: _iconSize - 4,
            height: _iconSize - 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          )
        : Icon(
            icon,
            size: _iconSize,
            color: color,
          );

    // Add badge if present
    if (badge != null && badge! > 0 && !isLoading) {
      iconWidget = Badge(
        label: Text(
          badge! > 99 ? '99+' : badge.toString(),
          style: const TextStyle(fontSize: 10),
        ),
        child: iconWidget,
      );
    }

    Widget button = SizedBox(
      width: _size,
      height: _size,
      child: backgroundColor != null
          ? IconButton.filled(
              onPressed: isLoading ? null : onPressed,
              icon: iconWidget,
              style: IconButton.styleFrom(
                backgroundColor: backgroundColor,
              ),
            )
          : IconButton(
              onPressed: isLoading ? null : onPressed,
              icon: iconWidget,
            ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
