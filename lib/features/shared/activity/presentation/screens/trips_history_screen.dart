import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/loading/shimmer_loading.dart';
import '../../../home/domain/entities/trip_entity.dart';
import '../../../home/presentation/providers/home_providers.dart';

class TripsHistoryScreen extends ConsumerWidget {
  const TripsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(allTripsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: () async {
        ref.invalidate(allTripsProvider);
      },
      child: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return _buildEmptyState(context);
          }
          // Use ListView.builder with addAutomaticKeepAlives: false for better memory
          return ListView.builder(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: trips.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) => _TripCard(
              key: ValueKey(trips[index].id),
              trip: trips[index],
            ),
          );
        },
        loading: () => const _TripsLoadingState(),
        error: (_, __) => _TripsErrorState(isDark: isDark),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 64,
            color: isDark
                ? Colors.grey[600]
                : AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No trips yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your trip history will appear here',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Extracted loading state widget for better performance.
class _TripsLoadingState extends StatelessWidget {
  const _TripsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ShimmerTripCard(margin: EdgeInsets.zero),
      ),
    );
  }
}

/// Extracted error state widget for better performance.
class _TripsErrorState extends StatelessWidget {
  const _TripsErrorState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to load trips',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Extracted trip card widget for better rebuild isolation.
class _TripCard extends StatelessWidget {
  const _TripCard({
    super.key,
    required this.trip,
  });

  final TripEntity trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                trip.isCompleted ? Icons.check_circle : Icons.cancel,
                color: trip.isCompleted ? AppColors.success : AppColors.error,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.routeName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.isCompleted ? 'Completed' : 'Failed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: trip.isCompleted
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                trip.formattedFare,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Location details with RepaintBoundary for complex content
          RepaintBoundary(
            child: _TripLocationDetails(
              fromLocation: trip.fromLocation,
              toLocation: trip.toLocation,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
              const SizedBox(width: 6),
              Text(
                '${dateFormat.format(trip.tripDate)} at ${timeFormat.format(trip.tripDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Extracted location details widget with RepaintBoundary for complex layout.
class _TripLocationDetails extends StatelessWidget {
  const _TripLocationDetails({
    required this.fromLocation,
    required this.toLocation,
    required this.isDark,
  });

  final String fromLocation;
  final String toLocation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.trip_origin,
                size: 16,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fromLocation,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Row(
              children: [
                Container(
                  width: 2,
                  height: 16,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  toLocation,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
