enum PaymentType {
  topUp,
  trip,
  refund,
}

enum PaymentStatus {
  completed,
  failed,
  pending,
}

class PaymentEntity {
  final int id;
  final int userId;
  final double amount;
  final PaymentType type;
  final PaymentStatus status;
  final String? description;
  final String referenceId;
  final DateTime transactionDate;

  const PaymentEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    required this.referenceId,
    required this.transactionDate,
  });

  bool get isTopUp => type == PaymentType.topUp;
  bool get isTrip => type == PaymentType.trip;
  bool get isRefund => type == PaymentType.refund;
  bool get isCompleted => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isPending => status == PaymentStatus.pending;

  // Money in = top-up, refund; Money out = trip
  bool get isMoneyIn => type == PaymentType.topUp || type == PaymentType.refund;
  bool get isMoneyOut => type == PaymentType.trip;

  String get formattedAmount => 'KES ${amount.toStringAsFixed(0)}';

  String get signedAmount {
    if (isMoneyIn) {
      return '+KES ${amount.toStringAsFixed(0)}';
    } else {
      return '-KES ${amount.toStringAsFixed(0)}';
    }
  }

  String get typeLabel {
    switch (type) {
      case PaymentType.topUp:
        return 'Top Up';
      case PaymentType.trip:
        return 'Trip Payment';
      case PaymentType.refund:
        return 'Refund';
    }
  }

  String get statusLabel {
    switch (status) {
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
    }
  }
}
