/// Points balance card widget.
///
/// Displays the user's loyalty points balance with tier badge.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/loyalty_points.dart';

/// A card displaying the user's loyalty points balance.
///
/// Shows:
/// - Available points with tier badge
/// - Pending points (if any)
/// - Redemption value
class PointsBalanceCard extends StatelessWidget {
  /// Creates a points balance card.
  const PointsBalanceCard({
    super.key,
    required this.loyaltyPoints,
    this.onRedeemPressed,
    this.isLoading = false,
    this.hasError = false,
  });

  /// The loyalty points data.
  final LoyaltyPoints? loyaltyPoints;

  /// Callback when redeem button is pressed.
  final VoidCallback? onRedeemPressed;

  /// Whether data is loading.
  final bool isLoading;

  /// Whether there was an error loading data.
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with tier badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Loyalty Points',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (loyaltyPoints != null)
                _TierBadge(tier: loyaltyPoints!.tier),
            ],
          ),
          const SizedBox(height: 16),

          // Loading/Error/Content
          if (isLoading)
            const SizedBox(
              height: 80,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (hasError)
            const Text(
              'Unable to load points',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            )
          else if (loyaltyPoints != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available points
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${loyaltyPoints!.availablePoints}',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'points',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Pending points
                if (loyaltyPoints!.pendingPoints > 0)
                  Text(
                    '+${loyaltyPoints!.pendingPoints} pending',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),

                const SizedBox(height: 16),

                // Redemption value and button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Worth',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          loyaltyPoints!.formattedRedemptionValue,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (loyaltyPoints!.hasRedeemablePoints && onRedeemPressed != null)
                      ElevatedButton(
                        onPressed: onRedeemPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Redeem',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            )
          else
            const Text(
              'No points data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }
}

/// Tier badge widget.
class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final LoyaltyTier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(tier.colorValue).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tier == LoyaltyTier.platinum
                ? Icons.workspace_premium
                : Icons.stars_rounded,
            size: 16,
            color: Color(tier.colorValue),
          ),
          const SizedBox(width: 6),
          Text(
            tier.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(tier.colorValue),
            ),
          ),
        ],
      ),
    );
  }
}
