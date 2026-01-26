/// Page Transitions - Custom page route transitions.
///
/// Provides various page transition animations for navigation,
/// including slide, fade, scale, and combined transitions.
library;

import 'package:flutter/material.dart';

import '../utils/animation_utils.dart';

/// Direction for slide transitions.
enum SlideDirection {
  /// Slide from left to right.
  left,

  /// Slide from right to left.
  right,

  /// Slide from top to bottom.
  top,

  /// Slide from bottom to top.
  bottom,
}

/// Custom page route with fade transition.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  /// Creates a fade page route.
  FadePageRoute({
    required this.page,
    super.settings,
    Duration? duration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration ?? AnimationDurations.pageTransition,
          reverseTransitionDuration:
              duration ?? AnimationDurations.pageTransition,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                Tween<double>(begin: 0.0, end: 1.0).chain(
                  CurveTween(curve: AnimationCurves.easeInOut),
                ),
              ),
              child: child,
            );
          },
        );

  /// The page to display.
  final Widget page;
}

/// Custom page route with slide transition.
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  /// Creates a slide page route.
  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
    super.settings,
    Duration? duration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration ?? AnimationDurations.pageTransition,
          reverseTransitionDuration:
              duration ?? AnimationDurations.pageTransition,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = _getBeginOffset(direction);
            const end = Offset.zero;

            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: AnimationCurves.fastOutSlowIn),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

  /// The page to display.
  final Widget page;

  /// The direction to slide from.
  final SlideDirection direction;

  static Offset _getBeginOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(-1.0, 0.0);
      case SlideDirection.right:
        return const Offset(1.0, 0.0);
      case SlideDirection.top:
        return const Offset(0.0, -1.0);
      case SlideDirection.bottom:
        return const Offset(0.0, 1.0);
    }
  }
}

/// Custom page route with scale transition.
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  /// Creates a scale page route.
  ScalePageRoute({
    required this.page,
    this.alignment = Alignment.center,
    super.settings,
    Duration? duration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration ?? AnimationDurations.pageTransition,
          reverseTransitionDuration:
              duration ?? AnimationDurations.pageTransition,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleTween = Tween<double>(begin: 0.8, end: 1.0).chain(
              CurveTween(curve: AnimationCurves.fastOutSlowIn),
            );

            final opacityTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: AnimationCurves.easeIn),
            );

            return ScaleTransition(
              alignment: alignment,
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(opacityTween),
                child: child,
              ),
            );
          },
        );

  /// The page to display.
  final Widget page;

  /// Alignment for the scale transformation.
  final Alignment alignment;
}

/// Custom page route with slide and fade transition.
class SlideAndFadePageRoute<T> extends PageRouteBuilder<T> {
  /// Creates a slide and fade page route.
  SlideAndFadePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
    super.settings,
    Duration? duration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration ?? AnimationDurations.pageTransition,
          reverseTransitionDuration:
              duration ?? AnimationDurations.pageTransition,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = _getBeginOffset(direction);
            const end = Offset.zero;

            final slideTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: AnimationCurves.fastOutSlowIn),
            );

            final opacityTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: AnimationCurves.easeIn),
            );

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(opacityTween),
                child: child,
              ),
            );
          },
        );

  /// The page to display.
  final Widget page;

  /// The direction to slide from.
  final SlideDirection direction;

  static Offset _getBeginOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(-0.3, 0.0);
      case SlideDirection.right:
        return const Offset(0.3, 0.0);
      case SlideDirection.top:
        return const Offset(0.0, -0.3);
      case SlideDirection.bottom:
        return const Offset(0.0, 0.3);
    }
  }
}

/// Custom page route with scale and fade transition from a specific point.
class ScaleFromPointPageRoute<T> extends PageRouteBuilder<T> {
  /// Creates a scale from point page route.
  ScaleFromPointPageRoute({
    required this.page,
    required this.originOffset,
    super.settings,
    Duration? duration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration ?? AnimationDurations.pageTransition,
          reverseTransitionDuration:
              duration ?? AnimationDurations.pageTransition,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final size = MediaQuery.of(context).size;
            final alignment = Alignment(
              (originOffset.dx / size.width) * 2 - 1,
              (originOffset.dy / size.height) * 2 - 1,
            );

            final scaleTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: AnimationCurves.fastOutSlowIn),
            );

            final opacityTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: AnimationCurves.easeIn),
            );

            return ScaleTransition(
              alignment: alignment,
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(opacityTween),
                child: child,
              ),
            );
          },
        );

  /// The page to display.
  final Widget page;

  /// The screen offset to scale from.
  final Offset originOffset;
}

/// Custom page route with shared axis transition (similar to Material).
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  /// Creates a shared axis page route.
  SharedAxisPageRoute({
    required this.page,
    this.transitionType = SharedAxisTransitionType.horizontal,
    super.settings,
    Duration? duration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration ?? AnimationDurations.pageTransition,
          reverseTransitionDuration:
              duration ?? AnimationDurations.pageTransition,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: transitionType,
              child: child,
            );
          },
        );

  /// The page to display.
  final Widget page;

  /// The type of shared axis transition.
  final SharedAxisTransitionType transitionType;
}

/// Types of shared axis transitions.
enum SharedAxisTransitionType {
  /// Horizontal (left-right) transition.
  horizontal,

  /// Vertical (top-bottom) transition.
  vertical,

  /// Scaled (zoom) transition.
  scaled,
}

class _SharedAxisTransition extends StatelessWidget {
  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SharedAxisTransitionType transitionType;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    Widget transitionChild;

    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        final slideIn = Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: AnimationCurves.fastOutSlowIn),
        );

        final slideOut = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).animate(
          CurvedAnimation(
              parent: secondaryAnimation, curve: AnimationCurves.fastOutSlowIn),
        );

        transitionChild = SlideTransition(
          position: slideIn,
          child: SlideTransition(
            position: slideOut,
            child: child,
          ),
        );

      case SharedAxisTransitionType.vertical:
        final slideIn = Tween<Offset>(
          begin: const Offset(0.0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: AnimationCurves.fastOutSlowIn),
        );

        final slideOut = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -0.3),
        ).animate(
          CurvedAnimation(
              parent: secondaryAnimation, curve: AnimationCurves.fastOutSlowIn),
        );

        transitionChild = SlideTransition(
          position: slideIn,
          child: SlideTransition(
            position: slideOut,
            child: child,
          ),
        );

      case SharedAxisTransitionType.scaled:
        final scaleIn = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AnimationCurves.fastOutSlowIn),
        );

        final scaleOut = Tween<double>(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(
              parent: secondaryAnimation, curve: AnimationCurves.fastOutSlowIn),
        );

        transitionChild = ScaleTransition(
          scale: scaleIn,
          child: ScaleTransition(
            scale: scaleOut,
            child: child,
          ),
        );
    }

    return FadeTransition(
      opacity: fadeIn,
      child: FadeTransition(
        opacity: fadeOut,
        child: transitionChild,
      ),
    );
  }
}

/// Custom page route builder for creating reusable transitions.
class CustomPageTransition {
  const CustomPageTransition._();

  /// Create a page transition with the specified type.
  static Route<T> create<T>({
    required Widget page,
    required PageTransitionType type,
    RouteSettings? settings,
    Duration? duration,
    SlideDirection slideDirection = SlideDirection.right,
    Alignment scaleAlignment = Alignment.center,
    Offset? originOffset,
  }) {
    switch (type) {
      case PageTransitionType.fade:
        return FadePageRoute<T>(
          page: page,
          settings: settings,
          duration: duration,
        );
      case PageTransitionType.slide:
        return SlidePageRoute<T>(
          page: page,
          direction: slideDirection,
          settings: settings,
          duration: duration,
        );
      case PageTransitionType.scale:
        return ScalePageRoute<T>(
          page: page,
          alignment: scaleAlignment,
          settings: settings,
          duration: duration,
        );
      case PageTransitionType.slideAndFade:
        return SlideAndFadePageRoute<T>(
          page: page,
          direction: slideDirection,
          settings: settings,
          duration: duration,
        );
      case PageTransitionType.scaleFromPoint:
        return ScaleFromPointPageRoute<T>(
          page: page,
          originOffset: originOffset ?? Offset.zero,
          settings: settings,
          duration: duration,
        );
      case PageTransitionType.none:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          settings: settings,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
    }
  }
}

/// Types of page transitions.
enum PageTransitionType {
  /// Fade in/out transition.
  fade,

  /// Slide transition.
  slide,

  /// Scale transition.
  scale,

  /// Combined slide and fade transition.
  slideAndFade,

  /// Scale from a specific point.
  scaleFromPoint,

  /// No transition (instant).
  none,
}
