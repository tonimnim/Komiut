/// Daily vehicle total entity.
///
/// Represents daily earnings totals for a vehicle.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// DailyVehicleTotal entity for tracking daily earnings.
class DailyVehicleTotal extends Equatable {
  /// Creates a new DailyVehicleTotal instance.
  const DailyVehicleTotal({
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

  /// ID of the vehicle.
  final String vehicleId;

  /// Currency for the amounts.
  final Currency currency;

  /// Total amount collected.
  final double totalCollected;

  /// Date of the totals.
  final DateTime date;

  /// Vehicle registration (for display).
  final String? vehicleRegistration;

  /// Number of trips completed.
  final int? tripCount;

  /// Number of passengers served.
  final int? passengerCount;

  /// ID of the primary route (if single route).
  final String? routeId;

  /// Route name (for display).
  final String? routeName;

  /// Cash payments collected.
  final double? cashCollected;

  /// Mobile payments collected.
  final double? mobileCollected;

  /// When the record was created.
  final DateTime? createdAt;

  /// When the record was last updated.
  final DateTime? updatedAt;

  /// Format the total collected with currency.
  String get formattedTotal => currency.format(totalCollected);

  /// Format the cash collected if available.
  String? get formattedCash {
    if (cashCollected == null) return null;
    return currency.format(cashCollected!);
  }

  /// Format the mobile collected if available.
  String? get formattedMobile {
    if (mobileCollected == null) return null;
    return currency.format(mobileCollected!);
  }

  /// Average fare per passenger.
  double? get averageFare {
    if (passengerCount == null || passengerCount == 0) return null;
    return totalCollected / passengerCount!;
  }

  /// Creates a copy with modified fields.
  DailyVehicleTotal copyWith({
    String? vehicleId,
    Currency? currency,
    double? totalCollected,
    DateTime? date,
    String? vehicleRegistration,
    int? tripCount,
    int? passengerCount,
    String? routeId,
    String? routeName,
    double? cashCollected,
    double? mobileCollected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyVehicleTotal(
      vehicleId: vehicleId ?? this.vehicleId,
      currency: currency ?? this.currency,
      totalCollected: totalCollected ?? this.totalCollected,
      date: date ?? this.date,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      tripCount: tripCount ?? this.tripCount,
      passengerCount: passengerCount ?? this.passengerCount,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      cashCollected: cashCollected ?? this.cashCollected,
      mobileCollected: mobileCollected ?? this.mobileCollected,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        vehicleId,
        currency,
        totalCollected,
        date,
        vehicleRegistration,
        tripCount,
        passengerCount,
        routeId,
        routeName,
        cashCollected,
        mobileCollected,
        createdAt,
        updatedAt,
      ];
}
