/// Vehicle entity.
///
/// Represents a vehicle in the domain layer.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Vehicle entity representing a transport vehicle.
class Vehicle extends Equatable {
  /// Creates a new Vehicle instance.
  const Vehicle({
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

  /// Unique identifier.
  final String id;

  /// Vehicle registration/plate number.
  final String registrationNumber;

  /// Passenger capacity.
  final int capacity;

  /// Vehicle operational status.
  final VehicleStatus status;

  /// ID of currently assigned route.
  final String? currentRouteId;

  /// ID of the owning organization.
  final String organizationId;

  /// ID of the domain.
  final String? domainId;

  /// Vehicle make (e.g., Toyota).
  final String? make;

  /// Vehicle model (e.g., Hiace).
  final String? model;

  /// Manufacturing year.
  final int? year;

  /// Vehicle color.
  final String? color;

  /// URL to vehicle image.
  final String? imageUrl;

  /// When the vehicle was registered.
  final DateTime? createdAt;

  /// When the vehicle was last updated.
  final DateTime? updatedAt;

  /// Whether the vehicle is active.
  bool get isActive => status == VehicleStatus.active;

  /// Whether the vehicle has an assigned route.
  bool get hasRoute => currentRouteId != null;

  /// Display name combining registration and make/model.
  String get displayName {
    if (make != null && model != null) {
      return '$registrationNumber - $make $model';
    }
    return registrationNumber;
  }

  /// Creates a copy with modified fields.
  Vehicle copyWith({
    String? id,
    String? registrationNumber,
    int? capacity,
    VehicleStatus? status,
    String? currentRouteId,
    String? organizationId,
    String? domainId,
    String? make,
    String? model,
    int? year,
    String? color,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentRouteId: currentRouteId ?? this.currentRouteId,
      organizationId: organizationId ?? this.organizationId,
      domainId: domainId ?? this.domainId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        registrationNumber,
        capacity,
        status,
        currentRouteId,
        organizationId,
        domainId,
        make,
        model,
        year,
        color,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}
