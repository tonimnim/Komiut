import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  Future<List<ConnectivityResult>> get connectivityStatus async {
    return await _connectivity.checkConnectivity();
  }
}
