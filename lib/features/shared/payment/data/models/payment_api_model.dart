/// Payment API models.
///
/// Data transfer objects for Payment operations matching API schema.
library;

import '../../../../../core/domain/enums/enums.dart';
import '../../domain/entities/payment_entity.dart' as local;

/// Payment API model for API responses.
///
/// Maps between the API response format and the local PaymentEntity.
/// This bridges the core Payment model (API) with the feature-specific PaymentEntity.
class PaymentApiModel {
  /// Creates a new PaymentApiModel instance.
  const PaymentApiModel({
    required this.id,
    this.organizationId,
    this.vehicleId,
    this.routeId,
    this.bookingId,
    this.passengerId,
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
  factory PaymentApiModel.fromJson(Map<String, dynamic> json) {
    return PaymentApiModel(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      routeId: json['routeId'] as String?,
      bookingId: json['bookingId'] as String?,
      passengerId: json['passengerId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      status: _parseStatus(json['status'] as String?),
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

  /// Parse status from string, mapping API values to core enum.
  static PaymentStatus _parseStatus(String? status) {
    if (status == null) return PaymentStatus.pending;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'successful':
        return PaymentStatus.completed;
      case 'failed':
      case 'failure':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }

  /// Unique identifier.
  final String id;

  /// Organization ID.
  final String? organizationId;

  /// Vehicle ID.
  final String? vehicleId;

  /// Route ID.
  final String? routeId;

  /// Booking ID.
  final String? bookingId;

  /// Passenger ID.
  final String? passengerId;

  /// Payment amount.
  final double amount;

  /// Currency code.
  final String currency;

  /// Payment status (from core enums).
  final PaymentStatus status;

  /// Transaction time.
  final DateTime? transactionTime;

  /// Payment method.
  final String? paymentMethod;

  /// Transaction reference.
  final String? transactionReference;

  /// Description.
  final String? description;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Created timestamp.
  final DateTime? createdAt;

  /// Updated timestamp.
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        if (organizationId != null) 'organizationId': organizationId,
        if (vehicleId != null) 'vehicleId': vehicleId,
        if (routeId != null) 'routeId': routeId,
        if (bookingId != null) 'bookingId': bookingId,
        if (passengerId != null) 'passengerId': passengerId,
        'amount': amount,
        'currency': currency,
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

  /// Converts to feature-specific PaymentEntity.
  ///
  /// Maps the API model to the local feature entity format.
  local.PaymentEntity toEntity() {
    // Determine payment type based on available fields
    local.PaymentType type = local.PaymentType.trip;
    if (description?.toLowerCase().contains('top') == true ||
        description?.toLowerCase().contains('fund') == true ||
        description?.toLowerCase().contains('deposit') == true) {
      type = local.PaymentType.topUp;
    } else if (status == PaymentStatus.refunded ||
        description?.toLowerCase().contains('refund') == true) {
      type = local.PaymentType.refund;
    }

    // Map core PaymentStatus to local PaymentStatus enum
    final localStatus = _mapToLocalStatus(status);

    return local.PaymentEntity(
      id: int.tryParse(id) ?? id.hashCode,
      userId: int.tryParse(passengerId ?? '') ?? 0,
      amount: amount,
      type: type,
      status: localStatus,
      description: description,
      referenceId: transactionReference ?? id,
      transactionDate: transactionTime ?? createdAt ?? DateTime.now(),
    );
  }

  /// Maps core PaymentStatus to feature-local PaymentStatus.
  local.PaymentStatus _mapToLocalStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return local.PaymentStatus.completed;
      case PaymentStatus.failed:
        return local.PaymentStatus.failed;
      case PaymentStatus.pending:
        return local.PaymentStatus.pending;
      case PaymentStatus.refunded:
        // Treat refunded as completed for local status
        return local.PaymentStatus.completed;
    }
  }
}

/// Request model for creating a payment.
///
/// Matches the CreatePaymentCommand API schema.
class CreatePaymentRequest {
  /// Creates a new CreatePaymentRequest.
  const CreatePaymentRequest({
    this.organizationId,
    this.vehicleId,
    this.routeId,
    this.bookingId,
    this.passengerId,
    required this.amount,
    this.currency = 'KES',
    this.paymentMethod,
    this.transactionReference,
    this.description,
    this.metadata,
  });

  /// Organization ID.
  final String? organizationId;

  /// Vehicle ID.
  final String? vehicleId;

  /// Route ID.
  final String? routeId;

  /// Booking ID.
  final String? bookingId;

  /// Passenger ID.
  final String? passengerId;

  /// Payment amount.
  final double amount;

  /// Currency code.
  final String currency;

  /// Payment method.
  final String? paymentMethod;

  /// External transaction reference.
  final String? transactionReference;

  /// Payment description.
  final String? description;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Converts to JSON map for API request.
  Map<String, dynamic> toJson() => {
        if (organizationId != null) 'organizationId': organizationId,
        if (vehicleId != null) 'vehicleId': vehicleId,
        if (routeId != null) 'routeId': routeId,
        if (bookingId != null) 'bookingId': bookingId,
        if (passengerId != null) 'passengerId': passengerId,
        'amount': amount,
        'currency': currency,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (transactionReference != null)
          'transactionReference': transactionReference,
        if (description != null) 'description': description,
        if (metadata != null) 'metadata': metadata,
      };
}
