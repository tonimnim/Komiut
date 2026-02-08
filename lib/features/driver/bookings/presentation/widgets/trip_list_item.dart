import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../trips/domain/entities/driver_trip.dart';

/// A single trip item in the list.
class TripListItem extends StatelessWidget {
  const TripListItem({
    super.key,
    required this.trip,
    this.onTap,
  });

  final DriverTrip trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final occupiedSeats = trip.passengerCount;
    final totalSeats = trip.maxCapacity ?? 14;
    final progress = totalSeats > 0 ? occupiedSeats / totalSeats : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route name row
            Row(
              children: [
                Icon(
                  Icons.route,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.routeName,
                    style: AppTextStyles.heading4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(trip.status),
              ],
            ),
            const SizedBox(height: 12),

            // Seats and time row
            Row(
              children: [
                // Seats info
                Icon(
                  Icons.event_seat,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$occupiedSeats/$totalSeats seats',
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),

                // Time info
                Icon(
                  Icons.access_time,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(trip.startTime),
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progress),
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DriverTripStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case DriverTripStatus.pending:
        bgColor = AppColors.pillBlueBg;
        textColor = AppColors.primaryBlue;
        label = 'Pending';
        break;
      case DriverTripStatus.active:
        bgColor = AppColors.pillGreenBg;
        textColor = AppColors.primaryGreen;
        label = 'Active';
        break;
      case DriverTripStatus.completed:
        bgColor = AppColors.pillGrayBg;
        textColor = AppColors.textSecondary;
        label = 'Completed';
        break;
      case DriverTripStatus.cancelled:
        bgColor = AppColors.pillRedBg;
        textColor = AppColors.error;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.body3.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return AppColors.primaryOrange;
    if (progress < 0.7) return AppColors.primaryBlue;
    return AppColors.primaryGreen;
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
