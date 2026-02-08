/// Vehicle Capacity Widget - Shows seat occupancy during loading.
///
/// Displays a circular progress indicator showing filled vs available
/// seats with current location text.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// A widget that displays vehicle capacity with a circular progress indicator.
///
/// Shows:
/// - Circular progress ring showing occupancy
/// - Seats filled / total seats
/// - Current loading location
class VehicleCapacityWidget extends StatelessWidget {
  /// Creates a VehicleCapacityWidget.
  const VehicleCapacityWidget({
    super.key,
    required this.seatsOccupied,
    required this.totalSeats,
    required this.locationName,
    this.onTap,
  });

  /// Number of seats currently occupied.
  final int seatsOccupied;

  /// Total number of seats in the vehicle.
  final int totalSeats;

  /// Name of the current loading location.
  final String locationName;

  /// Callback when the widget is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeats > 0 ? seatsOccupied / totalSeats : 0.0;
    final isFull = seatsOccupied >= totalSeats;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular capacity indicator
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _CapacityRingPainter(
                      progress: progress,
                      isFull: isFull,
                    ),
                  ),
                ),
                // Center content
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$seatsOccupied / $totalSeats',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isFull
                              ? AppColors.primaryGreen
                              : AppColors.textPrimary,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'seats',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Status text
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isFull ? AppColors.pillGreenBg : AppColors.pillBlueBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFull ? Icons.check_circle : Icons.location_on,
                  size: 16,
                  color: isFull ? AppColors.primaryGreen : AppColors.primaryBlue,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  isFull ? 'Ready to depart' : 'Loading at $locationName',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isFull ? AppColors.primaryGreen : AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the capacity ring.
class _CapacityRingPainter extends CustomPainter {
  _CapacityRingPainter({
    required this.progress,
    required this.isFull,
  });

  final double progress;
  final bool isFull;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;

    // Background arc
    final backgroundPaint = Paint()
      ..color = AppColors.grey200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = isFull ? AppColors.primaryGreen : AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CapacityRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isFull != isFull;
  }
}

/// Compact version of the capacity widget for inline display.
class VehicleCapacityCompact extends StatelessWidget {
  /// Creates a VehicleCapacityCompact.
  const VehicleCapacityCompact({
    super.key,
    required this.seatsOccupied,
    required this.totalSeats,
    this.showLabel = true,
    this.onTap,
  });

  /// Number of seats currently occupied.
  final int seatsOccupied;

  /// Total number of seats in the vehicle.
  final int totalSeats;

  /// Whether to show the "seats" label.
  final bool showLabel;

  /// Callback when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeats > 0 ? seatsOccupied / totalSeats : 0.0;
    final isFull = seatsOccupied >= totalSeats;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isFull
              ? AppColors.pillGreenBg
              : AppColors.cardBgLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: isFull ? AppColors.primaryGreen : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFull ? AppColors.primaryGreen : AppColors.primaryBlue,
                    ),
                  ),
                  if (isFull)
                    const Icon(
                      Icons.check,
                      size: 12,
                      color: AppColors.primaryGreen,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$seatsOccupied/$totalSeats',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isFull ? AppColors.primaryGreen : AppColors.textPrimary,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                'seats',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
