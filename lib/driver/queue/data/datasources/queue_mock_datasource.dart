import 'package:komiut/driver/queue/data/datasources/queue_remote_datasource.dart';
import 'package:komiut/driver/queue/data/models/queue_model.dart';

import 'package:komiut/driver/dashboard/data/datasources/dashboard_mock_datasource.dart';

class QueueMockDataSource implements QueueRemoteDataSource {
  @override
  Future<QueueStatusModel> getQueueStatus(String routeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return QueueStatusModel(
      queueId: 'mock-queue-123',
      routeId: routeId,
      totalVehicles: 15,
      estimatedWaitMins: 45,
      isDriverInQueue: false,
    );
  }

  @override
  Future<QueuePositionModel> joinQueue(String routeId, double lat, double lng) async {
    _isInQueueInternal = true;
    
    DashboardMockDataSource.addNotification(
      'Joined Queue',
      'You are now #16 in the queue. Est. wait: 45 min',
      'status',
    );
    
    return QueuePositionModel(
      queueEntryId: 'mock-entry-123',
      position: 16,
      vehiclesAhead: 15,
      estimatedWaitMins: 45,
      status: 'waiting',
      joinedAt: DateTime.now(),
    );
  }

  static bool _isInQueueInternal = false;

  @override
  Future<QueuePositionModel> getQueuePosition() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_isInQueueInternal) {
      throw Exception('Not in queue');
    }
    return QueuePositionModel(
      queueEntryId: 'mock-entry-123',
      position: 3,
      vehiclesAhead: 2,
      estimatedWaitMins: 8,
      status: 'waiting',
      joinedAt: DateTime.now().subtract(const Duration(minutes: 20)),
    );
  }

  static void setInQueue(bool inQueue) {
    _isInQueueInternal = inQueue;
  }

  @override
  Future<void> leaveQueue() async {
    _isInQueueInternal = false;
  }

  @override
  Future<List<QueuePositionModel>> getQueueList(String routeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      QueuePositionModel(
        queueEntryId: 'entry-1',
        position: 1,
        vehiclesAhead: 0,
        estimatedWaitMins: 0,
        status: 'ready',
        joinedAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      QueuePositionModel(
        queueEntryId: 'entry-2',
        position: 2,
        vehiclesAhead: 1,
        estimatedWaitMins: 5,
        status: 'waiting',
        joinedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      QueuePositionModel(
        queueEntryId: 'mock-entry-123',
        position: 3,
        vehiclesAhead: 2,
        estimatedWaitMins: 8,
        status: 'waiting',
        joinedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ];
  }
}
