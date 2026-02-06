/// Trip Progress Widget - Shows active trip progress with route visualization.
///
/// Displays trip status, passenger count, and visual route progress
/// with stops and current position indicator.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/cards/app_card.dart';
import '../../../trips/domain/entities/driver_trip.dart';

/// A widget that displays the progress of an active trip.
///
/// Shows:
/// - Trip status header with passenger count
/// - Visual route progress with stops
/// - Current position indicator
/// - Start/end times
class TripProgressWidget extends StatelessWidget {
  /// Creates a TripProgressWidget.
  const TripProgressWidget({
    super.key,
    required this.trip,
    required this.stops,
    this.onTap,
  });

  /// The active trip to display.
  final DriverTrip trip;

  /// List of stop names along the route.
  final List<String> stops;

  /// Callback when the widget is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TripHeader(
            status: trip.status,
            passengerCount: trip.passengerCount,
          ),
          const SizedBox(height: AppSpacing.md),
          _RouteProgress(
            stops: stops,
            currentStopIndex: trip.currentStopIndex ?? 0,
            progress: trip.progress,
          ),
          const SizedBox(height: AppSpacing.sm),
          _TimeLine(
            startTime: trip.startTime,
            endTime: trip.endTime,
            currentStopIndex: trip.currentStopIndex ?? 0,
            totalStops: stops.length,
          ),
        ],
      ),
    );
  }
}

/// Trip header showing status and passenger count.
class _TripHeader extends StatelessWidget {
  const _TripHeader({
    required this.status,
    required this.passengerCount,
  });

  final DriverTripStatus status;
  final int passengerCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _getStatusText(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.pillBlueBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$passengerCount pax',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    return switch (status) {
      DriverTripStatus.active => AppColors.primaryGreen,
      DriverTripStatus.pending => AppColors.warning,
      DriverTripStatus.completed => AppColors.completed,
      DriverTripStatus.cancelled => AppColors.error,
    };
  }

  String _getStatusText() {
    return switch (status) {
      DriverTripStatus.active => 'TRIP IN PROGRESS',
      DriverTripStatus.pending => 'TRIP PENDING',
      DriverTripStatus.completed => 'TRIP COMPLETED',
      DriverTripStatus.cancelled => 'TRIP CANCELLED',
    };
  }
}

/// Visual route progress with stops.
class _RouteProgress extends StatelessWidget {
  const _RouteProgress({
    required this.stops,
    required this.currentStopIndex,
    required this.progress,
  });

  final List<String> stops;
  final int currentStopIndex;
  final double progress;

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Progress line with stops
        SizedBox(
          height: 40,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final stopCount = stops.length;

              if (stopCount < 2) {
                return const SizedBox.shrink();
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background line
                  Positioned(
                    left: 12,
                    right: 12,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Progress line
                  Positioned(
                    left: 12,
                    child: Container(
                      width: (width - 24) * progress.clamp(0.0, 1.0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Stop indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(stopCount, (index) {
                      final isPast = index < currentStopIndex;
                      final isCurrent = index == currentStopIndex;

                      return _StopIndicator(
                        isPast: isPast,
                        isCurrent: isCurrent,
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        // Stop names
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(stops.length, (index) {
            final isCurrent = index == currentStopIndex;
            final isFirst = index == 0;
            final isLast = index == stops.length - 1;

            return Flexible(
              child: Container(
                alignment: isFirst
                    ? Alignment.centerLeft
                    : isLast
                        ? Alignment.centerRight
                        : Alignment.center,
                child: Text(
                  stops[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    color: isCurrent
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: isFirst
                      ? TextAlign.left
                      : isLast
                          ? TextAlign.right
                          : TextAlign.center,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Individual stop indicator on the progress line.
class _StopIndicator extends StatelessWidget {
  const _StopIndicator({
    required this.isPast,
    required this.isCurrent,
  });

  final bool isPast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.navigation,
          size: 12,
          color: AppColors.white,
        ),
      );
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isPast ? AppColors.primaryBlue : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isPast ? AppColors.primaryBlue : AppColors.grey300,
          width: 2,
        ),
      ),
    );
  }
}

/// Timeline showing start and end times.
class _TimeLine extends StatelessWidget {
  const _TimeLine({
    required this.startTime,
    this.endTime,
    required this.currentStopIndex,
    required this.totalStops,
  });

  final DateTime startTime;
  final DateTime? endTime;
  final int currentStopIndex;
  final int totalStops;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          timeFormat.format(startTime),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        if (currentStopIndex > 0 && currentStopIndex < totalStops - 1)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.pillGreenBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Text(
                  'You are here',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        Text(
          endTime != null
              ? timeFormat.format(endTime!)
              : 'Est. ${timeFormat.format(startTime.add(const Duration(minutes: 45)))}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
