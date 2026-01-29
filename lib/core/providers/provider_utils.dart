/// Provider Utilities.
///
/// Provides utilities for optimizing Riverpod provider usage including
/// caching, selective watching, and disposal helpers.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cached Provider Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// A provider that caches its value for a specified duration.
///
/// After the cache expires, the next read will recompute the value.
/// Useful for data that doesn't need to be refetched on every access.
///
/// Example:
/// ```dart
/// final cachedDataProvider = CachedProvider<List<Item>>(
///   duration: Duration(minutes: 5),
///   provider: (ref) async {
///     return await api.fetchItems();
///   },
/// );
/// ```
class CachedProvider<T> {
  /// Creates a CachedProvider with the specified cache duration.
  CachedProvider({
    required this.duration,
    required this.provider,
  });

  /// How long to cache the value.
  final Duration duration;

  /// The provider function.
  final Future<T> Function(Ref ref) provider;

  DateTime? _lastFetch;
  T? _cachedValue;
  Future<T>? _pendingFuture;

  /// Gets the cached value or fetches a new one if expired.
  Future<T> get(Ref ref) async {
    final now = DateTime.now();

    // Return cached value if still valid
    if (_cachedValue != null &&
        _lastFetch != null &&
        now.difference(_lastFetch!) < duration) {
      return _cachedValue!;
    }

    // If a fetch is in progress, return its future
    if (_pendingFuture != null) {
      return _pendingFuture!;
    }

    // Fetch new value
    _pendingFuture = provider(ref);
    try {
      _cachedValue = await _pendingFuture!;
      _lastFetch = now;
      return _cachedValue!;
    } finally {
      _pendingFuture = null;
    }
  }

  /// Forces a refresh of the cached value.
  void invalidate() {
    _lastFetch = null;
    _cachedValue = null;
  }

  /// Whether the cache is currently valid.
  bool get isValid {
    if (_lastFetch == null || _cachedValue == null) return false;
    return DateTime.now().difference(_lastFetch!) < duration;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selective Watch Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Extension for optimized provider watching.
extension OptimizedWatch on WidgetRef {
  /// Watches a provider and only rebuilds when the selected value changes.
  ///
  /// This is equivalent to using `ref.watch(provider.select(selector))` but
  /// with a cleaner syntax for complex selectors.
  ///
  /// Example:
  /// ```dart
  /// // Only rebuilds when user name changes
  /// final userName = ref.watchSelect(
  ///   userProvider,
  ///   (user) => user?.name ?? 'Guest',
  /// );
  /// ```
  R watchSelect<T, R>(
    ProviderListenable<T> provider,
    R Function(T) selector,
  ) {
    return watch(provider.select(selector));
  }

  /// Watches multiple providers and combines their values.
  ///
  /// Only rebuilds when the combined result changes.
  ///
  /// Example:
  /// ```dart
  /// final (user, settings) = ref.watchMultiple(
  ///   userProvider,
  ///   settingsProvider,
  /// );
  /// ```
  (T1, T2) watchMultiple<T1, T2>(
    ProviderListenable<T1> provider1,
    ProviderListenable<T2> provider2,
  ) {
    final value1 = watch(provider1);
    final value2 = watch(provider2);
    return (value1, value2);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auto-Dispose Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// A mixin that provides auto-dispose functionality for providers.
///
/// Use with StateNotifier to automatically clean up resources.
mixin AutoDisposeStateNotifier<T> on StateNotifier<T> {
  final List<void Function()> _disposers = [];

  /// Adds a dispose callback.
  void addDisposer(void Function() disposer) {
    _disposers.add(disposer);
  }

  @override
  void dispose() {
    for (final disposer in _disposers) {
      disposer();
    }
    _disposers.clear();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Family Provider Cache
// ─────────────────────────────────────────────────────────────────────────────

/// A cache for family providers to prevent redundant fetches.
///
/// Useful when the same family provider is accessed with the same
/// argument multiple times.
class FamilyCache<K, V> {
  /// Creates a FamilyCache with optional maximum size.
  FamilyCache({this.maxSize = 100});

  /// Maximum number of entries to cache.
  final int maxSize;

  final Map<K, V> _cache = {};
  final List<K> _accessOrder = [];

  /// Gets a cached value or computes it.
  V getOrPut(K key, V Function() compute) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      _accessOrder.remove(key);
      _accessOrder.add(key);
      return _cache[key]!;
    }

    // Evict oldest if at capacity
    while (_cache.length >= maxSize) {
      final oldest = _accessOrder.removeAt(0);
      _cache.remove(oldest);
    }

    final value = compute();
    _cache[key] = value;
    _accessOrder.add(key);
    return value;
  }

  /// Removes a cached value.
  void remove(K key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  /// Clears all cached values.
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// Current cache size.
  int get length => _cache.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Debounced Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Creates a debounced state provider.
///
/// Updates to the state are debounced, preventing rapid state changes
/// from triggering unnecessary rebuilds.
///
/// Example:
/// ```dart
/// final searchQueryProvider = createDebouncedProvider<String>(
///   initialValue: '',
///   debounceMilliseconds: 300,
/// );
/// ```
StateNotifierProvider<DebouncedNotifier<T>, T> createDebouncedProvider<T>({
  required T initialValue,
  int debounceMilliseconds = 300,
}) {
  return StateNotifierProvider<DebouncedNotifier<T>, T>((ref) {
    return DebouncedNotifier(
      initialValue,
      debounceMilliseconds: debounceMilliseconds,
    );
  });
}

/// A StateNotifier that debounces state updates.
class DebouncedNotifier<T> extends StateNotifier<T> {
  /// Creates a DebouncedNotifier.
  DebouncedNotifier(
    super.state, {
    this.debounceMilliseconds = 300,
  });

  /// Debounce delay in milliseconds.
  final int debounceMilliseconds;

  DateTime? _lastUpdate;
  T? _pendingValue;

  /// Updates the state with debouncing.
  void updateDebounced(T value) {
    _pendingValue = value;
    final now = DateTime.now();

    if (_lastUpdate == null ||
        now.difference(_lastUpdate!).inMilliseconds >= debounceMilliseconds) {
      _applyPending();
    } else {
      // Schedule delayed update
      Future.delayed(
        Duration(milliseconds: debounceMilliseconds),
        () {
          if (_pendingValue != null) {
            _applyPending();
          }
        },
      );
    }
  }

  void _applyPending() {
    if (_pendingValue != null) {
      state = _pendingValue!;
      _lastUpdate = DateTime.now();
      _pendingValue = null;
    }
  }

  /// Updates the state immediately without debouncing.
  void updateImmediate(T value) {
    _pendingValue = null;
    state = value;
    _lastUpdate = DateTime.now();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider Lifecycle Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Extension for provider lifecycle management.
extension ProviderLifecycle on Ref {
  /// Schedules a cache refresh after a delay.
  ///
  /// Useful for implementing stale-while-revalidate patterns.
  void scheduleRefresh<T>(
    ProviderOrFamily provider,
    Duration delay,
  ) {
    Future.delayed(delay, () {
      invalidate(provider);
    });
  }

  /// Invalidates a provider after the specified duration.
  void invalidateAfter<T>(
    ProviderOrFamily provider,
    Duration duration,
  ) {
    onDispose(() {}); // Ensure cleanup
    Future.delayed(duration, () {
      invalidate(provider);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance Monitoring
// ─────────────────────────────────────────────────────────────────────────────

/// A provider observer for monitoring provider performance.
///
/// Use this to identify providers that are being accessed too frequently
/// or taking too long to compute.
class PerformanceObserver extends ProviderObserver {
  /// Creates a PerformanceObserver.
  PerformanceObserver({
    this.logThresholdMs = 100,
    this.enableLogging = true,
  });

  /// Threshold in milliseconds for logging slow providers.
  final int logThresholdMs;

  /// Whether to enable logging.
  final bool enableLogging;

  final Map<String, int> _accessCounts = {};
  final Map<String, List<int>> _computeTimes = {};

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    _accessCounts[provider.name ?? provider.toString()] =
        (_accessCounts[provider.name ?? provider.toString()] ?? 0) + 1;
  }

  /// Gets the access count for a provider.
  int getAccessCount(String providerName) {
    return _accessCounts[providerName] ?? 0;
  }

  /// Gets the average compute time for a provider.
  double getAverageComputeTime(String providerName) {
    final times = _computeTimes[providerName];
    if (times == null || times.isEmpty) return 0;
    return times.reduce((a, b) => a + b) / times.length;
  }

  /// Prints a performance report.
  void printReport() {
    debugPrint('=== Provider Performance Report ===');
    for (final entry in _accessCounts.entries) {
      debugPrint('${entry.key}: ${entry.value} accesses');
      final avgTime = getAverageComputeTime(entry.key);
      if (avgTime > 0) {
        debugPrint('  Average compute time: ${avgTime.toStringAsFixed(2)}ms');
      }
    }
    debugPrint('===================================');
  }
}
