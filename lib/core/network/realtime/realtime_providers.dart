/// Riverpod providers for real-time communication.
///
/// Provides state management for SignalR connection, connection state,
/// and app lifecycle integration for automatic reconnection.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network_info.dart';
import 'realtime_connection_state.dart';
import 'realtime_service.dart';
import 'signalr_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the SignalR service instance.
///
/// This creates and manages the SignalR connection lifecycle.
/// The service is automatically disposed when no longer needed.
final signalRServiceProvider = Provider<SignalRService>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  // Access token can be watched from auth state if needed
  // final authState = ref.watch(authStateProvider);
  // final accessToken = authState.accessToken;

  final service = SignalRService(
    networkInfo: networkInfo,
    accessToken: null, // Will be set when user logs in
  );

  // Clean up when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for the abstract [RealtimeService] interface.
///
/// This allows switching between implementations (SignalR, WebSocket, mock).
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return ref.watch(signalRServiceProvider);
});

// ─────────────────────────────────────────────────────────────────────────────
// Connection State Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Stream provider for connection state changes.
///
/// Use this to reactively update UI based on connection status.
final realtimeConnectionStateProvider =
    StreamProvider<RealtimeConnectionState>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  return service.connectionStateStream;
});

/// Provider for the current connection status.
///
/// A simpler version that just provides the status enum.
final realtimeConnectionStatusProvider =
    Provider<RealtimeConnectionStatus>((ref) {
  final stateAsync = ref.watch(realtimeConnectionStateProvider);
  return stateAsync.when(
    data: (state) => state.status,
    loading: () => RealtimeConnectionStatus.disconnected,
    error: (_, __) => RealtimeConnectionStatus.failed,
  );
});

/// Provider for checking if real-time is connected.
final isRealtimeConnectedProvider = Provider<bool>((ref) {
  final status = ref.watch(realtimeConnectionStatusProvider);
  return status == RealtimeConnectionStatus.connected;
});

// ─────────────────────────────────────────────────────────────────────────────
// Connection Control Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Notifier for controlling real-time connection.
///
/// Provides methods to connect, disconnect, and reconnect.
class RealtimeConnectionNotifier extends StateNotifier<RealtimeConnectionState> {
  RealtimeConnectionNotifier(this._service)
      : super(const RealtimeConnectionState.initial()) {
    // Listen to service state changes
    _subscription = _service.connectionStateStream.listen((state) {
      this.state = state;
    });
  }

  final RealtimeService _service;
  StreamSubscription<RealtimeConnectionState>? _subscription;

  /// Establishes a connection to the real-time server.
  Future<void> connect() async {
    state = state.copyWith(status: RealtimeConnectionStatus.connecting);
    final result = await _service.connect();
    result.fold(
      (failure) {
        state = state.copyWith(
          status: RealtimeConnectionStatus.failed,
          error: failure.message,
        );
      },
      (_) {
        // State will be updated via stream
      },
    );
  }

  /// Disconnects from the real-time server.
  Future<void> disconnect() async {
    await _service.disconnect();
  }

  /// Reconnects to the server.
  Future<void> reconnect() async {
    await _service.reconnect();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for the connection notifier.
final realtimeConnectionNotifierProvider =
    StateNotifierProvider<RealtimeConnectionNotifier, RealtimeConnectionState>(
        (ref) {
  final service = ref.watch(realtimeServiceProvider);
  return RealtimeConnectionNotifier(service);
});

// ─────────────────────────────────────────────────────────────────────────────
// Queue Update Providers
// ─────────────────────────────────────────────────────────────────────────────

/// State for a specific route's queue updates.
class RouteQueueState {
  const RouteQueueState({
    this.routeId,
    this.isSubscribed = false,
    this.updates = const [],
    this.lastUpdate,
  });

  final String? routeId;
  final bool isSubscribed;
  final List<VehicleQueueUpdate> updates;
  final DateTime? lastUpdate;

  RouteQueueState copyWith({
    String? routeId,
    bool? isSubscribed,
    List<VehicleQueueUpdate>? updates,
    DateTime? lastUpdate,
  }) {
    return RouteQueueState(
      routeId: routeId ?? this.routeId,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      updates: updates ?? this.updates,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// Notifier for managing queue updates for a specific route.
class RouteQueueNotifier extends StateNotifier<RouteQueueState> {
  RouteQueueNotifier(this._service) : super(const RouteQueueState()) {
    // Register handler for queue updates
    _service.onVehicleQueueUpdate(_handleQueueUpdate);
  }

  final RealtimeService _service;

  /// Subscribes to queue updates for a route.
  Future<void> subscribeToRoute(String routeId) async {
    final result = await _service.joinQueueUpdates(routeId);
    result.fold(
      (failure) {
        // Handle error - state remains unsubscribed
      },
      (_) {
        state = state.copyWith(
          routeId: routeId,
          isSubscribed: true,
          updates: [],
        );
      },
    );
  }

  /// Unsubscribes from queue updates for the current route.
  Future<void> unsubscribe() async {
    if (state.routeId == null) return;

    await _service.leaveQueueUpdates(state.routeId!);
    state = const RouteQueueState();
  }

  void _handleQueueUpdate(VehicleQueueUpdate update) {
    if (update.routeId != state.routeId) return;

    // Update or add the vehicle in the list
    final updatedList = List<VehicleQueueUpdate>.from(state.updates);
    final existingIndex =
        updatedList.indexWhere((u) => u.vehicleId == update.vehicleId);

    if (existingIndex >= 0) {
      updatedList[existingIndex] = update;
    } else {
      updatedList.add(update);
    }

    // Sort by queue position
    updatedList.sort((a, b) => a.queuePosition.compareTo(b.queuePosition));

    state = state.copyWith(
      updates: updatedList,
      lastUpdate: DateTime.now(),
    );
  }

  @override
  void dispose() {
    if (state.isSubscribed && state.routeId != null) {
      _service.leaveQueueUpdates(state.routeId!);
    }
    super.dispose();
  }
}

/// Provider for route queue updates.
final routeQueueProvider =
    StateNotifierProvider.autoDispose<RouteQueueNotifier, RouteQueueState>(
        (ref) {
  final service = ref.watch(realtimeServiceProvider);
  return RouteQueueNotifier(service);
});

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle Position Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Stream provider for vehicle position updates.
final vehiclePositionStreamProvider =
    StreamProvider.autoDispose<VehiclePositionUpdate>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  final controller = StreamController<VehiclePositionUpdate>();

  service.onVehiclePositionUpdate((update) {
    if (!controller.isClosed) {
      controller.add(update);
    }
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});

// ─────────────────────────────────────────────────────────────────────────────
// Trip Status Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Stream provider for trip status changes.
final tripStatusStreamProvider =
    StreamProvider.autoDispose<TripStatusChange>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  final controller = StreamController<TripStatusChange>();

  service.onTripStatusChange((change) {
    if (!controller.isClosed) {
      controller.add(change);
    }
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});

// ─────────────────────────────────────────────────────────────────────────────
// App Lifecycle Observer
// ─────────────────────────────────────────────────────────────────────────────

/// Widget observer for handling app lifecycle events.
///
/// Add this to your [WidgetsBinding] to automatically manage
/// real-time connections during app pause/resume.
class RealtimeLifecycleObserver extends WidgetsBindingObserver {
  RealtimeLifecycleObserver(this._service);

  final RealtimeService _service;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _service.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        _service.onAppResumed();
        break;
    }
  }
}

/// Provider for the lifecycle observer.
///
/// Use this to get the observer instance for adding to WidgetsBinding.
final realtimeLifecycleObserverProvider =
    Provider<RealtimeLifecycleObserver>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  return RealtimeLifecycleObserver(service);
});
