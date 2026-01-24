/// Trip API model.
///
/// Data transfer object for Trip entity matching API schema.
library;

import '../../domain/entities/trip.dart';
import '../../domain/enums/enums.dart';

/// Trip model for API communication.
class TripModel {
  /// Creates a new TripModel instance.
  const TripModel({
    required this.id,
    required this.vehicleId,
    required this.routeId,
    this.driverId,
    this.toutId,
    this.startTime,
    this.endTime,
    required this.status,
    this.vehicleRegistration,
    this.routeName,
    this.driverName,
    this.toutName,
    this.availableSeats,
    this.totalSeats,
    this.currentStopId,
    this.nextStopId,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates from JSON map.
  /// Handles both flat and nested vehicleRegistrationNumber formats from API.
  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Handle nested value object format: { "vehicleRegistrationNumber": { "value": "KAA 123A" } }
    String? vehicleReg;
    final regField = json['vehicleRegistrationNumber'] ?? json['vehicleRegistration'];
    if (regField is Map<String, dynamic>) {
      vehicleReg = regField['value'] as String?;
    } else {
      vehicleReg = regField as String?;
    }

    // Handle status as int (from API) or string
    TripStatus tripStatus;
    final statusField = json['status'];
    if (statusField is int) {
      tripStatus = TripStatus.values[statusField.clamp(0, TripStatus.values.length - 1)];
    } else {
      tripStatus = tripStatusFromString(statusField as String? ?? 'scheduled');
    }

    return TripModel(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      routeId: json['routeId'] as String,
      driverId: json['driverId'] as String?,
      toutId: json['toutId'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      status: tripStatus,
      vehicleRegistration: vehicleReg,
      routeName: json['routeName'] as String?,
      driverName: json['driverName'] as String?,
      toutName: json['toutName'] as String?,
      availableSeats: json['availableSeats'] as int?,
      totalSeats: json['totalSeats'] as int?,
      currentStopId: json['currentStopId'] as String?,
      nextStopId: json['nextStopId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory TripModel.fromEntity(Trip entity) {
    return TripModel(
      id: entity.id,
      vehicleId: entity.vehicleId,
      routeId: entity.routeId,
      driverId: entity.driverId,
      toutId: entity.toutId,
      startTime: entity.startTime,
      endTime: entity.endTime,
      status: entity.status,
      vehicleRegistration: entity.vehicleRegistration,
      routeName: entity.routeName,
      driverName: entity.driverName,
      toutName: entity.toutName,
      availableSeats: entity.availableSeats,
      totalSeats: entity.totalSeats,
      currentStopId: entity.currentStopId,
      nextStopId: entity.nextStopId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String vehicleId;
  final String routeId;
  final String? driverId;
  final String? toutId;
  final DateTime? startTime;
  final DateTime? endTime;
  final TripStatus status;
  final String? vehicleRegistration;
  final String? routeName;
  final String? driverName;
  final String? toutName;
  final int? availableSeats;
  final int? totalSeats;
  final String? currentStopId;
  final String? nextStopId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'routeId': routeId,
        if (driverId != null) 'driverId': driverId,
        if (toutId != null) 'toutId': toutId,
        if (startTime != null) 'startTime': startTime!.toIso8601String(),
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        'status': status.toApiValue(),
        if (vehicleRegistration != null)
          'vehicleRegistration': vehicleRegistration,
        if (routeName != null) 'routeName': routeName,
        if (driverName != null) 'driverName': driverName,
        if (toutName != null) 'toutName': toutName,
        if (availableSeats != null) 'availableSeats': availableSeats,
        if (totalSeats != null) 'totalSeats': totalSeats,
        if (currentStopId != null) 'currentStopId': currentStopId,
        if (nextStopId != null) 'nextStopId': nextStopId,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  Trip toEntity() => Trip(
        id: id,
        vehicleId: vehicleId,
        routeId: routeId,
        driverId: driverId,
        toutId: toutId,
        startTime: startTime,
        endTime: endTime,
        status: status,
        vehicleRegistration: vehicleRegistration,
        routeName: routeName,
        driverName: driverName,
        toutName: toutName,
        availableSeats: availableSeats,
        totalSeats: totalSeats,
        currentStopId: currentStopId,
        nextStopId: nextStopId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
