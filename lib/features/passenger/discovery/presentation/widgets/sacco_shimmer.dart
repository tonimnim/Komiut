/// SaccoShimmer - Shimmer loading placeholder for sacco list.
///
/// Displays shimmer placeholders matching the SaccoCard layout.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/loading/shimmer_loading.dart';

/// Shimmer loading placeholder for a single sacco card.
class SaccoCardShimmer extends StatelessWidget {
  /// Creates a SaccoCardShimmer.
  const SaccoCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          // Logo placeholder
          ShimmerCircle(size: 48),
          SizedBox(width: 16),

          // Content placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name placeholder
                ShimmerBox(
                  height: 16,
                  width: 140,
                  borderRadius: 4,
                ),
                SizedBox(height: 8),

                // Route count and status row
                Row(
                  children: [
                    ShimmerBox(
                      height: 12,
                      width: 70,
                      borderRadius: 4,
                    ),
                    SizedBox(width: 12),
                    ShimmerBox(
                      height: 12,
                      width: 50,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chevron placeholder
          ShimmerBox(
            height: 24,
            width: 24,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading for the sacco list.
class SaccoListShimmer extends StatelessWidget {
  /// Creates a SaccoListShimmer.
  const SaccoListShimmer({
    super.key,
    this.itemCount = 6,
  });

  /// Number of shimmer items to display.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SaccoCardShimmer(),
    );
  }
}

/// Shimmer loading for the filter chips.
class SaccoFilterChipsShimmer extends StatelessWidget {
  /// Creates a SaccoFilterChipsShimmer.
  const SaccoFilterChipsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final widths = [100.0, 80.0, 70.0];
          return ShimmerBox(
            width: widths[index],
            height: 36,
            borderRadius: 20,
          );
        },
      ),
    );
  }
}
