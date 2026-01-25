/// Active trip screen.
///
/// Displays real-time trip tracking with map view, progress,
/// and trip information for passengers.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/active_trip.dart';
import '../providers/active_trip_providers.dart';
import '../widgets/trip_map_view.dart';
import '../widgets/trip_progress_bar.dart';
import '../widgets/trip_info_card.dart';
import '../widgets/trip_eta_display.dart';
import '../widgets/next_stop_indicator.dart';

/// Screen for tracking an active trip in real-time.
class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({
    super.key,
    this.tripId,
  });

  /// Optional trip ID to load a specific trip.
  final String? tripId;

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen>
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
    final tripAsync = widget.tripId != null
        ? ref.watch(activeTripByIdProvider(widget.tripId!))
        : ref.watch(activeTripProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: tripAsync.when(
        loading: () => _buildLoading(context),
        error: (error, _) => _buildError(context, error),
        data: (trip) {
          if (trip == null) {
            return _buildNoActiveTrip(context);
          }
          return _buildTripContent(context, trip, isDark);
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryBlue,
          ),
          SizedBox(height: 16),
          Text(
            'Loading trip...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load trip',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.tripId != null) {
                  ref.invalidate(activeTripByIdProvider(widget.tripId!));
                } else {
                  ref.invalidate(activeTripProvider);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActiveTrip(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bus_outlined,
                  size: 60,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Active Trip',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You don\'t have any active trips at the moment. Book a ride to start tracking.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripContent(BuildContext context, ActiveTrip trip, bool isDark) {
    return Stack(
      children: [
        // Main content
        CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // App bar
            SliverAppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Trip Tracking',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                // ETA badge
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TripETABadge(eta: trip.formattedETA),
                ),
                // More options
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface,
                  ),
                  onSelected: (value) => _handleMenuAction(value, trip),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: ListTile(
                        leading: Icon(Icons.share),
                        title: Text('Share Trip'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: ListTile(
                        leading: Icon(Icons.flag_outlined),
                        title: Text('Report Issue'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'help',
                      child: ListTile(
                        leading: Icon(Icons.help_outline),
                        title: Text('Get Help'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Map view
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TripMapView(
                  trip: trip,
                  height: 280,
                ),
              ),
            ),

            // Next stop indicator (banner style)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: NextStopIndicator(
                  trip: trip,
                  style: NextStopIndicatorStyle.banner,
                ),
              ),
            ),

            // ETA display
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TripETADisplay(
                  trip: trip,
                  style: TripETADisplayStyle.card,
                ),
              ),
            ),

            // Progress bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TripProgressBar(
                  trip: trip,
                  height: 100,
                ),
              ),
            ),

            // Tabs for details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primaryBlue,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        isDark ? Colors.grey[400] : AppColors.textSecondary,
                    tabs: const [
                      Tab(text: 'Trip Info'),
                      Tab(text: 'Stops'),
                    ],
                  ),
                ),
              ),
            ),

            // Tab content
            SliverToBoxAdapter(
              child: SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Trip Info tab
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TripInfoCard(
                        trip: trip,
                        onCallDriver: () => _callDriver(trip),
                        onReportIssue: () => _reportIssue(trip),
                      ),
                    ),

                    // Stops tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NextStopIndicator(
                            trip: trip,
                            style: NextStopIndicatorStyle.card,
                          ),
                          const SizedBox(height: 16),
                          UpcomingStopsList(trip: trip),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),

        // Bottom action bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(context, trip, isDark),
        ),
      ],
    );
  }

  ThemeData get theme => Theme.of(context);

  Widget _buildBottomBar(BuildContext context, ActiveTrip trip, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status indicator
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(trip.status),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  trip.status.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Emergency button
          OutlinedButton.icon(
            onPressed: () => _showEmergencyOptions(context, trip),
            icon: const Icon(Icons.sos, size: 18),
            label: const Text('SOS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),

          const SizedBox(width: 12),

          // View ticket button
          ElevatedButton.icon(
            onPressed: () => _viewTicket(trip),
            icon: const Icon(Icons.qr_code, size: 18),
            label: const Text('Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ActiveTripStatus status) {
    switch (status) {
      case ActiveTripStatus.boarding:
        return AppColors.warning;
      case ActiveTripStatus.inProgress:
        return AppColors.info;
      case ActiveTripStatus.nearingDestination:
        return AppColors.success;
      case ActiveTripStatus.arrived:
        return AppColors.success;
      case ActiveTripStatus.cancelled:
        return AppColors.error;
    }
  }

  void _handleMenuAction(String action, ActiveTrip trip) {
    switch (action) {
      case 'share':
        _shareTrip(trip);
        break;
      case 'report':
        _reportIssue(trip);
        break;
      case 'help':
        _getHelp(trip);
        break;
    }
  }

  void _callDriver(ActiveTrip trip) {
    HapticFeedback.lightImpact();
    if (trip.driver?.phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver phone number not available'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    // TODO: Implement actual phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${trip.driver!.name}...'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _reportIssue(ActiveTrip trip) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportIssueSheet(trip: trip),
    );
  }

  void _shareTrip(ActiveTrip trip) {
    HapticFeedback.lightImpact();
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _getHelp(ActiveTrip trip) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help center coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _viewTicket(ActiveTrip trip) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to ticket screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ticket view coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _showEmergencyOptions(BuildContext context, ActiveTrip trip) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _EmergencySheet(trip: trip),
    );
  }
}

/// Report issue bottom sheet.
class _ReportIssueSheet extends StatelessWidget {
  const _ReportIssueSheet({required this.trip});

  final ActiveTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final issues = [
      ('Route deviation', Icons.wrong_location_outlined),
      ('Driver behavior', Icons.person_off_outlined),
      ('Vehicle condition', Icons.car_crash_outlined),
      ('Safety concern', Icons.shield_outlined),
      ('Overcharging', Icons.attach_money),
      ('Other', Icons.more_horiz),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Report an Issue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to report?',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: issues.map((issue) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Report submitted: ${issue.$1}'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 56) / 2,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          issue.$2,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            issue.$1,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Emergency options bottom sheet.
class _EmergencySheet extends StatelessWidget {
  const _EmergencySheet({required this.trip});

  final ActiveTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sos,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Emergency Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Need immediate assistance?',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _EmergencyOption(
                  icon: Icons.local_police_outlined,
                  label: 'Call Police',
                  subtitle: 'Emergency: 999',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calling emergency services...'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _EmergencyOption(
                  icon: Icons.medical_services_outlined,
                  label: 'Call Ambulance',
                  subtitle: 'Medical emergency',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calling ambulance...'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _EmergencyOption(
                  icon: Icons.share_location,
                  label: 'Share Live Location',
                  subtitle: 'Send to emergency contact',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sharing location with emergency contacts...'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Emergency option button.
class _EmergencyOption extends StatelessWidget {
  const _EmergencyOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
