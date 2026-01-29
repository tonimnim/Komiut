/// Vehicle API model.
///
/// Data transfer object for Vehicle entity matching API schema.
library;

import '../../domain/entities/vehicle.dart';
import '../../domain/enums/enums.dart';

/// Vehicle model for API communication.
class VehicleModel {
  /// Creates a new VehicleModel instance.
  const VehicleModel({
    required this.id,
    required this.registrationNumber,
    required this.capacity,
    required this.status,
    this.currentRouteId,
    required this.organizationId,
    this.domainId,
    this.make,
    this.model,
    this.year,
    this.color,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates from JSON map.
  /// Handles both flat and nested registrationNumber formats from API.
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Handle nested value object format: { "registrationNumber": { "value": "KAA 123A" } }
    String regNumber;
    final regField = json['registrationNumber'];
    if (regField is Map<String, dynamic>) {
      regNumber = regField['value'] as String;
    } else {
      regNumber = regField as String;
    }

    // Handle status as int (from API) or string
    VehicleStatus vehicleStatus;
    final statusField = json['status'];
    if (statusField is int) {
      vehicleStatus =
          statusField == 0 ? VehicleStatus.active : VehicleStatus.inactive;
    } else {
      vehicleStatus = statusField == 'active'
          ? VehicleStatus.active
          : VehicleStatus.inactive;
    }

    return VehicleModel(
      id: json['id'] as String,
      registrationNumber: regNumber,
      capacity: json['capacity'] as int,
      status: vehicleStatus,
      currentRouteId: json['currentRouteId'] as String?,
      organizationId: json['organizationId'] as String,
      domainId: json['domainId'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      color: json['color'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory VehicleModel.fromEntity(Vehicle entity) {
    return VehicleModel(
      id: entity.id,
      registrationNumber: entity.registrationNumber,
      capacity: entity.capacity,
      status: entity.status,
      currentRouteId: entity.currentRouteId,
      organizationId: entity.organizationId,
      domainId: entity.domainId,
      make: entity.make,
      model: entity.model,
      year: entity.year,
      color: entity.color,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String registrationNumber;
  final int capacity;
  final VehicleStatus status;
  final String? currentRouteId;
  final String organizationId;
  final String? domainId;
  final String? make;
  final String? model;
  final int? year;
  final String? color;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'registrationNumber': registrationNumber,
        'capacity': capacity,
        'status': status.toApiValue(),
        if (currentRouteId != null) 'currentRouteId': currentRouteId,
        'organizationId': organizationId,
        if (domainId != null) 'domainId': domainId,
        if (make != null) 'make': make,
        if (model != null) 'model': model,
        if (year != null) 'year': year,
        if (color != null) 'color': color,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  Vehicle toEntity() => Vehicle(
        id: id,
        registrationNumber: registrationNumber,
        capacity: capacity,
        status: status,
        currentRouteId: currentRouteId,
        organizationId: organizationId,
        domainId: domainId,
        make: make,
        model: model,
        year: year,
        color: color,
        imageUrl: imageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
