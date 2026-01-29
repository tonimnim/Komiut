/// ScaleIn Widget - Scale up animation on appear.
///
/// A widget that scales up its child when it appears in the widget tree.
library;

import 'package:flutter/material.dart';

import '../../utils/animation_utils.dart';

/// A widget that scales in its child when mounted.
class ScaleIn extends StatefulWidget {
  /// Creates a ScaleIn widget.
  const ScaleIn({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.begin = 0.0,
    this.end = 1.0,
    this.alignment = Alignment.center,
    this.onComplete,
  });

  /// Creates a ScaleIn with a pop effect.
  const ScaleIn.pop({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.alignment = Alignment.center,
    this.onComplete,
  })  : curve = AnimationCurves.overshoot,
        begin = 0.5,
        end = 1.0;

  /// Creates a ScaleIn with a subtle effect.
  const ScaleIn.subtle({
    super.key,
    required this.child,
    this.duration = AnimationDurations.fast,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.easeOut,
    this.alignment = Alignment.center,
    this.onComplete,
  })  : begin = 0.9,
        end = 1.0;

  /// The widget to animate.
  final Widget child;

  /// Duration of the scale animation.
  final Duration duration;

  /// Delay before starting the animation.
  final Duration delay;

  /// Animation curve.
  final Curve curve;

  /// Starting scale value.
  final double begin;

  /// Ending scale value.
  final double end;

  /// Alignment for the scale transformation.
  final Alignment alignment;

  /// Callback when animation completes.
  final VoidCallback? onComplete;

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(
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
    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}

/// A widget that scales and fades in its child when mounted.
class ScaleAndFadeIn extends StatefulWidget {
  /// Creates a ScaleAndFadeIn widget.
  const ScaleAndFadeIn({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.fastOutSlowIn,
    this.beginScale = 0.8,
    this.endScale = 1.0,
    this.alignment = Alignment.center,
    this.onComplete,
  });

  /// Creates a ScaleAndFadeIn with a pop effect.
  const ScaleAndFadeIn.pop({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.alignment = Alignment.center,
    this.onComplete,
  })  : curve = AnimationCurves.overshoot,
        beginScale = 0.5,
        endScale = 1.0;

  /// The widget to animate.
  final Widget child;

  /// Duration of the animation.
  final Duration duration;

  /// Delay before starting the animation.
  final Duration delay;

  /// Animation curve.
  final Curve curve;

  /// Starting scale value.
  final double beginScale;

  /// Ending scale value.
  final double endScale;

  /// Alignment for the scale transformation.
  final Alignment alignment;

  /// Callback when animation completes.
  final VoidCallback? onComplete;

  @override
  State<ScaleAndFadeIn> createState() => _ScaleAndFadeInState();
}

class _ScaleAndFadeInState extends State<ScaleAndFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.easeIn),
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
    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: widget.alignment,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// A widget that bounces when tapped.
class BounceOnTap extends StatefulWidget {
  /// Creates a BounceOnTap widget.
  const BounceOnTap({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = ScaleAnimations.pressedNormal,
    this.duration = AnimationDurations.fast,
  });

  /// The widget to wrap.
  final Widget child;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Scale when pressed.
  final double scale;

  /// Duration of the animation.
  final Duration duration;

  @override
  State<BounceOnTap> createState() => _BounceOnTapState();
}

class _BounceOnTapState extends State<BounceOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
