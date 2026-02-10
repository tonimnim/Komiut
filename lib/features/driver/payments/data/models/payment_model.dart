import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.amount,
    required super.currency,
    required super.transactionTime,
    super.payerName,
    super.payerPhone,
    super.status,
    super.vehicleRegistration,
    super.referenceId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String? ?? json['paymentId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'KES',
      transactionTime:
          DateTime.tryParse(json['transactionTime'] as String? ?? '') ??
              DateTime.now(),
      payerName: json['payerName'] as String?,
      payerPhone: json['payerPhone'] as String?,
      status: json['status'] as String?,
      vehicleRegistration: json['vehicleRegistration'] as String?,
      referenceId: json['referenceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'transactionTime': transactionTime.toIso8601String(),
      'payerName': payerName,
      'payerPhone': payerPhone,
      'status': status,
      'vehicleRegistration': vehicleRegistration,
      'referenceId': referenceId,
    };
  }
}
