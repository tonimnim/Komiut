import 'package:equatable/equatable.dart';

class DriverProfile extends Equatable {
  final String id;
  final String organizationId;
  final String name;
  final String email;
  final String phone;
  final dynamic role; // PersonnelRole in swagger
  final int status; // PersonnelStatus (enum 0, 1)
  final DateTime createdAt;
  final String? imageUrl;
  final double? rating;
  final int? totalTrips;

  const DriverProfile({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.email,
    required this.phone,
    this.role,
    required this.status,
    required this.createdAt,
    this.imageUrl,
    this.rating,
    this.totalTrips,
  });

  bool get isOnline => status == 1; // Assuming 1 is Active/Online based on Swagger
  bool get isOffline => status == 0;

  @override
  List<Object?> get props => [id, organizationId, name, email, phone, role, status, createdAt, imageUrl, rating, totalTrips];

  DriverProfile copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? email,
    String? phone,
    dynamic role,
    int? status,
    DateTime? createdAt,
    String? imageUrl,
    double? rating,
    int? totalTrips,
  }) {
    return DriverProfile(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
    );
  }
}

class RegistrationNumber extends Equatable {
  final String value;

  const RegistrationNumber({required this.value});

  @override
  List<Object?> get props => [value];
}

class Vehicle extends Equatable {
  final String id;
  final RegistrationNumber registrationNumber;
  final int capacity;
  final String status;
  final String? currentRouteId;
  final String organizationId;
  final String domainId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? model;
  final int? year;
  final String? color;
  final String? type;
  final DateTime? insuranceExpiry;
  final DateTime? inspectionExpiry;

  const Vehicle({
    required this.id,
    required this.registrationNumber,
    required this.capacity,
    required this.status,
    this.currentRouteId,
    required this.organizationId,
    required this.domainId,
    required this.createdAt,
    this.updatedAt,
    this.model,
    this.year,
    this.color,
    this.type,
    this.insuranceExpiry,
    this.inspectionExpiry,
  });

  @override
  List<Object?> get props => [
        id,
        registrationNumber,
        capacity,
        status,
        currentRouteId,
        organizationId,
        domainId,
        createdAt,
        updatedAt,
        model,
        year,
        color,
        type,
        insuranceExpiry,
        inspectionExpiry,
      ];
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
  final String name;
  final String code;
  final String status;
  final String organizationId;
  final DateTime createdAt;
  final String? circleName;
  final String? pickupPoint;

  const CircleRoute({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.organizationId,
    required this.createdAt,
    this.circleName,
    this.pickupPoint,
  });

  @override
  List<Object?> get props => [id, name, code, status, organizationId, createdAt, circleName, pickupPoint];
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
