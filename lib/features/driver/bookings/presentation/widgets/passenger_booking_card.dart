import 'package:flutter/material.dart';
import '../../../../../core/domain/entities/booking.dart';
import '../../../../../core/domain/enums/enums.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Card widget displaying a passenger booking.
class PassengerBookingCard extends StatelessWidget {
  const PassengerBookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  final Booking booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerTheme.color ?? Colors.grey[700]!,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(isDark),
            const SizedBox(width: 12),

            // Passenger info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and seat
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.passengerName ?? 'Passenger',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (booking.hasSeat)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.pillBlueBg.withValues(alpha: 0.1)
                                : AppColors.pillBlueBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Seat ${booking.seatNumber}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Phone
                  if (booking.passengerPhone != null)
                    Text(
                      booking.passengerPhone!,
                      style: AppTextStyles.body3.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                  const SizedBox(height: 6),

                  // Pickup → Dropoff
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${booking.pickupStopName ?? 'Pickup'} → ${booking.dropoffStopName ?? 'Dropoff'}',
                          style: AppTextStyles.caption.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Status badge
            _buildStatusBadge(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    final initials = _getInitials(booking.passengerName ?? 'P');
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.pillBlueBg.withValues(alpha: 0.1)
            : AppColors.pillBlueBg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    Color bgColor;
    Color textColor;
    String label;

    switch (booking.status) {
      case BookingStatus.confirmed:
        bgColor = isDark
            ? AppColors.primaryGreen.withValues(alpha: 0.15)
            : AppColors.pillGreenBg;
        textColor = AppColors.success;
        label = 'Confirmed';
      case BookingStatus.pending:
        bgColor = isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : const Color(0xFFFEF3C7); // Amber 100
        textColor = AppColors.warning;
        label = 'Pending';
      case BookingStatus.cancelled:
        bgColor = isDark
            ? AppColors.error.withValues(alpha: 0.15)
            : AppColors.pillRedBg;
        textColor = AppColors.error;
        label = 'Cancelled';
      case BookingStatus.completed:
        bgColor = isDark ? Colors.grey[800]! : AppColors.pillGrayBg;
        textColor = isDark ? Colors.grey[400]! : AppColors.textSecondary;
        label = 'Completed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'P';
  }
}
