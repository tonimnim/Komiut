import 'package:equatable/equatable.dart';
import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart' show CircleRoute;

enum TripStatus { scheduled, started, inProgress, completed, cancelled }

class Trip extends Equatable {
  final String id;
  final CircleRoute route;
  final DateTime scheduledTime;
  final TripStatus status;
  final int currentPassengerCount;
  final double currentEarnings;
  final List<Passenger> passengers;
  final List<TripStop> stops;

  const Trip({
    required this.id,
    required this.route,
    required this.scheduledTime,
    required this.status,
    required this.currentPassengerCount,
    required this.currentEarnings,
    this.passengers = const [],
    this.stops = const [],
  });

  int get passengerCount => currentPassengerCount;
  double get earnings => currentEarnings;
  String get destination => route.endPoint.name;
  String get origin => route.startPoint.name;

  @override
  List<Object?> get props => [id, route, scheduledTime, status, currentPassengerCount, currentEarnings, passengers, stops];
}

class Passenger extends Equatable {
  final String passengerId;
  final String name;
  final String? phoneNumber;
  final String? profileImage;
  final String boardingPoint;
  final String alightingPoint;
  final double fare;
  final String paymentStatus;
  final DateTime boardedAt;

  const Passenger({
    required this.passengerId,
    required this.name,
    this.phoneNumber,
    this.profileImage,
    required this.boardingPoint,
    required this.alightingPoint,
    required this.fare,
    required this.paymentStatus,
    required this.boardedAt,
  });

  @override
  List<Object?> get props => [passengerId, name, phoneNumber, profileImage, boardingPoint, alightingPoint, fare, paymentStatus, boardedAt];
}

class TripStop extends Equatable {
  final String stopId;
  final String name;
  final double lat;
  final double lng;
  final int order;
  final bool isReached;
  final DateTime? reachedAt;

  const TripStop({
    required this.stopId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.order,
    required this.isReached,
    this.reachedAt,
  });

  @override
  List<Object?> get props => [stopId, name, lat, lng, order, isReached, reachedAt];
}
