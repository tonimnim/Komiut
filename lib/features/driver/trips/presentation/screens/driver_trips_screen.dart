/// Driver trips screen.
///
/// Shows the driver's trip history and current trips:
/// - Current/active trip (if any)
/// - Today's completed trips
/// - Historical trips with filters
/// - Trip statistics
///
/// ## TODO(Musa): Implement driver trips screen
///
/// ### High Priority
/// - [ ] Create `DriverTripsProvider` in `providers/driver_trips_provider.dart`
/// - [ ] Fetch trips using `ApiEndpoints.tripsMyDriver`
/// - [ ] Display current active trip at the top
/// - [ ] List today's completed trips
/// - [ ] Implement trip status updates (start, complete, cancel)
///
/// ### Medium Priority
/// - [ ] Add date filters for historical trips
/// - [ ] Show trip details (route, passengers, fare collected)
/// - [ ] Add trip statistics summary (total trips, passengers, earnings)
/// - [ ] Implement trip detail view navigation
///
/// ### Low Priority
/// - [ ] Add search functionality for trips
/// - [ ] Implement pagination for trip history
/// - [ ] Add export trip history functionality
/// - [ ] Implement offline trip data caching
///
/// ### API Endpoints to use:
/// - `ApiEndpoints.tripsMyDriver` - Get driver's trips
/// - `ApiEndpoints.tripsByDriver(driverId)` - Get trips by driver ID
/// - `ApiEndpoints.tripById(id)` - Get trip details
/// - `ApiEndpoints.trips` (POST) - Start new trip
///
/// ### Trip Entity (from core/domain/entities/trip.dart):
/// - id, vehicleId, routeId, driverId, toutId
/// - startTime, endTime, status (scheduled, inProgress, completed, cancelled)
/// - availableSeats, totalSeats, currentStopId, nextStopId
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/navigation/driver_bottom_nav.dart';

/// Driver trips screen widget.
///
/// Displays the driver's trip history with tabs for different views.
class DriverTripsScreen extends ConsumerStatefulWidget {
  const DriverTripsScreen({super.key});

  @override
  ConsumerState<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends ConsumerState<DriverTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODO(Musa): Replace with actual state from provider
  bool _hasActiveTrip = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            onPressed: () {
              // TODO(Musa): Show trip filters dialog
              _showFilterDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Today'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─────────────────────────────────────────────────────────────────────
          // Trip Statistics
          // TODO(Musa): Replace with actual stats from provider
          // ─────────────────────────────────────────────────────────────────────
          _buildStatisticsSection(context),

          // ─────────────────────────────────────────────────────────────────────
          // Tab Content
          // ─────────────────────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTripsTab(context),
                _buildTodayTripsTab(context),
                _buildHistoryTab(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 2),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    // TODO(Musa): Replace with actual statistics
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'Today',
              value: '--',
              icon: Icons.today,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              label: 'This Week',
              value: '--',
              icon: Icons.date_range,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              label: 'Total',
              value: '--',
              icon: Icons.all_inclusive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTripsTab(BuildContext context) {
    // TODO(Musa): Replace with actual active trip data
    if (!_hasActiveTrip) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bus_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Active Trip',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start a new trip from the home screen',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO(Musa): Navigate to start trip flow
                setState(() => _hasActiveTrip = true);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Trip'),
            ),
          ],
        ),
      );
    }

    // Show active trip card
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildActiveTripCard(context),
    );
  }

  Widget _buildActiveTripCard(BuildContext context) {
    // TODO(Musa): Replace with actual trip data
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'IN PROGRESS',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Started 10:30 AM',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'CBD - Westlands',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('KAA 123X', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 16),
                Icon(Icons.people, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('12/14 passengers', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Trip progress
            // TODO(Musa): Implement actual route stops progress
            const Text(
              'Current Stop',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text(
              'Uhuru Highway',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.grey.withAlpha(51),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CBD', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('4 stops remaining',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Westlands',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO(Musa): Navigate to passenger list
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('Passengers'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO(Musa): End trip with confirmation
                      _showEndTripConfirmation(context);
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('End Trip'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTripsTab(BuildContext context) {
    // TODO(Musa): Fetch and display today's completed trips
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // TODO(Musa): Replace with actual trip data
        _buildTripListItem(
          route: 'CBD - Westlands',
          time: '08:30 AM - 09:15 AM',
          passengers: 14,
          earnings: 'KSh 1,400',
          status: 'completed',
        ),
        _buildTripListItem(
          route: 'Westlands - CBD',
          time: '09:45 AM - 10:20 AM',
          passengers: 12,
          earnings: 'KSh 1,200',
          status: 'completed',
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Pull down to refresh',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    // TODO(Musa): Implement pagination and date filters
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date header
        _buildDateHeader('Today'),
        _buildTripListItem(
          route: 'CBD - Westlands',
          time: '08:30 AM',
          passengers: 14,
          earnings: 'KSh 1,400',
          status: 'completed',
        ),
        _buildDateHeader('Yesterday'),
        _buildTripListItem(
          route: 'Westlands - CBD',
          time: '06:00 PM',
          passengers: 10,
          earnings: 'KSh 1,000',
          status: 'completed',
        ),
        _buildTripListItem(
          route: 'CBD - Westlands',
          time: '02:30 PM',
          passengers: 8,
          earnings: 'KSh 800',
          status: 'cancelled',
        ),
        const SizedBox(height: 24),
        // TODO(Musa): Add "Load More" button for pagination
        Center(
          child: TextButton(
            onPressed: () {
              // TODO(Musa): Load more trips
            },
            child: const Text('Load More'),
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        date,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTripListItem({
    required String route,
    required String time,
    required int passengers,
    required String earnings,
    required String status,
  }) {
    final isCompleted = status == 'completed';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? AppColors.success.withAlpha(26)
              : AppColors.error.withAlpha(26),
          child: Icon(
            isCompleted ? Icons.check : Icons.close,
            color: isCompleted ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text(route),
        subtitle: Text('$time | $passengers passengers'),
        trailing: Text(
          earnings,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCompleted ? AppColors.success : Colors.grey,
          ),
        ),
        onTap: () {
          // TODO(Musa): Navigate to trip detail
          // context.push(RouteConstants.driverTripDetailPath(tripId));
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // TODO(Musa): Implement proper filter dialog
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Trips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date Range'),
              subtitle: const Text('Select date range'),
              onTap: () {
                // TODO(Musa): Show date picker
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('Route'),
              subtitle: const Text('All routes'),
              onTap: () {
                // TODO(Musa): Show route selector
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Status'),
              subtitle: const Text('All statuses'),
              onTap: () {
                // TODO(Musa): Show status filter
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEndTripConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Trip?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to end this trip?'),
            SizedBox(height: 8),
            Text(
              'Trip Summary:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Passengers: 12'),
            Text('Earnings: KSh 1,200'),
            Text('Duration: 45 min'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO(Musa): Call API to end trip
              setState(() => _hasActiveTrip = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip ended successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (!_hasActiveTrip) {
      return FloatingActionButton.extended(
        onPressed: () {
          // TODO(Musa): Navigate to start trip flow
          // Need to check if in queue first
          setState(() => _hasActiveTrip = true);
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Trip'),
        backgroundColor: AppColors.primaryGreen,
      );
    }
    return null;
  }
}
