/// Next stop indicator widget.
///
/// Displays information about the upcoming stop including
/// name and estimated time of arrival.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/domain/entities/route_stop.dart';
import '../../domain/entities/active_trip.dart';

/// A widget displaying the next stop with ETA.
class NextStopIndicator extends StatelessWidget {
  const NextStopIndicator({
    super.key,
    required this.trip,
    this.style = NextStopIndicatorStyle.card,
    this.onTap,
  });

  /// The active trip.
  final ActiveTrip trip;

  /// Display style.
  final NextStopIndicatorStyle style;

  /// Callback when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final nextStop = trip.nextStop;
    final currentStop = trip.currentStop;

    if (nextStop == null) {
      return _buildArrivedState(context);
    }

    switch (style) {
      case NextStopIndicatorStyle.card:
        return _buildCardStyle(context, nextStop, currentStop);
      case NextStopIndicatorStyle.banner:
        return _buildBannerStyle(context, nextStop, currentStop);
      case NextStopIndicatorStyle.minimal:
        return _buildMinimalStyle(context, nextStop);
    }
  }

  Widget _buildArrivedState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arriving at destination',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trip.dropoffStop.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStyle(
      BuildContext context, RouteStop nextStop, RouteStop? currentStop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDestination = nextStop.id == trip.dropoffStop.id;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.navigate_next,
                  size: 20,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Next Stop',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isDestination)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Your Stop',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Stop info
            Row(
              children: [
                // Stop icon with animation
                _AnimatedStopIcon(
                  isDestination: isDestination,
                ),
                const SizedBox(width: 12),

                // Stop details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextStop.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDestination
                              ? AppColors.success
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (nextStop.address != null)
                        Text(
                          nextStop.address!,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isDark ? Colors.grey[500] : AppColors.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                // ETA
                if (nextStop.estimatedTimeFromStart != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDestination
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _calculateETA(nextStop),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDestination
                                ? AppColors.success
                                : AppColors.primaryBlue,
                          ),
                        ),
                        Text(
                          'ETA',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDestination
                                ? AppColors.success.withValues(alpha: 0.7)
                                : AppColors.primaryBlue.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Current stop info
            if (currentStop != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[900]
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Currently at: ',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? Colors.grey[500] : AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        currentStop.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBannerStyle(
      BuildContext context, RouteStop nextStop, RouteStop? currentStop) {
    final isDestination = nextStop.id == trip.dropoffStop.id;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDestination
              ? [AppColors.success, AppColors.success.withValues(alpha: 0.8)]
              : [AppColors.primaryBlue, AppColors.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDestination ? Icons.flag : Icons.navigate_next,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDestination ? 'Arriving at destination' : 'Next Stop',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  nextStop.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ETA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _calculateETA(nextStop),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalStyle(BuildContext context, RouteStop nextStop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDestination = nextStop.id == trip.dropoffStop.id;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isDestination ? Icons.flag : Icons.navigate_next,
          size: 16,
          color: isDestination ? AppColors.success : AppColors.primaryBlue,
        ),
        const SizedBox(width: 6),
        Text(
          nextStop.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _calculateETA(nextStop),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _calculateETA(RouteStop stop) {
    // Calculate based on current stop and ETA
    if (trip.currentStopIndex == null || stop.estimatedTimeFromStart == null) {
      return '--';
    }

    final currentStop = trip.currentStop;
    if (currentStop?.estimatedTimeFromStart == null) {
      return '${stop.estimatedTimeFromStart} min';
    }

    final timeDiff = stop.estimatedTimeFromStart! -
        currentStop!.estimatedTimeFromStart!;
    return '$timeDiff min';
  }
}

/// Display style options.
enum NextStopIndicatorStyle {
  /// Card style with shadow.
  card,

  /// Banner style with gradient.
  banner,

  /// Minimal inline style.
  minimal,
}

/// Animated stop icon with pulse effect.
class _AnimatedStopIcon extends StatefulWidget {
  const _AnimatedStopIcon({required this.isDestination});

  final bool isDestination;

  @override
  State<_AnimatedStopIcon> createState() => _AnimatedStopIconState();
}

class _AnimatedStopIconState extends State<_AnimatedStopIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestination ? AppColors.success : AppColors.primaryBlue;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring
            Container(
              width: 48 * _animation.value,
              height: 48 * _animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15 / _animation.value),
              ),
            ),
            // Main icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(
                widget.isDestination ? Icons.flag : Icons.location_on,
                color: color,
                size: 22,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// All upcoming stops list.
class UpcomingStopsList extends StatelessWidget {
  const UpcomingStopsList({
    super.key,
    required this.trip,
    this.maxStops = 5,
  });

  final ActiveTrip trip;
  final int maxStops;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get upcoming stops
    final currentIndex = trip.currentStopIndex ?? 0;
    final dropoffIndex =
        trip.route.stops.indexWhere((s) => s.id == trip.dropoffStop.id);

    if (currentIndex >= dropoffIndex) {
      return const SizedBox.shrink();
    }

    final upcomingStops = trip.route.stops
        .sublist(currentIndex + 1, dropoffIndex + 1)
        .take(maxStops)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Upcoming Stops',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ),
        ...upcomingStops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;
          final isDestination = stop.id == trip.dropoffStop.id;
          final isLast = index == upcomingStops.length - 1;

          return _UpcomingStopTile(
            stop: stop,
            isDestination: isDestination,
            isLast: isLast,
            isDark: isDark,
          );
        }),
      ],
    );
  }
}

/// Individual upcoming stop tile.
class _UpcomingStopTile extends StatelessWidget {
  const _UpcomingStopTile({
    required this.stop,
    required this.isDestination,
    required this.isLast,
    required this.isDark,
  });

  final RouteStop stop;
  final bool isDestination;
  final bool isLast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Timeline
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 8,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
                Container(
                  width: isDestination ? 12 : 8,
                  height: isDestination ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDestination
                        ? AppColors.error
                        : (isDark ? Colors.grey[600] : Colors.grey[400]),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Stop name
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                stop.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isDestination ? FontWeight.w600 : FontWeight.normal,
                  color: isDestination
                      ? AppColors.error
                      : (isDark ? Colors.grey[400] : AppColors.textSecondary),
                ),
              ),
            ),
          ),

          // Destination badge
          if (isDestination)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Destination',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
