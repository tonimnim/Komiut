/// Driver location provider for real-time GPS tracking.
///
/// Provides streaming location updates for the driver's position.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Current driver location state.
class DriverLocationState {
  const DriverLocationState({
    this.position,
    this.isLoading = false,
    this.error,
    this.permissionGranted = false,
  });

  final LatLng? position;
  final bool isLoading;
  final String? error;
  final bool permissionGranted;

  DriverLocationState copyWith({
    LatLng? position,
    bool? isLoading,
    String? error,
    bool? permissionGranted,
  }) {
    return DriverLocationState(
      position: position ?? this.position,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }
}

/// Notifier for driver location tracking.
class DriverLocationNotifier extends StateNotifier<DriverLocationState> {
  DriverLocationNotifier() : super(const DriverLocationState());

  StreamSubscription<Position>? _positionSubscription;

  /// Start tracking driver location.
  Future<void> startTracking() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location services are disabled',
        );
        return;
      }

      // Check permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            error: 'Location permission denied',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission permanently denied',
        );
        return;
      }

      state = state.copyWith(permissionGranted: true);

      // Get initial position
      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      state = state.copyWith(
        position: LatLng(initialPosition.latitude, initialPosition.longitude),
        isLoading: false,
      );

      // Start listening to position updates
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10, // Update every 10 meters
            ),
          ).listen(
            (position) {
              state = state.copyWith(
                position: LatLng(position.latitude, position.longitude),
              );
            },
            onError: (error) {
              state = state.copyWith(error: error.toString());
            },
          );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Stop tracking driver location.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}

/// Provider for driver location state.
final driverLocationProvider =
    StateNotifierProvider<DriverLocationNotifier, DriverLocationState>((ref) {
      return DriverLocationNotifier();
    });
