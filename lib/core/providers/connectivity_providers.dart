/// Connectivity Providers - State management for network connectivity.
///
/// Provides Riverpod providers for:
/// - Connectivity service instance
/// - Online/offline state streams
/// - Connection type information
/// - Network quality assessment
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cache_manager.dart';
import '../services/connectivity_service.dart';
import '../services/sync_queue_service.dart';

/// Provider for the connectivity service instance.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityServiceImpl();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for initializing connectivity service.
///
/// Must be awaited before using other connectivity providers.
final connectivityInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(connectivityServiceProvider);
  await service.initialize();
});

/// Stream provider for connection state changes.
final connectionStateProvider = StreamProvider<ConnectionState>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectionStateChanged;
});

/// Provider for current connection state.
final currentConnectionStateProvider = Provider<ConnectionState>((ref) {
  final asyncState = ref.watch(connectionStateProvider);
  return asyncState.whenData((state) => state).value ??
      ref.read(connectivityServiceProvider).currentState;
});

/// Stream provider for online status.
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectionStateChanged.map((state) => state.isOnline);
});

/// Provider for current online status (synchronous access).
final isOnlineStateProvider = Provider<bool>((ref) {
  final asyncState = ref.watch(isOnlineProvider);
  return asyncState.whenData((isOnline) => isOnline).value ??
      ref.read(connectivityServiceProvider).isOnline;
});

/// Provider for connection type.
final connectionTypeProvider = Provider<ConnectionType>((ref) {
  final state = ref.watch(currentConnectionStateProvider);
  return state.connectionType;
});

/// Provider for network quality.
final networkQualityProvider = Provider<NetworkQuality>((ref) {
  final state = ref.watch(currentConnectionStateProvider);
  return state.networkQuality;
});

/// Provider for whether connection is stable enough for important operations.
final isConnectionStableProvider = Provider<bool>((ref) {
  final state = ref.watch(currentConnectionStateProvider);
  return state.isStable;
});

/// Provider for connection type label.
final connectionTypeLabelProvider = Provider<String>((ref) {
  final type = ref.watch(connectionTypeProvider);
  return switch (type) {
    ConnectionType.wifi => 'WiFi',
    ConnectionType.mobile => 'Mobile Data',
    ConnectionType.ethernet => 'Ethernet',
    ConnectionType.none => 'No Connection',
  };
});

/// Provider for network quality label.
final networkQualityLabelProvider = Provider<String>((ref) {
  final quality = ref.watch(networkQualityProvider);
  return switch (quality) {
    NetworkQuality.good => 'Good',
    NetworkQuality.poor => 'Poor',
    NetworkQuality.none => 'No Connection',
  };
});

// ============================================================================
// Cache Manager Providers
// ============================================================================

/// Provider for cache configuration.
final cacheConfigProvider = Provider<CacheConfig>((ref) {
  return const CacheConfig(
    defaultTtl: Duration(hours: 1),
    maxEntries: 200,
    enablePersistence: true,
    cleanupInterval: Duration(hours: 2),
  );
});

/// Provider for cache manager instance.
final cacheManagerProvider = Provider<CacheManager>((ref) {
  final config = ref.watch(cacheConfigProvider);
  final manager = CacheManagerImpl(config: config);

  ref.onDispose(() {
    manager.dispose();
  });

  return manager;
});

/// Provider for initializing cache manager.
final cacheInitProvider = FutureProvider<void>((ref) async {
  final manager = ref.watch(cacheManagerProvider);
  await manager.initialize();
});

/// Provider for cache statistics.
final cacheStatsProvider = Provider<CacheStats>((ref) {
  final manager = ref.watch(cacheManagerProvider);
  return manager.stats;
});

// ============================================================================
// Sync Queue Providers
// ============================================================================

/// Provider for sync queue configuration.
final syncQueueConfigProvider = Provider<SyncQueueConfig>((ref) {
  return const SyncQueueConfig(
    processingInterval: Duration(seconds: 10),
    maxConcurrent: 2,
    retryDelay: Duration(seconds: 30),
  );
});

/// Provider for sync queue service instance.
final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final config = ref.watch(syncQueueConfigProvider);

  final service = SyncQueueServiceImpl(
    connectivityService: connectivity,
    config: config,
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for initializing sync queue.
final syncQueueInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(syncQueueServiceProvider);
  await service.initialize();
});

/// Stream provider for sync queue changes.
final syncQueueProvider = StreamProvider<List<SyncAction>>((ref) {
  final service = ref.watch(syncQueueServiceProvider);
  return service.onQueueChanged;
});

/// Provider for pending sync action count.
final pendingSyncCountProvider = Provider<int>((ref) {
  final asyncQueue = ref.watch(syncQueueProvider);
  return asyncQueue.whenData((queue) {
    return queue.where((a) => a.status == SyncStatus.pending).length;
  }).value ?? ref.read(syncQueueServiceProvider).pendingCount;
});

/// Provider for whether there are pending sync actions.
final hasPendingSyncProvider = Provider<bool>((ref) {
  return ref.watch(pendingSyncCountProvider) > 0;
});

/// Provider for whether sync queue is processing.
final isSyncProcessingProvider = Provider<bool>((ref) {
  final service = ref.watch(syncQueueServiceProvider);
  return service.isProcessing;
});

// ============================================================================
// Combined Offline Status Providers
// ============================================================================

/// Offline status with sync queue information.
class OfflineStatus {
  /// Creates offline status.
  const OfflineStatus({
    required this.isOnline,
    required this.connectionType,
    required this.networkQuality,
    required this.pendingSyncCount,
    required this.isSyncing,
  });

  /// Whether currently online.
  final bool isOnline;

  /// Type of connection.
  final ConnectionType connectionType;

  /// Quality of network.
  final NetworkQuality networkQuality;

  /// Number of pending sync actions.
  final int pendingSyncCount;

  /// Whether currently syncing.
  final bool isSyncing;

  /// Whether there are pending actions.
  bool get hasPendingActions => pendingSyncCount > 0;

  /// Status message for display.
  String get statusMessage {
    if (!isOnline) {
      if (hasPendingActions) {
        return 'Offline - $pendingSyncCount actions pending';
      }
      return 'Offline';
    }
    if (isSyncing) {
      return 'Syncing...';
    }
    if (hasPendingActions) {
      return 'Syncing $pendingSyncCount actions...';
    }
    return 'Online';
  }
}

/// Provider for combined offline status.
final offlineStatusProvider = Provider<OfflineStatus>((ref) {
  final state = ref.watch(currentConnectionStateProvider);
  final pendingCount = ref.watch(pendingSyncCountProvider);
  final isSyncing = ref.watch(isSyncProcessingProvider);

  return OfflineStatus(
    isOnline: state.isOnline,
    connectionType: state.connectionType,
    networkQuality: state.networkQuality,
    pendingSyncCount: pendingCount,
    isSyncing: isSyncing,
  );
});

// ============================================================================
// Initialization Provider
// ============================================================================

/// Provider for initializing all offline services.
///
/// Call this during app startup:
/// ```dart
/// await ref.read(offlineServicesInitProvider.future);
/// ```
final offlineServicesInitProvider = FutureProvider<void>((ref) async {
  // Initialize in order
  await ref.watch(connectivityInitProvider.future);
  await ref.watch(cacheInitProvider.future);
  await ref.watch(syncQueueInitProvider.future);
});
