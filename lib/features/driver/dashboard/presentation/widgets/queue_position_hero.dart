/// Queue Position Hero Widget.
///
/// Shows the driver's queue position as the main hero element
/// with a visual queue representation and wait time estimate.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/loading/shimmer_loading.dart';
import '../../../queue/domain/entities/queue_position.dart';
import '../../../queue/presentation/providers/queue_providers.dart';
import 'youre_up_banner.dart';

/// Hero widget displaying the driver's queue position prominently.
///
/// Shows a large position number with visual queue representation,
/// vehicles ahead count, and estimated wait time.
class QueuePositionHero extends ConsumerWidget {
  const QueuePositionHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queuePositionAsync = ref.watch(driverQueuePositionProvider);

    return queuePositionAsync.when(
      loading: () => const _QueuePositionHeroShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (position) {
        if (position == null) {
          return const SizedBox.shrink();
        }

        // Show "You're Up" banner when at position 1
        if (position.isFirst) {
          return const YoureUpBanner();
        }

        return _QueuePositionHeroContent(position: position);
      },
    );
  }
}

/// Content widget for queue position display.
class _QueuePositionHeroContent extends StatelessWidget {
  const _QueuePositionHeroContent({
    required this.position,
  });

  final QueuePosition position;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Text(
            'YOUR POSITION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          // Position number container
          _buildPositionNumber(),
          const SizedBox(height: 20),
          // Visual queue representation
          _buildVisualQueue(),
          const SizedBox(height: 16),
          // Info text
          _buildInfoText(),
        ],
      ),
    );
  }

  Widget _buildPositionNumber() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
    );
  }

  Widget _buildVisualQueue() {
    final totalVehicles = (position.vehiclesAhead ?? position.position - 1) + 5;
    final vehicleCount = totalVehicles.clamp(5, 9);
    final currentIndex = position.position - 1;

    return Column(
      children: [
        SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(vehicleCount, (index) {
              final isCurrentUser = index == currentIndex;
              final icon = _getVehicleIcon(index);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: isCurrentUser ? 24 : 20,
                      color: isCurrentUser
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                    if (isCurrentUser)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'YOU',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(int index) {
    // Mix of vehicle types for visual variety
    if (index % 4 == 2) {
      return Icons.directions_bus_rounded;
    }
    return Icons.airport_shuttle_rounded;
  }

  Widget _buildInfoText() {
    final ahead = position.vehiclesAhead ?? (position.position - 1);
    final waitText = position.displayEstimatedWait;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$ahead ahead',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            '$waitText wait',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading placeholder for queue position hero.
class _QueuePositionHeroShimmer extends StatelessWidget {
  const _QueuePositionHeroShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title shimmer
          ShimmerBox(
            height: 12,
            width: 100,
            borderRadius: 6,
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          // Position number shimmer
          ShimmerBox(
            height: 100,
            width: 100,
            borderRadius: 16,
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 20),
          // Visual queue shimmer
          ShimmerBox(
            height: 32,
            width: 200,
            borderRadius: 8,
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          // Info text shimmer
          ShimmerBox(
            height: 32,
            width: 160,
            borderRadius: 16,
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
