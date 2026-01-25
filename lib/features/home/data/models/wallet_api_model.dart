/// Wallet API models.
///
/// Data transfer objects for Wallet entities matching API schema.
library;

import '../../domain/entities/wallet_entity.dart';

/// Wallet model for API communication.
///
/// Handles parsing wallet data from various API response formats:
/// - Embedded in user response
/// - Direct wallet endpoint response
/// - Organization wallet data
class WalletApiModel {
  /// Creates a new WalletApiModel instance.
  const WalletApiModel({
    this.id,
    this.userId,
    required this.balance,
    this.points = 0,
    required this.currency,
    this.createdAt,
    this.updatedAt,
    this.transactions,
  });

  /// Creates from JSON map (direct wallet response).
  factory WalletApiModel.fromJson(Map<String, dynamic> json) {
    List<WalletTransactionApiModel>? transactions;
    if (json['recentTransactions'] != null) {
      transactions = (json['recentTransactions'] as List)
          .map((e) => WalletTransactionApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['transactions'] != null) {
      transactions = (json['transactions'] as List)
          .map((e) => WalletTransactionApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return WalletApiModel(
      id: _parseId(json['id']),
      userId: _parseId(json['userId']),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      points: json['points'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'KES',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      transactions: transactions,
    );
  }

  /// Creates from user JSON (when wallet is embedded in user response).
  factory WalletApiModel.fromUserJson(Map<String, dynamic> json) {
    return WalletApiModel(
      id: _parseId(json['walletId']),
      userId: _parseId(json['id']),
      balance: (json['balance'] as num?)?.toDouble() ??
          (json['walletBalance'] as num?)?.toDouble() ??
          0.0,
      points: json['points'] as int? ??
          json['walletPoints'] as int? ??
          json['loyaltyPoints'] as int? ??
          0,
      currency: json['currency'] as String? ??
          json['walletCurrency'] as String? ??
          'KES',
    );
  }

  /// Parse ID from various formats (string, int, null).
  static int? _parseId(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  /// Parse DateTime from string or null.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is DateTime) return value;
    return null;
  }

  /// Wallet ID.
  final int? id;

  /// User ID associated with this wallet.
  final int? userId;

  /// Current wallet balance.
  final double balance;

  /// Loyalty/reward points.
  final int points;

  /// Currency code (e.g., KES, USD).
  final String currency;

  /// When the wallet was created.
  final DateTime? createdAt;

  /// When the wallet was last updated.
  final DateTime? updatedAt;

  /// Recent transactions.
  final List<WalletTransactionApiModel>? transactions;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (userId != null) 'userId': userId,
        'balance': balance,
        'points': points,
        'currency': currency,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  WalletEntity toEntity() => WalletEntity(
        id: id ?? 0,
        userId: userId ?? 0,
        balance: balance,
        points: points,
        currency: currency,
        lastUpdated: updatedAt,
        recentTransactions: transactions?.map((t) => t.toEntity()).toList(),
      );
}

/// Wallet transaction API model.
class WalletTransactionApiModel {
  /// Creates a wallet transaction API model.
  const WalletTransactionApiModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.reference,
    this.description,
    required this.timestamp,
  });

  /// Creates from JSON.
  factory WalletTransactionApiModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionApiModel(
      id: json['id']?.toString() ?? '',
      type: _parseTransactionType(json['type']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ??
          (json['balance_after'] as num?)?.toDouble() ??
          0.0,
      reference: json['reference'] as String? ?? json['mpesaReceiptNumber'] as String?,
      description: json['description'] as String? ?? json['narration'] as String?,
      timestamp: _parseDateTime(json['timestamp']) ??
          _parseDateTime(json['createdAt']) ??
          _parseDateTime(json['transactionDate']) ??
          DateTime.now(),
    );
  }

  static TransactionType _parseTransactionType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'topup':
        case 'top_up':
        case 'deposit':
          return TransactionType.topup;
        case 'payment':
        case 'debit':
        case 'trip':
          return TransactionType.payment;
        case 'refund':
          return TransactionType.refund;
        case 'bonus':
        case 'reward':
          return TransactionType.bonus;
      }
    }
    return TransactionType.payment;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is DateTime) return value;
    return null;
  }

  /// Transaction ID.
  final String id;

  /// Transaction type.
  final TransactionType type;

  /// Amount.
  final double amount;

  /// Balance after transaction.
  final double balanceAfter;

  /// External reference.
  final String? reference;

  /// Description.
  final String? description;

  /// Timestamp.
  final DateTime timestamp;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'balanceAfter': balanceAfter,
        if (reference != null) 'reference': reference,
        if (description != null) 'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Converts to domain entity.
  WalletTransaction toEntity() => WalletTransaction(
        id: id,
        type: type,
        amount: amount,
        balanceAfter: balanceAfter,
        reference: reference,
        description: description,
        timestamp: timestamp,
      );
}

/// Top-up request model.
class TopUpRequestModel {
  /// Creates a top-up request.
  const TopUpRequestModel({
    required this.amount,
    required this.paymentMethod,
    required this.phoneNumber,
  });

  /// Amount to top up.
  final double amount;

  /// Payment method (e.g., 'mpesa').
  final String paymentMethod;

  /// Phone number for M-Pesa.
  final String phoneNumber;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'paymentMethod': paymentMethod,
        'phoneNumber': phoneNumber,
      };
}

/// Top-up response model.
class TopUpResponseModel {
  /// Creates a top-up response.
  const TopUpResponseModel({
    required this.transactionId,
    required this.checkoutRequestId,
    required this.merchantRequestId,
    this.responseDescription,
  });

  /// Creates from JSON.
  factory TopUpResponseModel.fromJson(Map<String, dynamic> json) {
    return TopUpResponseModel(
      transactionId: json['transactionId']?.toString() ?? json['id']?.toString() ?? '',
      checkoutRequestId: json['checkoutRequestId']?.toString() ?? '',
      merchantRequestId: json['merchantRequestId']?.toString() ?? '',
      responseDescription: json['responseDescription'] as String? ?? json['message'] as String?,
    );
  }

  /// Transaction ID.
  final String transactionId;

  /// M-Pesa checkout request ID.
  final String checkoutRequestId;

  /// M-Pesa merchant request ID.
  final String merchantRequestId;

  /// Response description.
  final String? responseDescription;
}

/// Top-up status response model.
class TopUpStatusModel {
  /// Creates a top-up status.
  const TopUpStatusModel({
    required this.status,
    this.mpesaReceiptNumber,
    this.amount,
    this.balanceAfter,
    this.message,
  });

  /// Creates from JSON.
  factory TopUpStatusModel.fromJson(Map<String, dynamic> json) {
    return TopUpStatusModel(
      status: _parseStatus(json['status']),
      mpesaReceiptNumber: json['mpesaReceiptNumber'] as String? ?? json['receiptNumber'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? (json['newBalance'] as num?)?.toDouble(),
      message: json['message'] as String? ?? json['resultDesc'] as String?,
    );
  }

  static TopUpStatus _parseStatus(dynamic status) {
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'pending':
        case 'processing':
          return TopUpStatus.pending;
        case 'completed':
        case 'success':
          return TopUpStatus.completed;
        case 'failed':
        case 'error':
          return TopUpStatus.failed;
        case 'cancelled':
          return TopUpStatus.cancelled;
      }
    }
    return TopUpStatus.pending;
  }

  /// Top-up status.
  final TopUpStatus status;

  /// M-Pesa receipt number.
  final String? mpesaReceiptNumber;

  /// Amount topped up.
  final double? amount;

  /// New balance after top-up.
  final double? balanceAfter;

  /// Status message.
  final String? message;
}

/// Top-up status enum.
enum TopUpStatus {
  pending,
  completed,
  failed,
  cancelled,
}
