import 'package:equatable/equatable.dart';

class DriverProfile extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImage;
  final double rating;
  final int totalTrips;
  final String status; // offline, online, on_trip

  const DriverProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImage,
    required this.rating,
    required this.totalTrips,
    required this.status,
  });

  bool get isOnline => status == 'online';
  bool get isOffline => status == 'offline';
  bool get isOnTrip => status == 'on_trip';

  @override
  List<Object?> get props => [id, name, phone, email, profileImage, rating, totalTrips, status];
}

class Vehicle extends Equatable {
  final String id;
  final String plateNumber;
  final String type;
  final int capacity;
  final String model;
  final int year;
  final String color;
  final String status;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.type,
    required this.capacity,
    required this.model,
    required this.year,
    required this.color,
    required this.status,
  });

  @override
  List<Object?> get props => [id, plateNumber, type, capacity, model, year, color, status];
}

class Circle extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double lat;
  final double lng;
  final double radiusKm;

  const Circle({
    required this.id,
    required this.name,
    this.description,
    required this.lat,
    required this.lng,
    required this.radiusKm,
  });

  @override
  List<Object?> get props => [id, name, description, lat, lng, radiusKm];
}

class CircleRoute extends Equatable {
  final String id;
  final String number;
  final String name;
  final String? description;
  final String circleId;
  final RoutePoint startPoint;
  final RoutePoint endPoint;
  final List<RoutePoint> stops;
  final double fare;
  final int estimatedDurationMins;

  const CircleRoute({
    required this.id,
    required this.number,
    required this.name,
    this.description,
    required this.circleId,
    required this.startPoint,
    required this.endPoint,
    required this.stops,
    required this.fare,
    required this.estimatedDurationMins,
  });

  @override
  List<Object?> get props => [id, number, name, description, circleId, startPoint, endPoint, stops, fare, estimatedDurationMins];
}

class RoutePoint extends Equatable {
  final String name;
  final double lat;
  final double lng;
  final int? order;

  const RoutePoint({
    required this.name,
    required this.lat,
    required this.lng,
    this.order,
  });

  @override
  List<Object?> get props => [name, lat, lng, order];
}

class EarningsSummary extends Equatable {
  final int tripCount;
  final double totalEarnings;

  const EarningsSummary({
    required this.tripCount,
    required this.totalEarnings,
  });

  @override
  List<Object?> get props => [tripCount, totalEarnings];
}
