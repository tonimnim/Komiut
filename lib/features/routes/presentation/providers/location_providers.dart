/// Location providers for GPS-based route discovery.
///
/// Provides location services, current position tracking, and
/// nearby routes filtering based on user's GPS coordinates.
library;

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/route_entity.dart';
import 'route_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Location Models
// ─────────────────────────────────────────────────────────────────────────────

/// Represents the user's current location.
class UserLocation {
  /// Creates a user location instance.
  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.timestamp,
  });

  /// Latitude in degrees.
  final double latitude;

  /// Longitude in degrees.
  final double longitude;

  /// Location accuracy in meters (if available).
  final double? accuracy;

  /// Timestamp when location was determined.
  final DateTime? timestamp;

  /// Creates from a Geolocator Position.
  factory UserLocation.fromPosition(Position position) {
    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  /// Calculate distance to another point in kilometers.
  double distanceTo(double lat, double lng) {
    return _haversineDistance(latitude, longitude, lat, lng);
  }

  @override
  String toString() => 'UserLocation($latitude, $longitude)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Location Service
// ─────────────────────────────────────────────────────────────────────────────

/// Service for handling location operations.
class LocationService {
  /// Check if location services are enabled.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status.
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission.
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Open device location settings.
  Future<bool> openSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for permission management.
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get current position.
  ///
  /// Returns the user's current location or throws an exception
  /// if location services are disabled or permission is denied.
  Future<UserLocation> getCurrentPosition() async {
    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    // Check permission
    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException();
    }

    // Get position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );

    return UserLocation.fromPosition(position);
  }

  /// Get last known position (faster, may be stale).
  Future<UserLocation?> getLastKnownPosition() async {
    final position = await Geolocator.getLastKnownPosition();
    if (position == null) return null;
    return UserLocation.fromPosition(position);
  }
}

/// Exception when location services are disabled.
class LocationServiceDisabledException implements Exception {
  @override
  String toString() => 'Location services are disabled';
}

/// Exception when location permission is denied.
class LocationPermissionDeniedException implements Exception {
  @override
  String toString() => 'Location permission denied';
}

/// Exception when location permission is permanently denied.
class LocationPermissionPermanentlyDeniedException implements Exception {
  @override
  String toString() => 'Location permission permanently denied';
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the location service singleton.
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Provider for the current user location.
///
/// Fetches the user's GPS position. Returns null if location
/// is not available or permission is denied.
final currentLocationProvider = FutureProvider<UserLocation?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);

  try {
    // First try to get last known position (fast)
    final lastKnown = await locationService.getLastKnownPosition();
    if (lastKnown != null) {
      // Return last known immediately, then update
      final current = await locationService.getCurrentPosition();
      return current;
    }

    // No last known, get current
    return await locationService.getCurrentPosition();
  } on LocationServiceDisabledException {
    return null;
  } on LocationPermissionDeniedException {
    throw Exception('Location permission denied');
  } on LocationPermissionPermanentlyDeniedException {
    throw Exception('Location permission permanently denied. Please enable in settings.');
  } catch (e) {
    // For any other error, return null
    return null;
  }
});

/// Provider for location permission status.
final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.checkPermission();
});

/// Provider for checking if location services are enabled.
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.isLocationServiceEnabled();
});

// ─────────────────────────────────────────────────────────────────────────────
// Nearby Routes Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Default radius for nearby routes search in kilometers.
const double kDefaultNearbyRadiusKm = 5.0;

/// Provider for nearby routes based on user location.
///
/// Filters routes that have any stop within the specified radius
/// of the user's current location.
final nearbyRoutesProvider = FutureProvider.family<List<RouteEntity>, UserLocation>(
  (ref, location) async {
    final routes = await ref.watch(routesProvider.future);

    // For now, we use a simple approach: filter routes based on
    // matching location keywords in start/end points.
    // In production, this would use actual GPS coordinates of stops.
    final nearbyRoutes = _filterRoutesByProximity(
      routes,
      location,
      radiusKm: kDefaultNearbyRadiusKm,
    );

    // Limit to first 5 nearby routes
    return nearbyRoutes.take(5).toList();
  },
);

/// Configurable nearby routes provider with custom radius.
final nearbyRoutesWithRadiusProvider = FutureProvider.family<
    List<RouteEntity>,
    ({UserLocation location, double radiusKm})>((ref, params) async {
  final routes = await ref.watch(routesProvider.future);

  final nearbyRoutes = _filterRoutesByProximity(
    routes,
    params.location,
    radiusKm: params.radiusKm,
  );

  return nearbyRoutes;
});

/// Filter routes by proximity to a location.
///
/// Since routes may not have GPS coordinates for all stops yet,
/// this function uses a hybrid approach:
/// 1. If stop coordinates are available, use distance calculation
/// 2. Otherwise, use heuristic based on common locations
List<RouteEntity> _filterRoutesByProximity(
  List<RouteEntity> routes,
  UserLocation location,
  {double radiusKm = kDefaultNearbyRadiusKm}
) {
  // Nairobi area approximate zones for demo purposes
  // In production, route stops would have GPS coordinates
  final nairobiZones = _getNairobiZones();

  // Determine which zone the user is in
  final userZone = _findZoneForLocation(location, nairobiZones);

  if (userZone == null) {
    // User is outside known zones, return all routes as "nearby"
    return routes;
  }

  // Filter routes that serve the user's zone
  return routes.where((route) {
    // Check if route name, start, or end matches the zone keywords
    final routeText = '${route.name} ${route.startPoint} ${route.endPoint}'
        .toLowerCase();

    return userZone.keywords.any((keyword) => routeText.contains(keyword));
  }).toList();
}

/// Represents a geographic zone with associated keywords.
class _GeoZone {
  const _GeoZone({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.keywords,
  });

  final String name;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final List<String> keywords;
}

/// Get predefined zones for Nairobi (demo data).
List<_GeoZone> _getNairobiZones() {
  return const [
    _GeoZone(
      name: 'CBD',
      latitude: -1.2921,
      longitude: 36.8219,
      radiusKm: 2.0,
      keywords: ['cbd', 'city', 'nairobi', 'downtown', 'archives'],
    ),
    _GeoZone(
      name: 'Westlands',
      latitude: -1.2673,
      longitude: 36.8114,
      radiusKm: 3.0,
      keywords: ['westlands', 'sarit', 'parklands'],
    ),
    _GeoZone(
      name: 'Eastleigh',
      latitude: -1.2758,
      longitude: 36.8511,
      radiusKm: 2.5,
      keywords: ['eastleigh', 'mathare', 'pangani'],
    ),
    _GeoZone(
      name: 'South B/C',
      latitude: -1.3101,
      longitude: 36.8295,
      radiusKm: 3.0,
      keywords: ['south b', 'south c', 'industrial area', 'mombasa road'],
    ),
    _GeoZone(
      name: 'Thika Road',
      latitude: -1.2200,
      longitude: 36.8800,
      radiusKm: 5.0,
      keywords: ['thika', 'kasarani', 'roysambu', 'githurai'],
    ),
    _GeoZone(
      name: 'Ngong Road',
      latitude: -1.2981,
      longitude: 36.7658,
      radiusKm: 4.0,
      keywords: ['ngong', 'karen', 'langata', 'kibera'],
    ),
  ];
}

/// Find the zone that contains the given location.
_GeoZone? _findZoneForLocation(UserLocation location, List<_GeoZone> zones) {
  for (final zone in zones) {
    final distance = location.distanceTo(zone.latitude, zone.longitude);
    if (distance <= zone.radiusKm) {
      return zone;
    }
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Functions
// ─────────────────────────────────────────────────────────────────────────────

/// Calculate distance between two GPS points using Haversine formula.
///
/// Returns distance in kilometers.
double _haversineDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadiusKm = 6371.0;

  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);

  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadiusKm * c;
}

/// Convert degrees to radians.
double _toRadians(double degrees) => degrees * math.pi / 180;
