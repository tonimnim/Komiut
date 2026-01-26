/// Memory Management Utilities.
///
/// Provides utilities for managing memory in the app, including cache
/// management, subscription cleanup, and low memory detection.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/images/optimized_image.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Memory Observer
// ─────────────────────────────────────────────────────────────────────────────

/// A widget that listens for low memory warnings and clears caches.
///
/// Place this high in the widget tree (e.g., MaterialApp body) to
/// automatically respond to system memory pressure.
class MemoryAwareWidget extends StatefulWidget {
  /// Creates a MemoryAwareWidget.
  const MemoryAwareWidget({
    super.key,
    required this.child,
    this.onLowMemory,
  });

  /// Child widget.
  final Widget child;

  /// Callback when low memory is detected.
  final VoidCallback? onLowMemory;

  @override
  State<MemoryAwareWidget> createState() => _MemoryAwareWidgetState();
}

class _MemoryAwareWidgetState extends State<MemoryAwareWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    _handleLowMemory();
  }

  void _handleLowMemory() {
    debugPrint('Low memory detected, clearing caches...');

    // Clear image cache
    clearImageCache();

    // Call custom handler
    widget.onLowMemory?.call();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subscription Manager
// ─────────────────────────────────────────────────────────────────────────────

/// A mixin that helps manage stream subscriptions and dispose them properly.
///
/// Use this mixin in State classes that need to manage multiple subscriptions.
///
/// Example:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with SubscriptionManager {
///   @override
///   void initState() {
///     super.initState();
///     addSubscription(stream1.listen(_handleStream1));
///     addSubscription(stream2.listen(_handleStream2));
///   }
///
///   @override
///   void dispose() {
///     cancelAllSubscriptions();
///     super.dispose();
///   }
/// }
/// ```
mixin SubscriptionManager<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _subscriptions = [];

  /// Adds a subscription to be managed.
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancels all managed subscriptions.
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Pauses all managed subscriptions.
  void pauseAllSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.pause();
    }
  }

  /// Resumes all managed subscriptions.
  void resumeAllSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.resume();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller Manager
// ─────────────────────────────────────────────────────────────────────────────

/// A mixin that helps manage controllers and dispose them properly.
///
/// Use this mixin in State classes that need to manage multiple controllers.
///
/// Example:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with ControllerManager {
///   late TextEditingController textController;
///   late ScrollController scrollController;
///
///   @override
///   void initState() {
///     super.initState();
///     textController = addController(TextEditingController());
///     scrollController = addController(ScrollController());
///   }
///
///   @override
///   void dispose() {
///     disposeAllControllers();
///     super.dispose();
///   }
/// }
/// ```
mixin ControllerManager<T extends StatefulWidget> on State<T> {
  final List<ChangeNotifier> _controllers = [];

  /// Adds a controller to be managed.
  C addController<C extends ChangeNotifier>(C controller) {
    _controllers.add(controller);
    return controller;
  }

  /// Disposes all managed controllers.
  void disposeAllControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resource Cleanup
// ─────────────────────────────────────────────────────────────────────────────

/// A helper class for managing disposable resources.
///
/// Collects dispose callbacks and executes them all when dispose is called.
class DisposeBag {
  final List<VoidCallback> _disposers = [];

  /// Adds a dispose callback.
  void add(VoidCallback disposer) {
    _disposers.add(disposer);
  }

  /// Adds a stream subscription to dispose.
  void addSubscription(StreamSubscription subscription) {
    _disposers.add(subscription.cancel);
  }

  /// Adds a controller to dispose.
  void addController(ChangeNotifier controller) {
    _disposers.add(controller.dispose);
  }

  /// Disposes all resources.
  void dispose() {
    for (final disposer in _disposers.reversed) {
      try {
        disposer();
      } catch (e) {
        debugPrint('Error disposing resource: $e');
      }
    }
    _disposers.clear();
  }
}

/// Extension for adding to DisposeBag with fluent syntax.
extension DisposeBagExtension on StreamSubscription {
  /// Adds this subscription to a dispose bag.
  StreamSubscription disposeWith(DisposeBag bag) {
    bag.addSubscription(this);
    return this;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cache Management
// ─────────────────────────────────────────────────────────────────────────────

/// Global cache manager for app-wide cache control.
class AppCacheManager {
  AppCacheManager._();

  static final AppCacheManager instance = AppCacheManager._();

  final List<VoidCallback> _cacheClears = [];

  /// Registers a cache clear callback.
  void registerCache(VoidCallback clearCallback) {
    _cacheClears.add(clearCallback);
  }

  /// Unregisters a cache clear callback.
  void unregisterCache(VoidCallback clearCallback) {
    _cacheClears.remove(clearCallback);
  }

  /// Clears all registered caches.
  void clearAllCaches() {
    debugPrint('Clearing ${_cacheClears.length} caches...');
    for (final clear in _cacheClears) {
      try {
        clear();
      } catch (e) {
        debugPrint('Error clearing cache: $e');
      }
    }

    // Also clear image cache
    clearImageCache();
  }

  /// Clears caches on logout.
  void onLogout() {
    clearAllCaches();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Lifecycle Observer
// ─────────────────────────────────────────────────────────────────────────────

/// A widget that observes app lifecycle and optimizes resources.
///
/// Pauses animations and other resource-intensive operations when
/// the app goes to background.
class AppLifecycleObserver extends StatefulWidget {
  /// Creates an AppLifecycleObserver.
  const AppLifecycleObserver({
    super.key,
    required this.child,
    this.onResume,
    this.onPause,
    this.onDetached,
    this.pauseOnBackground = true,
  });

  /// Child widget.
  final Widget child;

  /// Called when app resumes.
  final VoidCallback? onResume;

  /// Called when app pauses.
  final VoidCallback? onPause;

  /// Called when app is detached.
  final VoidCallback? onDetached;

  /// Whether to pause resource-intensive operations on background.
  final bool pauseOnBackground;

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        widget.onResume?.call();
        break;
      case AppLifecycleState.paused:
        widget.onPause?.call();
        if (widget.pauseOnBackground) {
          // Reduce memory footprint when backgrounded
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        }
        break;
      case AppLifecycleState.detached:
        widget.onDetached?.call();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Do nothing for these states
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utility Functions
// ─────────────────────────────────────────────────────────────────────────────

/// Checks if the app is running in release mode.
bool get isReleaseMode => kReleaseMode;

/// Checks if the app is running in debug mode.
bool get isDebugMode => kDebugMode;

/// Runs a function only in debug mode.
void debugOnly(VoidCallback callback) {
  if (kDebugMode) {
    callback();
  }
}

/// Logs memory usage in debug mode.
void logMemoryUsage(String label) {
  if (kDebugMode) {
    final imageCache = PaintingBinding.instance.imageCache;
    debugPrint(
      '[$label] Image cache: ${imageCache.currentSize} bytes, '
      '${imageCache.liveImageCount} images',
    );
  }
}
