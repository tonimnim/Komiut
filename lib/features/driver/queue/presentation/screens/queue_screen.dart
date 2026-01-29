/// Queue management screen.
///
/// Shows the driver's position in the departure queue:
/// - Current queue position
/// - Estimated departure time
/// - Vehicles ahead in queue
/// - Queue actions (join, leave, refresh)
///
/// ## TODO(Musa): Implement queue management screen
///
/// ### High Priority
/// - [ ] Create `QueueProvider` in `providers/queue_provider.dart`
/// - [ ] Fetch queue position using `ApiEndpoints.queueMyPosition`
/// - [ ] Display current position with real-time updates
/// - [ ] Implement join queue using `ApiEndpoints.queueJoin`
/// - [ ] Implement leave queue using `ApiEndpoints.queueLeave`
///
/// ### Medium Priority
/// - [ ] Show list of vehicles ahead in queue
/// - [ ] Calculate and display estimated departure time
/// - [ ] Add manual refresh and auto-refresh (every 30s)
/// - [ ] Handle queue notifications (position change, departure time)
/// - [ ] Show route selection for joining queue
///
/// ### Low Priority
/// - [ ] Add queue position history
/// - [ ] Implement offline queue status caching
/// - [ ] Add push notification integration for queue updates
///
/// ### API Endpoints to use:
/// - `ApiEndpoints.queueMyPosition` - Get current position
/// - `ApiEndpoints.queueJoin` - Join a queue (POST)
/// - `ApiEndpoints.queueLeave` - Leave queue (POST)
/// - `ApiEndpoints.queueByRoute(routeId)` - Get queue for a route
/// - `ApiEndpoints.queueByStage(stageId)` - Get queue by stage
///
/// ### Data model needed:
/// ```dart
/// class QueuePosition {
///   final String id;
///   final String vehicleId;
///   final String routeId;
///   final int position;
///   final DateTime joinedAt;
///   final DateTime? estimatedDeparture;
///   final String routeName;
///   final int vehiclesAhead;
/// }
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/theme/app_colors.dart';

/// Queue screen widget.
///
/// Displays the driver's queue position and provides queue management actions.
class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  // TODO(Musa): Replace with actual state from provider
  bool _isInQueue = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Position'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.driverHome),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading
                ? null
                : () {
                    // TODO(Musa): Refresh queue position
                    // ref.invalidate(queuePositionProvider);
                    setState(() => _isLoading = true);
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) setState(() => _isLoading = false);
                    });
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─────────────────────────────────────────────────────────────
                  // Queue Position Card
                  // TODO(Musa): Replace with actual data
                  // ─────────────────────────────────────────────────────────────
                  _buildQueuePositionCard(context),
                  const SizedBox(height: 24),

                  // ─────────────────────────────────────────────────────────────
                  // Queue Info
                  // ─────────────────────────────────────────────────────────────
                  _buildQueueInfoSection(context),
                  const SizedBox(height: 24),

                  // ─────────────────────────────────────────────────────────────
                  // Vehicles Ahead (if in queue)
                  // TODO(Musa): Show actual vehicles list
                  // ─────────────────────────────────────────────────────────────
                  if (_isInQueue) ...[
                    _buildVehiclesAheadSection(context),
                    const SizedBox(height: 24),
                  ],

                  // ─────────────────────────────────────────────────────────────
                  // Route Selection (if not in queue)
                  // TODO(Musa): Show available routes to join
                  // ─────────────────────────────────────────────────────────────
                  if (!_isInQueue) ...[
                    _buildRouteSelectionSection(context),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildQueuePositionCard(BuildContext context) {
    // TODO(Musa): Replace with actual queue position data
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Position indicator
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _isInQueue
                    ? AppColors.primaryBlue.withAlpha(26)
                    : Colors.grey.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _isInQueue ? '#3' : '--',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: _isInQueue ? AppColors.primaryBlue : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isInQueue ? 'Your Position' : 'Not in Queue',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _isInQueue
                  ? 'CBD - Westlands Route'
                  : 'Join a queue to see your position',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            if (_isInQueue) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(
                    icon: Icons.access_time,
                    label: 'Est. Wait',
                    value: '~25 min',
                  ),
                  _buildInfoItem(
                    icon: Icons.directions_car,
                    label: 'Ahead',
                    value: '2 vehicles',
                  ),
                  _buildInfoItem(
                    icon: Icons.schedule,
                    label: 'Joined',
                    value: '10:30 AM',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueInfoSection(BuildContext context) {
    // TODO(Musa): Show actual queue statistics
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Queue Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Total in queue', '8 vehicles'),
            _buildInfoRow('Average wait time', '~45 min'),
            _buildInfoRow('Next departure', '10:45 AM'),
            _buildInfoRow('Route', 'CBD - Westlands'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesAheadSection(BuildContext context) {
    // TODO(Musa): Show actual vehicles ahead
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicles Ahead',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildVehicleItem(1, 'KAA 111A', 'Departing soon'),
            const Divider(),
            _buildVehicleItem(2, 'KBB 222B', '~10 min wait'),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleItem(int position, String plate, String status) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryBlue.withAlpha(26),
        child: Text(
          '#$position',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
      title: Text(plate),
      subtitle: Text(status),
    );
  }

  Widget _buildRouteSelectionSection(BuildContext context) {
    // TODO(Musa): Fetch and display available routes
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Route to Join',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // TODO(Musa): Replace with actual routes from API
            _buildRouteOption(
              'CBD - Westlands',
              '5 in queue',
              () {
                // TODO(Musa): Join this queue
                _showJoinConfirmation(context, 'CBD - Westlands');
              },
            ),
            const Divider(),
            _buildRouteOption(
              'CBD - Langata',
              '3 in queue',
              () {
                _showJoinConfirmation(context, 'CBD - Langata');
              },
            ),
            const Divider(),
            _buildRouteOption(
              'CBD - Eastleigh',
              '7 in queue',
              () {
                _showJoinConfirmation(context, 'CBD - Eastleigh');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteOption(String route, String queueInfo, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(route),
      subtitle: Text(queueInfo),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showJoinConfirmation(BuildContext context, String route) {
    // TODO(Musa): Implement with AppDialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Queue?'),
        content: Text('Do you want to join the queue for $route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO(Musa): Call API to join queue
              setState(() => _isInQueue = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Joined queue successfully!')),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (_isInQueue) {
      return FloatingActionButton.extended(
        onPressed: () {
          // TODO(Musa): Implement leave queue with confirmation
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Leave Queue?'),
              content: const Text(
                'Are you sure you want to leave the queue? '
                'You will lose your current position.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO(Musa): Call API to leave queue
                    setState(() => _isInQueue = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Leave'),
                ),
              ],
            ),
          );
        },
        backgroundColor: AppColors.error,
        icon: const Icon(Icons.exit_to_app),
        label: const Text('Leave Queue'),
      );
    }
    return null;
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, // Queue tab
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.format_list_numbered_outlined),
          activeIcon: Icon(Icons.format_list_numbered),
          label: 'Queue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_bus_outlined),
          activeIcon: Icon(Icons.directions_bus),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Earnings',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(RouteConstants.driverHome);
            break;
          case 1:
            // Already on queue
            break;
          case 2:
            context.go(RouteConstants.driverTrips);
            break;
          case 3:
            context.go(RouteConstants.driverEarnings);
            break;
        }
      },
    );
  }
}
