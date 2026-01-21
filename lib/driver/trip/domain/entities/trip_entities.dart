import 'package:equatable/equatable.dart';

enum TripStatus {
  pending,
  loading,
  inProgress,
  completed,
  cancelled,
}

class Trip extends Equatable {
  final String tripId;
  final String routeId;
  final String routeName;
  final String startPoint;
  final String endPoint;
  final TripStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final int passengerCount;
  final int capacity;
  final double fare;
  final double totalEarnings;
  final List<Passenger> passengers;
  final List<TripStop> stops;

  const Trip({
    required this.tripId,
    required this.routeId,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    required this.status,
    this.startTime,
    this.endTime,
    required this.passengerCount,
    required this.capacity,
    required this.fare,
    required this.totalEarnings,
    this.passengers = const [],
    this.stops = const [],
  });

  bool get isInProgress => status == TripStatus.inProgress;
  bool get isCompleted => status == TripStatus.completed;
  int get availableSeats => capacity - passengerCount;

  @override
  List<Object?> get props => [
    tripId, routeId, routeName, startPoint, endPoint, status,
    startTime, endTime, passengerCount, capacity, fare, totalEarnings,
    passengers, stops,
  ];
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

  bool get hasPaid => paymentStatus == 'paid';

  @override
  List<Object?> get props => [
    passengerId, name, phoneNumber, profileImage,
    boardingPoint, alightingPoint, fare, paymentStatus, boardedAt,
  ];
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
