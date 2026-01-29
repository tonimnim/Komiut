/// FadeIn Widget - Fade in animation on appear.
///
/// A widget that fades in its child when it appears in the widget tree.
library;

import 'package:flutter/material.dart';

import '../../utils/animation_utils.dart';

/// A widget that fades in its child when mounted.
class FadeIn extends StatefulWidget {
  /// Creates a FadeIn widget.
  const FadeIn({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.easeInOut,
    this.onComplete,
  });

  /// The widget to animate.
  final Widget child;

  /// Duration of the fade animation.
  final Duration duration;

  /// Delay before starting the animation.
  final Duration delay;

  /// Animation curve.
  final Curve curve;

  /// Callback when animation completes.
  final VoidCallback? onComplete;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      await _controller.forward();
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// A widget that fades in and out based on a boolean condition.
class FadeInOut extends StatelessWidget {
  /// Creates a FadeInOut widget.
  const FadeInOut({
    super.key,
    required this.child,
    required this.isVisible,
    this.duration = AnimationDurations.fast,
    this.curve = AnimationCurves.easeInOut,
    this.maintainState = true,
    this.maintainSize = false,
  });

  /// The widget to animate.
  final Widget child;

  /// Whether the child is visible.
  final bool isVisible;

  /// Duration of the animation.
  final Duration duration;

  /// Animation curve.
  final Curve curve;

  /// Whether to maintain the child's state when invisible.
  final bool maintainState;

  /// Whether to maintain the child's size when invisible.
  final bool maintainSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: duration,
      curve: curve,
      child: Visibility(
        visible: isVisible || maintainSize,
        maintainState: maintainState,
        maintainSize: maintainSize,
        maintainAnimation: maintainState,
        child: child,
      ),
    );
  }
}

/// A widget that crossfades between two children.
class CrossFade extends StatelessWidget {
  /// Creates a CrossFade widget.
  const CrossFade({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.showFirst,
    this.duration = AnimationDurations.normal,
    this.firstCurve = Curves.linear,
    this.secondCurve = Curves.linear,
    this.sizeCurve = AnimationCurves.fastOutSlowIn,
    this.alignment = Alignment.topCenter,
  });

  /// The first child widget.
  final Widget firstChild;

  /// The second child widget.
  final Widget secondChild;

  /// Whether to show the first child.
  final bool showFirst;

  /// Duration of the crossfade.
  final Duration duration;

  /// Curve for the first child animation.
  final Curve firstCurve;

  /// Curve for the second child animation.
  final Curve secondCurve;

  /// Curve for the size animation.
  final Curve sizeCurve;

  /// Alignment for size animation.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState:
          showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: duration,
      firstCurve: firstCurve,
      secondCurve: secondCurve,
      sizeCurve: sizeCurve,
      alignment: alignment,
    );
  }
}
