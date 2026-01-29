/// ResponsiveBuilder - Responsive layout helper.
///
/// Helper widget for building responsive layouts.
library;

import 'package:flutter/material.dart';

/// Breakpoints for responsive design.
class Breakpoints {
  const Breakpoints._();

  /// Mobile breakpoint (< 600).
  static const double mobile = 600;

  /// Tablet breakpoint (600 - 1024).
  static const double tablet = 1024;

  /// Desktop breakpoint (> 1024).
  static const double desktop = 1024;
}

/// Screen size category.
enum ScreenSize {
  /// Mobile phone size.
  mobile,

  /// Tablet size.
  tablet,

  /// Desktop size.
  desktop,
}

/// A widget that builds different layouts based on screen size.
class ResponsiveBuilder extends StatelessWidget {
  /// Creates a ResponsiveBuilder.
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Builder for mobile layout.
  final Widget mobile;

  /// Builder for tablet layout.
  final Widget? tablet;

  /// Builder for desktop layout.
  final Widget? desktop;

  /// Get current screen size.
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.mobile) {
      return ScreenSize.mobile;
    } else if (width < Breakpoints.tablet) {
      return ScreenSize.tablet;
    }
    return ScreenSize.desktop;
  }

  /// Check if current screen is mobile.
  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  /// Check if current screen is tablet.
  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.tablet;
  }

  /// Check if current screen is desktop.
  static bool isDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.desktop;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= Breakpoints.mobile) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// A builder that provides responsive values based on screen size.
class ResponsiveValue<T> {
  /// Creates a ResponsiveValue.
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Value for mobile.
  final T mobile;

  /// Value for tablet.
  final T? tablet;

  /// Value for desktop.
  final T? desktop;

  /// Get the appropriate value for the current screen size.
  T resolve(BuildContext context) {
    final screenSize = ResponsiveBuilder.getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }
}
