/// Queue management screen.
///
/// Shows driver's queue position or available routes to join.
/// Handles errors gracefully with mock data fallback.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/loading/shimmer_loading.dart';
import '../../domain/entities/queue_position.dart';
import '../providers/queue_providers.dart';
import '../widgets/queue_widgets.dart';

/// Mock routes for when server fails.
const _mockRoutes = [
  _MockRoute(id: '1', name: 'Nairobi CBD - Westlands', vehiclesInQueue: 12),
  _MockRoute(id: '2', name: 'Nairobi CBD - Karen', vehiclesInQueue: 8),
  _MockRoute(id: '3', name: 'Westlands - Kilimani', vehiclesInQueue: 5),
  _MockRoute(id: '4', name: 'CBD - Eastleigh', vehiclesInQueue: 15),
];

@immutable
class _MockRoute {
  const _MockRoute({
    required this.id,
    required this.name,
    required this.vehiclesInQueue,
  });

  final String id;
  final String name;
  final int vehiclesInQueue;
}

/// Queue screen widget.
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
    final queueAsync = ref.watch(driverQueuePositionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.grey[50],
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _QueueHeader(isDark: isDark),

            // Content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: () async => refreshQueue(ref),
                child: queueAsync.when(
                  loading: () => const _LoadingState(),
                  error: (_, __) => _NotInQueueState(isDark: isDark),
                  data: (position) {
                    if (position == null) {
                      return _NotInQueueState(isDark: isDark);
                    }
                    if (position.isFirst) {
                      return _YoureUpState(position: position, isDark: isDark);
                    }
                    return _InQueueState(position: position, isDark: isDark);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _QueueHeader extends ConsumerWidget {
  const _QueueHeader({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(queueOperationLoadingProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: isDark ? const Color(0xFF111111) : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Queue',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: isLoading ? null : () => refreshQueue(ref),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOADING STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          ShimmerBox(height: 200, borderRadius: 20),
          SizedBox(height: 24),
          ShimmerBox(height: 80, borderRadius: 12),
          SizedBox(height: 12),
          ShimmerBox(height: 80, borderRadius: 12),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOT IN QUEUE STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _NotInQueueState extends StatelessWidget {
  const _NotInQueueState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Empty state illustration
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_list_numbered_rounded,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Not in any queue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join a queue to start your day',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 32),

          // Available routes section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'AVAILABLE ROUTES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: isDark ? Colors.grey[500] : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Route list
          ..._mockRoutes.map((route) => _RouteCard(
                route: route,
                isDark: isDark,
              )),
        ],
      ),
    );
  }
}

class _RouteCard extends ConsumerWidget {
  const _RouteCard({required this.route, required this.isDark});

  final _MockRoute route;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showJoinDialog(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.route_rounded,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${route.vehiclesInQueue} vehicles in queue',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_road_rounded,
                color: AppColors.primaryBlue,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Join Queue?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              route.name,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will be placed at position #${route.vehiclesInQueue + 1}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await ref.read(joinQueueProvider(route.id).future);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Joined queue successfully!'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to join: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Join Queue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// IN QUEUE STATE (WAITING)
// ═══════════════════════════════════════════════════════════════════════════════

class _InQueueState extends ConsumerWidget {
  const _InQueueState({required this.position, required this.isDark});

  final QueuePosition position;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAhead = position.vehiclesAhead ?? (position.position - 1);
    final estimatedWait = vehiclesAhead * 6; // ~6 min per vehicle

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          // YOUR POSITION header
          Text(
            'YOUR POSITION',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: isDark ? Colors.grey[500] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Big position number
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlue, Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${position.position}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Visual queue
          VisualQueueIndicator(
            position: position.position,
            totalVisible: 7,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // Info text
          Text(
            '$vehiclesAhead ahead  •  ~$estimatedWait min wait',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Route info
          _RouteInfoCard(
            routeName: position.routeName,
            stageName: position.stageName,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Leave queue button
          GestureDetector(
            onTap: () => _showLeaveDialog(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Text(
                'Leave Queue',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Queue?'),
        content: const Text(
          'You will lose your current position and have to rejoin at the back.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(leaveQueueProvider.future);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Left queue')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// YOU'RE UP STATE (POSITION 1)
// ═══════════════════════════════════════════════════════════════════════════════

class _YoureUpState extends ConsumerWidget {
  const _YoureUpState({required this.position, required this.isDark});

  final QueuePosition position;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          // You're Up banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryGreen, Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "YOU'RE UP!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Start boarding passengers',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Route info
          _RouteInfoCard(
            routeName: position.routeName,
            stageName: position.stageName,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Start loading button
          GestureDetector(
            onTap: () {
              // TODO: Start loading passengers
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'START LOADING',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Leave queue button
          GestureDetector(
            onTap: () => _showLeaveDialog(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Text(
                'Leave Queue',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Queue?'),
        content: const Text(
          "You're at the front! Are you sure you want to leave?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(leaveQueueProvider.future);
              } catch (_) {}
            },
            child: const Text('Leave', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _RouteInfoCard extends StatelessWidget {
  const _RouteInfoCard({
    required this.routeName,
    this.stageName,
    required this.isDark,
  });

  final String routeName;
  final String? stageName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.route_rounded,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (stageName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    stageName!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
