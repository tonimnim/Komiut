/// AppDivider - Styled divider component.
///
/// A divider widget with consistent styling.
library;

import 'package:flutter/material.dart';

/// A styled divider widget.
class AppDivider extends StatelessWidget {
  /// Creates an AppDivider.
  const AppDivider({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  });

  /// Creates an indented divider for list items.
  const AppDivider.inset({
    super.key,
    this.height,
    this.thickness,
    this.indent = 16,
    this.endIndent,
    this.color,
  });

  /// Creates a full-width divider with spacing.
  const AppDivider.section({
    super.key,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  }) : height = 24;

  /// Total height of the divider (including space).
  final double? height;

  /// Thickness of the line.
  final double? thickness;

  /// Left indent.
  final double? indent;

  /// Right indent.
  final double? endIndent;

  /// Divider color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? 1,
      thickness: thickness ?? 1,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}

/// A vertical divider widget.
class AppVerticalDivider extends StatelessWidget {
  /// Creates an AppVerticalDivider.
  const AppVerticalDivider({
    super.key,
    this.width,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  });

  /// Total width of the divider.
  final double? width;

  /// Thickness of the line.
  final double? thickness;

  /// Top indent.
  final double? indent;

  /// Bottom indent.
  final double? endIndent;

  /// Divider color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: width ?? 1,
      thickness: thickness ?? 1,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}
