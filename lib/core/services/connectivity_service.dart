/// Connectivity Service - Network monitoring and reachability checking.
///
/// Provides comprehensive network monitoring including:
/// - Connection state changes (wifi, mobile, none)
/// - Actual internet reachability testing
/// - Network quality assessment
library;

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Connection type enumeration.
enum ConnectionType {
  /// Connected via WiFi.
  wifi,

  /// Connected via mobile data.
  mobile,

  /// Connected via ethernet.
  ethernet,

  /// No network connection.
  none,
}

/// Network quality levels.
enum NetworkQuality {
  /// Good network quality - fast and reliable.
  good,

  /// Poor network quality - slow or unstable.
  poor,

  /// No network available.
  none,
}

/// Connection state with additional metadata.
class ConnectionState {
  /// Creates a connection state.
  const ConnectionState({
    required this.isOnline,
    required this.connectionType,
    required this.networkQuality,
    this.lastChecked,
  });

  /// Creates an offline state.
  const ConnectionState.offline()
      : isOnline = false,
        connectionType = ConnectionType.none,
        networkQuality = NetworkQuality.none,
        lastChecked = null;

  /// Creates an online state.
  factory ConnectionState.online({
    required ConnectionType connectionType,
    NetworkQuality networkQuality = NetworkQuality.good,
  }) {
    return ConnectionState(
      isOnline: true,
      connectionType: connectionType,
      networkQuality: networkQuality,
      lastChecked: DateTime.now(),
    );
  }

  /// Whether the device is online with internet access.
  final bool isOnline;

  /// Type of network connection.
  final ConnectionType connectionType;

  /// Quality of the network connection.
  final NetworkQuality networkQuality;

  /// When the connection was last verified.
  final DateTime? lastChecked;

  /// Whether the connection is stable enough for important operations.
  bool get isStable => isOnline && networkQuality == NetworkQuality.good;

  /// Copy with new values.
  ConnectionState copyWith({
    bool? isOnline,
    ConnectionType? connectionType,
    NetworkQuality? networkQuality,
    DateTime? lastChecked,
  }) {
    return ConnectionState(
      isOnline: isOnline ?? this.isOnline,
      connectionType: connectionType ?? this.connectionType,
      networkQuality: networkQuality ?? this.networkQuality,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  @override
  String toString() {
    return 'ConnectionState(isOnline: $isOnline, type: $connectionType, quality: $networkQuality)';
  }
}

/// Service for monitoring network connectivity.
///
/// Provides real-time network status updates and internet reachability testing.
abstract class ConnectivityService {
  /// Stream of connection state changes.
  Stream<ConnectionState> get onConnectionStateChanged;

  /// Current connection state.
  ConnectionState get currentState;

  /// Check if currently online.
  bool get isOnline;

  /// Current connection type.
  ConnectionType get connectionType;

  /// Current network quality.
  NetworkQuality get networkQuality;

  /// Initialize the service and start monitoring.
  Future<void> initialize();

  /// Stop monitoring and clean up resources.
  Future<void> dispose();

  /// Force a connectivity check.
  Future<ConnectionState> checkConnectivity();

  /// Test if the internet is actually reachable.
  ///
  /// This performs a real network request to verify connectivity,
  /// not just checking if a network interface is available.
  Future<bool> testInternetReachability();
}

/// Implementation of [ConnectivityService] using connectivity_plus.
class ConnectivityServiceImpl implements ConnectivityService {
  /// Creates a new connectivity service.
  ConnectivityServiceImpl({
    Connectivity? connectivity,
    this.reachabilityTestUrls = const [
      'https://clients3.google.com/generate_204',
      'https://www.gstatic.com/generate_204',
      'https://connectivitycheck.android.com/generate_204',
    ],
    this.reachabilityTimeout = const Duration(seconds: 5),
    this.recheckInterval = const Duration(seconds: 30),
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// URLs to use for testing internet reachability.
  final List<String> reachabilityTestUrls;

  /// Timeout for reachability tests.
  final Duration reachabilityTimeout;

  /// Interval for periodic reachability checks when connected.
  final Duration recheckInterval;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _recheckTimer;
  final _stateController = StreamController<ConnectionState>.broadcast();

  ConnectionState _currentState = const ConnectionState.offline();

  @override
  Stream<ConnectionState> get onConnectionStateChanged =>
      _stateController.stream;

  @override
  ConnectionState get currentState => _currentState;

  @override
  bool get isOnline => _currentState.isOnline;

  @override
  ConnectionType get connectionType => _currentState.connectionType;

  @override
  NetworkQuality get networkQuality => _currentState.networkQuality;

  @override
  Future<void> initialize() async {
    // Initial check
    await checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });

    // Start periodic reachability checks
    _startPeriodicChecks();
  }

  @override
  Future<void> dispose() async {
    _recheckTimer?.cancel();
    await _subscription?.cancel();
    await _stateController.close();
  }

  @override
  Future<ConnectionState> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _handleConnectivityChange(results);
    } catch (e) {
      debugPrint('ConnectivityService: Error checking connectivity: $e');
      _updateState(const ConnectionState.offline());
      return _currentState;
    }
  }

  @override
  Future<bool> testInternetReachability() async {
    if (kIsWeb) {
      // On web, just assume connected if we have a network interface
      return _currentState.connectionType != ConnectionType.none;
    }

    for (final url in reachabilityTestUrls) {
      try {
        final uri = Uri.parse(url);
        final socket = await Socket.connect(
          uri.host,
          uri.port == 0 ? 443 : uri.port,
          timeout: reachabilityTimeout,
        );
        socket.destroy();
        return true;
      } catch (_) {
        // Try next URL
        continue;
      }
    }

    // All tests failed
    return false;
  }

  Future<ConnectionState> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final connectionType = _determineConnectionType(results);

    if (connectionType == ConnectionType.none) {
      _updateState(const ConnectionState.offline());
      return _currentState;
    }

    // We have a network interface, test actual reachability
    final isReachable = await testInternetReachability();

    if (!isReachable) {
      _updateState(ConnectionState(
        isOnline: false,
        connectionType: connectionType,
        networkQuality: NetworkQuality.none,
        lastChecked: DateTime.now(),
      ));
      return _currentState;
    }

    // Determine network quality based on connection type
    final quality = _determineNetworkQuality(connectionType);

    _updateState(ConnectionState.online(
      connectionType: connectionType,
      networkQuality: quality,
    ));

    return _currentState;
  }

  ConnectionType _determineConnectionType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectionType.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionType.mobile;
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectionType.ethernet;
    }
    return ConnectionType.none;
  }

  NetworkQuality _determineNetworkQuality(ConnectionType type) {
    // Basic quality assessment based on connection type
    // In a production app, this could be enhanced with actual speed tests
    switch (type) {
      case ConnectionType.wifi:
      case ConnectionType.ethernet:
        return NetworkQuality.good;
      case ConnectionType.mobile:
        // Mobile could be variable, default to good but monitor
        return NetworkQuality.good;
      case ConnectionType.none:
        return NetworkQuality.none;
    }
  }

  void _updateState(ConnectionState newState) {
    if (_currentState.isOnline != newState.isOnline ||
        _currentState.connectionType != newState.connectionType ||
        _currentState.networkQuality != newState.networkQuality) {
      _currentState = newState;
      _stateController.add(newState);
      debugPrint('ConnectivityService: State changed to $newState');
    }
  }

  void _startPeriodicChecks() {
    _recheckTimer?.cancel();
    _recheckTimer = Timer.periodic(recheckInterval, (_) async {
      if (_currentState.connectionType != ConnectionType.none) {
        await checkConnectivity();
      }
    });
  }
}
