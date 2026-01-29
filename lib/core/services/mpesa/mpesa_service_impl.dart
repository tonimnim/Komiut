/// M-Pesa service implementation.
///
/// Implements M-Pesa STK Push integration using the Daraja API
/// through our backend server. The backend handles authentication
/// with Safaricom and provides simplified endpoints.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../errors/failures.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'mpesa_models.dart';
import 'mpesa_service.dart';
import 'mpesa_utils.dart';

/// Implementation of [MpesaService] using backend API.
///
/// Communicates with our backend server which handles:
/// - Safaricom OAuth authentication
/// - STK Push initiation via Daraja API
/// - Transaction status queries
/// - Callback handling and status updates
class MpesaServiceImpl implements MpesaService {
  /// Creates a new M-Pesa service implementation.
  const MpesaServiceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  // ─────────────────────────────────────────────────────────────────────────
  // MpesaService Implementation
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, StkPushResponse>> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    // Validate phone number
    final phoneError = MpesaUtils.validatePhoneNumber(phoneNumber);
    if (phoneError != null) {
      return Left(ValidationFailure(phoneError));
    }

    // Format phone number to M-Pesa format
    final formattedPhone = MpesaUtils.formatPhoneNumber(phoneNumber);
    if (formattedPhone == null) {
      return const Left(ValidationFailure('Invalid phone number format'));
    }

    // Validate amount
    final amountError = MpesaUtils.validateAmount(amount);
    if (amountError != null) {
      return Left(ValidationFailure(amountError));
    }

    // Create request
    final request = StkPushRequest(
      phoneNumber: formattedPhone,
      amount: amount,
      accountReference: accountReference,
      transactionDesc: transactionDesc,
    );

    debugPrint('MpesaService: Initiating STK Push for $formattedPhone, '
        'amount: KES $amount, ref: $accountReference');

    // Send request to backend
    final result = await _apiClient.post<StkPushResponse>(
      ApiEndpoints.mpesaStkPush,
      data: request.toJson(),
      fromJson: (data) => StkPushResponse.fromJson(data as Map<String, dynamic>),
    );

    return result.fold(
      (failure) {
        debugPrint('MpesaService: STK Push failed - ${failure.message}');
        return Left(_mapToMpesaFailure(failure, isStk: true));
      },
      (response) {
        if (response.isSuccess) {
          debugPrint('MpesaService: STK Push initiated successfully - '
              'checkoutRequestId: ${response.checkoutRequestId}');
          return Right(response);
        } else {
          debugPrint('MpesaService: STK Push failed - '
              'code: ${response.responseCode}, desc: ${response.responseDescription}');
          return Left(StkPushFailure(
            response.responseDescription ?? 'Failed to initiate payment',
          ));
        }
      },
    );
  }

  @override
  Future<Either<Failure, TransactionStatus>> checkTransactionStatus(
    String checkoutRequestId,
  ) async {
    if (checkoutRequestId.isEmpty) {
      return const Left(ValidationFailure('Invalid checkout request ID'));
    }

    debugPrint('MpesaService: Checking status for $checkoutRequestId');

    final result = await _apiClient.get<TransactionStatus>(
      ApiEndpoints.mpesaStatus(checkoutRequestId),
      fromJson: (data) => TransactionStatus.fromJson(data as Map<String, dynamic>),
    );

    return result.fold(
      (failure) {
        debugPrint('MpesaService: Status check failed - ${failure.message}');
        return Left(_mapToMpesaFailure(failure, isStk: false));
      },
      (status) {
        debugPrint('MpesaService: Transaction status - ${status.status.name}, '
            'resultCode: ${status.resultCode.name}');
        return Right(status);
      },
    );
  }

  @override
  Future<Either<Failure, void>> cancelTransaction(
    String checkoutRequestId,
  ) async {
    if (checkoutRequestId.isEmpty) {
      return const Left(ValidationFailure('Invalid checkout request ID'));
    }

    debugPrint('MpesaService: Cancelling transaction $checkoutRequestId');

    final result = await _apiClient.post<void>(
      ApiEndpoints.mpesaCancel(checkoutRequestId),
    );

    return result.fold(
      (failure) {
        debugPrint('MpesaService: Cancel failed - ${failure.message}');
        // Cancellation failure is not critical - transaction may already be complete
        return Left(failure);
      },
      (_) {
        debugPrint('MpesaService: Cancel request sent successfully');
        return const Right(null);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps generic failures to M-Pesa specific failures.
  Failure _mapToMpesaFailure(Failure failure, {required bool isStk}) {
    if (failure is NetworkFailure) {
      return failure; // Keep network failures as-is
    }

    if (failure is ServerFailure) {
      final message = _getServerErrorMessage(failure.statusCode);
      if (isStk) {
        return StkPushFailure(message);
      }
      return TransactionStatusFailure(message);
    }

    if (isStk) {
      return StkPushFailure(failure.message);
    }
    return TransactionStatusFailure(failure.message);
  }

  /// Gets user-friendly message for server errors.
  String _getServerErrorMessage(int? statusCode) {
    return switch (statusCode) {
      400 => 'Invalid request. Please check your details and try again.',
      401 => 'Session expired. Please login again.',
      403 => 'Payment service is not available for your account.',
      404 => 'Transaction not found.',
      429 => 'Too many requests. Please wait a moment and try again.',
      500 => 'Payment service temporarily unavailable. Please try again later.',
      502 => 'M-Pesa service is currently unavailable. Please try again later.',
      503 => 'Payment service is under maintenance. Please try again later.',
      _ => 'An error occurred. Please try again.',
    };
  }
}
