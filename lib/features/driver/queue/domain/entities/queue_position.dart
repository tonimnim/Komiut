import 'package:equatable/equatable.dart';

/// Status of a driver in the queue.
enum QueueStatus {
  waiting,
  boarding,
  departed,
  cancelled,
}

/// Represents a driver's position in the stage queue.
class QueuePosition extends Equatable {
  const QueuePosition({
    required this.id,
    required this.position,
    required this.routeId,
    required this.routeName,
    required this.joinedAt,
    this.stageId,
    this.stageName,
    this.status = QueueStatus.waiting,
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
  final QueueStatus status;
  final int? estimatedWaitMinutes;
  final int? vehiclesAhead;
  final String? vehicleRegistration;

  /// Whether the driver is first in queue.
  bool get isFirst => position == 1;

  /// Whether the driver is currently waiting.
  bool get isWaiting => status == QueueStatus.waiting;

  /// Whether the driver is boarding passengers.
  bool get isBoarding => status == QueueStatus.boarding;

  /// Duration since joining the queue.
  Duration get waitDuration => DateTime.now().difference(joinedAt);

  /// Formatted wait time for display.
  String get displayWaitTime {
    final duration = waitDuration;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }

  /// Formatted estimated wait for display.
  String get displayEstimatedWait {
    if (estimatedWaitMinutes == null) return 'Unknown';
    if (estimatedWaitMinutes! < 60) return '~$estimatedWaitMinutes min';
    final hours = estimatedWaitMinutes! ~/ 60;
    final mins = estimatedWaitMinutes! % 60;
    return '~${hours}h ${mins}m';
  }

  /// Human-readable status name.
  String get statusName {
    switch (status) {
      case QueueStatus.waiting:
        return 'Waiting';
      case QueueStatus.boarding:
        return 'Boarding';
      case QueueStatus.departed:
        return 'Departed';
      case QueueStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  List<Object?> get props => [
        id,
        position,
        routeId,
        routeName,
        joinedAt,
        stageId,
        stageName,
        status,
        estimatedWaitMinutes,
        vehiclesAhead,
        vehicleRegistration,
      ];

  QueuePosition copyWith({
    String? id,
    int? position,
    String? routeId,
    String? routeName,
    DateTime? joinedAt,
    String? stageId,
    String? stageName,
    QueueStatus? status,
    int? estimatedWaitMinutes,
    int? vehiclesAhead,
    String? vehicleRegistration,
  }) {
    return QueuePosition(
      id: id ?? this.id,
      position: position ?? this.position,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      joinedAt: joinedAt ?? this.joinedAt,
      stageId: stageId ?? this.stageId,
      stageName: stageName ?? this.stageName,
      status: status ?? this.status,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      vehiclesAhead: vehiclesAhead ?? this.vehiclesAhead,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
    );
  }
}
