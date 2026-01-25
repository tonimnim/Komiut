/// Daily vehicle total API model.
///
/// Data transfer object for DailyVehicleTotal entity matching API schema.
library;

import '../../domain/entities/daily_vehicle_total.dart';
import '../../domain/enums/enums.dart';

/// DailyVehicleTotal model for API communication.
class DailyVehicleTotalModel {
  /// Creates a new DailyVehicleTotalModel instance.
  const DailyVehicleTotalModel({
    required this.vehicleId,
    required this.currency,
    required this.totalCollected,
    required this.date,
    this.vehicleRegistration,
    this.tripCount,
    this.passengerCount,
    this.routeId,
    this.routeName,
    this.cashCollected,
    this.mobileCollected,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates from JSON map.
  factory DailyVehicleTotalModel.fromJson(Map<String, dynamic> json) {
    return DailyVehicleTotalModel(
      vehicleId: json['vehicleId'] as String,
      currency: currencyFromString(json['currency'] as String? ?? 'KES'),
      totalCollected: (json['totalCollected'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      vehicleRegistration: json['vehicleRegistration'] as String?,
      tripCount: json['tripCount'] as int?,
      passengerCount: json['passengerCount'] as int?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      cashCollected: (json['cashCollected'] as num?)?.toDouble(),
      mobileCollected: (json['mobileCollected'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory DailyVehicleTotalModel.fromEntity(DailyVehicleTotal entity) {
    return DailyVehicleTotalModel(
      vehicleId: entity.vehicleId,
      currency: entity.currency,
      totalCollected: entity.totalCollected,
      date: entity.date,
      vehicleRegistration: entity.vehicleRegistration,
      tripCount: entity.tripCount,
      passengerCount: entity.passengerCount,
      routeId: entity.routeId,
      routeName: entity.routeName,
      cashCollected: entity.cashCollected,
      mobileCollected: entity.mobileCollected,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String vehicleId;
  final Currency currency;
  final double totalCollected;
  final DateTime date;
  final String? vehicleRegistration;
  final int? tripCount;
  final int? passengerCount;
  final String? routeId;
  final String? routeName;
  final double? cashCollected;
  final double? mobileCollected;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'currency': currency.name,
        'totalCollected': totalCollected,
        'date': date.toIso8601String(),
        if (vehicleRegistration != null)
          'vehicleRegistration': vehicleRegistration,
        if (tripCount != null) 'tripCount': tripCount,
        if (passengerCount != null) 'passengerCount': passengerCount,
        if (routeId != null) 'routeId': routeId,
        if (routeName != null) 'routeName': routeName,
        if (cashCollected != null) 'cashCollected': cashCollected,
        if (mobileCollected != null) 'mobileCollected': mobileCollected,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  DailyVehicleTotal toEntity() => DailyVehicleTotal(
        vehicleId: vehicleId,
        currency: currency,
        totalCollected: totalCollected,
        date: date,
        vehicleRegistration: vehicleRegistration,
        tripCount: tripCount,
        passengerCount: passengerCount,
        routeId: routeId,
        routeName: routeName,
        cashCollected: cashCollected,
        mobileCollected: mobileCollected,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
