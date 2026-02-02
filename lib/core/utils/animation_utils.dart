/// Animation Utilities - Standard animation constants and helpers.
///
/// Provides consistent animation durations, curves, and helper functions
/// for animations throughout the app.
library;

import 'package:flutter/material.dart';

/// Standard animation durations used throughout the app.
abstract class AnimationDurations {
  /// Fast animations (200ms) - Quick feedback, micro-interactions.
  static const Duration fast = Duration(milliseconds: 200);

  /// Normal animations (300ms) - Standard transitions.
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow animations (500ms) - Deliberate, emphasized transitions.
  static const Duration slow = Duration(milliseconds: 500);

  /// Extra slow animations (800ms) - Very deliberate, major transitions.
  static const Duration extraSlow = Duration(milliseconds: 800);

  /// Shimmer duration (1500ms) - Loading shimmer effect.
  static const Duration shimmer = Duration(milliseconds: 1500);

  /// Page transition duration (350ms) - Navigation transitions.
  static const Duration pageTransition = Duration(milliseconds: 350);
}

/// Standard animation curves used throughout the app.
abstract class AnimationCurves {
  /// Standard ease in-out curve.
  static const Curve easeInOut = Curves.easeInOut;

  /// Ease out curve - starts fast, ends slow.
  static const Curve easeOut = Curves.easeOut;

  /// Ease in curve - starts slow, ends fast.
  static const Curve easeIn = Curves.easeIn;

  /// Decelerate curve - natural deceleration.
  static const Curve decelerate = Curves.decelerate;

  /// Spring curve - natural spring effect.
  static const Curve spring = Curves.elasticOut;

  /// Bounce curve - bouncing effect at end.
  static const Curve bounce = Curves.bounceOut;

  /// Fast out slow in - material design standard.
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  /// Linear curve - constant speed.
  static const Curve linear = Curves.linear;

  /// Overshoot curve - goes past target then returns.
  static const Curve overshoot = Curves.easeOutBack;
}

/// Staggered animation helper for creating cascading animations.
class StaggeredAnimation {
  const StaggeredAnimation._();

  /// Calculate the interval for a staggered item.
  ///
  /// [index] - The index of the item in the list.
  /// [itemCount] - Total number of items.
  /// [staggerDelay] - Delay between each item (default 50ms).
  /// [baseDuration] - Base animation duration (default 300ms).
  static Interval getInterval({
    required int index,
    required int itemCount,
    Duration staggerDelay = const Duration(milliseconds: 50),
    Duration baseDuration = AnimationDurations.normal,
  }) {
    final totalDuration =
        baseDuration.inMilliseconds + (staggerDelay.inMilliseconds * itemCount);
    final start = (staggerDelay.inMilliseconds * index) / totalDuration;
    final end =
        (staggerDelay.inMilliseconds * index + baseDuration.inMilliseconds) /
            totalDuration;

    return Interval(
      start.clamp(0.0, 1.0),
      end.clamp(0.0, 1.0),
      curve: AnimationCurves.fastOutSlowIn,
    );
  }

  /// Get the delay duration for a staggered item.
  ///
  /// [index] - The index of the item.
  /// [staggerDelay] - Delay between each item (default 50ms).
  static Duration getDelay({
    required int index,
    Duration staggerDelay = const Duration(milliseconds: 50),
  }) {
    return Duration(milliseconds: staggerDelay.inMilliseconds * index);
  }
}

/// Helper extension for creating tween animations.
extension TweenExtensions<T> on Tween<T> {
  /// Create a curved animation from this tween.
  Animation<T> curved(Animation<double> parent, Curve curve) {
    return animate(CurvedAnimation(parent: parent, curve: curve));
  }
}

/// Scale tween presets for button press effects.
abstract class ScaleAnimations {
  /// Subtle press scale (0.98).
  static const double pressedSubtle = 0.98;

  /// Normal press scale (0.95).
  static const double pressedNormal = 0.95;

  /// Strong press scale (0.90).
  static const double pressedStrong = 0.90;

  /// Pop scale for emphasis (1.1).
  static const double popScale = 1.1;
}

/// Opacity presets for fade animations.
abstract class OpacityAnimations {
  /// Fully transparent.
  static const double transparent = 0.0;

  /// Slightly visible.
  static const double subtle = 0.3;

  /// Half visible.
  static const double half = 0.5;

  /// Mostly visible.
  static const double prominent = 0.8;

  /// Fully opaque.
  static const double opaque = 1.0;
}

/// Offset presets for slide animations.
abstract class SlideAnimations {
  /// Slide in from left.
  static const Offset fromLeft = Offset(-1.0, 0.0);

  /// Slide in from right.
  static const Offset fromRight = Offset(1.0, 0.0);

  /// Slide in from top.
  static const Offset fromTop = Offset(0.0, -1.0);

  /// Slide in from bottom.
  static const Offset fromBottom = Offset(0.0, 1.0);

  /// Subtle slide from left.
  static const Offset subtleFromLeft = Offset(-0.2, 0.0);

  /// Subtle slide from right.
  static const Offset subtleFromRight = Offset(0.2, 0.0);

  /// Subtle slide from top.
  static const Offset subtleFromTop = Offset(0.0, -0.2);

  /// Subtle slide from bottom.
  static const Offset subtleFromBottom = Offset(0.0, 0.2);

  /// Center position (no offset).
  static const Offset center = Offset.zero;
}
