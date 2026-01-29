/// Trip info card widget.
///
/// Displays vehicle information, driver details, and route information
/// for the active trip.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/active_trip.dart';

/// A card displaying trip, vehicle, and driver information.
class TripInfoCard extends StatelessWidget {
  const TripInfoCard({
    super.key,
    required this.trip,
    this.onCallDriver,
    this.onReportIssue,
  });

  /// The active trip to display info for.
  final ActiveTrip trip;

  /// Callback when call driver is tapped.
  final VoidCallback? onCallDriver;

  /// Callback when report issue is tapped.
  final VoidCallback? onReportIssue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle info row
          Row(
            children: [
              // Vehicle icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),

              // Vehicle details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.vehicle.registrationNumber,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.vehicle.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                    if (trip.vehicle.color != null)
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 6, top: 4),
                            decoration: BoxDecoration(
                              color: _getColorFromName(trip.vehicle.color!),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[600]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              trip.vehicle.color!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[500]
                                    : AppColors.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Status badge
              _StatusBadge(status: trip.status),
            ],
          ),

          if (trip.driver != null) ...[
            const SizedBox(height: 16),
            Divider(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            const SizedBox(height: 16),

            // Driver info row
            Row(
              children: [
                // Driver avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: trip.driver!.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            trip.driver!.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: AppColors.primaryGreen,
                        ),
                ),
                const SizedBox(width: 12),

                // Driver details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.driver!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Driver',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[400]
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (trip.driver!.rating != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              trip.driver!.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.grey[400]
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Call button
                if (trip.driver!.phone != null && onCallDriver != null)
                  IconButton(
                    onPressed: onCallDriver,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          Divider(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          const SizedBox(height: 16),

          // Route info
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.route,
                  label: 'Route',
                  value: trip.route.name,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Booking Ref',
                  value: trip.bookingReference ?? trip.bookingId.substring(0, 8),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Fare info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[900]
                  : AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 20,
                      color: isDark ? Colors.grey[400] : AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fare',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  trip.formattedFare,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          // Report issue button
          if (onReportIssue != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onReportIssue?.call();
              },
              icon: const Icon(
                Icons.flag_outlined,
                size: 18,
              ),
              label: const Text('Report an issue'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.grey[400] : AppColors.textSecondary,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get a Color from a color name string.
  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'silver':
        return Colors.grey.shade400;
      default:
        return Colors.grey;
    }
  }
}

/// Status badge widget.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ActiveTripStatus status;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case ActiveTripStatus.boarding:
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      case ActiveTripStatus.inProgress:
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        break;
      case ActiveTripStatus.nearingDestination:
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case ActiveTripStatus.arrived:
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case ActiveTripStatus.cancelled:
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// Info item widget for displaying labeled information.
class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[500] : AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Compact version of the trip info card.
class TripInfoCardCompact extends StatelessWidget {
  const TripInfoCardCompact({
    super.key,
    required this.trip,
    this.onTap,
  });

  final ActiveTrip trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            // Vehicle icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_bus,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.vehicle.registrationNumber,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    trip.route.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
