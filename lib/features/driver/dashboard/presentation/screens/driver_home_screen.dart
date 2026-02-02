/// Driver home screen.
///
/// Main dashboard for drivers showing:
/// - Current trip status
/// - Queue position
/// - Today's earnings summary
/// - Quick actions
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
import '../../../../shared/notifications/presentation/providers/notification_provider.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../queue/presentation/providers/queue_providers.dart';
import '../../../trips/presentation/providers/trips_providers.dart';
import '../providers/dashboard_providers.dart';

/// Driver home screen widget.
class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(driverProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          _NotificationBell(),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(RouteConstants.sharedProfile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshDashboard(ref);
          ref.invalidate(driverQueuePositionProvider);
          ref.invalidate(activeTripProvider);
          ref.invalidate(earningsSummaryProvider);
        },
        child: profileAsync.when(
          loading: () => const _LoadingState(),
          error: (error, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: AppErrorWidget(
                title: 'Failed to load dashboard',
                message: error.toString(),
                type: ErrorType.server,
                onRetry: () => ref.invalidate(driverProfileProvider),
              ),
            ),
          ),
          data: (profile) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _WelcomeSection(
                  greeting: _getGreeting(),
                  driverName: profile.fullName.split(' ').first,
                  vehicleId: profile.vehicleId,
                  isOnline: profile.isOnline,
                ),
                const SizedBox(height: 24),

                // Current Trip Status
                _SectionHeader(title: 'Current Trip'),
                const SizedBox(height: 12),
                const _TripStatusCard(),
                const SizedBox(height: 24),

                // Queue Position
                _SectionHeader(title: 'Queue Status'),
                const SizedBox(height: 12),
                const _QueueCard(),
                const SizedBox(height: 24),

                // Today's Summary
                _SectionHeader(title: "Today's Summary"),
                const SizedBox(height: 12),
                const _TodaySummary(),
                const SizedBox(height: 24),

                // Quick Actions
                _SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                const _QuickActions(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Bell
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);
    final theme = Theme.of(context);

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          if (unreadCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: () => context.push(RouteConstants.sharedNotifications),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading State
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome shimmer
          const ShimmerBox(height: 28, width: 200),
          const SizedBox(height: 8),
          const ShimmerBox(height: 16, width: 140),
          const SizedBox(height: 24),

          // Trip card shimmer
          const ShimmerBox(height: 18, width: 100),
          const SizedBox(height: 12),
          const ShimmerCard(height: 140),
          const SizedBox(height: 24),

          // Queue card shimmer
          const ShimmerBox(height: 18, width: 100),
          const SizedBox(height: 12),
          const ShimmerCard(height: 100),
          const SizedBox(height: 24),

          // Stats shimmer
          const ShimmerBox(height: 18, width: 120),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ShimmerCard(height: 100, margin: EdgeInsets.zero)),
              const SizedBox(width: 12),
              Expanded(child: ShimmerCard(height: 100, margin: EdgeInsets.zero)),
              const SizedBox(width: 12),
              Expanded(child: ShimmerCard(height: 100, margin: EdgeInsets.zero)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Welcome Section
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({
    required this.greeting,
    required this.driverName,
    this.vehicleId,
    this.isOnline = false,
  });

  final String greeting;
  final String driverName;
  final String? vehicleId;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                driverName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (vehicleId != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Vehicle: $vehicleId',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Online status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isOnline
                ? AppColors.success.withOpacity(0.1)
                : AppColors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isOnline ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip Status Card
// ─────────────────────────────────────────────────────────────────────────────

class _TripStatusCard extends ConsumerWidget {
  const _TripStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTripAsync = ref.watch(activeTripProvider);

    return activeTripAsync.when(
      loading: () => const ShimmerCard(height: 140, margin: EdgeInsets.zero),
      error: (_, __) => _NoActiveTripCard(),
      data: (trip) {
        if (trip == null) return _NoActiveTripCard();
        return _ActiveTripCard(trip: trip);
      },
    );
  }
}

class _NoActiveTripCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bus_outlined,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
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
                      style: TextStyle(color: AppColors.textSecondary),
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
                context.go(RouteConstants.driverQueue);
              },
              icon: const Icon(Icons.add),
              label: const Text('Join Queue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  const _ActiveTripCard({required this.trip});

  final dynamic trip; // DriverTrip

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.primaryGreen.withOpacity(0.05),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  size: 32,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Trip In Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.routeName ?? 'Unknown Route',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TripStat(
                  icon: Icons.people,
                  label: 'Passengers',
                  value: '${trip.passengerCount ?? 0}',
                ),
              ),
              Expanded(
                child: _TripStat(
                  icon: Icons.attach_money,
                  label: 'Fare',
                  value: trip.displayFare ?? 'KES 0',
                ),
              ),
              Expanded(
                child: _TripStat(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: trip.displayDuration ?? '--',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  const _TripStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Queue Card
// ─────────────────────────────────────────────────────────────────────────────

class _QueueCard extends ConsumerWidget {
  const _QueueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(driverQueuePositionProvider);

    return queueAsync.when(
      loading: () => const ShimmerCard(height: 90, margin: EdgeInsets.zero),
      error: (_, __) => _NotInQueueCard(),
      data: (position) {
        if (position == null) return _NotInQueueCard();
        return _InQueueCard(position: position);
      },
    );
  }
}

class _NotInQueueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.driverQueue),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

class _InQueueCard extends StatelessWidget {
  const _InQueueCard({required this.position});

  final dynamic position; // QueuePosition

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.primaryBlue.withOpacity(0.05),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#${position.position}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.routeName ?? 'Unknown Route',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Est. wait: ${position.displayEstimatedWait ?? "--"}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (position.isFirst)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'NEXT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's Summary
// ─────────────────────────────────────────────────────────────────────────────

class _TodaySummary extends ConsumerWidget {
  const _TodaySummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(earningsSummaryProvider);
    final tripsCountAsync = ref.watch(todayCompletedTripsProvider);

    return earningsAsync.when(
      loading: () => Row(
        children: [
          Expanded(child: ShimmerCard(height: 90, margin: EdgeInsets.zero)),
          const SizedBox(width: 12),
          Expanded(child: ShimmerCard(height: 90, margin: EdgeInsets.zero)),
          const SizedBox(width: 12),
          Expanded(child: ShimmerCard(height: 90, margin: EdgeInsets.zero)),
        ],
      ),
      error: (_, __) => Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Earnings',
              value: '--',
              icon: Icons.account_balance_wallet,
              compact: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Trips',
              value: '--',
              icon: Icons.directions_bus,
              compact: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Rating',
              value: '--',
              icon: Icons.star,
              compact: true,
            ),
          ),
        ],
      ),
      data: (summary) => Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Earnings',
              value: summary.displayToday,
              icon: Icons.account_balance_wallet,
              valueColor: AppColors.primaryGreen,
              compact: true,
              onTap: () => context.go(RouteConstants.driverEarnings),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: tripsCountAsync.when(
              loading: () => const StatCard(
                label: 'Trips',
                value: '--',
                icon: Icons.directions_bus,
                compact: true,
              ),
              error: (_, __) => const StatCard(
                label: 'Trips',
                value: '--',
                icon: Icons.directions_bus,
                compact: true,
              ),
              data: (count) => StatCard(
                label: 'Trips',
                value: count.toString(),
                icon: Icons.directions_bus,
                valueColor: AppColors.primaryBlue,
                compact: true,
                onTap: () => context.go(RouteConstants.driverTrips),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final ratingAsync = ref.watch(driverRatingProvider);
                return StatCard(
                  label: 'Rating',
                  value: ratingAsync.valueOrNull ?? '--',
                  icon: Icons.star,
                  valueColor: AppColors.secondaryOrange,
                  compact: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ActionChip(
          avatar: const Icon(Icons.qr_code_scanner, size: 18),
          label: const Text('Scan Ticket'),
          onPressed: () => context.push(RouteConstants.scan),
        ),
        ActionChip(
          avatar: const Icon(Icons.history, size: 18),
          label: const Text('Trip History'),
          onPressed: () => context.go(RouteConstants.driverTrips),
        ),
        ActionChip(
          avatar: const Icon(Icons.attach_money, size: 18),
          label: const Text('Earnings'),
          onPressed: () => context.go(RouteConstants.driverEarnings),
        ),
        ActionChip(
          avatar: const Icon(Icons.settings, size: 18),
          label: const Text('Settings'),
          onPressed: () => context.push(RouteConstants.sharedSettings),
        ),
      ],
    );
  }
}
