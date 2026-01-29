/// Queued Vehicle Card - Individual vehicle card in the queue.
///
/// Displays vehicle information including position, registration,
/// seat availability, and status. Tappable for booking selection.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Status of a vehicle in the queue.
enum VehicleQueueStatus {
  /// Vehicle is currently boarding passengers.
  boarding,

  /// Vehicle is waiting in queue.
  waiting,

  /// Vehicle is about to depart.
  departing,

  /// Vehicle is full.
  full,
}

/// Extension to add display properties to VehicleQueueStatus.
extension VehicleQueueStatusX on VehicleQueueStatus {
  /// Display label for the status.
  String get label {
    switch (this) {
      case VehicleQueueStatus.boarding:
        return 'Boarding Now';
      case VehicleQueueStatus.waiting:
        return 'Waiting';
      case VehicleQueueStatus.departing:
        return 'Departing Soon';
      case VehicleQueueStatus.full:
        return 'Full';
    }
  }

  /// Color associated with the status.
  Color get color {
    switch (this) {
      case VehicleQueueStatus.boarding:
        return AppColors.success; // Green
      case VehicleQueueStatus.waiting:
        return AppColors.warning; // Yellow/Amber
      case VehicleQueueStatus.departing:
        return AppColors.info; // Blue
      case VehicleQueueStatus.full:
        return AppColors.textSecondary; // Gray
    }
  }

  /// Background color for status badge.
  Color get backgroundColor {
    return color.withValues(alpha: 0.1);
  }
}

/// A card widget displaying a queued vehicle's information.
///
/// Shows the vehicle's position in queue, registration number,
/// seat availability, and current status.
class QueuedVehicleCard extends StatelessWidget {
  /// Creates a QueuedVehicleCard widget.
  const QueuedVehicleCard({
    super.key,
    required this.position,
    required this.registrationNumber,
    required this.availableSeats,
    required this.totalSeats,
    required this.status,
    this.eta,
    this.vehicleType,
    this.onTap,
    this.isSelected = false,
  });

  /// Position in the queue (1-based).
  final int position;

  /// Vehicle registration number.
  final String registrationNumber;

  /// Number of available seats.
  final int availableSeats;

  /// Total number of seats.
  final int totalSeats;

  /// Current status of the vehicle.
  final VehicleQueueStatus status;

  /// Estimated time of arrival/departure.
  final String? eta;

  /// Type of vehicle (e.g., "Matatu", "Bus").
  final String? vehicleType;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Whether this vehicle is selected.
  final bool isSelected;

  /// Get ordinal suffix for position (1st, 2nd, 3rd, etc.)
  String get _ordinalPosition {
    if (position >= 11 && position <= 13) {
      return '${position}th';
    }
    switch (position % 10) {
      case 1:
        return '${position}st';
      case 2:
        return '${position}nd';
      case 3:
        return '${position}rd';
      default:
        return '${position}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = status == VehicleQueueStatus.full;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryBlue.withOpacity(0.15)
                  : AppColors.shadow.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1.0,
          child: Row(
            children: [
              // Position badge
              _PositionBadge(
                position: position,
                ordinal: _ordinalPosition,
                status: status,
                isDark: isDark,
              ),
              const SizedBox(width: 14),

              // Vehicle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Registration number
                    Text(
                      registrationNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Seat availability
                    Row(
                      children: [
                        Icon(
                          Icons.event_seat,
                          size: 14,
                          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$availableSeats/$totalSeats seats',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                          ),
                        ),
                        if (vehicleType != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            vehicleType!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Status and ETA
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Status badge
                  _StatusBadge(status: status),
                  if (eta != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      eta!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),

              // Chevron for tap affordance
              if (onTap != null && !isDisabled) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isDark ? Colors.grey[600] : AppColors.textHint,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Position badge widget.
class _PositionBadge extends StatelessWidget {
  const _PositionBadge({
    required this.position,
    required this.ordinal,
    required this.status,
    required this.isDark,
  });

  final int position;
  final String ordinal;
  final VehicleQueueStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Determine badge color based on position
    Color badgeColor;
    if (position == 1) {
      badgeColor = AppColors.success; // First in queue
    } else if (position <= 3) {
      badgeColor = AppColors.primaryBlue;
    } else {
      badgeColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: badgeColor.withOpacity(0.15),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$position',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: badgeColor,
                height: 1,
              ),
            ),
            Text(
              _getSuffix(position),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: badgeColor,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

/// Status badge widget.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final VehicleQueueStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}
