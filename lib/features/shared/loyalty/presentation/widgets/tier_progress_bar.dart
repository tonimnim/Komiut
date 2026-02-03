/// Tier progress bar widget.
///
/// Displays progress towards the next loyalty tier.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/loyalty_points.dart';

/// A widget showing progress to the next tier.
///
/// Displays:
/// - Current tier and next tier
/// - Progress bar
/// - Points needed
class TierProgressBar extends StatelessWidget {
  /// Creates a tier progress bar.
  const TierProgressBar({
    super.key,
    required this.loyaltyPoints,
    this.showDetails = true,
  });

  /// The loyalty points data.
  final LoyaltyPoints loyaltyPoints;

  /// Whether to show detailed information.
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentTier = loyaltyPoints.tier;
    final nextTier = loyaltyPoints.nextTier;
    final progress = loyaltyPoints.progressToNextTier;
    final pointsNeeded = loyaltyPoints.pointsToNextTier;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tier Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (nextTier != null)
                Text(
                  '$pointsNeeded pts to ${nextTier.displayName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                )
              else
                Text(
                  'Max tier reached!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(LoyaltyTier.platinum.colorValue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Row(
            children: [
              // Current tier icon
              _TierIcon(tier: currentTier, isActive: true),
              const SizedBox(width: 12),

              // Progress bar
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        // Background
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Progress
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(currentTier.colorValue),
                                  nextTier != null
                                      ? Color(nextTier.colorValue)
                                      : Color(currentTier.colorValue),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (showDetails) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentTier.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(currentTier.colorValue),
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey[400]
                                  : AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            nextTier?.displayName ?? 'Max',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: nextTier != null
                                  ? Color(nextTier.colorValue).withOpacity(0.7)
                                  : Color(currentTier.colorValue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Next tier icon
              _TierIcon(
                tier: nextTier ?? currentTier,
                isActive: nextTier == null,
              ),
            ],
          ),

          // Bonus info
          if (showDetails && currentTier.bonusPercentage > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(currentTier.colorValue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Color(currentTier.colorValue),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Earning ${currentTier.bonusPercentage}% bonus points',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(currentTier.colorValue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tier icon widget.
class _TierIcon extends StatelessWidget {
  const _TierIcon({
    required this.tier,
    required this.isActive,
  });

  final LoyaltyTier tier;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive
            ? Color(tier.colorValue).withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color:
              isActive ? Color(tier.colorValue) : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        tier == LoyaltyTier.platinum
            ? Icons.workspace_premium
            : Icons.stars_rounded,
        size: 18,
        color: isActive ? Color(tier.colorValue) : Colors.grey.withOpacity(0.5),
      ),
    );
  }
}
