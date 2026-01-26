/// Payment processing screen.
///
/// Displays the payment processing state with animated indicators,
/// M-Pesa STK push instructions, and countdown timer.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../widgets/payment_status_indicator.dart';
import '../widgets/payment_countdown.dart';

/// Payment processing screen.
class PaymentProcessingScreen extends ConsumerStatefulWidget {
  const PaymentProcessingScreen({
    super.key,
    required this.bookingId,
  });

  /// The booking ID being processed.
  final String bookingId;

  @override
  ConsumerState<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends ConsumerState<PaymentProcessingScreen> {
  PaymentProcessingState _processingState = PaymentProcessingState.initiating;
  String? _errorMessage;
  Timer? _stateTransitionTimer;
  final GlobalKey<PaymentCountdownState> _countdownKey = GlobalKey();

  // Mock payment configuration
  static const int _stkTimeoutSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startPaymentProcess();
  }

  @override
  void dispose() {
    _stateTransitionTimer?.cancel();
    super.dispose();
  }

  void _startPaymentProcess() {
    // Simulate initiating payment
    _stateTransitionTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _processingState = PaymentProcessingState.waitingForPin;
        });
        // Start simulating the payment flow
        _simulatePaymentFlow();
      }
    });
  }

  void _simulatePaymentFlow() {
    // Simulate waiting for user to enter PIN (in real app, this would poll the server)
    _stateTransitionTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _processingState == PaymentProcessingState.waitingForPin) {
        setState(() {
          _processingState = PaymentProcessingState.processing;
        });

        // Simulate final processing
        _stateTransitionTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            _onPaymentSuccess();
          }
        });
      }
    });
  }

  void _onPaymentSuccess() {
    HapticFeedback.heavyImpact();
    setState(() {
      _processingState = PaymentProcessingState.success;
    });

    // Navigate to receipt screen after brief delay
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.go(RouteConstants.passengerPaymentReceiptPath(widget.bookingId));
      }
    });
  }

  void _onPaymentTimeout() {
    HapticFeedback.mediumImpact();
    setState(() {
      _processingState = PaymentProcessingState.timeout;
      _errorMessage = 'The M-Pesa prompt has expired. Please try again.';
    });
  }

  // TODO(API): Call this method when payment fails from API callback
  // ignore: unused_element
  void _onPaymentFailed(String message) {
    HapticFeedback.mediumImpact();
    setState(() {
      _processingState = PaymentProcessingState.failed;
      _errorMessage = message;
    });
  }

  void _cancelPayment() {
    _stateTransitionTimer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _processingState = PaymentProcessingState.cancelled;
    });
  }

  void _retryPayment() {
    setState(() {
      _processingState = PaymentProcessingState.initiating;
      _errorMessage = null;
    });
    _countdownKey.currentState?.restart();
    _startPaymentProcess();
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: !_processingState.isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _processingState.isLoading) {
          _showCancelConfirmation(context);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _processingState.isLoading
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => _showCancelConfirmation(context),
                )
              : _processingState.isError
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: _goBack,
                    )
                  : null,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PaymentStatusIndicator(
                        state: _processingState,
                        errorMessage: _errorMessage,
                      ),
                      const SizedBox(height: 32),

                      // Countdown timer (only during waiting states)
                      if (_processingState == PaymentProcessingState.waitingForPin)
                        PaymentCountdown(
                          key: _countdownKey,
                          durationSeconds: _stkTimeoutSeconds,
                          onTimeout: _onPaymentTimeout,
                          showProgress: false,
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildBottomActions(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isDark) {
    if (_processingState.isLoading) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _showCancelConfirmation(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Cancel Payment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (_processingState.isError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _retryPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _goBack,
              child: Text(
                'Change Payment Method',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Success state - no actions needed, auto-navigating
    return const SizedBox.shrink();
  }

  void _showCancelConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to cancel this payment? You will need to start again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No, Continue',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelPayment();
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
