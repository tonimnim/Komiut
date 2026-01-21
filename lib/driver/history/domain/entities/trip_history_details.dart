import 'package:equatable/equatable.dart';

import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart' show CircleRoute;
import 'package:komiut_app/driver/earnings/domain/entities/earnings.dart';

class TripHistoryDetails extends Equatable {
  final String tripId;
  final String status;
  final CircleRoute route; // Reusing from dashbaord
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationMins;
  final double distanceKm;
  final int passengerCount;
  final Earnings earnings; // Reusing from Earnings feature

  const TripHistoryDetails({
    required this.tripId,
    required this.status,
    required this.route,
    required this.startedAt,
    required this.endedAt,
    required this.durationMins,
    required this.distanceKm,
    required this.passengerCount,
    required this.earnings,
  });

  @override
  List<Object?> get props => [
        tripId,
        status,
        route,
        startedAt,
        endedAt,
        durationMins,
        distanceKm,
        passengerCount,
        earnings,
      ];
}
