/// Seat selector widget for visual seat selection.
///
/// Displays a visual seat map with available/taken/selected seats.
/// Supports selecting multiple seats based on passenger count.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/booking_flow_provider.dart';

/// Widget for selecting seats visually.
class SeatSelector extends ConsumerWidget {
  /// Creates a SeatSelector.
  const SeatSelector({
    super.key,
    this.onSeatsSelected,
    this.showLegend = true,
    this.showHeader = true,
  });

  /// Callback when seats are selected.
  final void Function(List<int> seatNumbers)? onSeatsSelected;

  /// Whether to show the seat legend.
  final bool showLegend;

  /// Whether to show the header.
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingFlowProvider);
    final selectedSeats = bookingState.selectedSeats ?? [];
    final passengerCount = bookingState.passengerCount;
    final seatMap = bookingState.seatMap;
    final vehicle = bookingState.selectedVehicle;

    if (seatMap == null || vehicle == null) {
      return const _NoSeatMapState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          _SeatSelectorHeader(
            vehicleRegistration: vehicle.registrationNumber,
            selectedCount: selectedSeats.length,
            requiredCount: passengerCount,
          ),
          const SizedBox(height: 16),
        ],

        if (showLegend) ...[
          const _SeatLegend(),
          const SizedBox(height: 16),
        ],

        // Seat map
        Expanded(
          child: _SeatMapView(
            seatMap: seatMap,
            selectedSeats: selectedSeats,
            onSeatTap: (seatNumber) {
              ref.read(bookingFlowProvider.notifier).toggleSeat(seatNumber);
              final updatedState = ref.read(bookingFlowProvider);
              onSeatsSelected?.call(updatedState.selectedSeats ?? []);
            },
          ),
        ),

        // Selection summary
        const SizedBox(height: 16),
        _SelectionSummary(
          selectedSeats: selectedSeats,
          passengerCount: passengerCount,
        ),
      ],
    );
  }
}

/// Header showing selection status.
class _SeatSelectorHeader extends StatelessWidget {
  const _SeatSelectorHeader({
    required this.vehicleRegistration,
    required this.selectedCount,
    required this.requiredCount,
  });

  final String vehicleRegistration;
  final int selectedCount;
  final int requiredCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isComplete = selectedCount == requiredCount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.primaryGreen.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete
              ? AppColors.primaryGreen
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.event_seat,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleRegistration,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Select $requiredCount ${requiredCount == 1 ? 'seat' : 'seats'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.primaryGreen
                  : (isDark ? Colors.grey[800] : Colors.grey[200]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$selectedCount / $requiredCount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isComplete
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Legend explaining seat colors.
class _SeatLegend extends StatelessWidget {
  const _SeatLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LegendItem(
            color: AppColors.primaryGreen,
            label: 'Available',
          ),
          _LegendItem(
            color: AppColors.primaryBlue,
            label: 'Selected',
          ),
          _LegendItem(
            color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
            label: 'Taken',
          ),
          _LegendItem(
            color: Colors.transparent,
            borderColor: isDark ? Colors.grey[700]! : Colors.grey[400]!,
            label: 'Driver',
            icon: Icons.airline_seat_recline_extra,
          ),
        ],
      ),
    );
  }
}

/// Legend item.
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.borderColor,
    this.icon,
  });

  final Color color;
  final String label;
  final Color? borderColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1.5)
                : null,
          ),
          child: icon != null
              ? Icon(icon, size: 12, color: borderColor)
              : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Visual seat map.
class _SeatMapView extends StatelessWidget {
  const _SeatMapView({
    required this.seatMap,
    required this.selectedSeats,
    required this.onSeatTap,
  });

  final List<List<Seat>> seatMap;
  final List<int> selectedSeats;
  final void Function(int seatNumber) onSeatTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Front indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'FRONT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Seat rows
            ...seatMap.asMap().entries.map((entry) {
              final row = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.asMap().entries.map((seatEntry) {
                    final seat = seatEntry.value;

                    // Add aisle space between columns 1 and 2
                    final needsAisle = seatEntry.key == 1;

                    return Row(
                      children: [
                        _SeatWidget(
                          seat: seat,
                          isSelected: selectedSeats.contains(seat.seatNumber),
                          onTap: seat.canSelect
                              ? () => onSeatTap(seat.seatNumber)
                              : null,
                        ),
                        if (needsAisle) const SizedBox(width: 24),
                        if (!needsAisle && seatEntry.key < row.length - 1)
                          const SizedBox(width: 8),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),

            // Back indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'BACK',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual seat widget.
class _SeatWidget extends StatelessWidget {
  const _SeatWidget({
    required this.seat,
    required this.isSelected,
    this.onTap,
  });

  final Seat seat;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Empty space
    if (seat.type == SeatType.empty) {
      return const SizedBox(width: 44, height: 44);
    }

    // Driver seat
    if (seat.type == SeatType.driver) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.airline_seat_recline_extra,
          size: 20,
          color: isDark ? Colors.grey[600] : Colors.grey[500],
        ),
      );
    }

    // Determine seat color
    Color seatColor;
    Color textColor;

    if (isSelected) {
      seatColor = AppColors.primaryBlue;
      textColor = Colors.white;
    } else if (!seat.isAvailable) {
      seatColor = isDark ? Colors.grey[700]! : Colors.grey[400]!;
      textColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;
    } else {
      seatColor = AppColors.primaryGreen;
      textColor = Colors.white;
    }

    // Seat type indicator
    IconData? typeIcon;
    switch (seat.type) {
      case SeatType.window:
        typeIcon = Icons.window;
        break;
      case SeatType.front:
        typeIcon = Icons.arrow_upward;
        break;
      case SeatType.back:
        typeIcon = Icons.arrow_downward;
        break;
      default:
        typeIcon = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Seat number
            Text(
              '${seat.seatNumber}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),

            // Type indicator (small icon in corner)
            if (typeIcon != null && seat.isAvailable)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  typeIcon,
                  size: 10,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),

            // Selected checkmark
            if (isSelected)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 8,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Selection summary showing selected seats.
class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({
    required this.selectedSeats,
    required this.passengerCount,
  });

  final List<int> selectedSeats;
  final int passengerCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final remaining = passengerCount - selectedSeats.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Seats',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                if (selectedSeats.isEmpty)
                  Text(
                    'None selected',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.grey[500] : AppColors.textHint,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: selectedSeats.map((seatNumber) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Seat $seatNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          if (remaining > 0)
            Text(
              '$remaining more',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }
}

/// State when no seat map is available.
class _NoSeatMapState extends StatelessWidget {
  const _NoSeatMapState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_seat_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No seat map available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select a vehicle first',
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
