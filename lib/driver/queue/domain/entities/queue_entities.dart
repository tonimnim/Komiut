import 'package:equatable/equatable.dart';

class QueuePosition extends Equatable {
  final String queueEntryId;
  final int position;
  final int vehiclesAhead;
  final int estimatedWaitMins;
  final String status;
  final DateTime joinedAt;

  const QueuePosition({
    required this.queueEntryId,
    required this.position,
    required this.vehiclesAhead,
    required this.estimatedWaitMins,
    required this.status,
    required this.joinedAt,
  });

  bool get isReady => status == 'ready';
  bool get isWaiting => status == 'waiting';

  @override
  List<Object?> get props => [queueEntryId, position, vehiclesAhead, estimatedWaitMins, status, joinedAt];
}

class QueueStatus extends Equatable {
  final String queueId;
  final String routeId;
  final int totalVehicles;
  final int estimatedWaitMins;
  final bool isDriverInQueue;
  final int? driverPosition;

  const QueueStatus({
    required this.queueId,
    required this.routeId,
    required this.totalVehicles,
    required this.estimatedWaitMins,
    required this.isDriverInQueue,
    this.driverPosition,
  });

  @override
  List<Object?> get props => [queueId, routeId, totalVehicles, estimatedWaitMins, isDriverInQueue, driverPosition];
}
