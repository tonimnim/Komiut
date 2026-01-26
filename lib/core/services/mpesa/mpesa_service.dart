/// M-Pesa service abstract interface.
///
/// Defines the contract for M-Pesa STK Push integration.
/// Implementations should handle communication with the backend API
/// which in turn communicates with Safaricom's Daraja API.
library;

import 'package:dartz/dartz.dart';

import '../../errors/failures.dart';
import 'mpesa_models.dart';

/// Abstract interface for M-Pesa payment operations.
///
/// Provides methods for:
/// - Initiating STK Push payments
/// - Checking transaction status
/// - Cancelling pending transactions
///
/// All methods return [Either] to handle errors gracefully using
/// the dartz functional programming pattern.
abstract class MpesaService {
  /// Initiates an M-Pesa STK Push payment.
  ///
  /// Sends a payment request to the user's phone. The user will see
  /// a prompt asking them to enter their M-Pesa PIN to authorize
  /// the payment.
  ///
  /// Parameters:
  /// - [phoneNumber]: Kenyan phone number in 254XXXXXXXXX format
  /// - [amount]: Amount to charge in KES (1-150,000)
  /// - [accountReference]: Unique reference for the transaction
  /// - [transactionDesc]: Description shown to user on M-Pesa prompt
  ///
  /// Returns:
  /// - [Right(StkPushResponse)]: STK Push was initiated successfully.
  ///   Contains [checkoutRequestId] for status polling.
  /// - [Left(Failure)]: STK Push failed to initiate.
  ///
  /// Note: A successful response does NOT mean the payment is complete.
  /// You must poll [checkTransactionStatus] to get the final result.
  Future<Either<Failure, StkPushResponse>> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  });

  /// Checks the status of an M-Pesa transaction.
  ///
  /// Polls the backend to get the current status of a previously
  /// initiated STK Push transaction.
  ///
  /// Parameters:
  /// - [checkoutRequestId]: The checkout request ID from [initiateStkPush]
  ///
  /// Returns:
  /// - [Right(TransactionStatus)]: Status retrieved successfully.
  ///   Check [TransactionStatus.status] for the current state.
  /// - [Left(Failure)]: Failed to retrieve status.
  ///
  /// Typical flow:
  /// 1. Call [initiateStkPush]
  /// 2. Wait 3 seconds
  /// 3. Call [checkTransactionStatus]
  /// 4. If status is pending, repeat from step 2
  /// 5. Stop when status is terminal (completed/failed/cancelled/timeout)
  Future<Either<Failure, TransactionStatus>> checkTransactionStatus(
    String checkoutRequestId,
  );

  /// Cancels a pending M-Pesa transaction.
  ///
  /// Attempts to cancel a transaction that is still pending user input.
  /// This may not always succeed if the user has already entered their PIN.
  ///
  /// Parameters:
  /// - [checkoutRequestId]: The checkout request ID from [initiateStkPush]
  ///
  /// Returns:
  /// - [Right(void)]: Cancellation request sent successfully.
  /// - [Left(Failure)]: Failed to send cancellation request.
  ///
  /// Note: Even if this succeeds, the transaction may still complete
  /// if the user has already authorized it. Always check the final
  /// status with [checkTransactionStatus].
  Future<Either<Failure, void>> cancelTransaction(String checkoutRequestId);
}

/// M-Pesa specific failure types.
class MpesaFailure extends Failure {
  const MpesaFailure(super.message, {this.resultCode});

  /// M-Pesa result code if available.
  final MpesaTransactionResultCode? resultCode;

  @override
  List<Object> get props =>
      [message, if (resultCode != null) resultCode!];
}

/// Failure when STK Push initiation fails.
class StkPushFailure extends MpesaFailure {
  const StkPushFailure(super.message, {super.resultCode});
}

/// Failure when transaction status check fails.
class TransactionStatusFailure extends MpesaFailure {
  const TransactionStatusFailure(super.message, {super.resultCode});
}

/// Failure when transaction times out.
class TransactionTimeoutFailure extends MpesaFailure {
  const TransactionTimeoutFailure([
    super.message = 'Transaction timed out waiting for user input',
  ]) : super(resultCode: MpesaTransactionResultCode.timeout);
}

/// Failure when user cancels the transaction.
class TransactionCancelledFailure extends MpesaFailure {
  const TransactionCancelledFailure([
    super.message = 'Transaction was cancelled',
  ]) : super(resultCode: MpesaTransactionResultCode.cancelled);
}
