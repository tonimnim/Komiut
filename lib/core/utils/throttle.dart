/// Throttle utility for rate-limiting function calls.
///
/// Provides throttling functionality to limit how often a function can be
/// executed. Useful for scroll events and other high-frequency interactions.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

/// A throttler that limits function execution frequency.
///
/// Unlike debouncing which delays execution, throttling ensures a function
/// is executed at most once per specified interval. The first call executes
/// immediately, and subsequent calls are ignored until the interval passes.
///
/// Example:
/// ```dart
/// final throttler = Throttler(milliseconds: 100);
///
/// void onScroll(ScrollPosition position) {
///   throttler.run(() {
///     updateScrollIndicator(position);
///   });
/// }
/// ```
class Throttler {
  /// Creates a Throttler with the specified interval in milliseconds.
  Throttler({
    this.milliseconds = 100,
    this.trailing = false,
  });

  /// The minimum interval between function executions in milliseconds.
  final int milliseconds;

  /// Whether to execute a trailing call after the interval.
  ///
  /// If true and calls were made during the throttle period, the last
  /// call will be executed after the interval passes.
  final bool trailing;

  DateTime? _lastExecutionTime;
  Timer? _trailingTimer;
  VoidCallback? _lastAction;
  bool _isThrottled = false;

  /// Runs the provided action if not currently throttled.
  ///
  /// If the throttler is currently throttled, the action is either
  /// ignored or queued for trailing execution based on [trailing].
  void run(VoidCallback action) {
    final now = DateTime.now();
    _lastAction = action;

    // First call or interval has passed
    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!).inMilliseconds >= milliseconds) {
      _execute(action, now);
    } else if (trailing) {
      // Queue trailing execution
      _scheduleTrailing();
    }
  }

  void _execute(VoidCallback action, DateTime now) {
    _lastExecutionTime = now;
    _isThrottled = true;
    action();

    // Schedule end of throttle period
    _trailingTimer?.cancel();
    _trailingTimer = Timer(Duration(milliseconds: milliseconds), () {
      _isThrottled = false;
      _trailingTimer = null;
    });
  }

  void _scheduleTrailing() {
    if (_trailingTimer != null) return;

    final timeSinceLast = _lastExecutionTime != null
        ? DateTime.now().difference(_lastExecutionTime!).inMilliseconds
        : milliseconds;

    final remaining = milliseconds - timeSinceLast;

    _trailingTimer =
        Timer(Duration(milliseconds: remaining.clamp(0, milliseconds)), () {
      _isThrottled = false;
      _trailingTimer = null;
      if (_lastAction != null) {
        _execute(_lastAction!, DateTime.now());
      }
    });
  }

  /// Whether the throttler is currently throttled.
  bool get isThrottled => _isThrottled;

  /// Resets the throttler, allowing immediate execution of the next call.
  void reset() {
    _lastExecutionTime = null;
    _isThrottled = false;
    _trailingTimer?.cancel();
    _trailingTimer = null;
    _lastAction = null;
  }

  /// Disposes the throttler.
  void dispose() {
    reset();
  }
}

/// A throttler that works with async operations.
///
/// Similar to [Throttler] but for async functions that return a Future.
class AsyncThrottler<T> {
  /// Creates an AsyncThrottler with the specified interval.
  AsyncThrottler({
    this.milliseconds = 100,
  });

  /// The minimum interval between function executions in milliseconds.
  final int milliseconds;

  DateTime? _lastExecutionTime;
  Future<T>? _lastFuture;
  bool _isExecuting = false;

  /// Runs the provided async action if not currently throttled.
  ///
  /// Returns the result of the action if executed, or the result of
  /// the last execution if throttled.
  Future<T?> run(Future<T> Function() action) async {
    final now = DateTime.now();

    // If currently executing, return the last future
    if (_isExecuting && _lastFuture != null) {
      return _lastFuture;
    }

    // If within throttle interval, return null
    if (_lastExecutionTime != null &&
        now.difference(_lastExecutionTime!).inMilliseconds < milliseconds) {
      return null;
    }

    _lastExecutionTime = now;
    _isExecuting = true;

    try {
      _lastFuture = action();
      return await _lastFuture;
    } finally {
      _isExecuting = false;
    }
  }

  /// Forces execution regardless of throttle state.
  Future<T> forceRun(Future<T> Function() action) async {
    _lastExecutionTime = DateTime.now();
    _isExecuting = true;

    try {
      _lastFuture = action();
      return await _lastFuture!;
    } finally {
      _isExecuting = false;
    }
  }

  /// Whether the throttler is currently throttled.
  bool get isThrottled {
    if (_lastExecutionTime == null) return false;
    return DateTime.now().difference(_lastExecutionTime!).inMilliseconds <
        milliseconds;
  }

  /// Resets the throttler.
  void reset() {
    _lastExecutionTime = null;
    _lastFuture = null;
    _isExecuting = false;
  }
}

/// A scroll throttler optimized for scroll events.
///
/// Provides additional scroll-specific functionality like direction
/// detection and velocity-based throttling.
class ScrollThrottler {
  /// Creates a ScrollThrottler.
  ScrollThrottler({
    this.milliseconds = 100,
    this.onScrollUpdate,
    this.onScrollStart,
    this.onScrollEnd,
  });

  /// The throttle interval in milliseconds.
  final int milliseconds;

  /// Callback for throttled scroll updates.
  final void Function(ScrollInfo info)? onScrollUpdate;

  /// Callback when scrolling starts.
  final VoidCallback? onScrollStart;

  /// Callback when scrolling ends.
  final VoidCallback? onScrollEnd;

  final Throttler _throttler = Throttler(trailing: true);
  Timer? _scrollEndTimer;
  bool _isScrolling = false;
  double _lastOffset = 0;
  DateTime? _lastScrollTime;

  /// Called on each scroll notification.
  void onScroll(double offset, double maxScrollExtent) {
    final now = DateTime.now();
    final direction = offset > _lastOffset
        ? ScrollDirection.down
        : (offset < _lastOffset ? ScrollDirection.up : ScrollDirection.none);

    // Calculate velocity
    double velocity = 0;
    if (_lastScrollTime != null) {
      final dt = now.difference(_lastScrollTime!).inMilliseconds;
      if (dt > 0) {
        velocity = (offset - _lastOffset) / dt * 1000; // pixels per second
      }
    }

    // Detect scroll start
    if (!_isScrolling) {
      _isScrolling = true;
      onScrollStart?.call();
    }

    // Reset scroll end timer
    _scrollEndTimer?.cancel();
    _scrollEndTimer = Timer(const Duration(milliseconds: 150), () {
      _isScrolling = false;
      onScrollEnd?.call();
    });

    // Throttled scroll update
    final info = ScrollInfo(
      offset: offset,
      maxScrollExtent: maxScrollExtent,
      direction: direction,
      velocity: velocity,
      progress: maxScrollExtent > 0 ? offset / maxScrollExtent : 0,
    );

    _throttler.run(() {
      onScrollUpdate?.call(info);
    });

    _lastOffset = offset;
    _lastScrollTime = now;
  }

  /// Disposes the throttler.
  void dispose() {
    _throttler.dispose();
    _scrollEndTimer?.cancel();
  }
}

/// Direction of scroll.
enum ScrollDirection {
  /// Scrolling up (content moving down).
  up,

  /// Scrolling down (content moving up).
  down,

  /// Not scrolling or direction unchanged.
  none,
}

/// Information about the current scroll state.
class ScrollInfo {
  /// Creates ScrollInfo.
  const ScrollInfo({
    required this.offset,
    required this.maxScrollExtent,
    required this.direction,
    required this.velocity,
    required this.progress,
  });

  /// Current scroll offset.
  final double offset;

  /// Maximum scroll extent.
  final double maxScrollExtent;

  /// Current scroll direction.
  final ScrollDirection direction;

  /// Current scroll velocity in pixels per second.
  final double velocity;

  /// Scroll progress from 0.0 to 1.0.
  final double progress;

  /// Whether scrolling up.
  bool get isScrollingUp => direction == ScrollDirection.up;

  /// Whether scrolling down.
  bool get isScrollingDown => direction == ScrollDirection.down;

  /// Whether at the top of the scroll view.
  bool get isAtTop => offset <= 0;

  /// Whether at the bottom of the scroll view.
  bool get isAtBottom => offset >= maxScrollExtent;

  /// Whether scrolling fast (velocity > 1000 px/s).
  bool get isFastScroll => velocity.abs() > 1000;
}

/// Extension for creating throttled versions of functions.
extension ThrottledFunction on Function {
  /// Creates a throttled version of this function.
  void Function(T) throttled<T>(
    void Function(T) original, {
    int milliseconds = 100,
  }) {
    final throttler = Throttler(milliseconds: milliseconds);
    return (T arg) => throttler.run(() => original(arg));
  }
}
