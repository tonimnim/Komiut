/// M-Pesa API data transfer objects.
///
/// Contains all models for M-Pesa STK Push integration:
/// - Request/response models for STK Push
/// - Transaction status models
/// - Payment state enum
library;

import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

/// M-Pesa payment state machine.
///
/// Represents all possible states during an M-Pesa STK Push transaction:
/// - [idle]: No active transaction
/// - [initiating]: Sending STK Push request to server
/// - [waitingForPin]: STK Push sent, waiting for user to enter PIN
/// - [processing]: User entered PIN, transaction being processed
/// - [completed]: Transaction completed successfully
/// - [failed]: Transaction failed (user cancelled, wrong PIN, etc.)
/// - [cancelled]: Transaction was cancelled by user or system
/// - [timeout]: Transaction timed out waiting for user input
enum MpesaPaymentState {
  idle,
  initiating,
  waitingForPin,
  processing,
  completed,
  failed,
  cancelled,
  timeout;

  /// Whether the transaction is in a terminal state.
  bool get isTerminal =>
      this == completed || this == failed || this == cancelled || this == timeout;

  /// Whether the transaction is in progress.
  bool get isInProgress =>
      this == initiating || this == waitingForPin || this == processing;

  /// User-friendly status message.
  String get message => switch (this) {
        MpesaPaymentState.idle => '',
        MpesaPaymentState.initiating => 'Initiating payment...',
        MpesaPaymentState.waitingForPin =>
          'Please check your phone and enter M-Pesa PIN',
        MpesaPaymentState.processing => 'Processing payment...',
        MpesaPaymentState.completed => 'Payment successful!',
        MpesaPaymentState.failed => 'Payment failed',
        MpesaPaymentState.cancelled => 'Payment cancelled',
        MpesaPaymentState.timeout => 'Payment timed out',
      };
}

/// M-Pesa transaction status from callback/status check.
enum MpesaTransactionResultCode {
  success(0),
  insufficientFunds(1),
  lessThanMinimum(2),
  moreThanMaximum(3),
  wouldExceedDailyLimit(4),
  wouldExceedMonthlyLimit(5),
  wrongPin(6),
  cancelled(1032),
  timeout(1037),
  unknown(-1);

  const MpesaTransactionResultCode(this.code);
  final int code;

  /// Creates from API result code.
  static MpesaTransactionResultCode fromCode(int? code) {
    if (code == null) return MpesaTransactionResultCode.unknown;
    return MpesaTransactionResultCode.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MpesaTransactionResultCode.unknown,
    );
  }

  /// User-friendly error message.
  String get errorMessage => switch (this) {
        MpesaTransactionResultCode.success => 'Transaction successful',
        MpesaTransactionResultCode.insufficientFunds =>
          'Insufficient funds in your M-Pesa account',
        MpesaTransactionResultCode.lessThanMinimum =>
          'Amount is below minimum allowed',
        MpesaTransactionResultCode.moreThanMaximum =>
          'Amount exceeds maximum allowed',
        MpesaTransactionResultCode.wouldExceedDailyLimit =>
          'Transaction would exceed daily limit',
        MpesaTransactionResultCode.wouldExceedMonthlyLimit =>
          'Transaction would exceed monthly limit',
        MpesaTransactionResultCode.wrongPin => 'Wrong M-Pesa PIN entered',
        MpesaTransactionResultCode.cancelled =>
          'Transaction was cancelled by user',
        MpesaTransactionResultCode.timeout =>
          'Transaction timed out. Please try again.',
        MpesaTransactionResultCode.unknown =>
          'An error occurred. Please try again.',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Request Models
// ─────────────────────────────────────────────────────────────────────────────

/// Request model for STK Push initiation.
class StkPushRequest extends Equatable {
  /// Creates a new STK Push request.
  const StkPushRequest({
    required this.phoneNumber,
    required this.amount,
    required this.accountReference,
    required this.transactionDesc,
  });

  /// Phone number in 254XXXXXXXXX format.
  final String phoneNumber;

  /// Amount to charge in KES.
  final double amount;

  /// Unique reference for the transaction (e.g., booking ID).
  final String accountReference;

  /// Description shown to user on M-Pesa prompt.
  final String transactionDesc;

  /// Converts to JSON for API request.
  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'amount': amount,
        'accountReference': accountReference,
        'transactionDesc': transactionDesc,
      };

  @override
  List<Object?> get props =>
      [phoneNumber, amount, accountReference, transactionDesc];
}

// ─────────────────────────────────────────────────────────────────────────────
// Response Models
// ─────────────────────────────────────────────────────────────────────────────

/// Response model for STK Push initiation.
class StkPushResponse extends Equatable {
  /// Creates a new STK Push response.
  const StkPushResponse({
    required this.checkoutRequestId,
    required this.merchantRequestId,
    required this.responseCode,
    this.responseDescription,
    this.customerMessage,
  });

  /// Unique ID for this checkout request (used for status checks).
  final String checkoutRequestId;

  /// Merchant request ID from M-Pesa.
  final String merchantRequestId;

  /// Response code ('0' means success).
  final String responseCode;

  /// Description of the response.
  final String? responseDescription;

  /// Message to display to customer.
  final String? customerMessage;

  /// Whether the STK Push was initiated successfully.
  bool get isSuccess => responseCode == '0';

  /// Creates from JSON response.
  factory StkPushResponse.fromJson(Map<String, dynamic> json) {
    return StkPushResponse(
      checkoutRequestId: json['checkoutRequestId'] as String? ??
          json['CheckoutRequestID'] as String? ??
          '',
      merchantRequestId: json['merchantRequestId'] as String? ??
          json['MerchantRequestID'] as String? ??
          '',
      responseCode: json['responseCode'] as String? ??
          json['ResponseCode'] as String? ??
          '-1',
      responseDescription: json['responseDescription'] as String? ??
          json['ResponseDescription'] as String?,
      customerMessage:
          json['customerMessage'] as String? ?? json['CustomerMessage'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'checkoutRequestId': checkoutRequestId,
        'merchantRequestId': merchantRequestId,
        'responseCode': responseCode,
        'responseDescription': responseDescription,
        'customerMessage': customerMessage,
      };

  @override
  List<Object?> get props => [
        checkoutRequestId,
        merchantRequestId,
        responseCode,
        responseDescription,
        customerMessage,
      ];
}

/// Transaction status response from status check endpoint.
class TransactionStatus extends Equatable {
  /// Creates a new transaction status.
  const TransactionStatus({
    required this.status,
    required this.resultCode,
    this.resultDesc,
    this.mpesaReceiptNumber,
    this.transactionDate,
    this.phoneNumber,
    this.amount,
  });

  /// Current status of the transaction.
  final MpesaPaymentState status;

  /// Result code from M-Pesa.
  final MpesaTransactionResultCode resultCode;

  /// Description of the result.
  final String? resultDesc;

  /// M-Pesa receipt number (only on success).
  final String? mpesaReceiptNumber;

  /// Transaction timestamp.
  final DateTime? transactionDate;

  /// Phone number that made the payment.
  final String? phoneNumber;

  /// Amount paid.
  final double? amount;

  /// Whether the transaction completed successfully.
  bool get isSuccess =>
      status == MpesaPaymentState.completed &&
      resultCode == MpesaTransactionResultCode.success;

  /// Whether the transaction is still pending.
  bool get isPending => status == MpesaPaymentState.processing ||
      status == MpesaPaymentState.waitingForPin;

  /// Creates from JSON response.
  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final resultCodeInt = json['resultCode'] as int?;

    return TransactionStatus(
      status: _parseStatus(statusStr, resultCodeInt),
      resultCode: MpesaTransactionResultCode.fromCode(resultCodeInt),
      resultDesc: json['resultDesc'] as String?,
      mpesaReceiptNumber: json['mpesaReceiptNumber'] as String?,
      transactionDate: json['transactionDate'] != null
          ? DateTime.tryParse(json['transactionDate'] as String)
          : null,
      phoneNumber: json['phoneNumber'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }

  /// Parse status from string and result code.
  static MpesaPaymentState _parseStatus(String status, int? resultCode) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        if (resultCode == 0) {
          return MpesaPaymentState.completed;
        }
        return MpesaPaymentState.failed;
      case 'failed':
        return MpesaPaymentState.failed;
      case 'cancelled':
        return MpesaPaymentState.cancelled;
      case 'timeout':
        return MpesaPaymentState.timeout;
      case 'pending':
      case 'processing':
        return MpesaPaymentState.processing;
      default:
        return MpesaPaymentState.processing;
    }
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'status': status.name,
        'resultCode': resultCode.code,
        'resultDesc': resultDesc,
        'mpesaReceiptNumber': mpesaReceiptNumber,
        'transactionDate': transactionDate?.toIso8601String(),
        'phoneNumber': phoneNumber,
        'amount': amount,
      };

  @override
  List<Object?> get props => [
        status,
        resultCode,
        resultDesc,
        mpesaReceiptNumber,
        transactionDate,
        phoneNumber,
        amount,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Session State
// ─────────────────────────────────────────────────────────────────────────────

/// Complete state for an M-Pesa payment session.
///
/// Tracks all information about an ongoing or completed payment.
class MpesaPaymentSession extends Equatable {
  /// Creates a new payment session.
  const MpesaPaymentSession({
    this.state = MpesaPaymentState.idle,
    this.checkoutRequestId,
    this.phoneNumber,
    this.amount,
    this.accountReference,
    this.transactionStatus,
    this.errorMessage,
    this.startTime,
  });

  /// Current state of the payment.
  final MpesaPaymentState state;

  /// Checkout request ID from STK Push response.
  final String? checkoutRequestId;

  /// Phone number being charged.
  final String? phoneNumber;

  /// Amount being charged.
  final double? amount;

  /// Account reference for the transaction.
  final String? accountReference;

  /// Latest transaction status from polling.
  final TransactionStatus? transactionStatus;

  /// Error message if payment failed.
  final String? errorMessage;

  /// When the payment was initiated.
  final DateTime? startTime;

  /// Whether the session has an active transaction.
  bool get hasActiveTransaction =>
      checkoutRequestId != null && state.isInProgress;

  /// Time elapsed since payment was initiated.
  Duration get elapsed =>
      startTime != null ? DateTime.now().difference(startTime!) : Duration.zero;

  /// Creates a copy with updated fields.
  MpesaPaymentSession copyWith({
    MpesaPaymentState? state,
    String? checkoutRequestId,
    String? phoneNumber,
    double? amount,
    String? accountReference,
    TransactionStatus? transactionStatus,
    String? errorMessage,
    DateTime? startTime,
  }) {
    return MpesaPaymentSession(
      state: state ?? this.state,
      checkoutRequestId: checkoutRequestId ?? this.checkoutRequestId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      amount: amount ?? this.amount,
      accountReference: accountReference ?? this.accountReference,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      startTime: startTime ?? this.startTime,
    );
  }

  /// Creates an idle session (reset).
  factory MpesaPaymentSession.idle() => const MpesaPaymentSession();

  @override
  List<Object?> get props => [
        state,
        checkoutRequestId,
        phoneNumber,
        amount,
        accountReference,
        transactionStatus,
        errorMessage,
        startTime,
      ];
}
