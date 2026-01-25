/// Real-time queue providers.
///
/// Provides real-time queue updates using StreamProvider and combines
/// HTTP data with WebSocket updates for live queue information.
///
/// Usage:
/// ```dart
/// // Watch queue state
/// final queueState = ref.watch(queueStreamProvider(routeId));
///
/// // Watch connection status
/// final connectionState = ref.watch(queueConnectionStateProvider(routeId));
///
/// // Subscribe to queue updates
/// ref.read(subscribeToQueueProvider(routeId));
/// ```
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import 'queue_update_handler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Real-time Service Stub
// ─────────────────────────────────────────────────────────────────────────────

/// Stub for the real-time service.
///
/// This will be replaced by the actual real-time service from
/// `lib/core/network/realtime/` when it's available.
///
/// The stub provides mock data and simulated real-time updates for
/// development and testing purposes.
class RealtimeServiceStub {
  /// Creates a new RealtimeServiceStub.
  RealtimeServiceStub();

  final _connectionController =
      StreamController<QueueConnectionState>.broadcast();
  final _eventControllers = <String, StreamController<QueueEvent>>{};
  final _activeSubscriptions = <String>{};

  Timer? _mockUpdateTimer;

  /// Stream of connection state changes.
  Stream<QueueConnectionState> get connectionStream =>
      _connectionController.stream;

  /// Subscribe to queue events for a route.
  Stream<QueueEvent> subscribeToQueue(String routeId) {
    if (!_eventControllers.containsKey(routeId)) {
      _eventControllers[routeId] = StreamController<QueueEvent>.broadcast();
    }

    if (!_activeSubscriptions.contains(routeId)) {
      _activeSubscriptions.add(routeId);
      _startMockUpdates(routeId);
    }

    return _eventControllers[routeId]!.stream;
  }

  /// Unsubscribe from queue events for a route.
  void unsubscribeFromQueue(String routeId) {
    _activeSubscriptions.remove(routeId);
    _eventControllers[routeId]?.close();
    _eventControllers.remove(routeId);
  }

  /// Connect to the real-time service.
  Future<void> connect() async {
    _connectionController.add(QueueConnectionState.connecting);
    // Simulate connection delay
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _connectionController.add(QueueConnectionState.connected);
  }

  /// Disconnect from the real-time service.
  Future<void> disconnect() async {
    _mockUpdateTimer?.cancel();
    _connectionController.add(QueueConnectionState.disconnected);
  }

  /// Get initial queue data via HTTP.
  Future<List<QueueVehicle>> getQueueVehicles(String routeId) async {
    // Simulate API delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Return mock data
    return _generateMockVehicles(routeId);
  }

  /// Start sending mock updates for testing.
  void _startMockUpdates(String routeId) {
    // Send initial sync event
    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
      if (_eventControllers.containsKey(routeId)) {
        _eventControllers[routeId]!.add(
          QueueSyncedEvent(
            routeId: routeId,
            timestamp: DateTime.now(),
            vehicles: _generateMockVehicles(routeId),
          ),
        );
      }
    });

    // Periodically send mock updates (every 10 seconds)
    _mockUpdateTimer?.cancel();
    _mockUpdateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        if (!_activeSubscriptions.contains(routeId)) {
          timer.cancel();
          return;
        }
        _sendMockUpdate(routeId);
      },
    );
  }

  void _sendMockUpdate(String routeId) {
    if (!_eventControllers.containsKey(routeId)) return;

    // Randomly choose an update type
    final random = DateTime.now().millisecondsSinceEpoch % 3;

    switch (random) {
      case 0:
        // Seat count change
        _eventControllers[routeId]!.add(
          VehicleSeatCountChangedEvent(
            routeId: routeId,
            timestamp: DateTime.now(),
            vehicleId: 'vehicle-1',
            oldSeatCount: 10,
            newSeatCount: 9,
          ),
        );
        break;
      case 1:
        // Position change
        _eventControllers[routeId]!.add(
          VehiclePositionChangedEvent(
            routeId: routeId,
            timestamp: DateTime.now(),
            vehicleId: 'vehicle-2',
            oldPosition: 2,
            newPosition: 1,
          ),
        );
        break;
      case 2:
        // Status change
        _eventControllers[routeId]!.add(
          VehicleStatusChangedEvent(
            routeId: routeId,
            timestamp: DateTime.now(),
            vehicleId: 'vehicle-1',
            oldStatus: QueueVehicleStatus.waiting,
            newStatus: QueueVehicleStatus.boarding,
          ),
        );
        break;
    }
  }

  List<QueueVehicle> _generateMockVehicles(String routeId) {
    return [
      QueueVehicle(
        id: 'queue-1',
        vehicleId: 'vehicle-1',
        registrationNumber: 'KBZ 123A',
        routeId: routeId,
        position: 1,
        status: QueueVehicleStatus.boarding,
        totalSeats: 14,
        availableSeats: 6,
        driverName: 'John Kamau',
        estimatedDepartureTime: DateTime.now().add(const Duration(minutes: 5)),
        joinedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        make: 'Toyota',
        model: 'Hiace',
        color: 'White',
      ),
      QueueVehicle(
        id: 'queue-2',
        vehicleId: 'vehicle-2',
        registrationNumber: 'KCA 456B',
        routeId: routeId,
        position: 2,
        status: QueueVehicleStatus.waiting,
        totalSeats: 14,
        availableSeats: 14,
        driverName: 'Peter Mwangi',
        estimatedDepartureTime: DateTime.now().add(const Duration(minutes: 15)),
        joinedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        make: 'Nissan',
        model: 'Caravan',
        color: 'Silver',
      ),
      QueueVehicle(
        id: 'queue-3',
        vehicleId: 'vehicle-3',
        registrationNumber: 'KDA 789C',
        routeId: routeId,
        position: 3,
        status: QueueVehicleStatus.waiting,
        totalSeats: 14,
        availableSeats: 14,
        driverName: 'James Ochieng',
        estimatedDepartureTime: DateTime.now().add(const Duration(minutes: 25)),
        joinedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        make: 'Toyota',
        model: 'Hiace',
        color: 'Blue',
      ),
    ];
  }

  /// Dispose resources.
  void dispose() {
    _mockUpdateTimer?.cancel();
    _connectionController.close();
    for (final controller in _eventControllers.values) {
      controller.close();
    }
    _eventControllers.clear();
    _activeSubscriptions.clear();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the real-time service.
///
/// Returns a stub implementation for now; will be replaced with actual
/// service when the real-time infrastructure is complete.
final realtimeServiceProvider = Provider<RealtimeServiceStub>((ref) {
  final service = RealtimeServiceStub();
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for the queue update handler.
final queueUpdateHandlerProvider =
    Provider.family<QueueUpdateHandler, String>((ref, routeId) {
  return QueueUpdateHandler(routeId: routeId);
});

/// Provider for the current queue connection state.
///
/// Watch this to display connection status indicators in the UI.
final queueConnectionStateProvider =
    StateProvider.family<QueueConnectionState, String>((ref, routeId) {
  return QueueConnectionState.disconnected;
});

/// Provider for queue state notifier.
///
/// Manages the complete queue state including vehicles, connection,
/// and optimistic updates.
final queueStateNotifierProvider =
    StateNotifierProvider.family<QueueStateNotifier, QueueState, String>(
  (ref, routeId) {
    final service = ref.watch(realtimeServiceProvider);
    final handler = ref.watch(queueUpdateHandlerProvider(routeId));
    return QueueStateNotifier(
      routeId: routeId,
      service: service,
      handler: handler,
      ref: ref,
    );
  },
);

/// StreamProvider for queue updates.
///
/// Combines initial HTTP data with real-time WebSocket updates.
/// Use this as the primary way to watch queue state in the UI.
final queueStreamProvider =
    StreamProvider.family<QueueState, String>((ref, routeId) {
  final notifier = ref.watch(queueStateNotifierProvider(routeId).notifier);
  return notifier.stateStream;
});

/// Provider to subscribe to queue updates.
///
/// Call this to initiate the subscription and start receiving updates.
/// Returns a function to unsubscribe.
final subscribeToQueueProvider =
    Provider.family<Future<void> Function(), String>((ref, routeId) {
  return () async {
    final notifier = ref.read(queueStateNotifierProvider(routeId).notifier);
    await notifier.subscribe();
  };
});

/// Provider to refresh queue data.
///
/// Forces a fresh fetch from the server.
final realtimeRefreshQueueProvider =
    Provider.family<Future<void> Function(), String>((ref, routeId) {
  return () async {
    final notifier = ref.read(queueStateNotifierProvider(routeId).notifier);
    await notifier.refresh();
  };
});

/// Provider to select a vehicle (optimistic UI).
///
/// Immediately shows the selection in the UI while confirming with server.
final selectVehicleProvider =
    Provider.family<Future<bool> Function(String vehicleId, int seats), String>(
  (ref, routeId) {
    return (vehicleId, seats) async {
      final notifier = ref.read(queueStateNotifierProvider(routeId).notifier);
      return notifier.selectVehicle(vehicleId, seats);
    };
  },
);

/// Provider to check if a specific vehicle is selected.
final isVehicleSelectedProvider =
    Provider.family<bool, ({String routeId, String vehicleId})>((ref, params) {
  final state = ref.watch(queueStateNotifierProvider(params.routeId));
  return state.selectedVehicleId == params.vehicleId;
});

// ─────────────────────────────────────────────────────────────────────────────
// Queue State Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// State notifier for managing queue state.
///
/// Handles subscription lifecycle, event processing, and optimistic updates.
class QueueStateNotifier extends StateNotifier<QueueState> {
  /// Creates a new QueueStateNotifier.
  QueueStateNotifier({
    required this.routeId,
    required this.service,
    required this.handler,
    required this.ref,
  }) : super(QueueState.loading(routeId)) {
    _stateController = StreamController<QueueState>.broadcast();
  }

  /// The route ID this notifier manages.
  final String routeId;

  /// The real-time service.
  final RealtimeServiceStub service;

  /// The queue update handler.
  final QueueUpdateHandler handler;

  /// The provider ref.
  final Ref ref;

  late final StreamController<QueueState> _stateController;
  StreamSubscription<QueueEvent>? _eventSubscription;
  StreamSubscription<QueueConnectionState>? _connectionSubscription;

  /// Stream of state changes.
  Stream<QueueState> get stateStream => _stateController.stream;

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _connectionSubscription?.cancel();
    _stateController.close();
    super.dispose();
  }

  /// Subscribe to queue updates.
  Future<void> subscribe() async {
    if (state.connectionState.isConnected) return;

    _updateState(state.copyWith(
      connectionState: QueueConnectionState.connecting,
      isLoading: true,
    ));

    try {
      // Connect to real-time service
      await service.connect();

      // Listen to connection state changes
      _connectionSubscription = service.connectionStream.listen(
        _handleConnectionChange,
      );

      // Fetch initial data
      final vehicles = await service.getQueueVehicles(routeId);

      // Subscribe to events
      _eventSubscription = service.subscribeToQueue(routeId).listen(
            _handleQueueEvent,
            onError: _handleError,
          );

      _updateState(state.copyWith(
        vehicles: handler.sortVehicles(vehicles),
        connectionState: QueueConnectionState.connected,
        isLoading: false,
        lastUpdated: DateTime.now(),
        clearError: true,
      ));

      // Update connection state provider
      ref.read(queueConnectionStateProvider(routeId).notifier).state =
          QueueConnectionState.connected;
    } catch (e) {
      _updateState(state.copyWith(
        connectionState: QueueConnectionState.error,
        isLoading: false,
        error: e.toString(),
      ));

      ref.read(queueConnectionStateProvider(routeId).notifier).state =
          QueueConnectionState.error;
    }
  }

  /// Unsubscribe from queue updates.
  void unsubscribe() {
    _eventSubscription?.cancel();
    _connectionSubscription?.cancel();
    service.unsubscribeFromQueue(routeId);

    _updateState(state.copyWith(
      connectionState: QueueConnectionState.disconnected,
    ));

    ref.read(queueConnectionStateProvider(routeId).notifier).state =
        QueueConnectionState.disconnected;
  }

  /// Refresh queue data from server.
  Future<void> refresh() async {
    _updateState(state.copyWith(isSyncing: true));

    try {
      final vehicles = await service.getQueueVehicles(routeId);
      _updateState(state.copyWith(
        vehicles: handler.sortVehicles(vehicles),
        isSyncing: false,
        lastUpdated: DateTime.now(),
        clearError: true,
      ));
    } catch (e) {
      _updateState(state.copyWith(
        isSyncing: false,
        error: 'Failed to refresh: ${e.toString()}',
      ));
    }
  }

  /// Select a vehicle with optimistic UI update.
  ///
  /// Returns true if selection was successful.
  Future<bool> selectVehicle(String vehicleId, int seats) async {
    // Check if vehicle exists and has enough seats
    final vehicle = state.getVehicleById(vehicleId);
    if (vehicle == null) {
      return false;
    }
    if (!vehicle.canBoard || vehicle.availableSeats < seats) {
      return false;
    }

    // Create pending selection for optimistic UI
    final pendingSelection = PendingVehicleSelection(
      vehicleId: vehicleId,
      seatsRequested: seats,
      timestamp: DateTime.now(),
    );

    _updateState(state.copyWith(
      selectedVehicleId: vehicleId,
      pendingSelection: pendingSelection,
    ));

    try {
      // TODO: Call actual booking API here
      // For now, simulate API call
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Confirm selection
      _updateState(state.copyWith(
        pendingSelection: pendingSelection.confirmed(),
      ));

      // Clear pending selection after a short delay
      Future<void>.delayed(const Duration(seconds: 2)).then((_) {
        if (mounted) {
          _updateState(state.copyWith(clearPendingSelection: true));
        }
      });

      return true;
    } catch (e) {
      // Handle selection conflict (vehicle left queue, no seats, etc.)
      _updateState(state.copyWith(
        clearSelectedVehicle: true,
        pendingSelection: pendingSelection.failed(e.toString()),
      ));

      return false;
    }
  }

  /// Clear vehicle selection.
  void clearSelection() {
    _updateState(state.copyWith(
      clearSelectedVehicle: true,
      clearPendingSelection: true,
    ));
  }

  void _handleQueueEvent(QueueEvent event) {
    final updatedVehicles = handler.handleEvent(state.vehicles, event);
    _updateState(state.copyWith(
      vehicles: updatedVehicles,
      lastUpdated: DateTime.now(),
    ));

    // Handle conflicts with pending selection
    if (state.hasPendingUpdate) {
      _checkSelectionConflicts(event);
    }
  }

  void _handleConnectionChange(QueueConnectionState connectionState) {
    _updateState(state.copyWith(connectionState: connectionState));
    ref.read(queueConnectionStateProvider(routeId).notifier).state =
        connectionState;

    // Auto-refresh on reconnect
    if (connectionState == QueueConnectionState.connected &&
        state.vehicles.isNotEmpty) {
      refresh();
    }
  }

  void _handleError(Object error) {
    _updateState(state.copyWith(
      connectionState: QueueConnectionState.error,
      error: error.toString(),
    ));

    ref.read(queueConnectionStateProvider(routeId).notifier).state =
        QueueConnectionState.error;
  }

  void _checkSelectionConflicts(QueueEvent event) {
    final pendingSelection = state.pendingSelection;
    if (pendingSelection == null || !pendingSelection.isPending) return;

    // Check if the selected vehicle left the queue
    if (event is VehicleLeftQueueEvent &&
        event.vehicleId == pendingSelection.vehicleId) {
      _updateState(state.copyWith(
        clearSelectedVehicle: true,
        pendingSelection: pendingSelection.failed('Vehicle has left the queue'),
      ));
      return;
    }

    // Check if available seats dropped below requested
    if (event is VehicleSeatCountChangedEvent &&
        event.vehicleId == pendingSelection.vehicleId &&
        event.newSeatCount < pendingSelection.seatsRequested) {
      _updateState(state.copyWith(
        pendingSelection:
            pendingSelection.failed('Not enough seats available'),
      ));
    }
  }

  void _updateState(QueueState newState) {
    state = newState;
    _stateController.add(newState);
  }
}
