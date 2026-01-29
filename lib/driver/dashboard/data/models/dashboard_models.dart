import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';

class DriverProfileModel extends DriverProfile {
  const DriverProfileModel({
    required super.id,
    required super.organizationId,
    required super.name,
    required super.email,
    required super.phone,
    super.role,
    required super.status,
    required super.createdAt,
    super.imageUrl,
    super.rating,
    super.totalTrips,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      name: json['name'] as String? ?? 'Driver',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'],
      status: json['status'] is int ? json['status'] as int : (json['status'] == 'Active' ? 1 : 0),
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      imageUrl: json['imageUrl'] as String? ?? 'https://i.pravatar.cc/150?u=${json['id']}', // Mock image
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0, // Mock rating
      totalTrips: json['totalTrips'] as int? ?? 1420, // Mock trips
    );
  }
}

class RegistrationNumberModel extends RegistrationNumber {
  const RegistrationNumberModel({required super.value});

  factory RegistrationNumberModel.fromJson(Map<String, dynamic> json) {
    return RegistrationNumberModel(
      value: json['value'] as String? ?? 'UNKNOWN',
    );
  }
}

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.registrationNumber,
    required super.capacity,
    required super.status,
    super.currentRouteId,
    required super.organizationId,
    required super.domainId,
    required super.createdAt,
    super.updatedAt,
    super.model,
    super.year,
    super.color,
    super.type,
    super.insuranceExpiry,
    super.inspectionExpiry,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      registrationNumber: json['registrationNumber'] != null 
          ? RegistrationNumberModel.fromJson(json['registrationNumber'] as Map<String, dynamic>)
          : const RegistrationNumberModel(value: 'KBA 000X'),
      capacity: json['capacity'] as int? ?? 14,
      status: json['status']?.toString() ?? 'active',
      currentRouteId: json['currentRouteId'] as String?,
      organizationId: json['organizationId'] as String? ?? '',
      domainId: json['domainId'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      
      // Default values for fields missing in Swagger
      model: json['model'] as String? ?? 'Toyota Hiace',
      year: json['year'] as int? ?? 2021,
      color: json['color'] as String? ?? 'White',
      type: json['type'] as String? ?? 'PSV',
      insuranceExpiry: json['insuranceExpiry'] != null 
          ? DateTime.parse(json['insuranceExpiry'] as String) 
          : DateTime.now().add(const Duration(days: 90)), // Mock 90 days out
      inspectionExpiry: json['inspectionExpiry'] != null 
          ? DateTime.parse(json['inspectionExpiry'] as String) 
          : DateTime.now().add(const Duration(days: 60)), // Mock 60 days out
    );
  }
}


class CircleModel extends Circle {
  const CircleModel({
    required super.id,
    required super.name,
    super.description,
    required super.lat,
    required super.lng,
    required super.radiusKm,
  });

  factory CircleModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>?;
    return CircleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      lat: (coords?['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (coords?['lng'] as num?)?.toDouble() ?? 0.0,
      radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CircleRouteModel extends CircleRoute {
  const CircleRouteModel({
    required super.id,
    required super.name,
    required super.code,
    required super.status,
    required super.organizationId,
    required super.createdAt,
    super.circleName,
    super.pickupPoint,
  });

  factory CircleRouteModel.fromJson(Map<String, dynamic> json) {
    return CircleRouteModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      status: json['status']?.toString() ?? 'active',
      organizationId: json['organizationId'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      circleName: json['circle_name'] as String? ?? json['domainName'] as String?,
      pickupPoint: json['pickup_point'] as String?,
    );
  }
}


class RoutePointModel extends RoutePoint {
  const RoutePointModel({
    required super.name,
    required super.lat,
    required super.lng,
    super.order,
  });

  factory RoutePointModel.fromJson(Map<String, dynamic> json) {
    return RoutePointModel(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      order: json['order'] as int?,
    );
  }
}

class EarningsSummaryModel extends EarningsSummary {
  const EarningsSummaryModel({
    required super.tripCount,
    required super.totalEarnings,
  });

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> json) {
    return EarningsSummaryModel(
      tripCount: json['total_trips'] as int? ?? 0,
      totalEarnings: (json['net_earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
