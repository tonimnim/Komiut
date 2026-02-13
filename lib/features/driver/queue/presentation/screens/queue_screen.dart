/// Queue management screen.
///
/// Shows driver's queue position, available routes, or loading interface.
/// Implements the 4-state flow: Browse -> In Queue -> You're Up -> Loading.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_spacing.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/core/widgets/widgets.dart';
import 'package:komiut/shared/widgets/komiut_map.dart';

import 'package:komiut/features/driver/queue/domain/entities/queue_position.dart';
import 'package:komiut/features/driver/queue/presentation/providers/queue_providers.dart';
import 'package:komiut/features/driver/dashboard/presentation/providers/dashboard_providers.dart';

import 'package:komiut/features/shared/routes/presentation/providers/route_providers.dart';

// ── Screen ─────────────────────────────────────────────────────────────────
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: QueueContent(),
    );
  }
}

/// Queue content widget (used in IndexedStack).
class QueueContent extends ConsumerWidget {
  const QueueContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(driverProfileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return profileAsync.when(
      loading: () => const _LoadingState(),
      error: (err, _) => CustomErrorWidget(
        message: 'Unable to load profile',
        onRetry: () => ref.invalidate(driverProfileProvider),
      ),
      data: (profile) {
        final queueAsync = ref.watch(driverQueuePositionProvider);
        final isBoarding = ref.watch(isLoadingPassengersProvider);

        // State 4: Loading Passengers
        if (isBoarding) {
          final position = queueAsync.valueOrNull;
          return _LoadingPassengersView(
            isDark: isDark,
            position: position,
          );
        }

        return AppScaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          // Bottom bar changes based on state
          bottomNavigationBar: _QueueBottomBar(
            isDark: isDark,
            queuePosition: queueAsync.valueOrNull,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              refreshQueue(ref);
              ref.invalidate(routesProvider);
            },
            displacement: 100,
            child: queueAsync.when(
              loading: () => const _LoadingState(),
              error: (_, __) => _NotInQueueView(isDark: isDark),
              data: (position) {
                if (position == null) {
                  // State 1: Browse Routes (Not in queue)
                  return _NotInQueueView(isDark: isDark);
                } else {
                  // State 2 & 3: In Queue / You're Up
                  return _InQueueView(
                    isDark: isDark,
                    position: position,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

// ── View States ────────────────────────────────────────────────────────────

/// State 1: Browse Routes (Not in queue)
class _NotInQueueView extends ConsumerWidget {
  const _NotInQueueView({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _SliverQueueAppBar(
          isDark: isDark,
          title: 'Available Queues',
          subtitle: 'Select a route to join',
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverToBoxAdapter(
            child: _QueueMapSection(isDark: isDark, isInQueue: false),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppSectionHeader(
                title: 'Select Route',
                actionLabel: 'Refresh',
                onAction: () => ref.invalidate(routesProvider),
              ),
            ),
          ),
        ),
        // Show warning if vehicle is already full
        if (ref.watch(isVehicleFullProvider))
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle Full (Externally Loaded)',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          Text(
                            'You cannot join a queue while full from Home Screen.',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        routesAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, _) => SliverToBoxAdapter(
            child: CustomErrorWidget(
              message: 'Unable to load routes',
              onRetry: () => ref.invalidate(routesProvider),
            ),
          ),
          data: (routes) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final route = routes[index];
                  final isSelected =
                      ref.watch(selectedRouteIdProvider) == route.id.toString();

                  return SelectableCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(selectedRouteIdProvider.notifier).state =
                          route.id.toString();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_bus_filled_rounded,
                          color:
                              isSelected ? AppColors.white : AppColors.grey500,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route.name,
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.white : null,
                                ),
                              ),
                              Text(
                                '${route.startPoint} → ${route.endPoint}',
                                style: AppTextStyles.body2.copyWith(
                                  color: isSelected
                                      ? AppColors.white.withValues(alpha: 0.8)
                                      : AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.white,
                          ),
                      ],
                    ),
                  );
                },
                childCount: routes.length,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

/// State 2 & 3: In Queue / You're Up
class _InQueueView extends ConsumerWidget {
  const _InQueueView({required this.isDark, required this.position});

  final bool isDark;
  final QueuePosition position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFirst = position.position == 1;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _SliverQueueAppBar(
          isDark: isDark,
          title: position.routeName,
          subtitle: 'Terminal A • Station Gate 14', // Mock data
          isExpress: true,
          // Add back button logic
          onBack: () {
            // Confirm leaving queue
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Leave Queue?'),
                content: const Text(
                  'Are you sure you want to leave the queue? You will lose your position.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Trigger leave queue
                      ref.read(queueOperationLoadingProvider.notifier).state =
                          true;
                      ref.read(leaveQueueProvider.future).then((_) {
                        ref.read(queueOperationLoadingProvider.notifier).state =
                            false;
                      }).catchError((_) {
                        ref.read(queueOperationLoadingProvider.notifier).state =
                            false;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Leave Queue'),
                  ),
                ],
              ),
            );
          },
        ),
        if (isFirst)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _YoureUpBanner(isDark: isDark),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverToBoxAdapter(
            child: _QueueStatusCard(
              position: position,
              isDark: isDark,
              onRefresh: () => refreshQueue(ref),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Queue List',
                    style: AppTextStyles.heading4.copyWith(
                      fontSize: 18,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${position.vehiclesAhead ?? 0} Drivers waiting',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _QueueListTile(
                index: index,
                isDark: isDark,
                currentUserPosition: position.position,
              ),
              childCount: 5, // Mock list size
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

/// State 4: Loading Passengers
class _LoadingPassengersView extends ConsumerWidget {
  const _LoadingPassengersView({required this.isDark, this.position});

  final bool isDark;
  final QueuePosition? position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine loading/full status based on passenger count vs capacity
    final paxCount = ref.watch(passengerCountProvider);
    final capacity = ref.watch(vehicleMaxCapacityProvider);
    final isFull = paxCount >= capacity;
    final loadingStatus = isFull ? 'Ready to Depart' : 'Loading Passengers';
    final loadingColor =
        isFull ? AppColors.primaryBlue : AppColors.primaryGreen;

    return AppScaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      bottomNavigationBar: _LoadingBottomBar(
        isDark: isDark,
        isFull: isFull,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.grey800 : AppColors.grey200,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            // Cancel loading -> go back to You're Up
                            ref
                                .read(isLoadingPassengersProvider.notifier)
                                .state = false;
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                position?.routeName ?? 'Route 402',
                                style: AppTextStyles.heading4.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                loadingStatus,
                                style: AppTextStyles.body2.copyWith(
                                  color: loadingColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48), // Balance close button
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Capacity Ring
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: paxCount / capacity,
                      strokeWidth: 16,
                      backgroundColor:
                          isDark ? AppColors.grey800 : AppColors.grey100,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$paxCount/$capacity',
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 48,
                          color:
                              isDark ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Seats filled',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
              ),
              child: Text(
                'Vehicle Capacity',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
            Text(
              'Currently loading passengers at Main Terminal',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.grey500,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Passenger Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PassengerControlButton(
                    icon: Icons.remove_rounded,
                    isDark: isDark,
                    onTap: () {
                      if (paxCount > 0) {
                        ref.read(passengerCountProvider.notifier).state =
                            paxCount - 1;
                      }
                    },
                  ),
                  Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: Text(
                      '$paxCount',
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 32,
                      ),
                    ),
                  ),
                  _PassengerControlButton(
                    icon: Icons.add_rounded,
                    isDark: isDark,
                    isPrimary: true,
                    onTap: () {
                      if (paxCount < capacity) {
                        ref.read(passengerCountProvider.notifier).state =
                            paxCount + 1;
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Components ─────────────────────────────────────────────────────────────

class _QueueBottomBar extends ConsumerWidget {
  const _QueueBottomBar({required this.isDark, this.queuePosition});

  final bool isDark;
  final QueuePosition? queuePosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(queueOperationLoadingProvider);
    final isInQueue = queuePosition != null;
    final isFirst = queuePosition?.position == 1;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.grey800 : AppColors.grey200,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: isFirst
                  ? AppButton.primary(
                      label: 'Start Loading',
                      icon: Icons.people_rounded,
                      backgroundColor: AppColors.primaryGreen,
                      onPressed: () {
                        // Switch to loading state
                        ref.read(isLoadingPassengersProvider.notifier).state =
                            true;
                      },
                    )
                  : isInQueue
                      ? AppButton(
                          label: 'Leave Queue',
                          icon: Icons.exit_to_app_rounded,
                          variant: ButtonVariant.secondary,
                          isLoading: isLoading,
                          onPressed: () async {
                            ref
                                .read(queueOperationLoadingProvider.notifier)
                                .state = true;
                            try {
                              ref.invalidate(leaveQueueProvider);
                              await ref.read(leaveQueueProvider.future);
                            } finally {
                              ref
                                  .read(queueOperationLoadingProvider.notifier)
                                  .state = false;
                            }
                          },
                        )
                      : AppButton.primary(
                          label: 'Join Queue',
                          icon: Icons.person_add_rounded,
                          isLoading: isLoading,
                          onPressed: (ref.watch(isVehicleFullProvider) ||
                                  ref.read(selectedRouteIdProvider) == null)
                              ? null
                              : () async {
                                  final routeId =
                                      ref.read(selectedRouteIdProvider);
                                  if (routeId == null) return;

                                  ref
                                      .read(queueOperationLoadingProvider
                                          .notifier)
                                      .state = true;
                                  try {
                                    ref.invalidate(joinQueueProvider(routeId));
                                    await ref.read(
                                        joinQueueProvider(routeId).future);
                                  } finally {
                                    ref
                                        .read(queueOperationLoadingProvider
                                            .notifier)
                                        .state = false;
                                  }
                                },
                        ),
            ),
            const SizedBox(width: AppSpacing.md),
            AppIconButton(
              icon: Icons.share_outlined,
              backgroundColor: isDark ? AppColors.grey800 : AppColors.white,
              color: isDark ? AppColors.white : AppColors.grey500,
              onPressed: () {
                Share.share('Trying out the Komiut Driver App!');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBottomBar extends ConsumerWidget {
  const _LoadingBottomBar({required this.isDark, required this.isFull});

  final bool isDark;
  final bool isFull;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(queueOperationLoadingProvider);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.grey800 : AppColors.grey200,
            ),
          ),
        ),
        child: AppButton.primary(
          label: 'Start Trip',
          icon: Icons.local_shipping_rounded,
          // Use green when loading, blue when full/departing
          backgroundColor:
              isFull ? AppColors.primaryBlue : AppColors.primaryGreen,
          isLoading: isLoading,
          onPressed: () {
            // Mock start trip
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Trip Started! (Mock)',
                  style: TextStyle(color: AppColors.white),
                ),
                backgroundColor: AppColors.primaryGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Reset state
            ref.read(isLoadingPassengersProvider.notifier).state = false;
            ref.read(passengerCountProvider.notifier).state = 0;
            ref.invalidate(driverQueuePositionProvider);
          },
        ),
      ),
    );
  }
}

class _SliverQueueAppBar extends StatelessWidget {
  const _SliverQueueAppBar({
    required this.isDark,
    required this.title,
    this.subtitle,
    this.isExpress = false,
    this.onBack,
  });

  final bool isDark;
  final String title;
  final String? subtitle;
  final bool isExpress;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      elevation: 0,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: isDark ? AppColors.white : AppColors.textPrimary,
              onPressed: onBack,
            )
          : null, // No back button on main tab unless specified

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading4.copyWith(
              color: isDark ? AppColors.white : AppColors.textPrimary,
              fontSize: 18,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.grey500,
                fontSize: 13,
              ),
            ),
        ],
      ),
      actions: [
        // Debug toggle for "Full Vehicle" state
        Consumer(
          builder: (context, ref, _) {
            final isFull = ref.watch(isVehicleFullProvider);
            return IconButton(
              icon: Icon(
                isFull ? Icons.reduce_capacity_rounded : Icons.people_outline,
                color: isFull
                    ? AppColors.error
                    : isDark
                        ? AppColors.white
                        : AppColors.grey500,
              ),
              tooltip: 'Toggle Mock Full State',
              onPressed: () {
                final current = ref.read(mockExternalPassengerCountProvider);
                final max = ref.read(vehicleMaxCapacityProvider);
                ref.read(mockExternalPassengerCountProvider.notifier).state =
                    current >= max ? 0 : max;
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _QueueMapSection extends StatelessWidget {
  const _QueueMapSection({required this.isDark, required this.isInQueue});

  final bool isDark;
  final bool isInQueue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Reduced height for more content space
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: KomiutMap(
        showMock: false,
        initialPosition: const LatLng(-1.2867, 36.8172),
        markers: [
          if (isInQueue)
            const Marker(
              point: LatLng(-1.2867, 36.8172),
              width: 40,
              height: 40,
              child: Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryBlue,
                size: 32,
              ),
            ),
        ],
      ),
    );
  }
}

class _YoureUpBanner extends StatelessWidget {
  const _YoureUpBanner({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "YOU'RE UP!",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "It's your turn to load passengers",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
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

class _QueueStatusCard extends StatelessWidget {
  const _QueueStatusCard({
    required this.position,
    required this.isDark,
    required this.onRefresh,
  });

  final QueuePosition position;
  final bool isDark;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Status info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR STATUS',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      'Position',
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '#${position.position}',
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 28,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Estimated wait: ${position.displayEstimatedWait}',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Refresh Position',
                  icon: Icons.refresh_rounded,
                  variant: ButtonVariant.secondary,
                  onPressed: onRefresh,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Right side: Mini Map
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(
                color: isDark ? AppColors.grey800 : AppColors.grey200,
              ),
              color: isDark ? AppColors.grey900 : AppColors.grey100,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  child: KomiutMap(
                    showMock: false,
                    initialPosition: const LatLng(-1.2867, 36.8172),
                  ),
                ),
                // Overlay to darken map slightly
                Container(
                  color: AppColors.black.withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueListTile extends StatelessWidget {
  const _QueueListTile({
    required this.index,
    required this.isDark,
    required this.currentUserPosition,
  });

  final int index;
  final bool isDark;
  final int currentUserPosition;

  @override
  Widget build(BuildContext context) {
    // Mock data based on index
    final position = index + 1;
    final isMe = position == currentUserPosition;
    final isAhead = position < currentUserPosition;

    final names = [
      'Alex M.',
      'Sarah L.',
      'John D.',
      'You (Me)',
      'David K.',
      'Lisa R.'
    ];
    final cars = [
      'Toyota Hiace • KBD 123',
      'Mercedes Sprinter • LMN 456',
      'Toyota Coaster • KXY 789',
      'Volkswagen Transporter • KYZ 789',
      'Nissan Caravan • KAB 123',
      'Isuzu NPR • KCD 456'
    ];
    final status = isMe ? 'POS #$position' : (isAhead ? 'Ahead' : 'Behind');

    // Bounds check for mock arrays
    final name = names[index % names.length];
    final car = cars[index % cars.length];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primaryBlue.withValues(alpha: 0.1)
            : (isDark ? AppColors.surfaceDark : AppColors.white),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: isMe
              ? AppColors.primaryBlue
              : (isDark ? AppColors.grey800 : AppColors.grey200),
          width: isMe ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: isMe ? AppColors.primaryBlue : AppColors.grey300,
          child: Icon(
            Icons.person,
            color: isMe ? AppColors.white : AppColors.grey600,
          ),
        ),
        title: Row(
          children: [
            Text(
              isMe ? 'You (Me)' : name,
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: isMe ? AppColors.primaryBlue : null,
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'POS #$position',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
            if (!isMe) ...[
              const SizedBox(width: 8),
              Text(
                '($status)',
                style: AppTextStyles.body2.copyWith(color: AppColors.grey500),
              ),
            ],
          ],
        ),
        subtitle: Text(
          car,
          style: AppTextStyles.body2.copyWith(color: AppColors.grey500),
        ),
        trailing: isAhead
            ? Text(
                'IN LOADING', // Mock logic: first few are loading
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.grey400,
                  fontWeight: FontWeight.bold,
                ),
              )
            : isMe
                ? const Icon(Icons.drag_handle, color: AppColors.primaryBlue)
                : Text(
                    '10M WAIT',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.grey400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
      ),
    );
  }
}

class _PassengerControlButton extends StatelessWidget {
  const _PassengerControlButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryBlue
              : (isDark ? AppColors.grey800 : AppColors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? AppColors.primaryBlue
                : (isDark ? AppColors.grey700 : AppColors.grey200),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 28,
          color: isPrimary
              ? AppColors.white
              : (isDark ? AppColors.white : AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
