/// Sync Queue Service - Offline action queueing and synchronization.
///
/// Provides a queue system for:
/// - Storing actions when offline
/// - Processing queue when back online
/// - Handling conflicts and retries
/// - Persisting queue to storage
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connectivity_service.dart';

/// Priority levels for queued actions.
enum SyncPriority {
  /// High priority - process first.
  high,

  /// Normal priority.
  normal,

  /// Low priority - process last.
  low,
}

/// Status of a sync action.
enum SyncStatus {
  /// Waiting to be processed.
  pending,

  /// Currently being processed.
  processing,

  /// Successfully completed.
  completed,

  /// Failed after all retries.
  failed,

  /// Cancelled by user.
  cancelled,
}

/// A queued action for offline sync.
class SyncAction {
  /// Creates a sync action.
  SyncAction({
    required this.id,
    required this.type,
    required this.payload,
    this.priority = SyncPriority.normal,
    this.maxRetries = 3,
    DateTime? createdAt,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.lastError,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Creates a sync action from JSON.
  factory SyncAction.fromJson(Map<String, dynamic> json) {
    return SyncAction(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      priority: SyncPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => SyncPriority.normal,
      ),
      maxRetries: json['maxRetries'] as int? ?? 3,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: SyncStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      retryCount: json['retryCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
    );
  }

  /// Unique identifier for this action.
  final String id;

  /// Type of action (e.g., 'booking', 'payment').
  final String type;

  /// Action payload data.
  final Map<String, dynamic> payload;

  /// Priority level.
  final SyncPriority priority;

  /// Maximum number of retry attempts.
  final int maxRetries;

  /// When the action was created.
  final DateTime createdAt;

  /// Current status.
  SyncStatus status;

  /// Number of retry attempts made.
  int retryCount;

  /// Last error message if failed.
  String? lastError;

  /// Whether more retries are available.
  bool get canRetry => retryCount < maxRetries;

  /// Age of the action.
  Duration get age => DateTime.now().difference(createdAt);

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'payload': payload,
      'priority': priority.name,
      'maxRetries': maxRetries,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'retryCount': retryCount,
      'lastError': lastError,
    };
  }

  /// Create a copy with updated fields.
  SyncAction copyWith({
    SyncStatus? status,
    int? retryCount,
    String? lastError,
  }) {
    return SyncAction(
      id: id,
      type: type,
      payload: payload,
      priority: priority,
      maxRetries: maxRetries,
      createdAt: createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  String toString() {
    return 'SyncAction(id: $id, type: $type, status: $status, retries: $retryCount/$maxRetries)';
  }
}

/// Result of processing a sync action.
class SyncResult {
  /// Creates a sync result.
  const SyncResult({
    required this.success,
    this.data,
    this.error,
    this.shouldRetry = false,
  });

  /// Creates a success result.
  factory SyncResult.success([dynamic data]) {
    return SyncResult(success: true, data: data);
  }

  /// Creates a failure result.
  factory SyncResult.failure(String error, {bool shouldRetry = true}) {
    return SyncResult(success: false, error: error, shouldRetry: shouldRetry);
  }

  /// Whether the action succeeded.
  final bool success;

  /// Result data if successful.
  final dynamic data;

  /// Error message if failed.
  final String? error;

  /// Whether the action should be retried.
  final bool shouldRetry;
}

/// Handler for processing sync actions.
typedef SyncActionHandler = Future<SyncResult> Function(SyncAction action);

/// Callback for sync events.
typedef SyncEventCallback = void Function(
    SyncAction action, SyncResult? result);

/// Configuration for sync queue.
class SyncQueueConfig {
  /// Creates sync queue configuration.
  const SyncQueueConfig({
    this.storageKey = 'sync_queue',
    this.processingInterval = const Duration(seconds: 5),
    this.maxConcurrent = 1,
    this.retryDelay = const Duration(seconds: 10),
    this.maxQueueAge = const Duration(days: 7),
  });

  /// Key for persistent storage.
  final String storageKey;

  /// Interval between processing attempts.
  final Duration processingInterval;

  /// Maximum concurrent processing.
  final int maxConcurrent;

  /// Delay between retries.
  final Duration retryDelay;

  /// Maximum age of queued actions.
  final Duration maxQueueAge;
}

/// Abstract sync queue service interface.
abstract class SyncQueueService {
  /// Stream of queue changes.
  Stream<List<SyncAction>> get onQueueChanged;

  /// Current queue.
  List<SyncAction> get queue;

  /// Number of pending actions.
  int get pendingCount;

  /// Whether the queue is currently processing.
  bool get isProcessing;

  /// Initialize the service.
  Future<void> initialize();

  /// Dispose resources.
  Future<void> dispose();

  /// Add an action to the queue.
  Future<void> enqueue(SyncAction action);

  /// Remove an action from the queue.
  Future<void> remove(String actionId);

  /// Cancel an action (mark as cancelled).
  Future<void> cancel(String actionId);

  /// Clear all completed/failed actions.
  Future<void> clearCompleted();

  /// Clear entire queue.
  Future<void> clearAll();

  /// Register a handler for an action type.
  void registerHandler(String type, SyncActionHandler handler);

  /// Process the queue now.
  Future<void> processQueue();

  /// Get actions by status.
  List<SyncAction> getByStatus(SyncStatus status);

  /// Get actions by type.
  List<SyncAction> getByType(String type);
}

/// Implementation of [SyncQueueService].
class SyncQueueServiceImpl implements SyncQueueService {
  /// Creates a sync queue service.
  SyncQueueServiceImpl({
    required ConnectivityService connectivityService,
    this.config = const SyncQueueConfig(),
    SharedPreferences? prefs,
  })  : _connectivity = connectivityService,
        _prefs = prefs;

  final ConnectivityService _connectivity;
  final SyncQueueConfig config;
  SharedPreferences? _prefs;

  final List<SyncAction> _queue = [];
  final Map<String, SyncActionHandler> _handlers = {};
  final _queueController = StreamController<List<SyncAction>>.broadcast();

  StreamSubscription<ConnectionState>? _connectivitySubscription;
  Timer? _processingTimer;
  bool _isProcessing = false;

  @override
  Stream<List<SyncAction>> get onQueueChanged => _queueController.stream;

  @override
  List<SyncAction> get queue => List.unmodifiable(_queue);

  @override
  int get pendingCount =>
      _queue.where((a) => a.status == SyncStatus.pending).length;

  @override
  bool get isProcessing => _isProcessing;

  @override
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();

    // Load persisted queue
    await _loadQueue();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectionStateChanged.listen(
      (state) {
        if (state.isOnline && pendingCount > 0) {
          processQueue();
        }
      },
    );

    // Start processing timer
    _processingTimer = Timer.periodic(config.processingInterval, (_) {
      if (_connectivity.isOnline && pendingCount > 0) {
        processQueue();
      }
    });

    // Clean old actions
    await _cleanOldActions();
  }

  @override
  Future<void> dispose() async {
    _processingTimer?.cancel();
    await _connectivitySubscription?.cancel();
    await _queueController.close();
  }

  @override
  Future<void> enqueue(SyncAction action) async {
    // Check for duplicates
    if (_queue.any((a) => a.id == action.id)) {
      debugPrint('SyncQueue: Action ${action.id} already in queue');
      return;
    }

    _queue.add(action);
    _sortQueue();
    await _persistQueue();
    _notifyQueueChanged();

    debugPrint('SyncQueue: Enqueued action ${action.id} (${action.type})');

    // Try to process immediately if online
    if (_connectivity.isOnline) {
      processQueue();
    }
  }

  @override
  Future<void> remove(String actionId) async {
    _queue.removeWhere((a) => a.id == actionId);
    await _persistQueue();
    _notifyQueueChanged();
  }

  @override
  Future<void> cancel(String actionId) async {
    final index = _queue.indexWhere((a) => a.id == actionId);
    if (index != -1) {
      _queue[index] = _queue[index].copyWith(status: SyncStatus.cancelled);
      await _persistQueue();
      _notifyQueueChanged();
    }
  }

  @override
  Future<void> clearCompleted() async {
    _queue.removeWhere(
      (a) =>
          a.status == SyncStatus.completed ||
          a.status == SyncStatus.failed ||
          a.status == SyncStatus.cancelled,
    );
    await _persistQueue();
    _notifyQueueChanged();
  }

  @override
  Future<void> clearAll() async {
    _queue.clear();
    await _persistQueue();
    _notifyQueueChanged();
  }

  @override
  void registerHandler(String type, SyncActionHandler handler) {
    _handlers[type] = handler;
    debugPrint('SyncQueue: Registered handler for type: $type');
  }

  @override
  Future<void> processQueue() async {
    if (_isProcessing || !_connectivity.isOnline) return;

    final pendingActions = _queue
        .where((a) => a.status == SyncStatus.pending)
        .take(config.maxConcurrent)
        .toList();

    if (pendingActions.isEmpty) return;

    _isProcessing = true;

    for (final action in pendingActions) {
      await _processAction(action);
    }

    _isProcessing = false;
    await _persistQueue();
    _notifyQueueChanged();
  }

  @override
  List<SyncAction> getByStatus(SyncStatus status) {
    return _queue.where((a) => a.status == status).toList();
  }

  @override
  List<SyncAction> getByType(String type) {
    return _queue.where((a) => a.type == type).toList();
  }

  Future<void> _processAction(SyncAction action) async {
    final handler = _handlers[action.type];

    if (handler == null) {
      debugPrint('SyncQueue: No handler registered for type: ${action.type}');
      action.status = SyncStatus.failed;
      action.lastError = 'No handler registered for action type';
      return;
    }

    action.status = SyncStatus.processing;
    _notifyQueueChanged();

    try {
      final result = await handler(action);

      if (result.success) {
        action.status = SyncStatus.completed;
        debugPrint('SyncQueue: Action ${action.id} completed successfully');
      } else if (result.shouldRetry && action.canRetry) {
        action.retryCount++;
        action.status = SyncStatus.pending;
        action.lastError = result.error;
        debugPrint(
          'SyncQueue: Action ${action.id} failed, will retry (${action.retryCount}/${action.maxRetries})',
        );
      } else {
        action.status = SyncStatus.failed;
        action.lastError = result.error;
        debugPrint(
            'SyncQueue: Action ${action.id} failed permanently: ${result.error}');
      }
    } catch (e) {
      if (action.canRetry) {
        action.retryCount++;
        action.status = SyncStatus.pending;
        action.lastError = e.toString();
      } else {
        action.status = SyncStatus.failed;
        action.lastError = e.toString();
      }
      debugPrint('SyncQueue: Action ${action.id} threw error: $e');
    }
  }

  void _sortQueue() {
    _queue.sort((a, b) {
      // Sort by priority first (high to low)
      final priorityCompare = a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) return priorityCompare;

      // Then by creation time (oldest first)
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  Future<void> _loadQueue() async {
    if (_prefs == null) return;

    final stored = _prefs!.getString(config.storageKey);
    if (stored == null) return;

    try {
      final list = jsonDecode(stored) as List<dynamic>;
      _queue.clear();
      for (final item in list) {
        final action = SyncAction.fromJson(item as Map<String, dynamic>);
        // Reset processing actions to pending
        if (action.status == SyncStatus.processing) {
          _queue.add(action.copyWith(status: SyncStatus.pending));
        } else {
          _queue.add(action);
        }
      }
      debugPrint('SyncQueue: Loaded ${_queue.length} actions from storage');
    } catch (e) {
      debugPrint('SyncQueue: Error loading queue: $e');
    }
  }

  Future<void> _persistQueue() async {
    if (_prefs == null) return;

    try {
      final json = _queue.map((a) => a.toJson()).toList();
      await _prefs!.setString(config.storageKey, jsonEncode(json));
    } catch (e) {
      debugPrint('SyncQueue: Error persisting queue: $e');
    }
  }

  Future<void> _cleanOldActions() async {
    final now = DateTime.now();
    _queue.removeWhere(
      (a) =>
          (a.status == SyncStatus.completed ||
              a.status == SyncStatus.failed ||
              a.status == SyncStatus.cancelled) &&
          now.difference(a.createdAt) > config.maxQueueAge,
    );
    await _persistQueue();
  }

  void _notifyQueueChanged() {
    _queueController.add(List.unmodifiable(_queue));
  }
}

/// Helper to generate unique action IDs.
class SyncActionId {
  const SyncActionId._();

  static int _counter = 0;

  /// Generate a unique action ID.
  static String generate(String type) {
    _counter++;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${type}_${timestamp}_$_counter';
  }
}
