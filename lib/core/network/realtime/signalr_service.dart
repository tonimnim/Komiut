/// SignalR implementation of the real-time service.
///
/// Provides real-time communication using Microsoft SignalR protocol
/// for live queue updates, vehicle tracking, and trip status changes.
library;

import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../config/env_config.dart';
import '../../errors/failures.dart';
import '../network_info.dart';
import 'realtime_connection_state.dart';
import 'realtime_service.dart';

/// Configuration for SignalR connection.
class SignalRConfig {
  const SignalRConfig._();

  /// SignalR hub endpoint path.
  static const String hubPath = '/hubs/transport';

  /// Get full hub URL.
  static String get hubUrl => '${EnvConfig.baseUrl}$hubPath';

  /// Initial reconnect delay in milliseconds.
  static const int initialReconnectDelayMs = 1000;

  /// Maximum reconnect delay in milliseconds (30 seconds).
  static const int maxReconnectDelayMs = 30000;

  /// Maximum number of reconnection attempts.
  static const int maxReconnectAttempts = 10;

  /// Heartbeat interval in seconds.
  static const int heartbeatIntervalSeconds = 15;

  /// Server timeout in seconds.
  static const int serverTimeoutSeconds = 30;

  /// Keep alive interval in seconds.
  static const int keepAliveIntervalSeconds = 15;
}

/// SignalR implementation of [RealtimeService].
///
/// Handles connection management with automatic reconnection using
/// exponential backoff, heartbeat/ping mechanism, and app lifecycle events.
class SignalRService implements RealtimeService {
  /// Creates a SignalR service with the given dependencies.
  SignalRService({
    required NetworkInfo networkInfo,
    String? accessToken,
  })  : _networkInfo = networkInfo,
        _accessToken = accessToken {
    _initializeHub();
  }

  final NetworkInfo _networkInfo;
  String? _accessToken;

  late HubConnection _hubConnection;
  final _connectionStateController =
      StreamController<RealtimeConnectionState>.broadcast();

  RealtimeConnectionState _currentState = const RealtimeConnectionState.initial();

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;
  bool _isPaused = false;

  // Subscribed route IDs for rejoining after reconnection.
  final Set<String> _subscribedRoutes = {};

  // Event handlers
  final List<RealtimeMessageHandler<VehicleQueueUpdate>> _queueUpdateHandlers =
      [];
  final List<RealtimeMessageHandler<VehiclePositionUpdate>>
      _positionUpdateHandlers = [];
  final List<RealtimeMessageHandler<TripStatusChange>> _tripStatusHandlers = [];

  // ─────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────

  void _initializeHub() {
    final httpOptions = HttpConnectionOptions(
      accessTokenFactory: () async => _accessToken ?? '',
      skipNegotiation: true,
      transport: HttpTransportType.WebSockets,
    );

    _hubConnection = HubConnectionBuilder()
        .withUrl(SignalRConfig.hubUrl, options: httpOptions)
        .withAutomaticReconnect(retryDelays: _buildRetryDelays())
        .build();

    // Configure timeouts
    _hubConnection.serverTimeoutInMilliseconds =
        SignalRConfig.serverTimeoutSeconds * 1000;
    _hubConnection.keepAliveIntervalInMilliseconds =
        SignalRConfig.keepAliveIntervalSeconds * 1000;

    // Register connection lifecycle handlers
    _hubConnection.onclose(_onConnectionClosed);
    _hubConnection.onreconnecting(_onReconnecting);
    _hubConnection.onreconnected(_onReconnected);

    // Register server-to-client message handlers
    _registerHubMethods();
  }

  /// Builds retry delay list for automatic reconnection.
  List<int> _buildRetryDelays() {
    final delays = <int>[];
    for (var i = 0; i < SignalRConfig.maxReconnectAttempts; i++) {
      final delay = min(
        SignalRConfig.initialReconnectDelayMs * pow(2, i).toInt(),
        SignalRConfig.maxReconnectDelayMs,
      );
      delays.add(delay);
    }
    return delays;
  }

  void _registerHubMethods() {
    // Vehicle queue updates
    _hubConnection.on('OnVehicleQueueUpdate', (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      try {
        final data = arguments[0] as Map<String, dynamic>;
        final update = VehicleQueueUpdate.fromJson(data);

        for (final handler in _queueUpdateHandlers) {
          handler(update);
        }
      } catch (e) {
        _logError('Error parsing VehicleQueueUpdate', e);
      }
    });

    // Vehicle position updates
    _hubConnection.on('OnVehiclePositionUpdate', (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      try {
        final data = arguments[0] as Map<String, dynamic>;
        final update = VehiclePositionUpdate.fromJson(data);

        for (final handler in _positionUpdateHandlers) {
          handler(update);
        }
      } catch (e) {
        _logError('Error parsing VehiclePositionUpdate', e);
      }
    });

    // Trip status changes
    _hubConnection.on('OnTripStatusChange', (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      try {
        final data = arguments[0] as Map<String, dynamic>;
        final change = TripStatusChange.fromJson(data);

        for (final handler in _tripStatusHandlers) {
          handler(change);
        }
      } catch (e) {
        _logError('Error parsing TripStatusChange', e);
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Connection State
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Stream<RealtimeConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  @override
  RealtimeConnectionState get currentState => _currentState;

  @override
  bool get isConnected =>
      _currentState.status == RealtimeConnectionStatus.connected;

  void _updateState(RealtimeConnectionState newState) {
    _currentState = newState;
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(newState);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Connection Management
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> connect() async {
    if (_isDisposed) {
      return const Left(ServerFailure('Service has been disposed'));
    }

    // Check network connectivity first
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      _updateState(_currentState.copyWith(
        status: RealtimeConnectionStatus.failed,
        error: 'No internet connection',
      ));
      return const Left(NetworkFailure('No internet connection'));
    }

    // Already connected
    if (_hubConnection.state == HubConnectionState.Connected) {
      return const Right(null);
    }

    _updateState(_currentState.copyWith(
      status: RealtimeConnectionStatus.connecting,
      clearError: true,
    ));

    try {
      await _hubConnection.start();

      _updateState(_currentState.copyWith(
        status: RealtimeConnectionStatus.connected,
        lastConnectedAt: DateTime.now(),
        retryCount: 0,
        clearError: true,
      ));

      _reconnectAttempts = 0;
      _startHeartbeat();

      // Rejoin any previously subscribed routes
      await _rejoinSubscribedRoutes();

      return const Right(null);
    } catch (e) {
      final errorMessage = 'Failed to connect: ${e.toString()}';
      _updateState(_currentState.copyWith(
        status: RealtimeConnectionStatus.failed,
        error: errorMessage,
      ));
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    _stopHeartbeat();
    _cancelReconnectTimer();

    if (_hubConnection.state == HubConnectionState.Disconnected) {
      _updateState(_currentState.copyWith(
        status: RealtimeConnectionStatus.disconnected,
        lastDisconnectedAt: DateTime.now(),
      ));
      return const Right(null);
    }

    try {
      await _hubConnection.stop();

      _updateState(_currentState.copyWith(
        status: RealtimeConnectionStatus.disconnected,
        lastDisconnectedAt: DateTime.now(),
      ));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to disconnect: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> reconnect() async {
    await disconnect();
    return connect();
  }

  /// Updates the access token for authenticated connections.
  void updateAccessToken(String? token) {
    _accessToken = token;

    // If connected, reconnect with new token
    if (isConnected) {
      reconnect();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Queue Updates
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> joinQueueUpdates(String routeId) async {
    if (!isConnected) {
      return const Left(ServerFailure('Not connected to server'));
    }

    try {
      await _hubConnection.invoke('JoinQueueUpdates', args: [routeId]);
      _subscribedRoutes.add(routeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to join queue updates: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveQueueUpdates(String routeId) async {
    if (!isConnected) {
      _subscribedRoutes.remove(routeId);
      return const Right(null);
    }

    try {
      await _hubConnection.invoke('LeaveQueueUpdates', args: [routeId]);
      _subscribedRoutes.remove(routeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to leave queue updates: ${e.toString()}'));
    }
  }

  /// Rejoins all previously subscribed routes after reconnection.
  Future<void> _rejoinSubscribedRoutes() async {
    for (final routeId in _subscribedRoutes.toList()) {
      try {
        await _hubConnection.invoke('JoinQueueUpdates', args: [routeId]);
      } catch (e) {
        _logError('Failed to rejoin route $routeId', e);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Event Handlers
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onVehicleQueueUpdate(RealtimeMessageHandler<VehicleQueueUpdate> handler) {
    _queueUpdateHandlers.add(handler);
  }

  @override
  void onVehiclePositionUpdate(
      RealtimeMessageHandler<VehiclePositionUpdate> handler) {
    _positionUpdateHandlers.add(handler);
  }

  @override
  void onTripStatusChange(RealtimeMessageHandler<TripStatusChange> handler) {
    _tripStatusHandlers.add(handler);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Connection Event Handlers
  // ─────────────────────────────────────────────────────────────────────────

  void _onConnectionClosed({Exception? error}) {
    _stopHeartbeat();

    final errorMessage = error?.toString();

    _updateState(_currentState.copyWith(
      status: RealtimeConnectionStatus.disconnected,
      error: errorMessage,
      lastDisconnectedAt: DateTime.now(),
    ));

    // Attempt manual reconnection if not paused and not disposed
    if (!_isPaused && !_isDisposed) {
      _scheduleReconnect();
    }
  }

  void _onReconnecting({Exception? error}) {
    _reconnectAttempts++;

    _updateState(_currentState.copyWith(
      status: RealtimeConnectionStatus.reconnecting,
      retryCount: _reconnectAttempts,
      error: error?.toString(),
    ));
  }

  void _onReconnected({String? connectionId}) {
    _reconnectAttempts = 0;

    _updateState(_currentState.copyWith(
      status: RealtimeConnectionStatus.connected,
      lastConnectedAt: DateTime.now(),
      retryCount: 0,
      clearError: true,
    ));

    _startHeartbeat();

    // Rejoin subscribed routes
    _rejoinSubscribedRoutes();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Heartbeat
  // ─────────────────────────────────────────────────────────────────────────

  void _startHeartbeat() {
    _stopHeartbeat();

    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: SignalRConfig.heartbeatIntervalSeconds),
      (_) => _sendHeartbeat(),
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _sendHeartbeat() async {
    if (!isConnected) return;

    try {
      // SignalR handles keep-alive automatically, but we can send a ping
      // to detect connection issues earlier
      await _hubConnection.invoke('Ping');
    } catch (e) {
      _logError('Heartbeat failed', e);
      // Connection may be broken, trigger reconnection
      if (!_isPaused && !_isDisposed) {
        _scheduleReconnect();
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reconnection with Exponential Backoff
  // ─────────────────────────────────────────────────────────────────────────

  void _scheduleReconnect() {
    if (_isDisposed || _isPaused) return;
    if (_reconnectAttempts >= SignalRConfig.maxReconnectAttempts) {
      _updateState(_currentState.copyWith(
        status: RealtimeConnectionStatus.failed,
        error: 'Maximum reconnection attempts reached',
      ));
      return;
    }

    _cancelReconnectTimer();

    // Calculate delay with exponential backoff
    final delay = min(
      SignalRConfig.initialReconnectDelayMs * pow(2, _reconnectAttempts).toInt(),
      SignalRConfig.maxReconnectDelayMs,
    );

    _reconnectTimer = Timer(
      Duration(milliseconds: delay),
      () async {
        if (_isDisposed || _isPaused) return;

        _reconnectAttempts++;
        _updateState(_currentState.copyWith(
          status: RealtimeConnectionStatus.reconnecting,
          retryCount: _reconnectAttempts,
        ));

        final result = await connect();
        result.fold(
          (failure) {
            // Connect failed, schedule another attempt
            _scheduleReconnect();
          },
          (_) {
            // Connect succeeded, reset attempts
            _reconnectAttempts = 0;
          },
        );
      },
    );
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle Management
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> onAppPaused() async {
    _isPaused = true;
    _stopHeartbeat();
    _cancelReconnectTimer();

    // Optionally disconnect to save resources
    // For now, we'll keep the connection but stop monitoring
    _log('App paused - suspending real-time monitoring');
  }

  @override
  Future<void> onAppResumed() async {
    _isPaused = false;
    _log('App resumed - resuming real-time monitoring');

    // Check if we need to reconnect
    if (!isConnected) {
      _reconnectAttempts = 0;
      await connect();
    } else {
      _startHeartbeat();
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;

    _stopHeartbeat();
    _cancelReconnectTimer();

    await _hubConnection.stop();
    await _connectionStateController.close();

    _queueUpdateHandlers.clear();
    _positionUpdateHandlers.clear();
    _tripStatusHandlers.clear();
    _subscribedRoutes.clear();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logging Helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _log(String message) {
    if (EnvConfig.enableLogging) {
      // ignore: avoid_print
      print('[SignalRService] $message');
    }
  }

  void _logError(String message, Object? error) {
    if (EnvConfig.enableLogging) {
      // ignore: avoid_print
      print('[SignalRService] ERROR: $message - $error');
    }
  }
}
