/// M-Pesa Riverpod providers.
///
/// Provides all M-Pesa payment state management including:
/// - Service provider
/// - STK Push initiation
/// - Transaction status polling
/// - Payment session state
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/api_client.dart';
import 'mpesa_models.dart';
import 'mpesa_service.dart';
import 'mpesa_service_impl.dart';
import 'mpesa_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the M-Pesa service.
final mpesaServiceProvider = Provider<MpesaService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MpesaServiceImpl(apiClient: apiClient);
});

// ─────────────────────────────────────────────────────────────────────────────
// Payment State Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for M-Pesa payment state management.
///
/// Manages the entire payment flow including:
/// - STK Push initiation
/// - Status polling
/// - Timeout handling
/// - Error handling
final mpesaPaymentStateProvider =
    StateNotifierProvider<MpesaPaymentStateNotifier, MpesaPaymentSession>((ref) {
  final mpesaService = ref.watch(mpesaServiceProvider);
  return MpesaPaymentStateNotifier(mpesaService);
});

/// State notifier for M-Pesa payment sessions.
///
/// Handles the complete payment lifecycle:
/// 1. Initiate STK Push
/// 2. Auto-poll status every 3 seconds
/// 3. Handle timeout after 30 seconds
/// 4. Update state based on transaction result
class MpesaPaymentStateNotifier extends StateNotifier<MpesaPaymentSession> {
  /// Creates a new payment state notifier.
  MpesaPaymentStateNotifier(this._mpesaService)
      : super(MpesaPaymentSession.idle());

  final MpesaService _mpesaService;
  Timer? _pollTimer;
  Timer? _timeoutTimer;
  int _pollAttempts = 0;

  /// Initiates an M-Pesa STK Push payment.
  ///
  /// This starts the payment flow:
  /// 1. Sends STK Push request to user's phone
  /// 2. Automatically starts polling for status
  /// 3. Handles timeout after 30 seconds
  ///
  /// Parameters:
  /// - [phoneNumber]: Kenyan phone number (any valid format)
  /// - [amount]: Amount to charge in KES
  /// - [accountReference]: Unique reference (e.g., booking ID)
  /// - [transactionDesc]: Description shown on M-Pesa prompt
  ///
  /// Returns `true` if STK Push was initiated successfully, `false` otherwise.
  Future<bool> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    // Cancel any existing transaction
    _cancelTimers();

    // Format phone number
    final formattedPhone = MpesaUtils.formatPhoneNumber(phoneNumber);
    if (formattedPhone == null) {
      state = state.copyWith(
        state: MpesaPaymentState.failed,
        errorMessage: 'Invalid phone number',
      );
      return false;
    }

    // Update state to initiating
    state = MpesaPaymentSession(
      state: MpesaPaymentState.initiating,
      phoneNumber: formattedPhone,
      amount: amount,
      accountReference: accountReference,
      startTime: DateTime.now(),
    );

    // Send STK Push request
    final result = await _mpesaService.initiateStkPush(
      phoneNumber: formattedPhone,
      amount: amount,
      accountReference: accountReference,
      transactionDesc: transactionDesc,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          state: MpesaPaymentState.failed,
          errorMessage: failure.message,
        );
        return false;
      },
      (response) {
        if (response.isSuccess) {
          // Update state with checkout request ID
          state = state.copyWith(
            state: MpesaPaymentState.waitingForPin,
            checkoutRequestId: response.checkoutRequestId,
          );

          // Start status polling
          _startStatusPolling(response.checkoutRequestId);

          // Start timeout timer
          _startTimeoutTimer();

          return true;
        } else {
          state = state.copyWith(
            state: MpesaPaymentState.failed,
            errorMessage: response.responseDescription ?? 'Failed to initiate payment',
          );
          return false;
        }
      },
    );
  }

  /// Manually checks the transaction status.
  ///
  /// Usually not needed as status is polled automatically,
  /// but can be used to force an immediate status check.
  Future<void> checkStatus() async {
    final checkoutRequestId = state.checkoutRequestId;
    if (checkoutRequestId == null || checkoutRequestId.isEmpty) {
      return;
    }

    await _checkTransactionStatus(checkoutRequestId);
  }

  /// Cancels the current transaction.
  ///
  /// Stops polling and attempts to cancel the transaction on the server.
  /// Note: This may not prevent payment if user has already entered PIN.
  Future<void> cancelTransaction() async {
    _cancelTimers();

    final checkoutRequestId = state.checkoutRequestId;
    if (checkoutRequestId != null && checkoutRequestId.isNotEmpty) {
      // Attempt to cancel on server (best effort)
      await _mpesaService.cancelTransaction(checkoutRequestId);
    }

    state = state.copyWith(
      state: MpesaPaymentState.cancelled,
      errorMessage: 'Payment cancelled',
    );
  }

  /// Resets the payment state to idle.
  ///
  /// Call this when starting a new payment or after handling a completed payment.
  void reset() {
    _cancelTimers();
    state = MpesaPaymentSession.idle();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Starts polling for transaction status.
  void _startStatusPolling(String checkoutRequestId) {
    _pollAttempts = 0;

    // Initial delay before first poll (give user time to see the prompt)
    Future.delayed(
      const Duration(seconds: MpesaUtils.statusPollIntervalSeconds),
      () {
        if (mounted && state.state.isInProgress) {
          _checkTransactionStatus(checkoutRequestId);
        }
      },
    );

    // Set up recurring poll timer
    _pollTimer = Timer.periodic(
      const Duration(seconds: MpesaUtils.statusPollIntervalSeconds),
      (_) {
        if (mounted && state.state.isInProgress) {
          _checkTransactionStatus(checkoutRequestId);
        } else {
          _pollTimer?.cancel();
        }
      },
    );
  }

  /// Starts the timeout timer.
  void _startTimeoutTimer() {
    _timeoutTimer = Timer(
      const Duration(seconds: MpesaUtils.stkPushTimeoutSeconds),
      () {
        if (mounted && state.state.isInProgress) {
          debugPrint('MpesaPaymentState: Transaction timed out');
          state = state.copyWith(
            state: MpesaPaymentState.timeout,
            errorMessage: 'Payment request timed out. Please try again.',
          );
          _pollTimer?.cancel();
        }
      },
    );
  }

  /// Checks the transaction status from the server.
  Future<void> _checkTransactionStatus(String checkoutRequestId) async {
    _pollAttempts++;

    if (_pollAttempts > MpesaUtils.maxPollAttempts) {
      debugPrint('MpesaPaymentState: Max poll attempts reached');
      // Don't mark as timeout yet - let the timeout timer handle it
      return;
    }

    debugPrint('MpesaPaymentState: Polling status (attempt $_pollAttempts)');

    final result = await _mpesaService.checkTransactionStatus(checkoutRequestId);

    result.fold(
      (failure) {
        // Status check failed - don't update state, will retry
        debugPrint('MpesaPaymentState: Status check failed - ${failure.message}');
      },
      (status) {
        debugPrint('MpesaPaymentState: Status update - ${status.status.name}');

        // Update state with transaction status
        state = state.copyWith(
          state: status.status,
          transactionStatus: status,
          errorMessage: status.status == MpesaPaymentState.failed
              ? status.resultCode.errorMessage
              : null,
        );

        // Stop polling if transaction is complete
        if (status.status.isTerminal) {
          _cancelTimers();
        }

        // Update to processing if still waiting but user might have started entering PIN
        if (status.status == MpesaPaymentState.processing &&
            state.state == MpesaPaymentState.waitingForPin) {
          state = state.copyWith(state: MpesaPaymentState.processing);
        }
      },
    );
  }

  /// Cancels all timers.
  void _cancelTimers() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Derived Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the current payment state.
final mpesaPaymentCurrentStateProvider = Provider<MpesaPaymentState>((ref) {
  return ref.watch(mpesaPaymentStateProvider).state;
});

/// Provider for whether a payment is currently in progress.
final mpesaPaymentInProgressProvider = Provider<bool>((ref) {
  return ref.watch(mpesaPaymentCurrentStateProvider).isInProgress;
});

/// Provider for whether the last payment was successful.
final mpesaPaymentSuccessProvider = Provider<bool>((ref) {
  final session = ref.watch(mpesaPaymentStateProvider);
  return session.state == MpesaPaymentState.completed &&
      session.transactionStatus?.isSuccess == true;
});

/// Provider for the current payment error message.
final mpesaPaymentErrorProvider = Provider<String?>((ref) {
  return ref.watch(mpesaPaymentStateProvider).errorMessage;
});

/// Provider for the current checkout request ID.
final mpesaCheckoutRequestIdProvider = Provider<String?>((ref) {
  return ref.watch(mpesaPaymentStateProvider).checkoutRequestId;
});

/// Provider for the M-Pesa receipt number (after successful payment).
final mpesaReceiptNumberProvider = Provider<String?>((ref) {
  return ref.watch(mpesaPaymentStateProvider).transactionStatus?.mpesaReceiptNumber;
});

// ─────────────────────────────────────────────────────────────────────────────
// Action Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for initiating an STK Push payment.
///
/// Usage:
/// ```dart
/// final initiateStkPush = ref.read(stkPushProvider);
/// final success = await initiateStkPush(
///   phoneNumber: '0712345678',
///   amount: 100.0,
///   accountReference: 'BOOKING-123',
///   transactionDesc: 'Payment for trip',
/// );
/// ```
final stkPushProvider = Provider<
    Future<bool> Function({
      required String phoneNumber,
      required double amount,
      required String accountReference,
      required String transactionDesc,
    })>((ref) {
  final notifier = ref.read(mpesaPaymentStateProvider.notifier);
  return notifier.initiateStkPush;
});

/// Provider for transaction status check for a specific checkout request.
///
/// This is a family provider that allows checking status for any checkout request ID.
/// Useful for checking status of transactions from previous sessions.
final transactionStatusProvider =
    FutureProvider.family<TransactionStatus?, String>((ref, checkoutRequestId) async {
  if (checkoutRequestId.isEmpty) return null;

  final mpesaService = ref.watch(mpesaServiceProvider);
  final result = await mpesaService.checkTransactionStatus(checkoutRequestId);

  return result.fold(
    (failure) => null,
    (status) => status,
  );
});

/// Provider for resetting the payment state.
///
/// Usage:
/// ```dart
/// ref.read(resetMpesaPaymentProvider)();
/// ```
final resetMpesaPaymentProvider = Provider<void Function()>((ref) {
  return () => ref.read(mpesaPaymentStateProvider.notifier).reset();
});

/// Provider for cancelling the current transaction.
///
/// Usage:
/// ```dart
/// await ref.read(cancelMpesaPaymentProvider)();
/// ```
final cancelMpesaPaymentProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(mpesaPaymentStateProvider.notifier).cancelTransaction();
});
