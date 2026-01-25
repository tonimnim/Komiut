/// Count Up Animation - Animated number counting.
///
/// A widget that animates numbers counting up or down.
library;

import 'package:flutter/material.dart';

import '../../utils/animation_utils.dart';

/// A widget that animates a number counting up.
class CountUpAnimation extends StatefulWidget {
  /// Creates a CountUpAnimation widget.
  const CountUpAnimation({
    super.key,
    required this.end,
    this.begin = 0,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
    this.curve = AnimationCurves.easeOut,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 0,
    this.separator = ',',
    this.decimalSeparator = '.',
    this.autoStart = true,
    this.onComplete,
  });

  /// Creates a CountUpAnimation for currency.
  factory CountUpAnimation.currency({
    Key? key,
    required double end,
    double begin = 0,
    Duration duration = const Duration(milliseconds: 1200),
    Duration delay = Duration.zero,
    Curve curve = AnimationCurves.easeOut,
    TextStyle? style,
    String currencySymbol = 'KSh ',
    int decimalPlaces = 0,
    bool autoStart = true,
    VoidCallback? onComplete,
  }) {
    return CountUpAnimation(
      key: key,
      end: end,
      begin: begin,
      duration: duration,
      delay: delay,
      curve: curve,
      style: style,
      prefix: currencySymbol,
      decimalPlaces: decimalPlaces,
      autoStart: autoStart,
      onComplete: onComplete,
    );
  }

  /// Creates a CountUpAnimation for percentages.
  factory CountUpAnimation.percentage({
    Key? key,
    required double end,
    double begin = 0,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = AnimationCurves.easeOut,
    TextStyle? style,
    int decimalPlaces = 0,
    bool autoStart = true,
    VoidCallback? onComplete,
  }) {
    return CountUpAnimation(
      key: key,
      end: end,
      begin: begin,
      duration: duration,
      delay: delay,
      curve: curve,
      style: style,
      suffix: '%',
      decimalPlaces: decimalPlaces,
      autoStart: autoStart,
      onComplete: onComplete,
    );
  }

  /// Starting value.
  final double begin;

  /// Ending value.
  final double end;

  /// Duration of the animation.
  final Duration duration;

  /// Delay before starting.
  final Duration delay;

  /// Animation curve.
  final Curve curve;

  /// Text style.
  final TextStyle? style;

  /// Text to show before the number.
  final String prefix;

  /// Text to show after the number.
  final String suffix;

  /// Number of decimal places.
  final int decimalPlaces;

  /// Thousands separator.
  final String separator;

  /// Decimal separator.
  final String decimalSeparator;

  /// Whether to start automatically.
  final bool autoStart;

  /// Callback when animation completes.
  final VoidCallback? onComplete;

  @override
  State<CountUpAnimation> createState() => CountUpAnimationState();
}

class CountUpAnimationState extends State<CountUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(CountUpAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end || oldWidget.begin != widget.begin) {
      _animation = Tween<double>(
        begin: widget.begin,
        end: widget.end,
      ).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
      if (widget.autoStart) {
        restart();
      }
    }
  }

  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Start the animation.
  void start() {
    _controller.forward();
  }

  /// Restart the animation.
  void restart() {
    _controller.reset();
    _controller.forward();
  }

  /// Reset the animation.
  void reset() {
    _controller.reset();
  }

  String _formatNumber(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();

    String numStr;
    if (widget.decimalPlaces > 0) {
      numStr = absValue.toStringAsFixed(widget.decimalPlaces);
    } else {
      numStr = absValue.round().toString();
    }

    // Split into integer and decimal parts
    final parts = numStr.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '';

    // Add thousands separators
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(widget.separator);
      }
      buffer.write(intPart[i]);
    }

    String result = buffer.toString();
    if (decPart.isNotEmpty) {
      result += widget.decimalSeparator + decPart;
    }

    if (isNegative) {
      result = '-$result';
    }

    return '${widget.prefix}$result${widget.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _formatNumber(_animation.value),
          style: widget.style ?? Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }
}

/// A widget that rolls through digits like a slot machine.
class RollingNumber extends StatefulWidget {
  /// Creates a RollingNumber widget.
  const RollingNumber({
    super.key,
    required this.value,
    this.duration = AnimationDurations.normal,
    this.style,
    this.curve = AnimationCurves.easeInOut,
    this.digitHeight,
  });

  /// The number to display.
  final int value;

  /// Duration of the rolling animation.
  final Duration duration;

  /// Text style for digits.
  final TextStyle? style;

  /// Animation curve.
  final Curve curve;

  /// Height of each digit (for rolling effect).
  final double? digitHeight;

  @override
  State<RollingNumber> createState() => _RollingNumberState();
}

class _RollingNumberState extends State<RollingNumber> {
  late List<int> _digits;

  @override
  void initState() {
    super.initState();
    _digits = _getDigits(widget.value);
  }

  @override
  void didUpdateWidget(RollingNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _digits = _getDigits(widget.value);
    }
  }

  List<int> _getDigits(int value) {
    if (value == 0) return [0];
    final digits = <int>[];
    var remaining = value.abs();
    while (remaining > 0) {
      digits.insert(0, remaining % 10);
      remaining ~/= 10;
    }
    return digits;
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? Theme.of(context).textTheme.titleLarge!;
    final digitHeight = widget.digitHeight ?? style.fontSize! * 1.2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.value < 0)
          Text('-', style: style),
        for (var i = 0; i < _digits.length; i++)
          _RollingDigit(
            digit: _digits[i],
            duration: widget.duration,
            curve: widget.curve,
            style: style,
            height: digitHeight,
          ),
      ],
    );
  }
}

class _RollingDigit extends StatelessWidget {
  const _RollingDigit({
    required this.digit,
    required this.duration,
    required this.curve,
    required this.style,
    required this.height,
  });

  final int digit;
  final Duration duration;
  final Curve curve;
  final TextStyle style;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: duration,
          switchInCurve: curve,
          switchOutCurve: curve,
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Text(
            digit.toString(),
            key: ValueKey(digit),
            style: style,
          ),
        ),
      ),
    );
  }
}

/// An animated progress value display.
class AnimatedValue extends StatelessWidget {
  /// Creates an AnimatedValue widget.
  const AnimatedValue({
    super.key,
    required this.value,
    this.duration = AnimationDurations.normal,
    this.curve = AnimationCurves.easeInOut,
    this.style,
    this.builder,
  });

  /// The value to display.
  final double value;

  /// Duration of the animation.
  final Duration duration;

  /// Animation curve.
  final Curve curve;

  /// Text style.
  final TextStyle? style;

  /// Custom builder for the value display.
  final Widget Function(BuildContext, double)? builder;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        if (builder != null) {
          return builder!(context, value);
        }
        return Text(
          value.toStringAsFixed(0),
          style: style ?? Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }
}
