/// Route API model.
///
/// Data transfer object for TransportRoute entity matching API schema.
library;

import '../../domain/entities/route.dart';
import '../../domain/enums/enums.dart';

/// Route model for API communication.
class RouteModel {
  /// Creates a new RouteModel instance.
  const RouteModel({
    required this.id,
    required this.name,
    this.code,
    required this.status,
    required this.organizationId,
    this.description,
    this.startPoint,
    this.endPoint,
    this.estimatedDuration,
    this.distance,
    this.baseFare,
    this.currency,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates from JSON map.
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      status: json['status'] == 'active'
          ? OrganizationStatus.active
          : OrganizationStatus.inactive,
      organizationId: json['organizationId'] as String,
      description: json['description'] as String?,
      startPoint: json['startPoint'] as String?,
      endPoint: json['endPoint'] as String?,
      estimatedDuration: json['estimatedDuration'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      baseFare: (json['baseFare'] as num?)?.toDouble(),
      currency: json['currency'] != null
          ? currencyFromString(json['currency'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory RouteModel.fromEntity(TransportRoute entity) {
    return RouteModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      status: entity.status,
      organizationId: entity.organizationId,
      description: entity.description,
      startPoint: entity.startPoint,
      endPoint: entity.endPoint,
      estimatedDuration: entity.estimatedDuration,
      distance: entity.distance,
      baseFare: entity.baseFare,
      currency: entity.currency,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String name;
  final String? code;
  final OrganizationStatus status;
  final String organizationId;
  final String? description;
  final String? startPoint;
  final String? endPoint;
  final int? estimatedDuration;
  final double? distance;
  final double? baseFare;
  final Currency? currency;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (code != null) 'code': code,
        'status': status == OrganizationStatus.active ? 'active' : 'inactive',
        'organizationId': organizationId,
        if (description != null) 'description': description,
        if (startPoint != null) 'startPoint': startPoint,
        if (endPoint != null) 'endPoint': endPoint,
        if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
        if (distance != null) 'distance': distance,
        if (baseFare != null) 'baseFare': baseFare,
        if (currency != null) 'currency': currency!.name,
        'isActive': isActive,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  TransportRoute toEntity() => TransportRoute(
        id: id,
        name: name,
        code: code,
        status: status,
        organizationId: organizationId,
        description: description,
        startPoint: startPoint,
        endPoint: endPoint,
        estimatedDuration: estimatedDuration,
        distance: distance,
        baseFare: baseFare,
        currency: currency,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
