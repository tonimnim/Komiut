/// Driver home screen.
///
/// Main dashboard for drivers showing:
/// - Current trip status
/// - Queue position
/// - Today's earnings summary
/// - Quick actions
///
/// ## TODO(Musa): Implement driver home screen
///
/// ### High Priority
/// - [ ] Create `DriverHomeProvider` in `providers/driver_home_provider.dart`
/// - [ ] Fetch driver profile using `ApiEndpoints.personnelMy`
/// - [ ] Display current trip status (scheduled, in progress, etc.)
/// - [ ] Show queue position using `ApiEndpoints.queueMyPosition`
/// - [ ] Display today's earnings summary
///
/// ### Medium Priority
/// - [ ] Add quick action buttons (start trip, join queue, etc.)
/// - [ ] Implement real-time updates for trip status (WebSocket/polling)
/// - [ ] Add notification badge to app bar
/// - [ ] Show assigned vehicle information
///
/// ### Low Priority
/// - [ ] Add pull-to-refresh functionality
/// - [ ] Implement offline mode with cached data
/// - [ ] Add analytics tracking for driver actions
///
/// ### API Endpoints to use:
/// - `ApiEndpoints.personnelMy` - Get driver profile
/// - `ApiEndpoints.vehicleMyDriver` - Get assigned vehicle
/// - `ApiEndpoints.queueMyPosition` - Get queue position
/// - `ApiEndpoints.tripsMyDriver` - Get driver's trips
/// - `ApiEndpoints.driverEarnings` - Get earnings summary
///
/// ### Shared widgets to use:
/// - `StatCard` for earnings/trips stats
/// - `AppCard` for sections
/// - `AppButton` for actions
/// - `AppLoading` / `ShimmerLoading` for loading states
/// - `AppError` for error states
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/navigation/driver_bottom_nav.dart';

/// Driver home screen widget.
///
/// Entry point for the driver interface. Shows dashboard with:
/// - Trip status card
/// - Queue position card
/// - Today's earnings
/// - Quick actions
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          // TODO(Musa): Add notification badge
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.push(RouteConstants.sharedNotifications);
            },
          ),
          // TODO(Musa): Add profile menu
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push(RouteConstants.sharedProfile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO(Musa): Implement refresh - invalidate providers
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────────────────────────────────────────
              // Welcome Section
              // ─────────────────────────────────────────────────────────────────
              _buildWelcomeSection(context),
              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────────────────────
              // Current Trip Status
              // TODO(Musa): Replace with actual trip data from provider
              // ─────────────────────────────────────────────────────────────────
              _buildSectionHeader('Current Trip'),
              const SizedBox(height: 12),
              _buildTripStatusCard(context),
              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────────────────────
              // Queue Position
              // TODO(Musa): Replace with actual queue data
              // ─────────────────────────────────────────────────────────────────
              _buildSectionHeader('Queue Status'),
              const SizedBox(height: 12),
              _buildQueueCard(context),
              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────────────────────
              // Today's Summary
              // TODO(Musa): Replace with actual earnings data
              // ─────────────────────────────────────────────────────────────────
              _buildSectionHeader("Today's Summary"),
              const SizedBox(height: 12),
              _buildTodaySummary(context),
              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────────────────────
              // Quick Actions
              // ─────────────────────────────────────────────────────────────────
              _buildSectionHeader('Quick Actions'),
              const SizedBox(height: 12),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 0),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    // TODO(Musa): Get actual driver name from provider
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          // TODO(Musa): Show actual vehicle registration
          'Vehicle: KAA 123X',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTripStatusCard(BuildContext context) {
    // TODO(Musa): Implement with actual trip data
    // Use TripStatus enum for status display
    // Show different UI based on trip state:
    // - No active trip: Show "Start Trip" button
    // - Trip in progress: Show trip details with "End Trip" button
    // - Trip scheduled: Show countdown to start
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  size: 40,
                  color: Colors.grey,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Active Trip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Join queue or start a new trip',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO(Musa): Navigate to trip start flow
                  // Check if in queue first, then start trip
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueCard(BuildContext context) {
    // TODO(Musa): Implement with actual queue data
    // Show:
    // - Current position number
    // - Route name
    // - Estimated wait time
    // - Join/Leave queue button
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Queue position indicator
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '--',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not in Queue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Join a route queue to get assigned',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                context.go(RouteConstants.driverQueue);
              },
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context) {
    // TODO(Musa): Implement with actual earnings data
    // Use StatCard widgets for each metric
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.account_balance_wallet,
            label: 'Earnings',
            value: 'KSh --',
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.directions_bus,
            label: 'Trips',
            value: '--',
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.people,
            label: 'Passengers',
            value: '--',
            color: AppColors.secondaryOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
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

  Widget _buildQuickActions(BuildContext context) {
    // TODO(Musa): Enable/disable based on current state
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionChip(
          icon: Icons.qr_code_scanner,
          label: 'Scan Ticket',
          onTap: () {
            // TODO(Musa): Navigate to ticket scanner
          },
        ),
        _buildActionChip(
          icon: Icons.history,
          label: 'Trip History',
          onTap: () {
            context.go(RouteConstants.driverTrips);
          },
        ),
        _buildActionChip(
          icon: Icons.attach_money,
          label: 'Earnings',
          onTap: () {
            context.go(RouteConstants.driverEarnings);
          },
        ),
        _buildActionChip(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {
            context.push(RouteConstants.sharedSettings);
          },
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
