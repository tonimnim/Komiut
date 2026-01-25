/// Route stop API model.
///
/// Data transfer object for RouteStop entity matching API schema.
library;

import '../../domain/entities/route_stop.dart';

/// RouteStop model for API communication.
class RouteStopModel {
  /// Creates a new RouteStopModel instance.
  const RouteStopModel({
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

  /// Creates from JSON map.
  factory RouteStopModel.fromJson(Map<String, dynamic> json) {
    return RouteStopModel(
      id: json['id'] as String,
      routeId: json['routeId'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      sequence: json['sequence'] as int,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      estimatedTimeFromStart: json['estimatedTimeFromStart'] as int?,
      distanceFromStart: (json['distanceFromStart'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory RouteStopModel.fromEntity(RouteStop entity) {
    return RouteStopModel(
      id: entity.id,
      routeId: entity.routeId,
      name: entity.name,
      latitude: entity.latitude,
      longitude: entity.longitude,
      sequence: entity.sequence,
      address: entity.address,
      isActive: entity.isActive,
      estimatedTimeFromStart: entity.estimatedTimeFromStart,
      distanceFromStart: entity.distanceFromStart,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String routeId;
  final String name;
  final double? latitude;
  final double? longitude;
  final int sequence;
  final String? address;
  final bool isActive;
  final int? estimatedTimeFromStart;
  final double? distanceFromStart;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'routeId': routeId,
        'name': name,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'sequence': sequence,
        if (address != null) 'address': address,
        'isActive': isActive,
        if (estimatedTimeFromStart != null)
          'estimatedTimeFromStart': estimatedTimeFromStart,
        if (distanceFromStart != null) 'distanceFromStart': distanceFromStart,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  RouteStop toEntity() => RouteStop(
        id: id,
        routeId: routeId,
        name: name,
        latitude: latitude,
        longitude: longitude,
        sequence: sequence,
        address: address,
        isActive: isActive,
        estimatedTimeFromStart: estimatedTimeFromStart,
        distanceFromStart: distanceFromStart,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
