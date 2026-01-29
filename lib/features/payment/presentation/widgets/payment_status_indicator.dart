/// Payment status indicator widget.
///
/// Displays the current payment processing state with animations
/// and appropriate messaging for each state.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Payment processing states.
enum PaymentProcessingState {
  initiating,
  waitingForPin,
  processing,
  success,
  failed,
  timeout,
  cancelled,
}

/// Extension to add display properties to PaymentProcessingState.
extension PaymentProcessingStateExtension on PaymentProcessingState {
  String get title {
    switch (this) {
      case PaymentProcessingState.initiating:
        return 'Initiating Payment';
      case PaymentProcessingState.waitingForPin:
        return 'Enter M-Pesa PIN';
      case PaymentProcessingState.processing:
        return 'Processing Payment';
      case PaymentProcessingState.success:
        return 'Payment Successful';
      case PaymentProcessingState.failed:
        return 'Payment Failed';
      case PaymentProcessingState.timeout:
        return 'Payment Timeout';
      case PaymentProcessingState.cancelled:
        return 'Payment Cancelled';
    }
  }

  String get description {
    switch (this) {
      case PaymentProcessingState.initiating:
        return 'Connecting to M-Pesa...';
      case PaymentProcessingState.waitingForPin:
        return 'Check your phone for the M-Pesa prompt and enter your PIN';
      case PaymentProcessingState.processing:
        return 'Your payment is being processed...';
      case PaymentProcessingState.success:
        return 'Your payment has been completed successfully';
      case PaymentProcessingState.failed:
        return 'Your payment could not be completed';
      case PaymentProcessingState.timeout:
        return 'The payment request has expired';
      case PaymentProcessingState.cancelled:
        return 'You cancelled the payment';
    }
  }

  bool get isLoading {
    return this == PaymentProcessingState.initiating ||
        this == PaymentProcessingState.waitingForPin ||
        this == PaymentProcessingState.processing;
  }

  bool get isSuccess => this == PaymentProcessingState.success;

  bool get isError {
    return this == PaymentProcessingState.failed ||
        this == PaymentProcessingState.timeout ||
        this == PaymentProcessingState.cancelled;
  }

  Color get color {
    if (isSuccess) return AppColors.success;
    if (isError) return AppColors.error;
    return AppColors.primaryBlue;
  }

  IconData? get icon {
    switch (this) {
      case PaymentProcessingState.success:
        return Icons.check_circle;
      case PaymentProcessingState.failed:
        return Icons.error;
      case PaymentProcessingState.timeout:
        return Icons.timer_off;
      case PaymentProcessingState.cancelled:
        return Icons.cancel;
      default:
        return null;
    }
  }
}

/// A widget that displays the current payment processing state.
class PaymentStatusIndicator extends StatefulWidget {
  const PaymentStatusIndicator({
    super.key,
    required this.state,
    this.errorMessage,
    this.showDescription = true,
  });

  /// The current processing state.
  final PaymentProcessingState state;

  /// Optional custom error message to display.
  final String? errorMessage;

  /// Whether to show the description text.
  final bool showDescription;

  @override
  State<PaymentStatusIndicator> createState() => _PaymentStatusIndicatorState();
}

class _PaymentStatusIndicatorState extends State<PaymentStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    if (!widget.state.isLoading) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PaymentStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.isLoading && !widget.state.isLoading) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon or loading indicator
        SizedBox(
          width: 80,
          height: 80,
          child: widget.state.isLoading
              ? _buildLoadingIndicator()
              : _buildResultIcon(),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          widget.state.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        if (widget.showDescription) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorMessage ?? widget.state.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        // M-Pesa PIN instruction card
        if (widget.state == PaymentProcessingState.waitingForPin) ...[
          const SizedBox(height: 24),
          _MpesaInstructionCard(isDark: isDark),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulsing circle
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.state.color.withValues(alpha: 0.1),
                ),
              ),
            );
          },
          onEnd: () {
            if (mounted && widget.state.isLoading) {
              setState(() {});
            }
          },
        ),
        // Loading spinner
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            color: widget.state.color,
            strokeWidth: 3,
          ),
        ),
        // Icon in center
        if (widget.state == PaymentProcessingState.waitingForPin)
          Icon(
            Icons.smartphone,
            color: widget.state.color,
            size: 24,
          ),
      ],
    );
  }

  Widget _buildResultIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.state.color.withOpacity(0.1),
              ),
              child: Icon(
                widget.state.icon,
                color: widget.state.color,
                size: 48,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MpesaInstructionCard extends StatelessWidget {
  const _MpesaInstructionCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.grey900
            : AppColors.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone_android,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'M-Pesa STK Push',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'A prompt will appear on your phone',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.grey400 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _InstructionStep(
            number: '1',
            text: 'Check your phone for the M-Pesa prompt',
          ),
          const SizedBox(height: 8),
          const _InstructionStep(
            number: '2',
            text: 'Enter your M-Pesa PIN',
          ),
          const SizedBox(height: 8),
          const _InstructionStep(
            number: '3',
            text: 'Press OK to confirm payment',
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.grey300 : AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.grey300 : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
