import 'package:equatable/equatable.dart';

class TripDto extends Equatable {
  final String id;
  final String vehicleId;
  final String vehicleRegistrationNumber;
  final String routeId;
  final String? routeName;
  final String driverId;
  final String? driverName;
  final String? toutId;
  final String? toutName;
  final DateTime startTime;
  final DateTime? endTime;
  final int status; // TripStatus enum (0, 1, 2)
  final DateTime createdAt;

  const TripDto({
    required this.id,
    required this.vehicleId,
    required this.vehicleRegistrationNumber,
    required this.routeId,
    this.routeName,
    required this.driverId,
    this.driverName,
    this.toutId,
    this.toutName,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        vehicleRegistrationNumber,
        routeId,
        routeName,
        driverId,
        driverName,
        toutId,
        toutName,
        startTime,
        endTime,
        status,
        createdAt,
      ];
}
