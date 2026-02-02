/// Trip map view widget.
///
/// Displays a map showing the vehicle position, route path, and stops.
/// Uses a placeholder implementation that can be replaced with google_maps_flutter.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/domain/entities/route_stop.dart';
import '../../domain/entities/active_trip.dart';

/// A placeholder map widget showing the route and vehicle position.
///
/// This is a simplified visualization that can later be replaced
/// with an actual map implementation (e.g., google_maps_flutter).
class TripMapView extends ConsumerWidget {
  const TripMapView({
    super.key,
    required this.trip,
    this.height = 300,
  });

  /// The active trip to display.
  final ActiveTrip trip;

  /// Height of the map container.
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.pillBlueBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Background grid pattern (simulates map)
          CustomPaint(
            size: Size.infinite,
            painter: _MapGridPainter(isDark: isDark),
          ),

          // Route path visualization
          Positioned.fill(
            child: CustomPaint(
              painter: _RoutePathPainter(
                stops: trip.route.stops,
                pickupStop: trip.pickupStop,
                dropoffStop: trip.dropoffStop,
                currentStopIndex: trip.currentStopIndex ?? 0,
                isDark: isDark,
              ),
            ),
          ),

          // Vehicle indicator
          if (trip.currentVehiclePosition != null)
            _VehicleMarker(
              position: trip.currentVehiclePosition!,
              trip: trip,
              isDark: isDark,
            ),

          // Map legend
          Positioned(
            bottom: 12,
            left: 12,
            child: _MapLegend(isDark: isDark),
          ),

          // Placeholder label
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.black.withOpacity(0.5)
                    : AppColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 14,
                    color: isDark ? AppColors.grey400 : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live Tracking',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? AppColors.grey400 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vehicle marker widget.
class _VehicleMarker extends StatelessWidget {
  const _VehicleMarker({
    required this.position,
    required this.trip,
    required this.isDark,
  });

  final VehiclePosition position;
  final ActiveTrip trip;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Calculate position based on progress along the route
    // This is a simplified visualization
    final progress = trip.progressPercentage;

    return Positioned(
      left: 40 + (progress * 280),
      top: 120 - (progress * 40),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_bus,
            color: AppColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Map legend widget.
class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.black.withOpacity(0.5)
            : AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(
            color: AppColors.primaryGreen,
            label: 'Pickup',
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _LegendItem(
            color: AppColors.error,
            label: 'Dropoff',
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _LegendItem(
            color: AppColors.primaryBlue,
            label: 'Vehicle',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

/// Legend item widget.
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDark,
  });

  final Color color;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
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

/// Custom painter for map grid background.
class _MapGridPainter extends CustomPainter {
  _MapGridPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? AppColors.grey500.withValues(alpha: 0.1)
          : AppColors.grey500.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    const gridSize = 30.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

/// Custom painter for route path visualization.
class _RoutePathPainter extends CustomPainter {
  _RoutePathPainter({
    required this.stops,
    required this.pickupStop,
    required this.dropoffStop,
    required this.currentStopIndex,
    required this.isDark,
  });

  final List<RouteStop> stops;
  final RouteStop pickupStop;
  final RouteStop dropoffStop;
  final int currentStopIndex;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (stops.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Calculate positions for each stop
    final stopPositions = <Offset>[];
    const padding = 40.0;
    final availableWidth = size.width - (padding * 2);
    final availableHeight = size.height - (padding * 2);

    for (int i = 0; i < stops.length; i++) {
      final progress = i / (stops.length - 1);
      // Create a curved path
      final x = padding + (progress * availableWidth);
      final y = padding +
          (availableHeight / 2) +
          (30 * (i.isEven ? -1 : 1) * (0.5 - (progress - 0.5).abs()));
      stopPositions.add(Offset(x, y));
    }

    // Draw the route path
    final path = Path();
    if (stopPositions.isNotEmpty) {
      path.moveTo(stopPositions.first.dx, stopPositions.first.dy);

      for (int i = 1; i < stopPositions.length; i++) {
        final prev = stopPositions[i - 1];
        final curr = stopPositions[i];
        final midX = (prev.dx + curr.dx) / 2;
        path.quadraticBezierTo(midX, prev.dy, curr.dx, curr.dy);
      }
    }

    // Draw grey path for future
    paint.color = isDark ? AppColors.grey700 : AppColors.grey300;
    canvas.drawPath(path, paint);

    // Draw colored path for completed portion
    if (currentStopIndex > 0 && currentStopIndex < stops.length) {
      final completedPath = Path();
      completedPath.moveTo(stopPositions.first.dx, stopPositions.first.dy);

      for (int i = 1; i <= currentStopIndex && i < stopPositions.length; i++) {
        final prev = stopPositions[i - 1];
        final curr = stopPositions[i];
        final midX = (prev.dx + curr.dx) / 2;
        completedPath.quadraticBezierTo(midX, prev.dy, curr.dx, curr.dy);
      }

      paint.color = AppColors.primaryBlue;
      canvas.drawPath(completedPath, paint);
    }

    // Draw stop dots
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final pickupIndex = stops.indexWhere((s) => s.id == pickupStop.id);
    final dropoffIndex = stops.indexWhere((s) => s.id == dropoffStop.id);

    for (int i = 0; i < stopPositions.length; i++) {
      final pos = stopPositions[i];
      final isPickup = i == pickupIndex;
      final isDropoff = i == dropoffIndex;
      final isPassed = i <= currentStopIndex;
      final isCurrent = i == currentStopIndex;

      // Determine dot size and color
      double dotSize;
      Color dotColor;

      if (isPickup) {
        dotSize = 14;
        dotColor = AppColors.primaryGreen;
      } else if (isDropoff) {
        dotSize = 14;
        dotColor = AppColors.error;
      } else if (isCurrent) {
        dotSize = 12;
        dotColor = AppColors.primaryBlue;
      } else if (isPassed) {
        dotSize = 8;
        dotColor = AppColors.primaryBlue;
      } else {
        dotSize = 8;
        dotColor = isDark ? AppColors.grey600 : AppColors.grey400;
      }

      // Draw outer ring for special stops
      if (isPickup || isDropoff || isCurrent) {
        dotPaint.color = dotColor.withValues(alpha: 0.3);
        canvas.drawCircle(pos, dotSize + 4, dotPaint);
      }

      // Draw white border
      dotPaint.color = AppColors.white;
      canvas.drawCircle(pos, dotSize + 2, dotPaint);

      // Draw dot
      dotPaint.color = dotColor;
      canvas.drawCircle(pos, dotSize, dotPaint);

      // Draw icon for special stops
      if (isPickup || isDropoff) {
        final iconPaint = Paint()
          ..color = AppColors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        if (isPickup) {
          // Draw up arrow
          final arrowPath = Path();
          arrowPath.moveTo(pos.dx, pos.dy - 4);
          arrowPath.lineTo(pos.dx - 4, pos.dy + 2);
          arrowPath.moveTo(pos.dx, pos.dy - 4);
          arrowPath.lineTo(pos.dx + 4, pos.dy + 2);
          canvas.drawPath(arrowPath, iconPaint);
        } else {
          // Draw down arrow
          final arrowPath = Path();
          arrowPath.moveTo(pos.dx, pos.dy + 4);
          arrowPath.lineTo(pos.dx - 4, pos.dy - 2);
          arrowPath.moveTo(pos.dx, pos.dy + 4);
          arrowPath.lineTo(pos.dx + 4, pos.dy - 2);
          canvas.drawPath(arrowPath, iconPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePathPainter oldDelegate) {
    return oldDelegate.currentStopIndex != currentStopIndex ||
        oldDelegate.isDark != isDark;
  }
}
