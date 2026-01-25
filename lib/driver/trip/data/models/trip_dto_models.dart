import 'package:komiut_app/driver/trip/domain/entities/trip_entities.dart';

class TripDtoModel extends TripDto {
  const TripDtoModel({
    required super.id,
    required super.vehicleId,
    required super.vehicleRegistrationNumber,
    required super.routeId,
    super.routeName,
    required super.driverId,
    super.driverName,
    super.toutId,
    super.toutName,
    required super.startTime,
    super.endTime,
    required super.status,
    required super.createdAt,
  });

  factory TripDtoModel.fromJson(Map<String, dynamic> json) {
    return TripDtoModel(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      vehicleRegistrationNumber: json['vehicleRegistrationNumber']['value'] as String,
      routeId: json['routeId'] as String,
      routeName: json['routeName'] as String?,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String?,
      toutId: json['toutId'] as String?,
      toutName: json['toutName'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
