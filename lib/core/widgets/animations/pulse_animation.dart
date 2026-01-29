/// Pulse Animation - Pulsing effect for attention.
///
/// A widget that creates a pulsing animation to draw attention.
library;

import 'package:flutter/material.dart';

/// A widget that pulses to draw attention.
class PulseAnimation extends StatefulWidget {
  /// Creates a PulseAnimation widget.
  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.autoStart = true,
    this.repeat = true,
    this.curve = Curves.easeInOut,
  });

  /// Creates a subtle pulse animation.
  const PulseAnimation.subtle({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.autoStart = true,
    this.repeat = true,
    this.curve = Curves.easeInOut,
  })  : minScale = 0.98,
        maxScale = 1.02;

  /// Creates a strong pulse animation.
  const PulseAnimation.strong({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.autoStart = true,
    this.repeat = true,
    this.curve = Curves.easeInOut,
  })  : minScale = 0.9,
        maxScale = 1.1;

  /// The widget to animate.
  final Widget child;

  /// Duration of one pulse cycle.
  final Duration duration;

  /// Minimum scale during pulse.
  final double minScale;

  /// Maximum scale during pulse.
  final double maxScale;

  /// Whether to start automatically.
  final bool autoStart;

  /// Whether to repeat the animation.
  final bool repeat;

  /// Animation curve.
  final Curve curve;

  @override
  State<PulseAnimation> createState() => PulseAnimationState();
}

class PulseAnimationState extends State<PulseAnimation>
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
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.autoStart) {
      start();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Start the pulse animation.
  void start() {
    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  /// Stop the pulse animation.
  void stop() {
    _controller.stop();
  }

  /// Reset the animation.
  void reset() {
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// A widget that creates a glowing pulse effect.
class GlowPulse extends StatefulWidget {
  /// Creates a GlowPulse widget.
  const GlowPulse({
    super.key,
    required this.child,
    this.glowColor,
    this.duration = const Duration(milliseconds: 1500),
    this.maxBlur = 20.0,
    this.minBlur = 5.0,
    this.autoStart = true,
    this.borderRadius,
  });

  /// The widget to wrap.
  final Widget child;

  /// Color of the glow effect.
  final Color? glowColor;

  /// Duration of one pulse cycle.
  final Duration duration;

  /// Maximum blur radius.
  final double maxBlur;

  /// Minimum blur radius.
  final double minBlur;

  /// Whether to start automatically.
  final bool autoStart;

  /// Border radius for the glow.
  final BorderRadius? borderRadius;

  @override
  State<GlowPulse> createState() => GlowPulseState();
}

class GlowPulseState extends State<GlowPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _blurAnimation = Tween<double>(
      begin: widget.minBlur,
      end: widget.maxBlur,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Start the glow animation.
  void start() {
    _controller.repeat(reverse: true);
  }

  /// Stop the glow animation.
  void stop() {
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.glowColor ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _blurAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: _blurAnimation.value,
                spreadRadius: _blurAnimation.value / 4,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// A widget that displays a breathing/heartbeat animation.
class HeartbeatAnimation extends StatefulWidget {
  /// Creates a HeartbeatAnimation widget.
  const HeartbeatAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.scale = 1.1,
    this.autoStart = true,
  });

  /// The widget to animate.
  final Widget child;

  /// Duration of one heartbeat.
  final Duration duration;

  /// Scale factor for the heartbeat.
  final double scale;

  /// Whether to start automatically.
  final bool autoStart;

  @override
  State<HeartbeatAnimation> createState() => HeartbeatAnimationState();
}

class HeartbeatAnimationState extends State<HeartbeatAnimation>
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

    // Create a more natural heartbeat curve
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.scale)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.scale, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.scale * 0.95)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.scale * 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
    ]).animate(_controller);

    if (widget.autoStart) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Start the heartbeat animation.
  void start() {
    _controller.repeat();
  }

  /// Stop the heartbeat animation.
  void stop() {
    _controller.stop();
  }

  /// Trigger a single heartbeat.
  Future<void> beat() async {
    await _controller.forward();
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// A blinking animation widget.
class BlinkAnimation extends StatefulWidget {
  /// Creates a BlinkAnimation widget.
  const BlinkAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
    this.autoStart = true,
  });

  /// The widget to animate.
  final Widget child;

  /// Duration of one blink cycle.
  final Duration duration;

  /// Minimum opacity during blink.
  final double minOpacity;

  /// Maximum opacity during blink.
  final double maxOpacity;

  /// Whether to start automatically.
  final bool autoStart;

  @override
  State<BlinkAnimation> createState() => BlinkAnimationState();
}

class BlinkAnimationState extends State<BlinkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(
      begin: widget.maxOpacity,
      end: widget.minOpacity,
    ).animate(_controller);

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Start the blink animation.
  void start() {
    _controller.repeat(reverse: true);
  }

  /// Stop the blink animation.
  void stop() {
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
    );
  }
}
