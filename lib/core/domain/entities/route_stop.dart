/// Route stop entity.
///
/// Represents a stop along a transport route.
library;

import 'package:equatable/equatable.dart';

/// RouteStop entity representing a stop on a route.
class RouteStop extends Equatable {
  /// Creates a new RouteStop instance.
  const RouteStop({
    required this.id,
    required this.routeId,
    required this.name,
    this.latitude,
    this.longitude,
    required this.sequence,
    this.address,
    this.isActive = true,
    this.estimatedTimeFromStart,
    this.distanceFromStart,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// ID of the route this stop belongs to.
  final String routeId;

  /// Stop name.
  final String name;

  /// Latitude coordinate.
  final double? latitude;

  /// Longitude coordinate.
  final double? longitude;

  /// Order/sequence of the stop on the route.
  final int sequence;

  /// Physical address.
  final String? address;

  /// Whether the stop is active.
  final bool isActive;

  /// Estimated time from route start in minutes.
  final int? estimatedTimeFromStart;

  /// Distance from route start in kilometers.
  final double? distanceFromStart;

  /// When the stop was created.
  final DateTime? createdAt;

  /// When the stop was last updated.
  final DateTime? updatedAt;

  /// Whether the stop has coordinates.
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Format the estimated time from start.
  String get formattedTime {
    if (estimatedTimeFromStart == null) return '';
    if (estimatedTimeFromStart! < 60) {
      return '$estimatedTimeFromStart min';
    }
    final hours = estimatedTimeFromStart! ~/ 60;
    final minutes = estimatedTimeFromStart! % 60;
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  /// Creates a copy with modified fields.
  RouteStop copyWith({
    String? id,
    String? routeId,
    String? name,
    double? latitude,
    double? longitude,
    int? sequence,
    String? address,
    bool? isActive,
    int? estimatedTimeFromStart,
    double? distanceFromStart,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteStop(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sequence: sequence ?? this.sequence,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      estimatedTimeFromStart:
          estimatedTimeFromStart ?? this.estimatedTimeFromStart,
      distanceFromStart: distanceFromStart ?? this.distanceFromStart,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        routeId,
        name,
        latitude,
        longitude,
        sequence,
        address,
        isActive,
        estimatedTimeFromStart,
        distanceFromStart,
        createdAt,
        updatedAt,
      ];
}
