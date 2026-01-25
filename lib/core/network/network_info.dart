/// Network connectivity checking utilities.
///
/// Provides methods to check and monitor network connectivity status.
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for network info instance.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

/// Provider for current connectivity status.
final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged;
});

/// Provider for checking if currently connected.
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.isConnected;
});

/// Abstract interface for network connectivity checking.
abstract class NetworkInfo {
  /// Check if device is connected to the internet.
  Future<bool> get isConnected;

  /// Stream of connectivity changes.
  Stream<List<ConnectivityResult>> get onConnectivityChanged;

  /// Get current connectivity result.
  Future<List<ConnectivityResult>> get currentConnectivity;
}

/// Implementation of [NetworkInfo] using connectivity_plus package.
class NetworkInfoImpl implements NetworkInfo {
  /// Creates a new instance with the given connectivity checker.
  const NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnectedFromResults(result);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  @override
  Future<List<ConnectivityResult>> get currentConnectivity {
    return _connectivity.checkConnectivity();
  }

  /// Helper to check if connected from connectivity results.
  bool _isConnectedFromResults(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }
}

/// Extension on connectivity results for easier checking.
extension ConnectivityResultX on List<ConnectivityResult> {
  /// Whether any connection is available.
  bool get isConnected {
    return any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  /// Whether connected via WiFi.
  bool get isWifi => contains(ConnectivityResult.wifi);

  /// Whether connected via mobile data.
  bool get isMobile => contains(ConnectivityResult.mobile);

  /// Whether connected via ethernet.
  bool get isEthernet => contains(ConnectivityResult.ethernet);

  /// Whether there is no connection.
  bool get isDisconnected => contains(ConnectivityResult.none) || isEmpty;
}
