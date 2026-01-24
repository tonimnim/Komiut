/// Fare calculator widget for displaying and calculating fares.
///
/// Shows fare breakdown based on route, stops, and passenger count.
/// Can be used standalone or integrated into booking flow.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../routes/domain/entities/route_entity.dart';
import '../providers/booking_flow_provider.dart';

/// Widget for calculating and displaying fare information.
class FareCalculator extends ConsumerWidget {
  /// Creates a FareCalculator.
  const FareCalculator({
    super.key,
    required this.route,
    this.pickupStopIndex,
    this.dropoffStopIndex,
    this.passengerCount = 1,
    this.onFareCalculated,
    this.showBreakdown = true,
    this.compact = false,
  });

  /// The route to calculate fare for.
  final RouteEntity route;

  /// Index of pickup stop.
  final int? pickupStopIndex;

  /// Index of dropoff stop.
  final int? dropoffStopIndex;

  /// Number of passengers.
  final int passengerCount;

  /// Callback when fare is calculated.
  final void Function(double fare)? onFareCalculated;

  /// Whether to show fare breakdown.
  final bool showBreakdown;

  /// Whether to use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate fare if stops are selected
    double baseFare = 0;
    int stopsCount = 0;

    if (pickupStopIndex != null &&
        dropoffStopIndex != null &&
        dropoffStopIndex! > pickupStopIndex!) {
      baseFare = route.calculateFare(pickupStopIndex!, dropoffStopIndex!);
      stopsCount = dropoffStopIndex! - pickupStopIndex!;
    }

    final totalFare = baseFare * passengerCount;

    // Notify listener
    if (onFareCalculated != null && baseFare > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onFareCalculated!(totalFare);
      });
    }

    if (compact) {
      return _CompactFareDisplay(
        baseFare: baseFare,
        totalFare: totalFare,
        currency: route.currency,
        passengerCount: passengerCount,
        stopsCount: stopsCount,
        isValid: baseFare > 0,
      );
    }

    return _DetailedFareDisplay(
      route: route,
      baseFare: baseFare,
      totalFare: totalFare,
      passengerCount: passengerCount,
      stopsCount: stopsCount,
      showBreakdown: showBreakdown,
      isValid: baseFare > 0,
    );
  }
}

/// Compact fare display for inline usage.
class _CompactFareDisplay extends StatelessWidget {
  const _CompactFareDisplay({
    required this.baseFare,
    required this.totalFare,
    required this.currency,
    required this.passengerCount,
    required this.stopsCount,
    required this.isValid,
  });

  final double baseFare;
  final double totalFare;
  final String currency;
  final int passengerCount;
  final int stopsCount;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isValid) {
      return Text(
        'Select stops to see fare',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: isDark ? Colors.grey[500] : AppColors.textHint,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.receipt_long,
          size: 16,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$stopsCount ${stopsCount == 1 ? 'stop' : 'stops'}',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey[500] : AppColors.textSecondary,
              ),
            ),
            Text(
              '$currency ${totalFare.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (passengerCount > 1) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'x$passengerCount',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Detailed fare display with breakdown.
class _DetailedFareDisplay extends StatelessWidget {
  const _DetailedFareDisplay({
    required this.route,
    required this.baseFare,
    required this.totalFare,
    required this.passengerCount,
    required this.stopsCount,
    required this.showBreakdown,
    required this.isValid,
  });

  final RouteEntity route;
  final double baseFare;
  final double totalFare;
  final int passengerCount;
  final int stopsCount;
  final bool showBreakdown;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isValid) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: isDark ? Colors.grey[500] : AppColors.textHint,
            ),
            const SizedBox(width: 8),
            Text(
              'Select pickup and dropoff stops to see fare',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calculate,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Fare Estimate',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          if (showBreakdown) ...[
            const SizedBox(height: 16),
            // Breakdown rows
            _FareRow(
              label: 'Base fare',
              value: '${route.currency} ${route.baseFare.toStringAsFixed(0)}',
              isSubItem: false,
            ),
            const SizedBox(height: 8),
            _FareRow(
              label: 'Per stop (${route.farePerStop.toStringAsFixed(0)} x ${stopsCount - 1})',
              value: '${route.currency} ${(route.farePerStop * (stopsCount - 1)).toStringAsFixed(0)}',
              isSubItem: true,
            ),
            const SizedBox(height: 8),
            _FareRow(
              label: 'Subtotal per passenger',
              value: '${route.currency} ${baseFare.toStringAsFixed(0)}',
              isSubItem: false,
            ),
            if (passengerCount > 1) ...[
              const SizedBox(height: 8),
              _FareRow(
                label: 'Passengers',
                value: 'x $passengerCount',
                isSubItem: true,
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
          ] else
            const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Fare',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$stopsCount ${stopsCount == 1 ? 'stop' : 'stops'}'
                    '${passengerCount > 1 ? ' - $passengerCount passengers' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : AppColors.textHint,
                    ),
                  ),
                ],
              ),
              Text(
                '${route.currency} ${totalFare.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 28,
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

/// Single row in fare breakdown.
class _FareRow extends StatelessWidget {
  const _FareRow({
    required this.label,
    required this.value,
    required this.isSubItem,
  });

  final String label;
  final String value;
  final bool isSubItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSubItem ? 12 : 13,
            color: isSubItem
                ? (isDark ? Colors.grey[500] : AppColors.textHint)
                : (isDark ? Colors.grey[400] : AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSubItem ? 12 : 13,
            fontWeight: isSubItem ? FontWeight.normal : FontWeight.w500,
            color: isSubItem
                ? (isDark ? Colors.grey[500] : AppColors.textSecondary)
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Fare calculator integrated with booking flow provider.
class BookingFareCalculator extends ConsumerWidget {
  /// Creates a BookingFareCalculator.
  const BookingFareCalculator({
    super.key,
    this.showBreakdown = true,
    this.compact = false,
  });

  /// Whether to show fare breakdown.
  final bool showBreakdown;

  /// Whether to use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingFlowProvider);
    final route = bookingState.selectedRoute;

    if (route == null) {
      return const _NoRouteState();
    }

    return FareCalculator(
      route: route,
      pickupStopIndex: bookingState.pickupStopIndex,
      dropoffStopIndex: bookingState.dropoffStopIndex,
      passengerCount: bookingState.passengerCount,
      showBreakdown: showBreakdown,
      compact: compact,
    );
  }
}

/// State when no route is selected.
class _NoRouteState extends StatelessWidget {
  const _NoRouteState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 20,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            'Select a route to calculate fare',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline fare preview widget.
class InlineFarePreview extends StatelessWidget {
  /// Creates an InlineFarePreview.
  const InlineFarePreview({
    super.key,
    required this.route,
    required this.pickupIndex,
    required this.dropoffIndex,
    this.passengerCount = 1,
  });

  /// The route.
  final RouteEntity route;

  /// Pickup stop index.
  final int pickupIndex;

  /// Dropoff stop index.
  final int dropoffIndex;

  /// Number of passengers.
  final int passengerCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fare = route.calculateFare(pickupIndex, dropoffIndex);
    final totalFare = fare * passengerCount;
    final stopsCount = dropoffIndex - pickupIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_money,
            size: 16,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            route.formatFare(totalFare),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($stopsCount ${stopsCount == 1 ? 'stop' : 'stops'})',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fare matrix showing fares between all stops.
class FareMatrix extends StatelessWidget {
  /// Creates a FareMatrix.
  const FareMatrix({
    super.key,
    required this.route,
    this.highlightPickup,
    this.highlightDropoff,
  });

  /// The route to show fares for.
  final RouteEntity route;

  /// Index of highlighted pickup stop.
  final int? highlightPickup;

  /// Index of highlighted dropoff stop.
  final int? highlightDropoff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stops = route.stops;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 36,
        columnSpacing: 12,
        horizontalMargin: 8,
        columns: [
          const DataColumn(label: Text('From \\ To')),
          ...stops.map((stop) => DataColumn(
                label: SizedBox(
                  width: 60,
                  child: Text(
                    stop,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )),
        ],
        rows: stops.asMap().entries.map((entry) {
          final fromIndex = entry.key;
          final fromStop = entry.value;

          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: 80,
                  child: Text(
                    fromStop,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              ...stops.asMap().entries.map((toEntry) {
                final toIndex = toEntry.key;

                if (toIndex <= fromIndex) {
                  return DataCell(
                    Container(
                      width: 60,
                      alignment: Alignment.center,
                      child: Text(
                        '-',
                        style: TextStyle(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                      ),
                    ),
                  );
                }

                final fare = route.calculateFare(fromIndex, toIndex);
                final isHighlighted = fromIndex == highlightPickup &&
                    toIndex == highlightDropoff;

                return DataCell(
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: isHighlighted
                        ? BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          )
                        : null,
                    child: Text(
                      fare.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isHighlighted ? FontWeight.bold : FontWeight.normal,
                        color: isHighlighted
                            ? AppColors.primaryBlue
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }
}
