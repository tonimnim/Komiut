import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart';

class DriverProfileModel extends DriverProfile {
  const DriverProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.profileImage,
    required super.rating,
    required super.totalTrips,
    required super.status,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      profileImage: json['profile_image'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: json['total_trips'] as int? ?? 0,
      status: json['status'] as String? ?? 'offline',
    );
  }
}

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.plateNumber,
    required super.type,
    required super.capacity,
    required super.model,
    required super.year,
    required super.color,
    required super.status,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      plateNumber: json['plate_number'] as String,
      type: json['type'] as String,
      capacity: json['capacity'] as int,
      model: json['model'] as String,
      year: json['year'] as int,
      color: json['color'] as String,
      status: json['status'] as String? ?? 'active',
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
    required super.number,
    required super.name,
    super.description,
    required super.circleId,
    required super.startPoint,
    required super.endPoint,
    required super.stops,
    required super.fare,
    required super.estimatedDurationMins,
  });

  factory CircleRouteModel.fromJson(Map<String, dynamic> json) {
    final startJson = json['start_point'] as Map<String, dynamic>;
    final endJson = json['end_point'] as Map<String, dynamic>;
    final stopsJson = json['stops'] as List<dynamic>? ?? [];

    return CircleRouteModel(
      id: json['id'] as String,
      number: json['number'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String?,
      circleId: json['circle_id'] as String,
      startPoint: RoutePointModel.fromJson(startJson),
      endPoint: RoutePointModel.fromJson(endJson),
      stops: stopsJson.map((s) => RoutePointModel.fromJson(s)).toList(),
      fare: (json['fare'] as num).toDouble(),
      estimatedDurationMins: json['estimated_duration_mins'] as int,
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
