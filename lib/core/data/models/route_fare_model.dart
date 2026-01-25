/// Route fare API model.
///
/// Data transfer object for RouteFare entity matching API schema.
library;

import '../../domain/entities/route_fare.dart';
import '../../domain/enums/enums.dart';

/// RouteFare model for API communication.
class RouteFareModel {
  /// Creates a new RouteFareModel instance.
  const RouteFareModel({
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

  /// Creates from JSON map.
  factory RouteFareModel.fromJson(Map<String, dynamic> json) {
    return RouteFareModel(
      id: json['id'] as String,
      routeId: json['routeId'] as String,
      fromStopId: json['fromPointId'] as String? ?? json['fromStopId'] as String,
      toStopId: json['toPointId'] as String? ?? json['toStopId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: currencyFromString(json['currency'] as String? ?? 'KES'),
      isActive: json['isActive'] as bool,
      fromStopName: json['fromStopName'] as String?,
      toStopName: json['toStopName'] as String?,
      discountedAmount: (json['discountedAmount'] as num?)?.toDouble(),
      effectiveFrom: json['effectiveFrom'] != null
          ? DateTime.parse(json['effectiveFrom'] as String)
          : null,
      effectiveUntil: json['effectiveUntil'] != null
          ? DateTime.parse(json['effectiveUntil'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory RouteFareModel.fromEntity(RouteFare entity) {
    return RouteFareModel(
      id: entity.id,
      routeId: entity.routeId,
      fromStopId: entity.fromStopId,
      toStopId: entity.toStopId,
      amount: entity.amount,
      currency: entity.currency,
      isActive: entity.isActive,
      fromStopName: entity.fromStopName,
      toStopName: entity.toStopName,
      discountedAmount: entity.discountedAmount,
      effectiveFrom: entity.effectiveFrom,
      effectiveUntil: entity.effectiveUntil,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String routeId;
  final String fromStopId;
  final String toStopId;
  final double amount;
  final Currency currency;
  final bool isActive;
  final String? fromStopName;
  final String? toStopName;
  final double? discountedAmount;
  final DateTime? effectiveFrom;
  final DateTime? effectiveUntil;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'routeId': routeId,
        'fromPointId': fromStopId,
        'toPointId': toStopId,
        'amount': amount,
        'currency': currency.name,
        'isActive': isActive,
        if (fromStopName != null) 'fromStopName': fromStopName,
        if (toStopName != null) 'toStopName': toStopName,
        if (discountedAmount != null) 'discountedAmount': discountedAmount,
        if (effectiveFrom != null)
          'effectiveFrom': effectiveFrom!.toIso8601String(),
        if (effectiveUntil != null)
          'effectiveUntil': effectiveUntil!.toIso8601String(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  RouteFare toEntity() => RouteFare(
        id: id,
        routeId: routeId,
        fromStopId: fromStopId,
        toStopId: toStopId,
        amount: amount,
        currency: currency,
        isActive: isActive,
        fromStopName: fromStopName,
        toStopName: toStopName,
        discountedAmount: discountedAmount,
        effectiveFrom: effectiveFrom,
        effectiveUntil: effectiveUntil,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
