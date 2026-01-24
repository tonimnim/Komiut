/// AppButton - Primary button component with animations.
///
/// A flexible button widget that supports multiple variants,
/// sizes, loading states, icons, and press animations.
library;

import 'package:flutter/material.dart';

import '../../utils/animation_utils.dart';

/// Button variant types.
enum ButtonVariant {
  /// Primary filled button.
  primary,

  /// Secondary filled button.
  secondary,

  /// Outlined button with border.
  outlined,

  /// Text-only button without background.
  text,
}

/// Button size presets.
enum ButtonSize {
  /// Small button (height: 36).
  small,

  /// Medium button (height: 48).
  medium,

  /// Large button (height: 56).
  large,
}

/// A versatile button component with multiple variants, sizes, and animations.
class AppButton extends StatefulWidget {
  /// Creates an AppButton.
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.enablePressAnimation = true,
    this.pressScale = ScaleAnimations.pressedNormal,
    this.splashColor,
    this.highlightColor,
  });

  /// Creates a primary button.
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.enablePressAnimation = true,
    this.pressScale = ScaleAnimations.pressedNormal,
    this.splashColor,
    this.highlightColor,
  })  : variant = ButtonVariant.primary,
        borderColor = null;

  /// Creates an outlined button.
  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.foregroundColor,
    this.borderColor,
    this.enablePressAnimation = true,
    this.pressScale = ScaleAnimations.pressedNormal,
    this.splashColor,
    this.highlightColor,
  })  : variant = ButtonVariant.outlined,
        backgroundColor = null;

  /// Creates a text button.
  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.foregroundColor,
    this.enablePressAnimation = true,
    this.pressScale = ScaleAnimations.pressedNormal,
    this.splashColor,
    this.highlightColor,
  })  : variant = ButtonVariant.text,
        backgroundColor = null,
        borderColor = null;

  /// Button label text.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Visual variant of the button.
  final ButtonVariant variant;

  /// Size preset of the button.
  final ButtonSize size;

  /// Whether to show a loading indicator.
  final bool isLoading;

  /// Whether button should fill parent width.
  final bool isFullWidth;

  /// Optional leading or trailing icon.
  final IconData? icon;

  /// Position of the icon.
  final IconPosition iconPosition;

  /// Custom background color (only for primary/secondary).
  final Color? backgroundColor;

  /// Custom foreground (text/icon) color.
  final Color? foregroundColor;

  /// Custom border color (only for outlined).
  final Color? borderColor;

  /// Whether to enable press scale animation.
  final bool enablePressAnimation;

  /// Scale factor when pressed (default 0.95).
  final double pressScale;

  /// Custom splash color for ripple effect.
  final Color? splashColor;

  /// Custom highlight color for pressed state.
  final Color? highlightColor;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(
      CurvedAnimation(parent: _scaleController, curve: AnimationCurves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enablePressAnimation && widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enablePressAnimation) {
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enablePressAnimation) {
      _scaleController.reverse();
    }
  }

  /// Get button height based on size.
  double get _height {
    switch (widget.size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  /// Get icon size based on button size.
  double get _iconSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  /// Get padding based on button size.
  EdgeInsets get _padding {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build content with animated crossfade between loading and normal states
    final Widget content = AnimatedSwitcher(
      duration: AnimationDurations.fast,
      switchInCurve: AnimationCurves.easeInOut,
      switchOutCurve: AnimationCurves.easeInOut,
      child: widget.isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: _iconSize,
              width: _iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.foregroundColor ?? _getForegroundColor(colorScheme),
                ),
              ),
            )
          : _buildContent(),
    );

    // Build button based on variant
    Widget button = _buildButtonByVariant(content, colorScheme);

    // Wrap with scale animation
    if (widget.enablePressAnimation) {
      button = GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: button,
        ),
      );
    }

    if (widget.isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildContent() {
    final textWidget = Text(widget.label, key: const ValueKey('label'));

    if (widget.icon != null) {
      final iconWidget = Icon(widget.icon, size: _iconSize);
      final spacing = SizedBox(width: widget.size == ButtonSize.small ? 4 : 8);

      return Row(
        key: const ValueKey('content'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.iconPosition == IconPosition.leading
            ? [iconWidget, spacing, textWidget]
            : [textWidget, spacing, iconWidget],
      );
    }

    return textWidget;
  }

  Widget _buildButtonByVariant(Widget content, ColorScheme colorScheme) {
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                widget.backgroundColor ?? _getBackgroundColor(colorScheme),
            foregroundColor:
                widget.foregroundColor ?? _getForegroundColor(colorScheme),
            padding: _padding,
            minimumSize: Size(0, _height),
            splashFactory: InkRipple.splashFactory,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return widget.highlightColor ??
                    Colors.white.withValues(alpha: 0.1);
              }
              return null;
            }),
          ),
          child: content,
        );

      case ButtonVariant.outlined:
        return OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.foregroundColor ?? colorScheme.primary,
            side: BorderSide(
              color: widget.borderColor ??
                  widget.foregroundColor ??
                  colorScheme.primary,
              width: 1.5,
            ),
            padding: _padding,
            minimumSize: Size(0, _height),
            splashFactory: InkRipple.splashFactory,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return widget.highlightColor ??
                    colorScheme.primary.withValues(alpha: 0.1);
              }
              return null;
            }),
          ),
          child: content,
        );

      case ButtonVariant.text:
        return TextButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: widget.foregroundColor ?? colorScheme.primary,
            padding: _padding,
            minimumSize: Size(0, _height),
            splashFactory: InkRipple.splashFactory,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return widget.highlightColor ??
                    colorScheme.primary.withValues(alpha: 0.1);
              }
              return null;
            }),
          ),
          child: content,
        );
    }
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return colorScheme.primary;
      case ButtonVariant.secondary:
        return colorScheme.secondary;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(ColorScheme colorScheme) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return colorScheme.onPrimary;
      case ButtonVariant.secondary:
        return colorScheme.onSecondary;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return colorScheme.primary;
    }
  }
}

/// Icon position in button.
enum IconPosition {
  /// Icon before label.
  leading,

  /// Icon after label.
  trailing,
}
