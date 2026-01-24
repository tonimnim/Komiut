/// Booking review widget for summary before payment.
///
/// Displays route info, stops, vehicle, seats, and fare breakdown
/// with edit buttons to go back to previous steps.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/booking_flow_provider.dart';

/// Widget for reviewing booking details before payment.
class BookingReview extends ConsumerWidget {
  /// Creates a BookingReview.
  const BookingReview({
    super.key,
    this.onEditStops,
    this.onEditVehicle,
    this.onEditSeats,
    this.onProceedToPayment,
  });

  /// Callback to edit stops selection.
  final VoidCallback? onEditStops;

  /// Callback to edit vehicle selection.
  final VoidCallback? onEditVehicle;

  /// Callback to edit seat selection.
  final VoidCallback? onEditSeats;

  /// Callback to proceed to payment.
  final VoidCallback? onProceedToPayment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingFlowProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final route = bookingState.selectedRoute;
    final vehicle = bookingState.selectedVehicle;

    if (route == null) {
      return const _NoBookingState();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route section
          _ReviewSection(
            title: 'Route',
            icon: Icons.route,
            onEdit: null, // Route cannot be edited at this point
            child: _RouteDetails(
              routeName: route.name,
              routeSummary: route.routeSummary,
            ),
          ),
          const SizedBox(height: 16),

          // Journey section (stops)
          _ReviewSection(
            title: 'Journey',
            icon: Icons.location_on,
            onEdit: onEditStops,
            child: _JourneyDetails(
              pickupStop: bookingState.pickupStopName ?? 'Not selected',
              dropoffStop: bookingState.dropoffStopName ?? 'Not selected',
              stopsCount: bookingState.stopsToTravel,
            ),
          ),
          const SizedBox(height: 16),

          // Vehicle section
          _ReviewSection(
            title: 'Vehicle',
            icon: Icons.directions_bus,
            onEdit: onEditVehicle,
            child: vehicle != null
                ? _VehicleDetails(
                    registration: vehicle.registrationNumber,
                    make: vehicle.make,
                    model: vehicle.model,
                    driverName: vehicle.driverName,
                    position: vehicle.position,
                    departureTime: vehicle.formattedDepartureTime,
                  )
                : const _NotSelectedState(message: 'No vehicle selected'),
          ),
          const SizedBox(height: 16),

          // Seats section (optional)
          if (bookingState.selectedSeats != null &&
              bookingState.selectedSeats!.isNotEmpty) ...[
            _ReviewSection(
              title: 'Seats',
              icon: Icons.event_seat,
              onEdit: onEditSeats,
              child: _SeatsDetails(
                seatNumbers: bookingState.selectedSeats!,
                passengerCount: bookingState.passengerCount,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Passengers section
          _ReviewSection(
            title: 'Passengers',
            icon: Icons.people,
            onEdit: null,
            child: _PassengerDetails(
              count: bookingState.passengerCount,
            ),
          ),
          const SizedBox(height: 16),

          // Fare breakdown
          _FareBreakdown(
            baseFare: bookingState.calculatedFare,
            passengerCount: bookingState.passengerCount,
            totalFare: bookingState.totalFare,
            currency: route.currency,
          ),
          const SizedBox(height: 24),

          // Terms and conditions notice
          _TermsNotice(),
          const SizedBox(height: 24),

          // Proceed button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: bookingState.isReadyForReview
                  ? (onProceedToPayment ?? () {
                      ref.read(bookingFlowProvider.notifier).proceedToPayment();
                    })
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proceed to Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: bookingState.isReadyForReview
                      ? Colors.white
                      : (isDark ? Colors.grey[600] : Colors.grey[500]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section container for review items.
class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.child,
    this.onEdit,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
              ),
              if (onEdit != null)
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          child,
        ],
      ),
    );
  }
}

/// Route details display.
class _RouteDetails extends StatelessWidget {
  const _RouteDetails({
    required this.routeName,
    required this.routeSummary,
  });

  final String routeName;
  final String routeSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          routeName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          routeSummary,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Journey (stops) details display.
class _JourneyDetails extends StatelessWidget {
  const _JourneyDetails({
    required this.pickupStop,
    required this.dropoffStop,
    required this.stopsCount,
  });

  final String pickupStop;
  final String dropoffStop;
  final int stopsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Pickup
        _StopRow(
          label: 'Pickup',
          stopName: pickupStop,
          color: AppColors.primaryGreen,
        ),
        // Connection line
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Container(
                width: 2,
                height: 24,
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
              const SizedBox(width: 16),
              Text(
                '$stopsCount ${stopsCount == 1 ? 'stop' : 'stops'}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
        // Dropoff
        _StopRow(
          label: 'Dropoff',
          stopName: dropoffStop,
          color: AppColors.error,
        ),
      ],
    );
  }
}

/// Single stop row in journey details.
class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.label,
    required this.stopName,
    required this.color,
  });

  final String label;
  final String stopName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            Text(
              stopName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Vehicle details display.
class _VehicleDetails extends StatelessWidget {
  const _VehicleDetails({
    required this.registration,
    this.make,
    this.model,
    this.driverName,
    required this.position,
    this.departureTime,
  });

  final String registration;
  final String? make;
  final String? model;
  final String? driverName;
  final int position;
  final String? departureTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              registration,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '#$position in queue',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        if (make != null && model != null) ...[
          const SizedBox(height: 4),
          Text(
            '$make $model',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            if (driverName != null) ...[
              Icon(
                Icons.person,
                size: 14,
                color: isDark ? Colors.grey[500] : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                driverName!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (departureTime != null) ...[
              Icon(
                Icons.schedule,
                size: 14,
                color: AppColors.info,
              ),
              const SizedBox(width: 4),
              Text(
                departureTime!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.info,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Seats details display.
class _SeatsDetails extends StatelessWidget {
  const _SeatsDetails({
    required this.seatNumbers,
    required this.passengerCount,
  });

  final List<int> seatNumbers;
  final int passengerCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${seatNumbers.length} of $passengerCount seats selected',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: seatNumbers.map((number) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Seat $number',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Passenger count display.
class _PassengerDetails extends StatelessWidget {
  const _PassengerDetails({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.person,
            size: 20,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$count ${count == 1 ? 'Passenger' : 'Passengers'}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Fare breakdown display.
class _FareBreakdown extends StatelessWidget {
  const _FareBreakdown({
    required this.baseFare,
    required this.passengerCount,
    required this.totalFare,
    required this.currency,
  });

  final double baseFare;
  final int passengerCount;
  final double totalFare;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Fare per passenger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fare per passenger',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
              Text(
                '$currency ${baseFare.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Passengers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Number of passengers',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
              Text(
                'x $passengerCount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '$currency ${totalFare.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Terms notice text.
class _TermsNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      'By proceeding, you agree to our Terms of Service and acknowledge '
      'that your booking is subject to vehicle availability.',
      style: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.grey[500] : AppColors.textHint,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Not selected state display.
class _NotSelectedState extends StatelessWidget {
  const _NotSelectedState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 18,
          color: AppColors.warning,
        ),
        const SizedBox(width: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.grey[500] : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}

/// No booking state display.
class _NoBookingState extends StatelessWidget {
  const _NoBookingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No booking to review',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select a route first',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
