import 'package:komiut_app/driver/trip/domain/entities/trip.dart';
import 'package:komiut_app/driver/dashboard/data/models/dashboard_models.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.route,
    required super.scheduledTime,
    required super.status,
    required super.currentPassengerCount,
    required super.currentEarnings,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['trip_id'],
      route: CircleRouteModel.fromJson(json['route']),
      scheduledTime: DateTime.parse(json['scheduled_time'] ?? json['started_at'] ?? DateTime.now().toIso8601String()),
      status: _parseStatus(json['status']),
      currentPassengerCount: json['passenger_count'] ?? 0,
      currentEarnings: (json['current_earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static TripStatus _parseStatus(String status) {
    switch (status) {
      case 'scheduled': return TripStatus.scheduled;
      case 'started': return TripStatus.started;
      case 'in_progress': return TripStatus.inProgress;
      case 'completed': return TripStatus.completed;
      case 'cancelled': return TripStatus.cancelled;
      default: return TripStatus.scheduled;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': id,
      // 'route': (route as CircleRouteModel).toJson(), // Assuming cast is safe or map it
      'status': status.toString().split('.').last, // simplified
      'passenger_count': currentPassengerCount,
      'current_earnings': currentEarnings,
    };
  }
}
