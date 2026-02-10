import '../../domain/entities/earnings_transaction.dart';

/// Data model for earnings transaction.
///
/// Maps to PaymentDto from the backend API:
/// GET /api/Payments
class EarningsTransactionModel {
  EarningsTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.tripId,
    this.bookingId,
    this.description,
    this.referenceId,
    this.status,
    this.currency = 'KES',
  });

  final String id;
  final double amount;
  final String type;
  final DateTime timestamp;
  final String? tripId;
  final String? bookingId;
  final String? description;
  final String? referenceId;
  final String? status;
  final String currency;

  /// Creates from PaymentDto JSON.
  ///
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "amount": 100.0,
  ///   "currency": "KES",
  ///   "status": "completed",
  ///   "bookingId": "uuid",
  ///   "referenceId": "string",
  ///   "transactionTime": "2026-02-02T01:14:04.639Z"
  /// }
  /// ```
  factory EarningsTransactionModel.fromJson(Map<String, dynamic> json) {
    return EarningsTransactionModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: _inferType(json),
      timestamp:
          DateTime.tryParse(json['transactionTime'] as String? ?? '') ??
              DateTime.now(),
      tripId: json['tripId']?.toString(),
      bookingId: json['bookingId']?.toString(),
      description: json['description'] as String?,
      referenceId: json['referenceId'] as String?,
      status: json['status'] as String?,
      currency: json['currency'] as String? ?? 'KES',
    );
  }

  static String _inferType(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    if (status == 'payout') return 'payout';
    if (status == 'refund') return 'refund';
    if (json['bookingId'] != null) return 'trip';
    return 'trip';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type,
        'transactionTime': timestamp.toIso8601String(),
        if (tripId != null) 'tripId': tripId,
        if (bookingId != null) 'bookingId': bookingId,
        if (description != null) 'description': description,
        if (referenceId != null) 'referenceId': referenceId,
        if (status != null) 'status': status,
        'currency': currency,
      };

  EarningsTransaction toEntity() => EarningsTransaction(
        id: id,
        amount: amount,
        type: _mapType(type),
        timestamp: timestamp,
        tripId: tripId ?? bookingId,
        description: description ?? referenceId,
        currency: currency,
      );

  EarningsType _mapType(String type) {
    switch (type.toLowerCase()) {
      case 'bonus':
        return EarningsType.bonus;
      case 'tip':
        return EarningsType.tip;
      case 'deduction':
        return EarningsType.deduction;
      case 'payout':
        return EarningsType.payout;
      case 'refund':
        return EarningsType.refund;
      default:
        return EarningsType.trip;
    }
  }
}
