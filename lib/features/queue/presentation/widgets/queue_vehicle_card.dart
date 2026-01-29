/// Queue vehicle card widget.
///
/// Displays a vehicle in the queue with real-time status, position,
/// seat availability, and selection state. Supports optimistic UI
/// with pending selection indicator.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/queue_vehicle.dart';

/// A card displaying a vehicle in the queue with real-time updates.
///
/// Shows:
/// - Queue position badge
/// - Vehicle registration and make/model
/// - Available seats with progress indicator
/// - Current status (boarding/waiting/departing)
/// - Selection state with pending indicator
class QueueVehicleCard extends StatelessWidget {
  /// Creates a QueueVehicleCard.
  const QueueVehicleCard({
    required this.vehicle,
    this.isSelected = false,
    this.isPending = false,
    this.onTap,
    super.key,
  });

  /// The vehicle to display.
  final QueueVehicle vehicle;

  /// Whether this vehicle is currently selected.
  final bool isSelected;

  /// Whether there's a pending selection on this vehicle.
  final bool isPending;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = !vehicle.canBoard;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(isDark),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryBlue.withValues(alpha: 0.15)
                  : AppColors.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
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
                position: vehicle.position,
                status: vehicle.status,
                isDark: isDark,
              ),
              const SizedBox(width: 14),

              // Vehicle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Registration number
                    Row(
                      children: [
                        Text(
                          vehicle.registrationNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (isPending) ...[
                          const SizedBox(width: 8),
                          const _PendingIndicator(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Make/model and driver
                    if (vehicle.make != null || vehicle.driverName != null)
                      Text(
                        [
                          if (vehicle.make != null && vehicle.model != null)
                            '${vehicle.make} ${vehicle.model}',
                          if (vehicle.driverName != null) vehicle.driverName,
                        ].join(' - '),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),

                    // Seat availability
                    _SeatIndicator(
                      available: vehicle.availableSeats,
                      total: vehicle.totalSeats,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // Status and ETA
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusBadge(status: vehicle.status),
                  if (vehicle.formattedDepartureTime != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      vehicle.formattedDepartureTime!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),

              // Selection indicator
              if (onTap != null && !isDisabled) ...[
                const SizedBox(width: 8),
                Icon(
                  isSelected ? Icons.check_circle : Icons.chevron_right,
                  size: 20,
                  color: isSelected
                      ? AppColors.primaryBlue
                      : (isDark ? Colors.grey[600] : AppColors.textHint),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (isSelected) {
      return isDark
          ? AppColors.primaryBlue.withOpacity(0.1)
          : AppColors.primaryBlue.withOpacity(0.05);
    }
    return isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  }

  Color _getBorderColor(bool isDark) {
    if (isSelected) {
      return AppColors.primaryBlue;
    }
    return isDark ? Colors.grey[700]! : Colors.grey[200]!;
  }
}

/// Position badge showing queue position.
class _PositionBadge extends StatelessWidget {
  const _PositionBadge({
    required this.position,
    required this.status,
    required this.isDark,
  });

  final int position;
  final QueueVehicleStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    if (status == QueueVehicleStatus.boarding) {
      badgeColor = AppColors.success;
    } else if (position == 1) {
      badgeColor = AppColors.info;
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

/// Status badge for vehicle status.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final QueueVehicleStatus status;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config.color,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (status) {
      case QueueVehicleStatus.boarding:
        return _StatusConfig(
          label: 'Boarding Now',
          color: AppColors.success,
        );
      case QueueVehicleStatus.waiting:
        return _StatusConfig(
          label: 'Waiting',
          color: AppColors.warning,
        );
      case QueueVehicleStatus.departing:
        return _StatusConfig(
          label: 'Departing Soon',
          color: AppColors.info,
        );
      case QueueVehicleStatus.departed:
        return _StatusConfig(
          label: 'Departed',
          color: AppColors.textSecondary,
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({required this.label, required this.color});
  final String label;
  final Color color;
}

/// Seat availability indicator.
class _SeatIndicator extends StatelessWidget {
  const _SeatIndicator({
    required this.available,
    required this.total,
    required this.isDark,
  });

  final int available;
  final int total;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final occupancy = total > 0 ? (total - available) / total : 0.0;

    Color progressColor;
    if (available == 0) {
      progressColor = AppColors.error;
    } else if (available <= 3) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.success;
    }

    return Row(
      children: [
        Icon(
          Icons.event_seat,
          size: 14,
          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$available/$total seats',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: occupancy,
                  minHeight: 4,
                  backgroundColor:
                      isDark ? Colors.grey[700] : Colors.grey[200],
                  color: progressColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pending selection indicator.
class _PendingIndicator extends StatefulWidget {
  const _PendingIndicator();

  @override
  State<_PendingIndicator> createState() => _PendingIndicatorState();
}

class _PendingIndicatorState extends State<_PendingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primaryBlue,
        ),
      ),
    );
  }
}
