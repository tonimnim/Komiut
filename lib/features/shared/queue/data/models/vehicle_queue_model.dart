/// Vehicle queue API model.
///
/// Data transfer object for VehicleQueue entity matching API schema.
library;

import '../../domain/entities/vehicle_queue.dart';
import 'queued_vehicle_model.dart';

/// Vehicle queue model for API communication.
///
/// Handles serialization/deserialization of queue data
/// from the API and conversion to domain entities.
class VehicleQueueModel {
  /// Creates a new VehicleQueueModel instance.
  const VehicleQueueModel({
    required this.routeId,
    required this.routeName,
    required this.vehicles,
    required this.lastUpdated,
    this.stageName,
    this.stageId,
    this.organizationId,
    this.organizationName,
  });

  /// Creates from JSON map.
  factory VehicleQueueModel.fromJson(Map<String, dynamic> json) {
    final vehiclesJson = json['vehicles'] as List<dynamic>? ??
        json['queuedVehicles'] as List<dynamic>? ??
        [];

    return VehicleQueueModel(
      routeId: json['routeId'] as String? ?? json['id'] as String? ?? '',
      routeName: json['routeName'] as String? ?? json['name'] as String? ?? '',
      vehicles: vehiclesJson
          .map((v) => QueuedVehicleModel.fromJson(v as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position)),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
      stageName:
          json['stageName'] as String? ?? json['terminalName'] as String?,
      stageId: json['stageId'] as String? ?? json['terminalId'] as String?,
      organizationId:
          json['organizationId'] as String? ?? json['saccoId'] as String?,
      organizationName:
          json['organizationName'] as String? ?? json['saccoName'] as String?,
    );
  }

  /// Creates from domain entity.
  factory VehicleQueueModel.fromEntity(VehicleQueue entity) {
    return VehicleQueueModel(
      routeId: entity.routeId,
      routeName: entity.routeName,
      vehicles:
          entity.vehicles.map((v) => QueuedVehicleModel.fromEntity(v)).toList(),
      lastUpdated: entity.lastUpdated,
      stageName: entity.stageName,
      stageId: entity.stageId,
      organizationId: entity.organizationId,
      organizationName: entity.organizationName,
    );
  }

  final String routeId;
  final String routeName;
  final List<QueuedVehicleModel> vehicles;
  final DateTime lastUpdated;
  final String? stageName;
  final String? stageId;
  final String? organizationId;
  final String? organizationName;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'routeId': routeId,
        'routeName': routeName,
        'vehicles': vehicles.map((v) => v.toJson()).toList(),
        'lastUpdated': lastUpdated.toIso8601String(),
        if (stageName != null) 'stageName': stageName,
        if (stageId != null) 'stageId': stageId,
        if (organizationId != null) 'organizationId': organizationId,
        if (organizationName != null) 'organizationName': organizationName,
      };

  /// Converts to domain entity.
  VehicleQueue toEntity() => VehicleQueue(
        routeId: routeId,
        routeName: routeName,
        vehicles: vehicles.map((v) => v.toEntity()).toList(),
        lastUpdated: lastUpdated,
        stageName: stageName,
        stageId: stageId,
        organizationId: organizationId,
        organizationName: organizationName,
      );
}

/// Response model for paginated queue list.
///
/// Used when fetching multiple queues with pagination.
class VehicleQueueListResponse {
  /// Creates a new VehicleQueueListResponse instance.
  const VehicleQueueListResponse({
    required this.queues,
    required this.totalCount,
    this.page = 1,
    this.pageSize = 20,
  });

  /// Creates from JSON map.
  factory VehicleQueueListResponse.fromJson(Map<String, dynamic> json) {
    final queuesJson = json['data'] as List<dynamic>? ??
        json['queues'] as List<dynamic>? ??
        json['items'] as List<dynamic>? ??
        [];

    return VehicleQueueListResponse(
      queues: queuesJson
          .map((q) => VehicleQueueModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int? ??
          json['total'] as int? ??
          queuesJson.length,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }

  final List<VehicleQueueModel> queues;
  final int totalCount;
  final int page;
  final int pageSize;

  /// Total number of pages.
  int get totalPages => (totalCount / pageSize).ceil();

  /// Whether there are more pages.
  bool get hasMore => page < totalPages;

  /// Converts to list of domain entities.
  List<VehicleQueue> toEntities() => queues.map((q) => q.toEntity()).toList();
}
