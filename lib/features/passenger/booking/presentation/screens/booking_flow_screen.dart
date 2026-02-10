/// Enhanced booking flow screen.
///
/// Multi-step booking screen that guides users through the entire
/// booking process from stop selection to confirmation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../shared/routes/domain/entities/route_entity.dart';
import '../providers/booking_flow_provider.dart';
import '../widgets/booking_review.dart';
import '../widgets/fare_calculator.dart';
import '../widgets/seat_selector.dart';
import '../widgets/stop_selector.dart';
import '../widgets/vehicle_selector.dart';

/// Enhanced booking flow screen with multi-step wizard.
class BookingFlowScreen extends ConsumerStatefulWidget {
  /// Creates a BookingFlowScreen.
  const BookingFlowScreen({
    super.key,
    required this.route,
  });

  /// The route to book for.
  final RouteEntity route;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize booking flow with the selected route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingFlowProvider.notifier).selectRoute(widget.route);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingFlowProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => _handleBack(context, bookingState),
        ),
        title: Text(
          _getStepTitle(bookingState.currentStep),
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // Passenger count (for steps that need it)
          if (_showPassengerCount(bookingState.currentStep))
            _PassengerCountButton(
              count: bookingState.passengerCount,
              onChanged: (count) {
                ref
                    .read(bookingFlowProvider.notifier)
                    .updatePassengerCount(count);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _StepProgressIndicator(
            currentStep: bookingState.currentStep,
            onStepTap: (step) {
              ref.read(bookingFlowProvider.notifier).goToStep(step);
            },
          ),

          // Error message
          if (bookingState.error != null)
            _ErrorBanner(
              message: bookingState.error!,
              onDismiss: () {
                ref.read(bookingFlowProvider.notifier).clearError();
              },
            ),

          // Step content
          Expanded(
            child: _buildStepContent(bookingState),
          ),

          // Bottom action bar
          _BottomActionBar(
            bookingState: bookingState,
            route: widget.route,
            onNext: () => _handleNext(bookingState),
            onSkip: _canSkip(bookingState.currentStep)
                ? () => _handleSkip(bookingState)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BookingFlowState state) {
    switch (state.currentStep) {
      case BookingFlowStep.selectRoute:
        // Route already selected, move to stops
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(bookingFlowProvider.notifier)
              .goToStep(BookingFlowStep.selectStops);
        });
        return const Center(child: CircularProgressIndicator());

      case BookingFlowStep.selectStops:
        return Padding(
          padding: const EdgeInsets.all(20),
          child: StopSelector(
            route: widget.route,
            showFarePreview: true,
          ),
        );

      case BookingFlowStep.selectVehicle:
        return Padding(
          padding: const EdgeInsets.all(20),
          child: VehicleSelector(
            routeId: widget.route.id.toString(),
          ),
        );

      case BookingFlowStep.selectSeats:
        return const Padding(
          padding: EdgeInsets.all(20),
          child: SeatSelector(),
        );

      case BookingFlowStep.reviewBooking:
        return Padding(
          padding: const EdgeInsets.all(20),
          child: BookingReview(
            onEditStops: () {
              ref
                  .read(bookingFlowProvider.notifier)
                  .goToStep(BookingFlowStep.selectStops);
            },
            onEditVehicle: () {
              ref
                  .read(bookingFlowProvider.notifier)
                  .goToStep(BookingFlowStep.selectVehicle);
            },
            onEditSeats: () {
              ref
                  .read(bookingFlowProvider.notifier)
                  .goToStep(BookingFlowStep.selectSeats);
            },
          ),
        );

      case BookingFlowStep.payment:
        return _PaymentStep(
          onPaymentSuccess: (paymentId) {
            ref.read(bookingFlowProvider.notifier).confirmBooking(paymentId);
          },
        );

      case BookingFlowStep.confirmation:
        return _ConfirmationStep(
          bookingId: state.bookingId ?? '',
          onDone: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
    }
  }

  void _handleBack(BuildContext context, BookingFlowState state) {
    if (state.currentStep == BookingFlowStep.selectStops ||
        state.currentStep == BookingFlowStep.selectRoute) {
      Navigator.pop(context);
    } else {
      ref.read(bookingFlowProvider.notifier).goBack();
    }
  }

  void _handleNext(BookingFlowState state) {
    switch (state.currentStep) {
      case BookingFlowStep.selectRoute:
        ref
            .read(bookingFlowProvider.notifier)
            .goToStep(BookingFlowStep.selectStops);
        break;

      case BookingFlowStep.selectStops:
        ref.read(bookingFlowProvider.notifier).confirmStops();
        break;

      case BookingFlowStep.selectVehicle:
        ref.read(bookingFlowProvider.notifier).confirmVehicle();
        break;

      case BookingFlowStep.selectSeats:
        ref.read(bookingFlowProvider.notifier).confirmSeats();
        break;

      case BookingFlowStep.reviewBooking:
        ref.read(bookingFlowProvider.notifier).proceedToPayment();
        break;

      case BookingFlowStep.payment:
        // Payment handles its own completion
        break;

      case BookingFlowStep.confirmation:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
    }
  }

  void _handleSkip(BookingFlowState state) {
    if (state.currentStep == BookingFlowStep.selectSeats) {
      ref.read(bookingFlowProvider.notifier).skipSeatSelection();
    }
  }

  bool _canSkip(BookingFlowStep step) {
    return step == BookingFlowStep.selectSeats;
  }

  bool _showPassengerCount(BookingFlowStep step) {
    return step == BookingFlowStep.selectStops ||
        step == BookingFlowStep.selectVehicle ||
        step == BookingFlowStep.selectSeats;
  }

  String _getStepTitle(BookingFlowStep step) {
    switch (step) {
      case BookingFlowStep.selectRoute:
        return 'Select Route';
      case BookingFlowStep.selectStops:
        return 'Select Stops';
      case BookingFlowStep.selectVehicle:
        return 'Select Vehicle';
      case BookingFlowStep.selectSeats:
        return 'Select Seats';
      case BookingFlowStep.reviewBooking:
        return 'Review Booking';
      case BookingFlowStep.payment:
        return 'Payment';
      case BookingFlowStep.confirmation:
        return 'Confirmed';
    }
  }
}

/// Progress indicator showing current step.
class _StepProgressIndicator extends StatelessWidget {
  const _StepProgressIndicator({
    required this.currentStep,
    required this.onStepTap,
  });

  final BookingFlowStep currentStep;
  final void Function(BookingFlowStep step) onStepTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Only show main steps (not route selection or confirmation)
    final visibleSteps = [
      BookingFlowStep.selectStops,
      BookingFlowStep.selectVehicle,
      BookingFlowStep.selectSeats,
      BookingFlowStep.reviewBooking,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: visibleSteps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isCompleted = step.stepNumber < currentStep.stepNumber;
          final isCurrent = step == currentStep;
          final isLast = index == visibleSteps.length - 1;

          return Expanded(
            child: Row(
              children: [
                // Step circle
                GestureDetector(
                  onTap: isCompleted ? () => onStepTap(step) : null,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isCurrent
                          ? AppColors.primaryBlue
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      border: isCurrent
                          ? Border.all(
                              color:
                                  AppColors.primaryBlue.withValues(alpha: 0.5),
                              width: 3,
                            )
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isCurrent
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[600]),
                              ),
                            ),
                    ),
                  ),
                ),

                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isCompleted
                          ? AppColors.primaryBlue
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Error banner for displaying errors.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: AppColors.error, size: 18),
          ),
        ],
      ),
    );
  }
}

/// Passenger count button.
class _PassengerCountButton extends StatelessWidget {
  const _PassengerCountButton({
    required this.count,
    required this.onChanged,
  });

  final int count;
  final void Function(int count) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: count > 1 ? () => onChanged(count - 1) : null,
            child: Icon(
              Icons.remove,
              size: 18,
              color: count > 1
                  ? AppColors.primaryBlue
                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.person,
                    size: 16, color: theme.colorScheme.onSurface),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: count < 10 ? () => onChanged(count + 1) : null,
            child: Icon(
              Icons.add,
              size: 18,
              color: count < 10
                  ? AppColors.primaryBlue
                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom action bar.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.bookingState,
    required this.route,
    required this.onNext,
    this.onSkip,
  });

  final BookingFlowState bookingState;
  final RouteEntity route;
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Don't show for confirmation step
    if (bookingState.currentStep == BookingFlowStep.confirmation) {
      return const SizedBox.shrink();
    }

    // Don't show for payment step (has its own actions)
    if (bookingState.currentStep == BookingFlowStep.payment) {
      return const SizedBox.shrink();
    }

    final canProceed = _canProceed(bookingState);
    final buttonLabel = _getButtonLabel(bookingState.currentStep);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Fare display (for relevant steps)
            if (_showFare(bookingState.currentStep)) ...[
              Expanded(
                child: FareCalculator(
                  route: route,
                  pickupStopIndex: bookingState.pickupStopIndex,
                  dropoffStopIndex: bookingState.dropoffStopIndex,
                  passengerCount: bookingState.passengerCount,
                  compact: true,
                ),
              ),
              const SizedBox(width: 16),
            ],

            // Skip button
            if (onSkip != null) ...[
              TextButton(
                onPressed: onSkip,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Next button
            Expanded(
              flex: onSkip != null || !_showFare(bookingState.currentStep)
                  ? 1
                  : 0,
              child: ElevatedButton(
                onPressed: canProceed ? onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor:
                      isDark ? Colors.grey[800] : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: canProceed
                        ? Colors.white
                        : (isDark ? Colors.grey[600] : Colors.grey[500]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed(BookingFlowState state) {
    switch (state.currentStep) {
      case BookingFlowStep.selectRoute:
        return state.selectedRoute != null;
      case BookingFlowStep.selectStops:
        return state.hasValidStops;
      case BookingFlowStep.selectVehicle:
        return state.hasVehicle;
      case BookingFlowStep.selectSeats:
        return true; // Optional
      case BookingFlowStep.reviewBooking:
        return state.isReadyForReview;
      default:
        return true;
    }
  }

  bool _showFare(BookingFlowStep step) {
    return step == BookingFlowStep.selectStops ||
        step == BookingFlowStep.selectVehicle;
  }

  String _getButtonLabel(BookingFlowStep step) {
    switch (step) {
      case BookingFlowStep.selectStops:
        return 'Select Vehicle';
      case BookingFlowStep.selectVehicle:
        return 'Select Seats';
      case BookingFlowStep.selectSeats:
        return 'Review Booking';
      case BookingFlowStep.reviewBooking:
        return 'Proceed to Payment';
      default:
        return 'Continue';
    }
  }
}

/// Payment step placeholder.
class _PaymentStep extends StatelessWidget {
  const _PaymentStep({required this.onPaymentSuccess});

  final void Function(String paymentId) onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payment,
              size: 64,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Payment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your payment to confirm the booking',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Payment methods (placeholder)
          _PaymentMethodButton(
            icon: Icons.phone_android,
            label: 'M-Pesa',
            onTap: () {
              // Simulate payment
              onPaymentSuccess('PAY-${DateTime.now().millisecondsSinceEpoch}');
            },
          ),
          const SizedBox(height: 12),
          _PaymentMethodButton(
            icon: Icons.account_balance_wallet,
            label: 'Wallet',
            onTap: () {
              onPaymentSuccess('PAY-${DateTime.now().millisecondsSinceEpoch}');
            },
          ),
        ],
      ),
    );
  }
}

/// Payment method button.
class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirmation step.
class _ConfirmationStep extends StatelessWidget {
  const _ConfirmationStep({
    required this.bookingId,
    required this.onDone,
  });

  final String bookingId;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Booking Confirmed!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your trip has been booked successfully',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Booking ID: $bookingId',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // View ticket/booking details
            },
            child: const Text(
              'View Ticket',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
