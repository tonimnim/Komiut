/// Queue management screen.
///
/// Shows the driver's position in the departure queue:
/// - Current queue position
/// - Estimated departure time
/// - Vehicles ahead in queue
/// - Queue actions (join, leave, refresh)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/cards/app_card.dart';
import '../../../../../core/widgets/feedback/app_error.dart';
import '../../../../../core/widgets/loading/shimmer_loading.dart';
import '../../../../../core/widgets/navigation/driver_bottom_nav.dart';
import '../../../../shared/routes/presentation/providers/route_providers.dart';
import '../providers/queue_providers.dart';

/// Queue screen widget.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(driverQueuePositionProvider);
    final isLoading = ref.watch(queueOperationLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Position'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.driverHome),
        ),
        actions: [
          IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: isLoading ? null : () => refreshQueue(ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshQueue(ref),
        child: queueAsync.when(
          loading: () => const _LoadingState(),
          error: (error, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: AppErrorWidget(
                title: 'Failed to load queue',
                message: error.toString(),
                type: ErrorType.server,
                onRetry: () => ref.invalidate(driverQueuePositionProvider),
              ),
            ),
          ),
          data: (position) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Queue Position Card
                _QueuePositionCard(position: position),
                const SizedBox(height: 24),

                // Queue Info or Route Selection
                if (position != null) ...[
                  _QueueInfoSection(position: position),
                  const SizedBox(height: 24),
                  if (position.vehiclesAhead != null && position.vehiclesAhead! > 0)
                    _VehiclesAheadSection(position: position),
                ] else ...[
                  const _RouteSelectionSection(),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: queueAsync.whenOrNull(
        data: (position) => position != null ? _LeaveQueueFAB() : null,
      ),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 1),
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
        children: [
          const ShimmerCard(height: 200, margin: EdgeInsets.zero),
          const SizedBox(height: 24),
          const ShimmerCard(height: 150, margin: EdgeInsets.zero),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Queue Position Card
// ─────────────────────────────────────────────────────────────────────────────

class _QueuePositionCard extends StatelessWidget {
  const _QueuePositionCard({this.position});

  final dynamic position; // QueuePosition?

  @override
  Widget build(BuildContext context) {
    final isInQueue = position != null;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Position indicator
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isInQueue
                  ? AppColors.primaryBlue.withOpacity(0.1)
                  : AppColors.textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isInQueue ? '#${position.position}' : '--',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isInQueue ? AppColors.primaryBlue : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isInQueue ? 'Your Position' : 'Not in Queue',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isInQueue
                ? position.routeName ?? 'Unknown Route'
                : 'Join a queue to see your position',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          if (isInQueue) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoItem(
                  icon: Icons.access_time,
                  label: 'Est. Wait',
                  value: position.displayEstimatedWait ?? '--',
                ),
                _InfoItem(
                  icon: Icons.directions_car,
                  label: 'Ahead',
                  value: '${position.vehiclesAhead ?? 0} vehicles',
                ),
                _InfoItem(
                  icon: Icons.timer,
                  label: 'Waited',
                  value: position.displayWaitTime ?? '--',
                ),
              ],
            ),
            if (position.isFirst) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "You're next!",
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
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
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Queue Info Section
// ─────────────────────────────────────────────────────────────────────────────

class _QueueInfoSection extends StatelessWidget {
  const _QueueInfoSection({required this.position});

  final dynamic position;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Queue Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Route', value: position.routeName ?? '--'),
          if (position.stageName != null)
            _InfoRow(label: 'Stage', value: position.stageName!),
          _InfoRow(label: 'Status', value: position.statusName ?? '--'),
          if (position.vehicleRegistration != null)
            _InfoRow(label: 'Vehicle', value: position.vehicleRegistration!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicles Ahead Section
// ─────────────────────────────────────────────────────────────────────────────

class _VehiclesAheadSection extends ConsumerWidget {
  const _VehiclesAheadSection({required this.position});

  final dynamic position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeQueueAsync = ref.watch(routeQueueProvider(position.routeId));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicles Ahead',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          routeQueueAsync.when(
            loading: () => const ShimmerList(itemCount: 2),
            error: (_, __) => const Text(
              'Unable to load queue',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            data: (positions) {
              final ahead = positions
                  .where((p) => p.position < position.position)
                  .toList()
                ..sort((a, b) => b.position.compareTo(a.position));

              if (ahead.isEmpty) {
                return const Text(
                  'No vehicles ahead',
                  style: TextStyle(color: AppColors.textSecondary),
                );
              }

              return Column(
                children: ahead.take(5).map((p) {
                  return _VehicleItem(
                    position: p.position,
                    registration: p.vehicleRegistration ?? 'Unknown',
                    status: p.isBoarding ? 'Boarding' : 'Waiting',
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VehicleItem extends StatelessWidget {
  const _VehicleItem({
    required this.position,
    required this.registration,
    required this.status,
  });

  final int position;
  final String registration;
  final String status;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
        child: Text(
          '#$position',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(registration),
      subtitle: Text(status),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route Selection Section
// ─────────────────────────────────────────────────────────────────────────────

class _RouteSelectionSection extends ConsumerWidget {
  const _RouteSelectionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Route to Join',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          routesAsync.when(
            loading: () => const ShimmerList(itemCount: 3),
            error: (_, __) => const Text(
              'Unable to load routes',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            data: (routes) {
              if (routes.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No routes available',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return Column(
                children: routes.map((route) {
                  return _RouteOption(
                    routeId: route.id.toString(),
                    routeName: route.name,
                    onTap: () => _showJoinConfirmation(
                        context, ref, route.id.toString(), route.name),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showJoinConfirmation(
    BuildContext context,
    WidgetRef ref,
    String routeId,
    String routeName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join Queue?'),
        content: Text('Do you want to join the queue for $routeName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(joinQueueProvider(routeId).future);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Joined queue successfully!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to join queue: $e')),
                  );
                }
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

class _RouteOption extends StatelessWidget {
  const _RouteOption({
    required this.routeId,
    required this.routeName,
    required this.onTap,
  });

  final String routeId;
  final String routeName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(routeName),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leave Queue FAB
// ─────────────────────────────────────────────────────────────────────────────

class _LeaveQueueFAB extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(queueOperationLoadingProvider);

    return FloatingActionButton.extended(
      onPressed: isLoading ? null : () => _showLeaveConfirmation(context, ref),
      backgroundColor: AppColors.error,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : const Icon(Icons.exit_to_app),
      label: Text(isLoading ? 'Leaving...' : 'Leave Queue'),
    );
  }

  void _showLeaveConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Queue?'),
        content: const Text(
          'Are you sure you want to leave the queue? '
          'You will lose your current position.',
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
                await ref.read(leaveQueueProvider.future);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Left queue successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to leave queue: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
