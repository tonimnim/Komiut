/// Driver trips screen.
///
/// Shows the driver's trip history and current trips:
/// - Current/active trip (if any)
/// - Today's completed trips
/// - Historical trips with filters
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/cards/app_card.dart';
import '../../../../../core/widgets/cards/stat_card.dart';
import '../../../../../core/widgets/feedback/app_error.dart';
import '../../../../../core/widgets/loading/shimmer_loading.dart';
import '../../../../../core/widgets/navigation/driver_bottom_nav.dart';
import '../../domain/entities/driver_trip.dart';
import '../providers/trips_providers.dart';

/// Driver trips screen widget.
class DriverTripsScreen extends ConsumerStatefulWidget {
  const DriverTripsScreen({super.key});

  @override
  ConsumerState<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends ConsumerState<DriverTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.driverHome),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Statistics Section
          const _StatisticsSection(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ActiveTripTab(),
                _HistoryTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _StartTripFAB(),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 2),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _FilterBottomSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Statistics Section
// ─────────────────────────────────────────────────────────────────────────────

class _StatisticsSection extends ConsumerWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTripsAsync = ref.watch(todayCompletedTripsProvider);
    final tripCountAsync = ref.watch(tripCountProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: todayTripsAsync.when(
              loading: () => const StatCard(
                label: 'Today',
                value: '--',
                icon: Icons.today,
                compact: true,
              ),
              error: (_, __) => const StatCard(
                label: 'Today',
                value: '--',
                icon: Icons.today,
                compact: true,
              ),
              data: (count) => StatCard(
                label: 'Today',
                value: count.toString(),
                icon: Icons.today,
                valueColor: AppColors.primaryGreen,
                compact: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Loaded',
              value: tripCountAsync.toString(),
              icon: Icons.list,
              valueColor: AppColors.primaryBlue,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active Trip Tab
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveTripTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTripAsync = ref.watch(activeTripProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(activeTripProvider),
      child: activeTripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: AppErrorWidget(
            title: 'Failed to load trip',
            message: error.toString(),
            type: ErrorType.server,
            onRetry: () => ref.invalidate(activeTripProvider),
          ),
        ),
        data: (trip) {
          if (trip == null) {
            return const _NoActiveTripView();
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: _ActiveTripCard(trip: trip),
          );
        },
      ),
    );
  }
}

class _NoActiveTripView extends StatelessWidget {
  const _NoActiveTripView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Active Trip',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a new trip from the queue',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(RouteConstants.driverQueue),
            icon: const Icon(Icons.queue),
            label: const Text('Go to Queue'),
          ),
        ],
      ),
    );
  }
}

class _ActiveTripCard extends ConsumerWidget {
  const _ActiveTripCard({required this.trip});

  final DriverTrip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(tripOperationLoadingProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trip.statusName.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Started ${_formatTime(trip.startTime)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            trip.routeName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.directions_car, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                trip.vehicleRegistration ?? '--',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.people, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${trip.passengerCount}/${trip.maxCapacity ?? "--"} passengers',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Trip progress
          if (trip.currentStopIndex != null && trip.totalStops != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                Text(
                  '${trip.currentStopIndex}/${trip.totalStops} stops',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: trip.progress,
              backgroundColor: AppColors.textSecondary.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
          ],

          // Fare collected
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fare Collected', style: TextStyle(color: AppColors.textSecondary)),
              Text(
                trip.displayFare,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => _showEndTripConfirmation(context, ref, trip),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.stop),
              label: Text(isLoading ? 'Ending...' : 'End Trip'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  void _showEndTripConfirmation(BuildContext context, WidgetRef ref, DriverTrip trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Trip?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to end this trip?'),
            const SizedBox(height: 16),
            const Text('Trip Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Route: ${trip.routeName}'),
            Text('Passengers: ${trip.passengerCount}'),
            Text('Fare: ${trip.displayFare}'),
            Text('Duration: ${trip.displayDuration}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(
                  endTripProvider(EndTripParams(tripId: trip.id)).future,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trip ended successfully!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to end trip: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History Tab
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsHistoryProvider);
    final hasMore = ref.watch(hasMoreTripsProvider);
    final selectedFilter = ref.watch(selectedTripFilterProvider);

    return RefreshIndicator(
      onRefresh: () async => refreshTrips(ref),
      child: Column(
        children: [
          // Filter chips
          _FilterChips(),

          // Trips list
          Expanded(
            child: tripsAsync.when(
              loading: () => const _HistoryLoading(),
              error: (error, _) => Center(
                child: AppErrorWidget(
                  title: 'Failed to load trips',
                  message: error.toString(),
                  type: ErrorType.server,
                  onRetry: () => ref.invalidate(tripsHistoryProvider),
                ),
              ),
              data: (trips) {
                if (trips.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No trips found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No ${selectedFilter.label.toLowerCase()} trips yet',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trips.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == trips.length) {
                      return Center(
                        child: TextButton(
                          onPressed: () => loadMoreTrips(ref),
                          child: const Text('Load More'),
                        ),
                      );
                    }

                    final trip = trips[index];
                    return _TripListItem(trip: trip);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedTripFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: TripFilter.values.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedTripFilterProvider.notifier).state = filter;
                  ref.read(tripsPageProvider.notifier).state = 1;
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: ShimmerCard(height: 80, margin: EdgeInsets.zero),
      ),
    );
  }
}

class _TripListItem extends StatelessWidget {
  const _TripListItem({required this.trip});

  final DriverTrip trip;

  @override
  Widget build(BuildContext context) {
    final isCompleted = trip.isCompleted;
    final statusColor = switch (trip.status) {
      DriverTripStatus.completed => AppColors.success,
      DriverTripStatus.active => AppColors.primaryGreen,
      DriverTripStatus.pending => AppColors.warning,
      DriverTripStatus.cancelled => AppColors.error,
    };

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.directions_bus,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.routeName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDateTime(trip.startTime)} | ${trip.passengerCount} passengers',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trip.displayFare,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? AppColors.primaryGreen : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trip.statusName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = DateTime(dt.year, dt.month, dt.day);

    String dateStr;
    if (tripDate == today) {
      dateStr = 'Today';
    } else if (tripDate == today.subtract(const Duration(days: 1))) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${dt.day}/${dt.month}';
    }

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$dateStr $hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Start Trip FAB
// ─────────────────────────────────────────────────────────────────────────────

class _StartTripFAB extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveTrip = ref.watch(hasActiveTripProvider);

    if (hasActiveTrip) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: () => context.go(RouteConstants.driverQueue),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Start Trip'),
      backgroundColor: AppColors.primaryGreen,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Trips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...TripFilter.values.map((filter) {
            final isSelected = ref.watch(selectedTripFilterProvider) == filter;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.primaryBlue : null,
              ),
              title: Text(filter.label),
              onTap: () {
                ref.read(selectedTripFilterProvider.notifier).state = filter;
                ref.read(tripsPageProvider.notifier).state = 1;
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}
