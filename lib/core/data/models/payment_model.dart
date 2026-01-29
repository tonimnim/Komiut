/// Payment API model.
///
/// Data transfer object for Payment entity matching API schema.
library;

import '../../domain/entities/payment.dart';
import '../../domain/enums/enums.dart';

/// Payment model for API communication.
class PaymentModel {
  /// Creates a new PaymentModel instance.
  const PaymentModel({
    required this.id,
    this.organizationId,
    this.vehicleId,
    this.routeId,
    this.bookingId,
    required this.amount,
    required this.currency,
    required this.status,
    this.transactionTime,
    this.paymentMethod,
    this.transactionReference,
    this.description,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates from JSON map.
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      routeId: json['routeId'] as String?,
      bookingId: json['bookingId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: currencyFromString(json['currency'] as String? ?? 'KES'),
      status: paymentStatusFromString(json['status'] as String? ?? 'pending'),
      transactionTime: json['transactionTime'] != null
          ? DateTime.parse(json['transactionTime'] as String)
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      transactionReference: json['transactionReference'] as String?,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory PaymentModel.fromEntity(Payment entity) {
    return PaymentModel(
      id: entity.id,
      organizationId: entity.organizationId,
      vehicleId: entity.vehicleId,
      routeId: entity.routeId,
      bookingId: entity.bookingId,
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status,
      transactionTime: entity.transactionTime,
      paymentMethod: entity.paymentMethod,
      transactionReference: entity.transactionReference,
      description: entity.description,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String? organizationId;
  final String? vehicleId;
  final String? routeId;
  final String? bookingId;
  final double amount;
  final Currency currency;
  final PaymentStatus status;
  final DateTime? transactionTime;
  final String? paymentMethod;
  final String? transactionReference;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        if (organizationId != null) 'organizationId': organizationId,
        if (vehicleId != null) 'vehicleId': vehicleId,
        if (routeId != null) 'routeId': routeId,
        if (bookingId != null) 'bookingId': bookingId,
        'amount': amount,
        'currency': currency.name,
        'status': status.toApiValue(),
        if (transactionTime != null)
          'transactionTime': transactionTime!.toIso8601String(),
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (transactionReference != null)
          'transactionReference': transactionReference,
        if (description != null) 'description': description,
        if (metadata != null) 'metadata': metadata,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  Payment toEntity() => Payment(
        id: id,
        organizationId: organizationId,
        vehicleId: vehicleId,
        routeId: routeId,
        bookingId: bookingId,
        amount: amount,
        currency: currency,
        status: status,
        transactionTime: transactionTime,
        paymentMethod: paymentMethod,
        transactionReference: transactionReference,
        description: description,
        metadata: metadata,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
