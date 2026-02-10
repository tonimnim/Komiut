import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.transactionTime,
    this.payerName,
    this.payerPhone,
    this.status,
    this.vehicleRegistration,
    this.referenceId,
  });

  final String id;
  final double amount;
  final String currency;
  final DateTime transactionTime;
  final String? payerName;
  final String? payerPhone;
  final String? status;
  final String? vehicleRegistration;
  final String? referenceId;

  String get displayAmount => '$currency ${amount.toStringAsFixed(0)}';

  String get timeAgo {
    final difference = DateTime.now().difference(transactionTime);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        currency,
        transactionTime,
        payerName,
        payerPhone,
        status,
        vehicleRegistration,
        referenceId,
      ];
}
