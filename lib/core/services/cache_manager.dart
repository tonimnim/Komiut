/// Cache Manager - Generic caching with TTL and size management.
///
/// Provides a flexible caching system with:
/// - Time-to-live (TTL) expiration
/// - Maximum cache size management
/// - Persistent storage support
/// - Type-safe cache entries
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A cached entry with metadata.
class CacheEntry<T> {
  /// Creates a cache entry.
  const CacheEntry({
    required this.data,
    required this.cachedAt,
    required this.expiresAt,
    this.key,
  });

  /// Creates a cache entry from JSON.
  factory CacheEntry.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return CacheEntry(
      data: fromJson(json['data']),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      key: json['key'] as String?,
    );
  }

  /// The cached data.
  final T data;

  /// When the data was cached.
  final DateTime cachedAt;

  /// When the cache expires.
  final DateTime expiresAt;

  /// Cache key (for reference).
  final String? key;

  /// Whether the cache has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether the cache is still valid.
  bool get isValid => !isExpired;

  /// Age of the cache entry.
  Duration get age => DateTime.now().difference(cachedAt);

  /// Time until expiration.
  Duration get timeToLive => expiresAt.difference(DateTime.now());

  /// Convert to JSON.
  Map<String, dynamic> toJson(dynamic Function(T) toJsonFunc) {
    return {
      'data': toJsonFunc(data),
      'cachedAt': cachedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'key': key,
    };
  }

  @override
  String toString() {
    return 'CacheEntry(key: $key, age: ${age.inMinutes}m, expired: $isExpired)';
  }
}

/// Result of a cache retrieval operation.
class CacheResult<T> {
  /// Creates a cache result.
  const CacheResult({
    this.data,
    required this.isHit,
    required this.isStale,
    this.entry,
  });

  /// Creates a cache hit result.
  factory CacheResult.hit(CacheEntry<T> entry) {
    return CacheResult(
      data: entry.data,
      isHit: true,
      isStale: entry.isExpired,
      entry: entry,
    );
  }

  /// Creates a cache miss result.
  factory CacheResult.miss() {
    return const CacheResult(
      data: null,
      isHit: false,
      isStale: false,
      entry: null,
    );
  }

  /// The cached data (null if miss).
  final T? data;

  /// Whether the cache had data (even if stale).
  final bool isHit;

  /// Whether the data is stale (expired).
  final bool isStale;

  /// The full cache entry.
  final CacheEntry<T>? entry;

  /// Whether this is a fresh cache hit.
  bool get isFresh => isHit && !isStale;
}

/// Cache configuration options.
class CacheConfig {
  /// Creates cache configuration.
  const CacheConfig({
    this.defaultTtl = const Duration(hours: 1),
    this.maxEntries = 100,
    this.maxSizeBytes = 10 * 1024 * 1024, // 10 MB
    this.persistencePrefix = 'cache_',
    this.enablePersistence = true,
    this.cleanupInterval = const Duration(hours: 1),
  });

  /// Default time-to-live for cache entries.
  final Duration defaultTtl;

  /// Maximum number of entries in cache.
  final int maxEntries;

  /// Maximum total size in bytes.
  final int maxSizeBytes;

  /// Prefix for persistent storage keys.
  final String persistencePrefix;

  /// Whether to persist cache to storage.
  final bool enablePersistence;

  /// Interval for automatic cleanup.
  final Duration cleanupInterval;
}

/// Abstract cache manager interface.
abstract class CacheManager {
  /// Get a value from cache.
  Future<CacheResult<T>> get<T>(
    String key, {
    T Function(dynamic)? fromJson,
  });

  /// Set a value in cache.
  Future<void> set<T>(
    String key,
    T value, {
    Duration? ttl,
    dynamic Function(T)? toJson,
  });

  /// Remove a value from cache.
  Future<void> remove(String key);

  /// Clear all cache entries.
  Future<void> clear();

  /// Clear all expired entries.
  Future<void> clearExpired();

  /// Check if a key exists and is valid.
  Future<bool> has(String key);

  /// Get all cache keys.
  Future<List<String>> keys();

  /// Get cache statistics.
  CacheStats get stats;

  /// Initialize the cache manager.
  Future<void> initialize();

  /// Dispose resources.
  Future<void> dispose();
}

/// Cache statistics.
class CacheStats {
  /// Creates cache statistics.
  const CacheStats({
    required this.entryCount,
    required this.hitCount,
    required this.missCount,
    required this.estimatedSizeBytes,
  });

  /// Number of entries in cache.
  final int entryCount;

  /// Number of cache hits.
  final int hitCount;

  /// Number of cache misses.
  final int missCount;

  /// Estimated size in bytes.
  final int estimatedSizeBytes;

  /// Hit rate percentage.
  double get hitRate {
    final total = hitCount + missCount;
    if (total == 0) return 0;
    return hitCount / total * 100;
  }

  @override
  String toString() {
    return 'CacheStats(entries: $entryCount, hits: $hitCount, misses: $missCount, hitRate: ${hitRate.toStringAsFixed(1)}%)';
  }
}

/// Implementation of [CacheManager] with memory and persistence.
class CacheManagerImpl implements CacheManager {
  /// Creates a cache manager.
  CacheManagerImpl({
    this.config = const CacheConfig(),
    SharedPreferences? prefs,
  }) : _prefs = prefs;

  /// Cache configuration.
  final CacheConfig config;

  SharedPreferences? _prefs;

  // In-memory cache
  final Map<String, CacheEntry<dynamic>> _memoryCache = {};

  // Statistics
  int _hitCount = 0;
  int _missCount = 0;

  Timer? _cleanupTimer;

  @override
  Future<void> initialize() async {
    if (config.enablePersistence) {
      _prefs ??= await SharedPreferences.getInstance();
      await _loadFromPersistence();
    }

    // Start cleanup timer
    _cleanupTimer = Timer.periodic(config.cleanupInterval, (_) {
      clearExpired();
    });
  }

  @override
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
  }

  @override
  Future<CacheResult<T>> get<T>(
    String key, {
    T Function(dynamic)? fromJson,
  }) async {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      _hitCount++;

      if (entry.isExpired) {
        return CacheResult<T>.hit(CacheEntry<T>(
          data: entry.data as T,
          cachedAt: entry.cachedAt,
          expiresAt: entry.expiresAt,
          key: key,
        ));
      }

      return CacheResult<T>.hit(CacheEntry<T>(
        data: entry.data as T,
        cachedAt: entry.cachedAt,
        expiresAt: entry.expiresAt,
        key: key,
      ));
    }

    // Check persistent storage
    if (config.enablePersistence && _prefs != null) {
      final stored = _prefs!.getString('${config.persistencePrefix}$key');
      if (stored != null) {
        try {
          final json = jsonDecode(stored) as Map<String, dynamic>;
          final entry = CacheEntry<T>.fromJson(
            json,
            fromJson ?? (data) => data as T,
          );
          _hitCount++;

          // Restore to memory cache
          _memoryCache[key] = CacheEntry<dynamic>(
            data: entry.data,
            cachedAt: entry.cachedAt,
            expiresAt: entry.expiresAt,
            key: key,
          );

          return CacheResult<T>.hit(entry);
        } catch (e) {
          debugPrint('CacheManager: Error deserializing cache entry: $e');
        }
      }
    }

    _missCount++;
    return CacheResult<T>.miss();
  }

  @override
  Future<void> set<T>(
    String key,
    T value, {
    Duration? ttl,
    dynamic Function(T)? toJson,
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? config.defaultTtl);

    final entry = CacheEntry<T>(
      data: value,
      cachedAt: now,
      expiresAt: expiresAt,
      key: key,
    );

    // Store in memory
    _memoryCache[key] = CacheEntry<dynamic>(
      data: value,
      cachedAt: now,
      expiresAt: expiresAt,
      key: key,
    );

    // Persist if enabled
    if (config.enablePersistence && _prefs != null) {
      try {
        final json = entry.toJson(toJson ?? (data) => data);
        await _prefs!.setString(
          '${config.persistencePrefix}$key',
          jsonEncode(json),
        );
      } catch (e) {
        debugPrint('CacheManager: Error persisting cache entry: $e');
      }
    }

    // Enforce max entries
    await _enforceMaxEntries();
  }

  @override
  Future<void> remove(String key) async {
    _memoryCache.remove(key);

    if (config.enablePersistence && _prefs != null) {
      await _prefs!.remove('${config.persistencePrefix}$key');
    }
  }

  @override
  Future<void> clear() async {
    _memoryCache.clear();

    if (config.enablePersistence && _prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith(config.persistencePrefix)) {
          await _prefs!.remove(key);
        }
      }
    }

    _hitCount = 0;
    _missCount = 0;
  }

  @override
  Future<void> clearExpired() async {
    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      await remove(key);
    }

    debugPrint('CacheManager: Cleared ${expiredKeys.length} expired entries');
  }

  @override
  Future<bool> has(String key) async {
    if (_memoryCache.containsKey(key)) {
      return !_memoryCache[key]!.isExpired;
    }

    if (config.enablePersistence && _prefs != null) {
      return _prefs!.containsKey('${config.persistencePrefix}$key');
    }

    return false;
  }

  @override
  Future<List<String>> keys() async {
    return _memoryCache.keys.toList();
  }

  @override
  CacheStats get stats {
    return CacheStats(
      entryCount: _memoryCache.length,
      hitCount: _hitCount,
      missCount: _missCount,
      estimatedSizeBytes: _estimateSize(),
    );
  }

  Future<void> _loadFromPersistence() async {
    if (_prefs == null) return;

    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith(config.persistencePrefix)) {
        final cacheKey = key.substring(config.persistencePrefix.length);
        final stored = _prefs!.getString(key);
        if (stored != null) {
          try {
            final json = jsonDecode(stored) as Map<String, dynamic>;
            final entry = CacheEntry<dynamic>.fromJson(json, (data) => data);

            if (!entry.isExpired) {
              _memoryCache[cacheKey] = entry;
            } else {
              // Clean up expired entries
              await _prefs!.remove(key);
            }
          } catch (e) {
            debugPrint('CacheManager: Error loading cached entry: $e');
          }
        }
      }
    }

    debugPrint('CacheManager: Loaded ${_memoryCache.length} entries from persistence');
  }

  Future<void> _enforceMaxEntries() async {
    if (_memoryCache.length <= config.maxEntries) return;

    // Sort by expiration time, remove oldest first
    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.expiresAt.compareTo(b.value.expiresAt));

    final toRemove = sortedEntries.length - config.maxEntries;
    for (var i = 0; i < toRemove; i++) {
      await remove(sortedEntries[i].key);
    }
  }

  int _estimateSize() {
    var size = 0;
    for (final entry in _memoryCache.values) {
      try {
        size += jsonEncode(entry.data).length;
      } catch (_) {
        size += 100; // Estimate for non-serializable data
      }
    }
    return size;
  }
}

/// Typed cache manager for specific data types.
class TypedCacheManager<T> {
  /// Creates a typed cache manager.
  TypedCacheManager({
    required CacheManager cacheManager,
    required this.keyPrefix,
    required this.fromJson,
    required this.toJson,
    this.defaultTtl,
  }) : _cache = cacheManager;

  final CacheManager _cache;

  /// Prefix for all keys in this typed cache.
  final String keyPrefix;

  /// Function to deserialize from JSON.
  final T Function(dynamic) fromJson;

  /// Function to serialize to JSON.
  final dynamic Function(T) toJson;

  /// Default TTL for this cache type.
  final Duration? defaultTtl;

  /// Get a value by key.
  Future<CacheResult<T>> get(String key) {
    return _cache.get<T>('$keyPrefix$key', fromJson: fromJson);
  }

  /// Set a value.
  Future<void> set(String key, T value, {Duration? ttl}) {
    return _cache.set<T>(
      '$keyPrefix$key',
      value,
      ttl: ttl ?? defaultTtl,
      toJson: toJson,
    );
  }

  /// Remove a value.
  Future<void> remove(String key) {
    return _cache.remove('$keyPrefix$key');
  }

  /// Clear all values with this prefix.
  Future<void> clear() async {
    final allKeys = await _cache.keys();
    for (final key in allKeys) {
      if (key.startsWith(keyPrefix)) {
        await _cache.remove(key);
      }
    }
  }
}
