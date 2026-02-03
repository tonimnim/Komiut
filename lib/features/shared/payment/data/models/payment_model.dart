import '../../../../../core/database/app_database.dart';
import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.type,
    required super.status,
    super.description,
    required super.referenceId,
    required super.transactionDate,
  });

  factory PaymentModel.fromDatabase(Payment payment) {
    return PaymentModel(
      id: payment.id,
      userId: payment.userId,
      amount: payment.amount,
      type: _parseType(payment.type),
      status: _parseStatus(payment.status),
      description: payment.description,
      referenceId: payment.referenceId,
      transactionDate: payment.transactionDate,
    );
  }

  static PaymentType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'top-up':
        return PaymentType.topUp;
      case 'trip':
        return PaymentType.trip;
      case 'refund':
        return PaymentType.refund;
      default:
        return PaymentType.trip;
    }
  }

  static PaymentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'pending':
        return PaymentStatus.pending;
      default:
        return PaymentStatus.pending;
    }
  }
}
