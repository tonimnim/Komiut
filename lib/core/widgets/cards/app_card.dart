/// AppCard - Base card component with animations.
///
/// A customizable card container with consistent styling and optional
/// press/hover animations.
library;

import 'package:flutter/material.dart';

import '../../utils/animation_utils.dart';

/// A flexible card container component with animations.
class AppCard extends StatefulWidget {
  /// Creates an AppCard.
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation = 1,
    this.onTap,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.enablePressAnimation = true,
    this.pressScale = ScaleAnimations.pressedSubtle,
    this.pressElevation,
    this.animationDuration = AnimationDurations.fast,
  });

  /// Creates a card with no elevation (flat).
  const AppCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.enablePressAnimation = true,
    this.pressScale = ScaleAnimations.pressedSubtle,
    this.animationDuration = AnimationDurations.fast,
  })  : elevation = 0,
        pressElevation = null;

  /// Creates an outlined card.
  factory AppCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Color? borderColor,
    double? width,
    double? height,
    bool enablePressAnimation = true,
    double pressScale = ScaleAnimations.pressedSubtle,
    Duration animationDuration = AnimationDurations.fast,
  }) {
    return AppCard(
      key: key,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      elevation: 0,
      onTap: onTap,
      borderRadius: borderRadius,
      border: Border.all(
        color: borderColor ?? Colors.grey.shade300,
        width: 1,
      ),
      width: width,
      height: height,
      enablePressAnimation: enablePressAnimation,
      pressScale: pressScale,
      animationDuration: animationDuration,
      child: child,
    );
  }

  /// Child widget to display inside card.
  final Widget child;

  /// Padding inside the card.
  final EdgeInsets? padding;

  /// Margin outside the card.
  final EdgeInsets? margin;

  /// Background color.
  final Color? backgroundColor;

  /// Card elevation.
  final double elevation;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Border radius.
  final BorderRadius? borderRadius;

  /// Card border.
  final BoxBorder? border;

  /// Fixed width.
  final double? width;

  /// Fixed height.
  final double? height;

  /// Whether to enable press animation.
  final bool enablePressAnimation;

  /// Scale factor when pressed.
  final double pressScale;

  /// Elevation when pressed.
  final double? pressElevation;

  /// Duration of animations.
  final Duration animationDuration;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.easeOut),
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.pressElevation ?? (widget.elevation * 0.5),
    ).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enablePressAnimation && widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enablePressAnimation) {
      _controller.reverse();
    }
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (widget.enablePressAnimation) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultRadius = BorderRadius.circular(12);
    final radius = widget.borderRadius ?? defaultRadius;

    Widget content = AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        final currentElevation = widget.enablePressAnimation
            ? _elevationAnimation.value
            : widget.elevation;

        return Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? theme.cardColor,
            borderRadius: radius,
            border: widget.border,
            boxShadow: currentElevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05 * currentElevation),
                      blurRadius: 4 * currentElevation,
                      offset: Offset(0, 2 * currentElevation),
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        );
      },
    );

    if (widget.enablePressAnimation && widget.onTap != null) {
      content = ScaleTransition(
        scale: _scaleAnimation,
        child: content,
      );
    }

    if (widget.margin != null) {
      content = Padding(padding: widget.margin!, child: content);
    }

    if (widget.onTap != null) {
      content = GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: content,
      );
    }

    return content;
  }
}

/// An expandable card that animates open/closed.
class ExpandableCard extends StatefulWidget {
  /// Creates an ExpandableCard.
  const ExpandableCard({
    super.key,
    required this.header,
    required this.content,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation = 1,
    this.borderRadius,
    this.animationDuration = AnimationDurations.normal,
    this.animationCurve = AnimationCurves.fastOutSlowIn,
  });

  /// Header widget (always visible).
  final Widget header;

  /// Expandable content widget.
  final Widget content;

  /// Whether initially expanded.
  final bool initiallyExpanded;

  /// Callback when expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  /// Padding inside the card.
  final EdgeInsets? padding;

  /// Margin outside the card.
  final EdgeInsets? margin;

  /// Background color.
  final Color? backgroundColor;

  /// Card elevation.
  final double elevation;

  /// Border radius.
  final BorderRadius? borderRadius;

  /// Duration of the expand/collapse animation.
  final Duration animationDuration;

  /// Curve for the animation.
  final Curve animationCurve;

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _iconRotation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: _isExpanded ? 1.0 : 0.0,
    );

    _heightFactor = _controller.drive(
      CurveTween(curve: widget.animationCurve),
    );

    _iconRotation = _controller.drive(
      Tween<double>(begin: 0.0, end: 0.5).chain(
        CurveTween(curve: widget.animationCurve),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultRadius = BorderRadius.circular(12);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return AppCard(
          padding: EdgeInsets.zero,
          margin: widget.margin,
          backgroundColor: widget.backgroundColor,
          elevation: widget.elevation,
          borderRadius: widget.borderRadius ?? defaultRadius,
          enablePressAnimation: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _handleTap,
                borderRadius: widget.borderRadius ?? defaultRadius,
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: widget.header),
                      RotationTransition(
                        turns: _iconRotation,
                        child: Icon(
                          Icons.expand_more,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: Padding(
                    padding: (widget.padding ?? const EdgeInsets.all(16))
                        .copyWith(top: 0),
                    child: widget.content,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A selectable card with selection animation.
class SelectableCard extends StatelessWidget {
  /// Creates a SelectableCard.
  const SelectableCard({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
    this.padding,
    this.margin,
    this.selectedColor,
    this.unselectedColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.borderRadius,
    this.elevation = 1,
    this.selectedElevation = 2,
    this.animationDuration = AnimationDurations.fast,
  });

  /// Child widget.
  final Widget child;

  /// Whether the card is selected.
  final bool isSelected;

  /// Callback when tapped.
  final VoidCallback onTap;

  /// Padding inside the card.
  final EdgeInsets? padding;

  /// Margin outside the card.
  final EdgeInsets? margin;

  /// Background color when selected.
  final Color? selectedColor;

  /// Background color when not selected.
  final Color? unselectedColor;

  /// Border color when selected.
  final Color? selectedBorderColor;

  /// Border color when not selected.
  final Color? unselectedBorderColor;

  /// Border radius.
  final BorderRadius? borderRadius;

  /// Elevation when not selected.
  final double elevation;

  /// Elevation when selected.
  final double selectedElevation;

  /// Animation duration.
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultRadius = BorderRadius.circular(12);
    final radius = borderRadius ?? defaultRadius;

    final bgColor = isSelected
        ? (selectedColor ?? colorScheme.primaryContainer)
        : (unselectedColor ?? theme.cardColor);

    final borderColor = isSelected
        ? (selectedBorderColor ?? colorScheme.primary)
        : (unselectedBorderColor ?? Colors.grey.shade300);

    return AnimatedContainer(
      duration: animationDuration,
      curve: AnimationCurves.fastOutSlowIn,
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isSelected ? 0.1 : 0.05,
            ),
            blurRadius: isSelected ? selectedElevation * 4 : elevation * 4,
            offset: Offset(0, isSelected ? selectedElevation * 2 : elevation * 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
