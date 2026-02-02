import '../../domain/entities/driver_trip.dart';

/// Data model for driver trip.
///
/// Maps to TripDto from the backend API:
/// GET /api/Trips
class DriverTripModel {
  DriverTripModel({
    required this.id,
    required this.vehicleId,
    required this.routeId,
    required this.routeName,
    required this.status,
    required this.startTime,
    this.vehicleRegistration,
    this.driverId,
    this.driverName,
    this.toutId,
    this.toutName,
    this.endTime,
    this.createdAt,
    this.passengerCount,
    this.maxCapacity,
    this.fare,
  });

  final String id;
  final String vehicleId;
  final String routeId;
  final String routeName;
  final int status;
  final DateTime startTime;
  final String? vehicleRegistration;
  final String? driverId;
  final String? driverName;
  final String? toutId;
  final String? toutName;
  final DateTime? endTime;
  final DateTime? createdAt;
  final int? passengerCount;
  final int? maxCapacity;
  final double? fare;

  /// Creates from TripDto JSON.
  ///
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "vehicleId": "uuid",
  ///   "vehicleRegistrationNumber": { "value": "KAA 123A" },
  ///   "routeId": "uuid",
  ///   "routeName": "CBD - Westlands",
  ///   "driverId": "uuid",
  ///   "driverName": "John Doe",
  ///   "startTime": "2026-02-02T01:14:04.775Z",
  ///   "endTime": null,
  ///   "status": 1,
  ///   "createdAt": "2026-02-02T01:14:04.775Z"
  /// }
  /// ```
  factory DriverTripModel.fromJson(Map<String, dynamic> json) {
    return DriverTripModel(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      routeId: json['routeId']?.toString() ?? '',
      routeName: json['routeName'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      vehicleRegistration: (json['vehicleRegistrationNumber']
          as Map<String, dynamic>?)?['value'] as String?,
      driverId: json['driverId']?.toString(),
      driverName: json['driverName'] as String?,
      toutId: json['toutId']?.toString(),
      toutName: json['toutName'] as String?,
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      passengerCount: json['passengerCount'] as int?,
      maxCapacity: json['maxCapacity'] as int?,
      fare: (json['fare'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'routeId': routeId,
        'routeName': routeName,
        'status': status,
        'startTime': startTime.toIso8601String(),
        if (vehicleRegistration != null)
          'vehicleRegistrationNumber': {'value': vehicleRegistration},
        if (driverId != null) 'driverId': driverId,
        if (driverName != null) 'driverName': driverName,
        if (toutId != null) 'toutId': toutId,
        if (toutName != null) 'toutName': toutName,
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  DriverTrip toEntity() => DriverTrip(
        id: id,
        routeId: routeId,
        routeName: routeName,
        status: _mapStatus(status),
        startTime: startTime,
        endTime: endTime,
        passengerCount: passengerCount ?? 0,
        maxCapacity: maxCapacity,
        fare: fare ?? 0.0,
        vehicleRegistration: vehicleRegistration,
      );

  DriverTripStatus _mapStatus(int status) {
    switch (status) {
      case 0:
        return DriverTripStatus.pending;
      case 1:
        return DriverTripStatus.active;
      case 2:
        return DriverTripStatus.completed;
      default:
        return DriverTripStatus.cancelled;
    }
  }

  static int statusToInt(DriverTripStatus status) {
    switch (status) {
      case DriverTripStatus.pending:
        return 0;
      case DriverTripStatus.active:
        return 1;
      case DriverTripStatus.completed:
        return 2;
      case DriverTripStatus.cancelled:
        return 3;
    }
  }
}
