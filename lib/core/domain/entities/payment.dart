/// Payment entity.
///
/// Represents a payment transaction.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Payment entity representing a financial transaction.
class Payment extends Equatable {
  /// Creates a new Payment instance.
  const Payment({
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

  /// Unique identifier.
  final String id;

  /// ID of the organization (for SACCO payments).
  final String? organizationId;

  /// ID of the vehicle (if vehicle-related).
  final String? vehicleId;

  /// ID of the route (if route-related).
  final String? routeId;

  /// ID of the booking (if booking payment).
  final String? bookingId;

  /// Payment amount.
  final double amount;

  /// Currency for the payment.
  final Currency currency;

  /// Payment status.
  final PaymentStatus status;

  /// When the transaction occurred.
  final DateTime? transactionTime;

  /// Payment method (e.g., M-PESA, card).
  final String? paymentMethod;

  /// External transaction reference.
  final String? transactionReference;

  /// Payment description.
  final String? description;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// When the payment was created.
  final DateTime? createdAt;

  /// When the payment was last updated.
  final DateTime? updatedAt;

  /// Whether the payment is pending.
  bool get isPending => status == PaymentStatus.pending;

  /// Whether the payment is completed.
  bool get isCompleted => status == PaymentStatus.completed;

  /// Whether the payment failed.
  bool get isFailed => status == PaymentStatus.failed;

  /// Whether the payment was refunded.
  bool get isRefunded => status == PaymentStatus.refunded;

  /// Whether the payment was successful.
  bool get isSuccessful => status.isSuccessful;

  /// Whether this is a booking payment.
  bool get isBookingPayment => bookingId != null;

  /// Format the amount with currency.
  String get formattedAmount => currency.format(amount);

  /// Creates a copy with modified fields.
  Payment copyWith({
    String? id,
    String? organizationId,
    String? vehicleId,
    String? routeId,
    String? bookingId,
    double? amount,
    Currency? currency,
    PaymentStatus? status,
    DateTime? transactionTime,
    String? paymentMethod,
    String? transactionReference,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      vehicleId: vehicleId ?? this.vehicleId,
      routeId: routeId ?? this.routeId,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      transactionTime: transactionTime ?? this.transactionTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionReference: transactionReference ?? this.transactionReference,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        organizationId,
        vehicleId,
        routeId,
        bookingId,
        amount,
        currency,
        status,
        transactionTime,
        paymentMethod,
        transactionReference,
        description,
        metadata,
        createdAt,
        updatedAt,
      ];
}
