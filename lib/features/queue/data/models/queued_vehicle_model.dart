/// Queued vehicle API model.
///
/// Data transfer object for QueuedVehicle entity matching API schema.
library;

import '../../domain/entities/queued_vehicle.dart';

/// Queued vehicle model for API communication.
///
/// Handles serialization/deserialization of vehicle queue data
/// from the API and conversion to domain entities.
class QueuedVehicleModel {
  /// Creates a new QueuedVehicleModel instance.
  const QueuedVehicleModel({
    required this.vehicleId,
    required this.registrationNumber,
    required this.position,
    required this.availableSeats,
    required this.totalSeats,
    this.estimatedDepartureTime,
    required this.currentStatus,
    this.driverName,
    this.driverPhone,
    this.vehicleType,
    this.organizationName,
  });

  /// Creates from JSON map.
  factory QueuedVehicleModel.fromJson(Map<String, dynamic> json) {
    return QueuedVehicleModel(
      vehicleId: json['vehicleId'] as String? ?? json['id'] as String,
      registrationNumber: json['registrationNumber'] as String? ??
          json['plateNumber'] as String? ??
          '',
      position: json['position'] as int? ?? json['queuePosition'] as int? ?? 0,
      availableSeats: json['availableSeats'] as int? ??
          json['seatsAvailable'] as int? ??
          0,
      totalSeats:
          json['totalSeats'] as int? ?? json['capacity'] as int? ?? 14,
      estimatedDepartureTime: json['estimatedDepartureTime'] != null
          ? DateTime.parse(json['estimatedDepartureTime'] as String)
          : json['estimatedDeparture'] != null
              ? DateTime.parse(json['estimatedDeparture'] as String)
              : null,
      currentStatus: _parseStatus(
        json['currentStatus'] as String? ?? json['status'] as String? ?? 'waiting',
      ),
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String? ??
          json['driverPhoneNumber'] as String?,
      vehicleType: json['vehicleType'] as String? ?? json['type'] as String?,
      organizationName: json['organizationName'] as String? ??
          json['saccoName'] as String?,
    );
  }

  /// Creates from domain entity.
  factory QueuedVehicleModel.fromEntity(QueuedVehicle entity) {
    return QueuedVehicleModel(
      vehicleId: entity.vehicleId,
      registrationNumber: entity.registrationNumber,
      position: entity.position,
      availableSeats: entity.availableSeats,
      totalSeats: entity.totalSeats,
      estimatedDepartureTime: entity.estimatedDepartureTime,
      currentStatus: entity.currentStatus,
      driverName: entity.driverName,
      driverPhone: entity.driverPhone,
      vehicleType: entity.vehicleType,
      organizationName: entity.organizationName,
    );
  }

  final String vehicleId;
  final String registrationNumber;
  final int position;
  final int availableSeats;
  final int totalSeats;
  final DateTime? estimatedDepartureTime;
  final QueuedVehicleStatus currentStatus;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleType;
  final String? organizationName;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'registrationNumber': registrationNumber,
        'position': position,
        'availableSeats': availableSeats,
        'totalSeats': totalSeats,
        if (estimatedDepartureTime != null)
          'estimatedDepartureTime': estimatedDepartureTime!.toIso8601String(),
        'currentStatus': currentStatus.toJson,
        if (driverName != null) 'driverName': driverName,
        if (driverPhone != null) 'driverPhone': driverPhone,
        if (vehicleType != null) 'vehicleType': vehicleType,
        if (organizationName != null) 'organizationName': organizationName,
      };

  /// Converts to domain entity.
  QueuedVehicle toEntity() => QueuedVehicle(
        vehicleId: vehicleId,
        registrationNumber: registrationNumber,
        position: position,
        availableSeats: availableSeats,
        totalSeats: totalSeats,
        estimatedDepartureTime: estimatedDepartureTime,
        currentStatus: currentStatus,
        driverName: driverName,
        driverPhone: driverPhone,
        vehicleType: vehicleType,
        organizationName: organizationName,
      );

  /// Parses status string to enum.
  static QueuedVehicleStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'boarding':
        return QueuedVehicleStatus.boarding;
      case 'departing':
        return QueuedVehicleStatus.departing;
      case 'waiting':
      default:
        return QueuedVehicleStatus.waiting;
    }
  }
}
