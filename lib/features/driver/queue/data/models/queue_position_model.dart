import '../../domain/entities/queue_position.dart';

/// Data model for queue position.
///
/// Note: The backend may not have a dedicated queue endpoint.
/// This model works with vehicle assignment data and SignalR updates.
class QueuePositionModel {
  QueuePositionModel({
    required this.id,
    required this.position,
    required this.routeId,
    required this.routeName,
    required this.joinedAt,
    this.stageId,
    this.stageName,
    this.status = 'waiting',
    this.estimatedWaitMinutes,
    this.vehiclesAhead,
    this.vehicleRegistration,
  });

  final String id;
  final int position;
  final String routeId;
  final String routeName;
  final DateTime joinedAt;
  final String? stageId;
  final String? stageName;
  final String status;
  final int? estimatedWaitMinutes;
  final int? vehiclesAhead;
  final String? vehicleRegistration;

  factory QueuePositionModel.fromJson(Map<String, dynamic> json) {
    return QueuePositionModel(
      id: json['id']?.toString() ?? '',
      position: json['position'] as int? ?? 0,
      routeId: json['routeId']?.toString() ?? '',
      routeName: json['routeName'] as String? ?? '',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : DateTime.now(),
      stageId: json['stageId']?.toString(),
      stageName: json['stageName'] as String?,
      status: json['status'] as String? ?? 'waiting',
      estimatedWaitMinutes: json['estimatedWaitMinutes'] as int?,
      vehiclesAhead: json['vehiclesAhead'] as int?,
      vehicleRegistration: json['vehicleRegistration'] as String?,
    );
  }

  /// Creates from vehicle route assignment.
  factory QueuePositionModel.fromVehicleAssignment(
    Map<String, dynamic> vehicle,
    Map<String, dynamic> route,
    int position,
  ) {
    return QueuePositionModel(
      id: '${vehicle['id']}_${route['id']}',
      position: position,
      routeId: route['id']?.toString() ?? '',
      routeName: route['name'] as String? ?? '',
      joinedAt: DateTime.now(),
      vehicleRegistration: (vehicle['registrationNumber']
          as Map<String, dynamic>?)?['value'] as String?,
      vehiclesAhead: position - 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
        'routeId': routeId,
        'routeName': routeName,
        'joinedAt': joinedAt.toIso8601String(),
        if (stageId != null) 'stageId': stageId,
        if (stageName != null) 'stageName': stageName,
        'status': status,
        if (estimatedWaitMinutes != null)
          'estimatedWaitMinutes': estimatedWaitMinutes,
        if (vehiclesAhead != null) 'vehiclesAhead': vehiclesAhead,
        if (vehicleRegistration != null)
          'vehicleRegistration': vehicleRegistration,
      };

  QueuePosition toEntity() => QueuePosition(
        id: id,
        position: position,
        routeId: routeId,
        routeName: routeName,
        joinedAt: joinedAt,
        stageId: stageId,
        stageName: stageName,
        status: _mapStatus(status),
        estimatedWaitMinutes: estimatedWaitMinutes,
        vehiclesAhead: vehiclesAhead,
        vehicleRegistration: vehicleRegistration,
      );

  QueueStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'boarding':
        return QueueStatus.boarding;
      case 'departed':
        return QueueStatus.departed;
      case 'cancelled':
        return QueueStatus.cancelled;
      default:
        return QueueStatus.waiting;
    }
  }
}
