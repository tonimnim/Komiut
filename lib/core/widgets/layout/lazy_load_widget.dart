/// Lazy Load Widget.
///
/// Defers widget building until the widget becomes visible in the viewport.
/// Useful for heavy widgets and long lists to improve initial load time.
library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that defers building its child until visible in the viewport.
///
/// This is useful for:
/// - Heavy widgets that take time to build
/// - Widgets far down in a scrollable list
/// - Widgets that may never be scrolled to
///
/// Example:
/// ```dart
/// ListView.builder(
///   itemBuilder: (context, index) {
///     return LazyLoadWidget(
///       placeholder: ShimmerListTile(),
///       child: ExpensiveWidget(data: items[index]),
///     );
///   },
/// )
/// ```
class LazyLoadWidget extends StatefulWidget {
  /// Creates a LazyLoadWidget.
  const LazyLoadWidget({
    super.key,
    required this.child,
    this.placeholder,
    this.preloadOffset = 100.0,
    this.fadeInDuration = const Duration(milliseconds: 200),
    this.maintainSize = true,
    this.estimatedHeight,
  });

  /// The widget to show when visible.
  final Widget child;

  /// Widget to show while loading/not visible.
  final Widget? placeholder;

  /// Offset in pixels to start loading before becoming visible.
  final double preloadOffset;

  /// Duration of fade-in animation when becoming visible.
  final Duration fadeInDuration;

  /// Whether to maintain size after loading.
  final bool maintainSize;

  /// Estimated height for placeholder (used when maintainSize is false).
  final double? estimatedHeight;

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  bool _hasBuilt = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (_hasBuilt) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final renderObject = context.findRenderObject();
      if (renderObject == null) return;

      final viewport = RenderAbstractViewport.maybeOf(renderObject);
      if (viewport == null) {
        // Not in a scrollable - show immediately
        _setVisible();
        return;
      }

      final offset = viewport.getOffsetToReveal(renderObject, 0.5);
      final scrollableState = Scrollable.maybeOf(context);
      if (scrollableState == null) {
        _setVisible();
        return;
      }

      final scrollPosition = scrollableState.position;
      final viewportDimension = scrollPosition.viewportDimension;
      final scrollOffset = scrollPosition.pixels;

      // Check if within viewport (with preload offset)
      final top = offset.offset - widget.preloadOffset;
      final bottom = offset.offset +
          (renderObject.paintBounds.height) +
          widget.preloadOffset;

      if (top < scrollOffset + viewportDimension && bottom > scrollOffset) {
        _setVisible();
      }
    });
  }

  void _setVisible() {
    if (_hasBuilt) return;
    setState(() {
      _isVisible = true;
      _hasBuilt = true;
    });
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Schedule visibility check
    if (!_hasBuilt) {
      _checkVisibility();
    }

    if (!_isVisible) {
      return widget.placeholder ??
          SizedBox(
            height: widget.estimatedHeight,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
    }

    if (widget.fadeInDuration > Duration.zero) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      );
    }

    return widget.child;
  }
}

/// A sliver version of LazyLoadWidget for use in CustomScrollView.
class SliverLazyLoadWidget extends StatefulWidget {
  /// Creates a SliverLazyLoadWidget.
  const SliverLazyLoadWidget({
    super.key,
    required this.child,
    this.placeholder,
    this.preloadOffset = 100.0,
    this.fadeInDuration = const Duration(milliseconds: 200),
  });

  /// The sliver to show when visible.
  final Widget child;

  /// Widget to show while loading.
  final Widget? placeholder;

  /// Offset in pixels to start loading before becoming visible.
  final double preloadOffset;

  /// Duration of fade-in animation.
  final Duration fadeInDuration;

  @override
  State<SliverLazyLoadWidget> createState() => _SliverLazyLoadWidgetState();
}

class _SliverLazyLoadWidgetState extends State<SliverLazyLoadWidget>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    );
    // Check visibility on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (_isVisible || !mounted) return;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      scrollable.position.addListener(_onScroll);
    }
    _onScroll();
  }

  void _onScroll() {
    if (_isVisible || !mounted) return;

    // Simplified visibility check - in practice, you'd check
    // if the sliver is within the viewport
    setState(() {
      _isVisible = true;
    });
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return widget.placeholder ??
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
    }

    return SliverAnimatedOpacity(
      duration: widget.fadeInDuration,
      opacity: _isVisible ? 1.0 : 0.0,
      sliver: widget.child,
    );
  }
}

/// A visibility detector that calls a callback when visibility changes.
///
/// Useful for triggering lazy loading or analytics.
class VisibilityDetector extends StatefulWidget {
  /// Creates a VisibilityDetector.
  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
    this.threshold = 0.5,
  });

  /// The child widget.
  final Widget child;

  /// Called when visibility changes.
  final void Function(bool isVisible, double visibleFraction)
      onVisibilityChanged;

  /// Fraction of widget that must be visible to count as visible.
  final double threshold;

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted) return;

    final renderObject = context.findRenderObject();
    if (renderObject == null) return;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      scrollable.position.addListener(_onScroll);
    }

    _onScroll();
  }

  void _onScroll() {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) {
      // Not in a scrollable - always visible
      if (!_wasVisible) {
        _wasVisible = true;
        widget.onVisibilityChanged(true, 1.0);
      }
      return;
    }

    final viewport = scrollable.position;
    final widgetRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    // Calculate visible portion
    const viewportTop = 0.0;
    final viewportBottom = viewport.viewportDimension;

    final visibleTop = widgetRect.top.clamp(viewportTop, viewportBottom);
    final visibleBottom = widgetRect.bottom.clamp(viewportTop, viewportBottom);
    final visibleHeight =
        (visibleBottom - visibleTop).clamp(0.0, widgetRect.height);

    final visibleFraction =
        widgetRect.height > 0 ? visibleHeight / widgetRect.height : 0.0;

    final isVisible = visibleFraction >= widget.threshold;

    if (isVisible != _wasVisible) {
      _wasVisible = isVisible;
      widget.onVisibilityChanged(isVisible, visibleFraction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Defers building a widget until the next frame.
///
/// Useful for spreading out heavy widget building across multiple frames.
class DeferredWidget extends StatefulWidget {
  /// Creates a DeferredWidget.
  const DeferredWidget({
    super.key,
    required this.child,
    this.placeholder,
    this.delay = Duration.zero,
  });

  /// The widget to build after deferral.
  final Widget child;

  /// Placeholder while waiting.
  final Widget? placeholder;

  /// Delay before building the child.
  final Duration delay;

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  bool _shouldBuild = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, _build);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _build());
    }
  }

  void _build() {
    if (mounted) {
      setState(() {
        _shouldBuild = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldBuild) {
      return widget.child;
    }
    return widget.placeholder ?? const SizedBox.shrink();
  }
}

/// Batch defers multiple widgets to build across frames.
///
/// Builds children one at a time across multiple frames to avoid jank.
class BatchDeferredWidgets extends StatefulWidget {
  /// Creates BatchDeferredWidgets.
  const BatchDeferredWidgets({
    super.key,
    required this.children,
    this.batchSize = 3,
    this.delayBetweenBatches = const Duration(milliseconds: 16),
    this.placeholder,
  });

  /// Children to build progressively.
  final List<Widget> children;

  /// Number of children to build per batch.
  final int batchSize;

  /// Delay between batches.
  final Duration delayBetweenBatches;

  /// Placeholder for unbuilt children.
  final Widget? placeholder;

  @override
  State<BatchDeferredWidgets> createState() => _BatchDeferredWidgetsState();
}

class _BatchDeferredWidgetsState extends State<BatchDeferredWidgets> {
  int _builtCount = 0;

  @override
  void initState() {
    super.initState();
    _buildNextBatch();
  }

  void _buildNextBatch() {
    if (!mounted || _builtCount >= widget.children.length) return;

    setState(() {
      _builtCount =
          (_builtCount + widget.batchSize).clamp(0, widget.children.length);
    });

    if (_builtCount < widget.children.length) {
      Future.delayed(widget.delayBetweenBatches, _buildNextBatch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          if (i < _builtCount)
            widget.children[i]
          else
            widget.placeholder ??
                const SizedBox(height: 48), // Estimated height
      ],
    );
  }
}

/// Extension for easy lazy loading.
extension LazyLoadExtension on Widget {
  /// Wraps this widget in a LazyLoadWidget.
  Widget lazy({
    Widget? placeholder,
    double preloadOffset = 100.0,
    Duration fadeInDuration = const Duration(milliseconds: 200),
  }) {
    return LazyLoadWidget(
      placeholder: placeholder,
      preloadOffset: preloadOffset,
      fadeInDuration: fadeInDuration,
      child: this,
    );
  }

  /// Wraps this widget in a DeferredWidget.
  Widget deferred({
    Widget? placeholder,
    Duration delay = Duration.zero,
  }) {
    return DeferredWidget(
      placeholder: placeholder,
      delay: delay,
      child: this,
    );
  }
}
