/// SlideIn Widget - Slide in animation from direction.
///
/// A widget that slides in its child from a specified direction.
library;

import 'package:flutter/material.dart';

import '../../utils/animation_utils.dart';

/// Direction for slide animations.
enum SlideInDirection {
  /// Slide from left.
  left,

  /// Slide from right.
  right,

  /// Slide from top.
  top,

  /// Slide from bottom.
  bottom,
}

/// A widget that slides in its child when mounted.
class SlideIn extends StatefulWidget {
  /// Creates a SlideIn widget.
  const SlideIn({
    super.key,
    required this.child,
    this.direction = SlideInDirection.bottom,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.offset = 1.0,
    this.onComplete,
  });

  /// Creates a SlideIn widget from the left.
  const SlideIn.fromLeft({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.offset = 1.0,
    this.onComplete,
  }) : direction = SlideInDirection.left;

  /// Creates a SlideIn widget from the right.
  const SlideIn.fromRight({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.offset = 1.0,
    this.onComplete,
  }) : direction = SlideInDirection.right;

  /// Creates a SlideIn widget from the top.
  const SlideIn.fromTop({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.offset = 1.0,
    this.onComplete,
  }) : direction = SlideInDirection.top;

  /// Creates a SlideIn widget from the bottom.
  const SlideIn.fromBottom({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.offset = 1.0,
    this.onComplete,
  }) : direction = SlideInDirection.bottom;

  /// The widget to animate.
  final Widget child;

  /// Direction to slide from.
  final SlideInDirection direction;

  /// Duration of the slide animation.
  final Duration duration;

  /// Delay before starting the animation.
  final Duration delay;

  /// Animation curve.
  final Curve curve;

  /// Offset multiplier (1.0 = full width/height).
  final double offset;

  /// Callback when animation completes.
  final VoidCallback? onComplete;

  @override
  State<SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<SlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final begin = _getBeginOffset();
    _slideAnimation = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _startAnimation();
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideInDirection.left:
        return Offset(-widget.offset, 0.0);
      case SlideInDirection.right:
        return Offset(widget.offset, 0.0);
      case SlideInDirection.top:
        return Offset(0.0, -widget.offset);
      case SlideInDirection.bottom:
        return Offset(0.0, widget.offset);
    }
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
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}

/// A widget that slides and fades in its child when mounted.
class SlideAndFadeIn extends StatefulWidget {
  /// Creates a SlideAndFadeIn widget.
  const SlideAndFadeIn({
    super.key,
    required this.child,
    this.direction = SlideInDirection.bottom,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.slideOffset = 0.2,
    this.onComplete,
  });

  /// Creates a SlideAndFadeIn from the left.
  const SlideAndFadeIn.fromLeft({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.slideOffset = 0.2,
    this.onComplete,
  }) : direction = SlideInDirection.left;

  /// Creates a SlideAndFadeIn from the right.
  const SlideAndFadeIn.fromRight({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.slideOffset = 0.2,
    this.onComplete,
  }) : direction = SlideInDirection.right;

  /// Creates a SlideAndFadeIn from the top.
  const SlideAndFadeIn.fromTop({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.slideOffset = 0.2,
    this.onComplete,
  }) : direction = SlideInDirection.top;

  /// Creates a SlideAndFadeIn from the bottom.
  const SlideAndFadeIn.fromBottom({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.slideOffset = 0.2,
    this.onComplete,
  }) : direction = SlideInDirection.bottom;

  /// The widget to animate.
  final Widget child;

  /// Direction to slide from.
  final SlideInDirection direction;

  /// Duration of the animation.
  final Duration duration;

  /// Delay before starting the animation.
  final Duration delay;

  /// Animation curve.
  final Curve curve;

  /// Slide offset (0.2 = 20% of parent size).
  final double slideOffset;

  /// Callback when animation completes.
  final VoidCallback? onComplete;

  @override
  State<SlideAndFadeIn> createState() => _SlideAndFadeInState();
}

class _SlideAndFadeInState extends State<SlideAndFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final begin = _getBeginOffset();
    _slideAnimation = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.easeIn),
    );

    _startAnimation();
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideInDirection.left:
        return Offset(-widget.slideOffset, 0.0);
      case SlideInDirection.right:
        return Offset(widget.slideOffset, 0.0);
      case SlideInDirection.top:
        return Offset(0.0, -widget.slideOffset);
      case SlideInDirection.bottom:
        return Offset(0.0, widget.slideOffset);
    }
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
