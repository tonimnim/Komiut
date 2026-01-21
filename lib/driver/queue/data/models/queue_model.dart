import '../../domain/entities/queue_entities.dart';

class QueuePositionModel extends QueuePosition {
  const QueuePositionModel({
    required super.queueEntryId,
    required super.position,
    required super.vehiclesAhead,
    required super.estimatedWaitMins,
    required super.status,
    required super.joinedAt,
  });

  factory QueuePositionModel.fromJson(Map<String, dynamic> json) {
    return QueuePositionModel(
      queueEntryId: json['queue_entry_id'],
      position: json['position'],
      vehiclesAhead: json['vehicles_ahead'],
      estimatedWaitMins: json['estimated_wait_mins'],
      status: json['status'],
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'queue_entry_id': queueEntryId,
      'position': position,
      'vehicles_ahead': vehiclesAhead,
      'estimated_wait_mins': estimatedWaitMins,
      'status': status,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

class QueueStatusModel extends QueueStatus {
  const QueueStatusModel({
    required super.queueId,
    required super.routeId,
    required super.totalVehicles,
    required super.estimatedWaitMins,
    required super.isDriverInQueue,
    super.driverPosition,
  });

  factory QueueStatusModel.fromJson(Map<String, dynamic> json) {
    return QueueStatusModel(
      queueId: json['queue_id'],
      routeId: json['route_id'],
      totalVehicles: json['total_vehicles'],
      estimatedWaitMins: json['estimated_wait_mins'],
      isDriverInQueue: json['is_driver_in_queue'] ?? false,
      driverPosition: json['driver_position'],
    );
  }
}
