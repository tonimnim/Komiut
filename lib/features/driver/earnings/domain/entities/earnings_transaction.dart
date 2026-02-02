import 'package:equatable/equatable.dart';

/// Type of earnings transaction.
enum EarningsType {
  trip,
  bonus,
  tip,
  deduction,
  payout,
  refund,
}

/// Represents a single earnings transaction.
class EarningsTransaction extends Equatable {
  const EarningsTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.tripId,
    this.description,
    this.currency = 'KES',
  });

  final String id;
  final double amount;
  final EarningsType type;
  final DateTime timestamp;
  final String? tripId;
  final String? description;
  final String currency;

  /// Whether this is a positive transaction (income).
  bool get isIncome =>
      type != EarningsType.deduction && type != EarningsType.payout;

  /// Whether this transaction is related to a trip.
  bool get isTrip => tripId != null;

  /// Formatted amount for display (with sign).
  String get displayAmount {
    final sign = isIncome ? '+' : '-';
    return '$sign$currency ${amount.abs().toStringAsFixed(2)}';
  }

  /// Human-readable type name.
  String get typeName {
    switch (type) {
      case EarningsType.trip:
        return 'Trip Fare';
      case EarningsType.bonus:
        return 'Bonus';
      case EarningsType.tip:
        return 'Tip';
      case EarningsType.deduction:
        return 'Deduction';
      case EarningsType.payout:
        return 'Payout';
      case EarningsType.refund:
        return 'Refund';
    }
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        timestamp,
        tripId,
        description,
        currency,
      ];

  EarningsTransaction copyWith({
    String? id,
    double? amount,
    EarningsType? type,
    DateTime? timestamp,
    String? tripId,
    String? description,
    String? currency,
  }) {
    return EarningsTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      tripId: tripId ?? this.tripId,
      description: description ?? this.description,
      currency: currency ?? this.currency,
    );
  }
}
