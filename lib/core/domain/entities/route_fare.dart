/// Route fare entity.
///
/// Represents fare pricing between two stops on a route.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// RouteFare entity representing pricing between stops.
class RouteFare extends Equatable {
  /// Creates a new RouteFare instance.
  const RouteFare({
    required this.id,
    required this.routeId,
    required this.fromStopId,
    required this.toStopId,
    required this.amount,
    required this.currency,
    required this.isActive,
    this.fromStopName,
    this.toStopName,
    this.discountedAmount,
    this.effectiveFrom,
    this.effectiveUntil,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// ID of the route.
  final String routeId;

  /// ID of the starting stop.
  final String fromStopId;

  /// ID of the destination stop.
  final String toStopId;

  /// Fare amount.
  final double amount;

  /// Currency for the fare.
  final Currency currency;

  /// Whether this fare is active.
  final bool isActive;

  /// Name of the starting stop (for display).
  final String? fromStopName;

  /// Name of the destination stop (for display).
  final String? toStopName;

  /// Discounted fare amount (if any).
  final double? discountedAmount;

  /// When this fare becomes effective.
  final DateTime? effectiveFrom;

  /// When this fare expires.
  final DateTime? effectiveUntil;

  /// When the fare was created.
  final DateTime? createdAt;

  /// When the fare was last updated.
  final DateTime? updatedAt;

  /// Format the fare amount with currency.
  String get formattedAmount => currency.format(amount);

  /// Format the discounted amount if available.
  String? get formattedDiscountedAmount {
    if (discountedAmount == null) return null;
    return currency.format(discountedAmount!);
  }

  /// Whether a discount is available.
  bool get hasDiscount =>
      discountedAmount != null && discountedAmount! < amount;

  /// Calculate the discount percentage.
  double? get discountPercentage {
    if (!hasDiscount) return null;
    return ((amount - discountedAmount!) / amount) * 100;
  }

  /// Get the effective fare (discounted if available, otherwise regular).
  double get effectiveFare => discountedAmount ?? amount;

  /// Creates a copy with modified fields.
  RouteFare copyWith({
    String? id,
    String? routeId,
    String? fromStopId,
    String? toStopId,
    double? amount,
    Currency? currency,
    bool? isActive,
    String? fromStopName,
    String? toStopName,
    double? discountedAmount,
    DateTime? effectiveFrom,
    DateTime? effectiveUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteFare(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      fromStopId: fromStopId ?? this.fromStopId,
      toStopId: toStopId ?? this.toStopId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      fromStopName: fromStopName ?? this.fromStopName,
      toStopName: toStopName ?? this.toStopName,
      discountedAmount: discountedAmount ?? this.discountedAmount,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveUntil: effectiveUntil ?? this.effectiveUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        routeId,
        fromStopId,
        toStopId,
        amount,
        currency,
        isActive,
        fromStopName,
        toStopName,
        discountedAmount,
        effectiveFrom,
        effectiveUntil,
        createdAt,
        updatedAt,
      ];
}
