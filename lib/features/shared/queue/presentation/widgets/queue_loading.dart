/// Queue Loading - Shimmer loading state for queue screen.
///
/// Provides a shimmer loading placeholder while queue data is being fetched.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/loading/shimmer_loading.dart';

/// Shimmer loading widget for the queue screen.
///
/// Displays placeholder content mimicking the queue layout while loading.
class QueueLoading extends StatelessWidget {
  /// Creates a QueueLoading widget.
  const QueueLoading({
    super.key,
    this.itemCount = 5,
  });

  /// Number of shimmer items to display.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Header shimmer
        _buildHeaderShimmer(isDark),
        const SizedBox(height: 16),

        // Vehicle cards shimmer
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _QueuedVehicleCardShimmer(isDark: isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderShimmer(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerBox(width: 180, height: 20),
              ShimmerBox(width: 40, height: 40, borderRadius: 20),
            ],
          ),
          const SizedBox(height: 12),
          const ShimmerBox(width: 140, height: 14),
          const SizedBox(height: 8),
          const ShimmerBox(width: 100, height: 14),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for a single queued vehicle card.
class _QueuedVehicleCardShimmer extends StatelessWidget {
  const _QueuedVehicleCardShimmer({
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position badge shimmer
          ShimmerBox(
            width: 48,
            height: 48,
            borderRadius: 24,
          ),
          const SizedBox(width: 14),

          // Vehicle info shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 100, height: 16),
                const SizedBox(height: 8),
                const ShimmerBox(width: 80, height: 14),
              ],
            ),
          ),

          // Status shimmer
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 80, height: 24, borderRadius: 12),
              const SizedBox(height: 8),
              const ShimmerBox(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading for just the vehicle list (used during refresh).
class QueueVehicleListShimmer extends StatelessWidget {
  /// Creates a QueueVehicleListShimmer widget.
  const QueueVehicleListShimmer({
    super.key,
    this.itemCount = 5,
  });

  /// Number of shimmer items to display.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _QueuedVehicleCardShimmer(isDark: isDark),
        );
      },
    );
  }
}
