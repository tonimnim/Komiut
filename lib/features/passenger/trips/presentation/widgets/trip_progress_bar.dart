/// Trip progress bar widget.
///
/// Displays a visual progress indicator showing the passenger's journey
/// through the stops on the route.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/domain/entities/route_stop.dart';
import '../../domain/entities/active_trip.dart';

/// A progress bar showing the trip's progress through stops.
class TripProgressBar extends StatelessWidget {
  const TripProgressBar({
    super.key,
    required this.trip,
    this.showStopNames = true,
    this.height = 120,
  });

  /// The active trip to display progress for.
  final ActiveTrip trip;

  /// Whether to show stop names below the progress bar.
  final bool showStopNames;

  /// Height of the widget.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get relevant stops (from pickup to dropoff)
    final pickupIndex =
        trip.route.stops.indexWhere((s) => s.id == trip.pickupStop.id);
    final dropoffIndex =
        trip.route.stops.indexWhere((s) => s.id == trip.dropoffStop.id);

    if (pickupIndex < 0 || dropoffIndex < 0 || pickupIndex >= dropoffIndex) {
      return const SizedBox.shrink();
    }

    final relevantStops =
        trip.route.stops.sublist(pickupIndex, dropoffIndex + 1);
    final currentIndex = (trip.currentStopIndex ?? 0) - pickupIndex;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(trip.progressPercentage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress visualization
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _ProgressVisualization(
                  stops: relevantStops,
                  currentIndex: currentIndex.clamp(0, relevantStops.length - 1),
                  width: constraints.maxWidth,
                  isDark: isDark,
                  showStopNames: showStopNames,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The actual progress visualization widget.
class _ProgressVisualization extends StatelessWidget {
  const _ProgressVisualization({
    required this.stops,
    required this.currentIndex,
    required this.width,
    required this.isDark,
    required this.showStopNames,
  });

  final List<RouteStop> stops;
  final int currentIndex;
  final double width;
  final bool isDark;
  final bool showStopNames;

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) return const SizedBox.shrink();

    final segmentWidth = width / (stops.length - 1);

    return Column(
      children: [
        // Progress line and dots
        SizedBox(
          height: 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background line
              Positioned(
                left: 0,
                right: 0,
                top: 14,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Progress line (completed portion)
              if (currentIndex > 0)
                Positioned(
                  left: 0,
                  top: 14,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: segmentWidth * currentIndex,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryGreen, AppColors.primaryBlue],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              // Stop dots
              ...List.generate(stops.length, (index) {
                final isFirst = index == 0;
                final isLast = index == stops.length - 1;
                final isPassed = index <= currentIndex;
                final isCurrent = index == currentIndex;

                return Positioned(
                  left: index * segmentWidth - 16,
                  top: 0,
                  child: _StopDot(
                    isFirst: isFirst,
                    isLast: isLast,
                    isPassed: isPassed,
                    isCurrent: isCurrent,
                    isDark: isDark,
                  ),
                );
              }),
            ],
          ),
        ),

        // Stop names
        if (showStopNames)
          SizedBox(
            height: 40,
            child: Stack(
              children: List.generate(stops.length, (index) {
                final stop = stops[index];
                final isFirst = index == 0;
                final isLast = index == stops.length - 1;
                final isCurrent = index == currentIndex;

                // Only show first, current, and last stop names
                if (!isFirst && !isLast && !isCurrent) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  left: isFirst
                      ? 0
                      : isLast
                          ? null
                          : (index * segmentWidth - 40),
                  right: isLast ? 0 : null,
                  child: SizedBox(
                    width: isFirst || isLast ? 80 : 80,
                    child: Text(
                      stop.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: isCurrent
                            ? AppColors.primaryBlue
                            : (isDark
                                ? Colors.grey[500]
                                : AppColors.textSecondary),
                      ),
                      textAlign: isFirst
                          ? TextAlign.left
                          : isLast
                              ? TextAlign.right
                              : TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

/// Individual stop dot widget.
class _StopDot extends StatelessWidget {
  const _StopDot({
    required this.isFirst,
    required this.isLast,
    required this.isPassed,
    required this.isCurrent,
    required this.isDark,
  });

  final bool isFirst;
  final bool isLast;
  final bool isPassed;
  final bool isCurrent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final size = (isFirst || isLast || isCurrent) ? 32.0 : 20.0;
    final innerSize = (isFirst || isLast || isCurrent) ? 20.0 : 12.0;

    Color dotColor;
    if (isFirst) {
      dotColor = AppColors.primaryGreen;
    } else if (isLast) {
      dotColor = AppColors.error;
    } else if (isCurrent) {
      dotColor = AppColors.primaryBlue;
    } else if (isPassed) {
      dotColor = AppColors.primaryBlue;
    } else {
      dotColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring for special stops
          if (isFirst || isLast || isCurrent)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor.withOpacity(0.2),
              ),
            ),

          // Inner dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: dotColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: (isFirst || isLast || isCurrent)
                ? Icon(
                    isFirst
                        ? Icons.trip_origin
                        : isLast
                            ? Icons.location_on
                            : Icons.directions_bus,
                    size: 10,
                    color: Colors.white,
                  )
                : null,
          ),

          // Pulse animation for current stop
          if (isCurrent)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Container(
                  width: size * value,
                  height: size * value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor.withOpacity(0.3 / value),
                      width: 2,
                    ),
                  ),
                );
              },
              onEnd: () {
                // Restart animation by rebuilding
              },
            ),
        ],
      ),
    );
  }
}

/// Compact version of the progress bar for smaller spaces.
class TripProgressBarCompact extends StatelessWidget {
  const TripProgressBarCompact({
    super.key,
    required this.progress,
    this.height = 6,
  });

  /// Progress value between 0.0 and 1.0.
  final double progress;

  /// Height of the progress bar.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.primaryBlue],
            ),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
