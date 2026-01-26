/// Route entity.
///
/// Represents a transport route in the domain layer.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Route entity representing a transport route.
class TransportRoute extends Equatable {
  /// Creates a new TransportRoute instance.
  const TransportRoute({
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

  /// Unique identifier.
  final String id;

  /// Route name.
  final String name;

  /// Route code (e.g., "R001").
  final String? code;

  /// Route status.
  final OrganizationStatus status;

  /// ID of the owning organization.
  final String organizationId;

  /// Route description.
  final String? description;

  /// Starting point name.
  final String? startPoint;

  /// Ending point name.
  final String? endPoint;

  /// Estimated duration in minutes.
  final int? estimatedDuration;

  /// Distance in kilometers.
  final double? distance;

  /// Base fare for the route.
  final double? baseFare;

  /// Currency for fares.
  final Currency? currency;

  /// Whether the route is active.
  final bool isActive;

  /// When the route was created.
  final DateTime? createdAt;

  /// When the route was last updated.
  final DateTime? updatedAt;

  /// Display name with code if available.
  String get displayName {
    if (code != null) {
      return '$code - $name';
    }
    return name;
  }

  /// Format the base fare with currency.
  String get formattedFare {
    if (baseFare == null) return 'N/A';
    final curr = currency ?? Currency.KES;
    return curr.format(baseFare!);
  }

  /// Format the estimated duration.
  String get formattedDuration {
    if (estimatedDuration == null) return 'N/A';
    if (estimatedDuration! < 60) {
      return '$estimatedDuration min';
    }
    final hours = estimatedDuration! ~/ 60;
    final minutes = estimatedDuration! % 60;
    return '${hours}h ${minutes}m';
  }

  /// Creates a copy with modified fields.
  TransportRoute copyWith({
    String? id,
    String? name,
    String? code,
    OrganizationStatus? status,
    String? organizationId,
    String? description,
    String? startPoint,
    String? endPoint,
    int? estimatedDuration,
    double? distance,
    double? baseFare,
    Currency? currency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      status: status ?? this.status,
      organizationId: organizationId ?? this.organizationId,
      description: description ?? this.description,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      distance: distance ?? this.distance,
      baseFare: baseFare ?? this.baseFare,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        status,
        organizationId,
        description,
        startPoint,
        endPoint,
        estimatedDuration,
        distance,
        baseFare,
        currency,
        isActive,
        createdAt,
        updatedAt,
      ];
}
