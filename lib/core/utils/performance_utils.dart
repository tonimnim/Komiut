/// Performance Utilities.
///
/// Provides various utilities for optimizing app performance including
/// memoization, caching, and computational helpers.
library;

import 'dart:async';
import 'dart:collection';

export 'debounce.dart';
export 'throttle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Memoization
// ─────────────────────────────────────────────────────────────────────────────

/// A simple memoization cache for expensive computations.
///
/// Caches the results of function calls based on their arguments.
/// Results are cached indefinitely or until manually cleared.
///
/// Example:
/// ```dart
/// final memo = Memoizer<String, UserProfile>();
///
/// Future<UserProfile> getProfile(String userId) async {
///   return memo.get(userId, () => api.fetchProfile(userId));
/// }
/// ```
class Memoizer<K, V> {
  /// Creates a Memoizer with optional maximum cache size.
  Memoizer({this.maxSize});

  /// Maximum number of entries to cache. Null means unlimited.
  final int? maxSize;

  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  /// Gets a cached value or computes and caches it.
  V get(K key, V Function() compute) {
    if (_cache.containsKey(key)) {
      final value = _cache.remove(key)!;
      _cache[key] = value; // Move to end (LRU)
      return value;
    }

    final value = compute();
    _set(key, value);
    return value;
  }

  /// Gets a cached value or computes it asynchronously.
  Future<V> getAsync(K key, Future<V> Function() compute) async {
    if (_cache.containsKey(key)) {
      final value = _cache.remove(key)!;
      _cache[key] = value; // Move to end (LRU)
      return value;
    }

    final value = await compute();
    _set(key, value);
    return value;
  }

  void _set(K key, V value) {
    // Enforce max size using LRU eviction
    if (maxSize != null && _cache.length >= maxSize!) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Checks if a key is cached.
  bool contains(K key) => _cache.containsKey(key);

  /// Gets a cached value without computing.
  V? peek(K key) => _cache[key];

  /// Removes a cached value.
  V? remove(K key) => _cache.remove(key);

  /// Clears all cached values.
  void clear() => _cache.clear();

  /// Current cache size.
  int get size => _cache.length;

  /// All cached keys.
  Iterable<K> get keys => _cache.keys;
}

/// A time-based memoization cache.
///
/// Cached values expire after the specified duration.
///
/// Example:
/// ```dart
/// final cache = TimedMemoizer<String, WeatherData>(
///   duration: Duration(minutes: 5),
/// );
///
/// Future<WeatherData> getWeather(String city) async {
///   return cache.get(city, () => api.fetchWeather(city));
/// }
/// ```
class TimedMemoizer<K, V> {
  /// Creates a TimedMemoizer with the specified expiration duration.
  TimedMemoizer({
    required this.duration,
    this.maxSize,
  });

  /// How long values remain valid.
  final Duration duration;

  /// Maximum number of entries to cache.
  final int? maxSize;

  final LinkedHashMap<K, _TimedEntry<V>> _cache =
      LinkedHashMap<K, _TimedEntry<V>>();

  /// Gets a cached value or computes and caches it.
  V get(K key, V Function() compute) {
    _evictExpired();

    if (_cache.containsKey(key)) {
      final entry = _cache.remove(key)!;
      if (!entry.isExpired) {
        _cache[key] = entry; // Move to end (LRU)
        return entry.value;
      }
    }

    final value = compute();
    _set(key, value);
    return value;
  }

  /// Gets a cached value or computes it asynchronously.
  Future<V> getAsync(K key, Future<V> Function() compute) async {
    _evictExpired();

    if (_cache.containsKey(key)) {
      final entry = _cache.remove(key)!;
      if (!entry.isExpired) {
        _cache[key] = entry; // Move to end (LRU)
        return entry.value;
      }
    }

    final value = await compute();
    _set(key, value);
    return value;
  }

  void _set(K key, V value) {
    // Enforce max size using LRU eviction
    if (maxSize != null && _cache.length >= maxSize!) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = _TimedEntry(value, DateTime.now().add(duration));
  }

  void _evictExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  /// Checks if a key is cached and not expired.
  bool contains(K key) {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }

  /// Refreshes a cached value's expiration time.
  void refresh(K key) {
    final entry = _cache[key];
    if (entry != null) {
      _cache[key] = _TimedEntry(entry.value, DateTime.now().add(duration));
    }
  }

  /// Removes a cached value.
  V? remove(K key) => _cache.remove(key)?.value;

  /// Clears all cached values.
  void clear() => _cache.clear();

  /// Current cache size (including expired entries).
  int get size => _cache.length;

  /// Number of valid (non-expired) entries.
  int get validSize {
    _evictExpired();
    return _cache.length;
  }
}

class _TimedEntry<V> {
  const _TimedEntry(this.value, this.expiresAt);

  final V value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// ─────────────────────────────────────────────────────────────────────────────
// Compute Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Runs a computation and returns its duration.
///
/// Useful for profiling and performance measurement.
///
/// Example:
/// ```dart
/// final (result, duration) = await measureAsync(() => heavyComputation());
/// print('Took ${duration.inMilliseconds}ms');
/// ```
Future<(T, Duration)> measureAsync<T>(Future<T> Function() computation) async {
  final stopwatch = Stopwatch()..start();
  final result = await computation();
  stopwatch.stop();
  return (result, stopwatch.elapsed);
}

/// Synchronous version of [measureAsync].
(T, Duration) measure<T>(T Function() computation) {
  final stopwatch = Stopwatch()..start();
  final result = computation();
  stopwatch.stop();
  return (result, stopwatch.elapsed);
}

/// Splits a list into chunks for batch processing.
///
/// Useful for processing large lists in smaller batches to avoid
/// blocking the main thread.
///
/// Example:
/// ```dart
/// final items = List.generate(1000, (i) => i);
/// for (final batch in chunk(items, 100)) {
///   await processBatch(batch);
///   await Future.delayed(Duration.zero); // Yield to event loop
/// }
/// ```
Iterable<List<T>> chunk<T>(List<T> list, int size) sync* {
  for (var i = 0; i < list.length; i += size) {
    yield list.sublist(i, (i + size).clamp(0, list.length));
  }
}

/// Processes items in batches with optional delay between batches.
///
/// Yields to the event loop between batches to keep the UI responsive.
Future<List<R>> batchProcess<T, R>(
  List<T> items,
  Future<R> Function(T item) processor, {
  int batchSize = 10,
  Duration delay = Duration.zero,
}) async {
  final results = <R>[];

  for (final batch in chunk(items, batchSize)) {
    for (final item in batch) {
      results.add(await processor(item));
    }
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    } else {
      await Future.delayed(Duration.zero); // Yield to event loop
    }
  }

  return results;
}

// ─────────────────────────────────────────────────────────────────────────────
// Memory Management
// ─────────────────────────────────────────────────────────────────────────────

/// A cache that limits memory usage by size.
///
/// Evicts oldest entries when the cache exceeds the specified size.
class LRUCache<K, V> {
  /// Creates an LRU cache with the specified maximum size.
  LRUCache(this.maxSize) : assert(maxSize > 0);

  /// Maximum number of entries.
  final int maxSize;

  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  /// Gets a value from the cache.
  V? get(K key) {
    if (!_cache.containsKey(key)) return null;

    // Move to end (most recently used)
    final value = _cache.remove(key)!;
    _cache[key] = value;
    return value;
  }

  /// Sets a value in the cache.
  void set(K key, V value) {
    // Remove if exists (to update order)
    _cache.remove(key);

    // Evict oldest if at capacity
    while (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = value;
  }

  /// Gets or computes a value.
  V getOrPut(K key, V Function() ifAbsent) {
    final existing = get(key);
    if (existing != null) return existing;

    final value = ifAbsent();
    set(key, value);
    return value;
  }

  /// Removes a value from the cache.
  V? remove(K key) => _cache.remove(key);

  /// Clears the cache.
  void clear() => _cache.clear();

  /// Current cache size.
  int get length => _cache.length;

  /// Whether the cache contains a key.
  bool containsKey(K key) => _cache.containsKey(key);

  /// All keys in the cache (oldest first).
  Iterable<K> get keys => _cache.keys;

  /// All values in the cache (oldest first).
  Iterable<V> get values => _cache.values;
}

/// A weak reference cache that allows garbage collection.
///
/// Uses WeakReference to hold values, allowing them to be garbage
/// collected when memory is low.
class WeakCache<K, V extends Object> {
  final Map<K, WeakReference<V>> _cache = {};

  /// Gets a value if still available.
  V? get(K key) {
    final ref = _cache[key];
    if (ref == null) return null;

    final value = ref.target;
    if (value == null) {
      // Reference was garbage collected
      _cache.remove(key);
      return null;
    }

    return value;
  }

  /// Sets a value in the cache.
  void set(K key, V value) {
    _cache[key] = WeakReference(value);
  }

  /// Gets or computes a value.
  V getOrPut(K key, V Function() ifAbsent) {
    final existing = get(key);
    if (existing != null) return existing;

    final value = ifAbsent();
    set(key, value);
    return value;
  }

  /// Removes a value from the cache.
  void remove(K key) => _cache.remove(key);

  /// Clears the cache.
  void clear() => _cache.clear();

  /// Cleans up garbage-collected entries.
  void cleanup() {
    _cache.removeWhere((_, ref) => ref.target == null);
  }

  /// Number of entries (may include garbage-collected ones).
  int get length => _cache.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Deferred Computation
// ─────────────────────────────────────────────────────────────────────────────

/// A lazy value that is computed only when first accessed.
///
/// Useful for expensive computations that may not always be needed.
class Lazy<T> {
  /// Creates a Lazy value with the given computation.
  Lazy(this._compute);

  final T Function() _compute;
  T? _value;
  bool _isComputed = false;

  /// Gets the value, computing it if necessary.
  T get value {
    if (!_isComputed) {
      _value = _compute();
      _isComputed = true;
    }
    return _value as T;
  }

  /// Whether the value has been computed.
  bool get isComputed => _isComputed;

  /// Resets the lazy value to be recomputed on next access.
  void reset() {
    _value = null;
    _isComputed = false;
  }
}

/// An async lazy value.
class AsyncLazy<T> {
  /// Creates an AsyncLazy value.
  AsyncLazy(this._compute);

  final Future<T> Function() _compute;
  Future<T>? _future;
  T? _value;
  bool _isComputed = false;

  /// Gets the value, computing it if necessary.
  Future<T> get value async {
    if (_isComputed) return _value as T;

    _future ??= _compute().then((value) {
      _value = value;
      _isComputed = true;
      return value;
    });

    return _future!;
  }

  /// Whether the value has been computed.
  bool get isComputed => _isComputed;

  /// The cached value, if computed.
  T? get cachedValue => _isComputed ? _value : null;

  /// Resets the lazy value.
  void reset() {
    _value = null;
    _isComputed = false;
    _future = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rate Limiting
// ─────────────────────────────────────────────────────────────────────────────

/// A rate limiter that enforces a maximum number of operations per time window.
///
/// Useful for API rate limiting and preventing abuse.
class RateLimiter {
  /// Creates a RateLimiter.
  RateLimiter({
    required this.maxOperations,
    required this.window,
  });

  /// Maximum operations allowed within the window.
  final int maxOperations;

  /// Time window for rate limiting.
  final Duration window;

  final List<DateTime> _timestamps = [];

  /// Checks if an operation is allowed.
  bool get canProceed {
    _cleanup();
    return _timestamps.length < maxOperations;
  }

  /// Records an operation and returns whether it was allowed.
  bool tryProceed() {
    if (!canProceed) return false;
    _timestamps.add(DateTime.now());
    return true;
  }

  /// Time until the next operation is allowed.
  Duration get timeUntilAllowed {
    _cleanup();
    if (_timestamps.length < maxOperations) return Duration.zero;

    final oldest = _timestamps.first;
    final elapsed = DateTime.now().difference(oldest);
    return window - elapsed;
  }

  void _cleanup() {
    final cutoff = DateTime.now().subtract(window);
    _timestamps.removeWhere((t) => t.isBefore(cutoff));
  }

  /// Resets the rate limiter.
  void reset() => _timestamps.clear();
}
