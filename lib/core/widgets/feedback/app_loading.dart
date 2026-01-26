/// AppLoading - Loading indicator components.
///
/// Various loading indicators for different contexts.
library;

import 'package:flutter/material.dart';

/// A centered loading indicator.
class AppLoading extends StatelessWidget {
  /// Creates an AppLoading widget.
  const AppLoading({
    super.key,
    this.message,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
  });

  /// Creates a small inline loading indicator.
  const AppLoading.small({
    super.key,
    this.message,
    this.color,
  })  : size = 20,
        strokeWidth = 2;

  /// Creates a full-screen loading overlay.
  const AppLoading.fullScreen({
    super.key,
    this.message,
    this.color,
  })  : size = 48,
        strokeWidth = 4;

  /// Optional loading message.
  final String? message;

  /// Size of the indicator.
  final double size;

  /// Stroke width of the indicator.
  final double strokeWidth;

  /// Custom color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A skeleton loading placeholder.
class AppSkeleton extends StatelessWidget {
  /// Creates a skeleton placeholder.
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  /// Creates a circular skeleton.
  const AppSkeleton.circle({
    super.key,
    double size = 48,
  })  : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(999));

  /// Width of the skeleton.
  final double? width;

  /// Height of the skeleton.
  final double height;

  /// Border radius.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

/// A shimmer loading effect widget.
class AppShimmer extends StatefulWidget {
  /// Creates a shimmer effect.
  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  /// Child widget to apply shimmer to.
  final Widget child;

  /// Whether shimmer is enabled.
  final bool enabled;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.grey,
                Colors.white,
                Colors.grey,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
