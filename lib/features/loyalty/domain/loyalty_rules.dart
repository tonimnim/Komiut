/// Loyalty program rules and calculations.
///
/// Contains all business logic for the loyalty points system.
library;

import 'entities/loyalty_points.dart';

/// Loyalty program rules and calculations.
///
/// Defines earning rates, redemption rates, and tier thresholds.
class LoyaltyRules {
  const LoyaltyRules._();

  // ─────────────────────────────────────────────────────────────────────────
  // Earning Rules
  // ─────────────────────────────────────────────────────────────────────────

  /// Points earned per KES spent.
  /// Earning: 1 point per KES 10 spent.
  static const double pointsPerKes = 0.1; // 1 point per 10 KES

  /// Calculate points earned for a given amount.
  ///
  /// Returns the number of points earned for [amount] KES.
  /// Applies tier bonus if [tier] is provided.
  static int calculatePointsEarned(double amount, {LoyaltyTier? tier}) {
    // Base points: 1 point per 10 KES
    int basePoints = (amount * pointsPerKes).floor();

    // Apply tier bonus if applicable
    if (tier != null && tier.bonusPercentage > 0) {
      final bonus = (basePoints * tier.bonusPercentage / 100).floor();
      basePoints += bonus;
    }

    return basePoints;
  }

  /// Calculate the amount needed to earn [targetPoints] points.
  static double amountForPoints(int targetPoints) {
    return targetPoints / pointsPerKes;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Redemption Rules
  // ─────────────────────────────────────────────────────────────────────────

  /// Points required for KES 10 discount.
  /// Redemption: 100 points = KES 10 discount.
  static const int pointsPerTenKes = 100;

  /// Minimum points required for redemption.
  static const int minimumRedemption = 100;

  /// Maximum points that can be redeemed per transaction.
  static const int maximumRedemption = 5000;

  /// Calculate discount value for given points.
  ///
  /// Returns the discount value in KES for [points].
  static double calculateRedemptionValue(int points) {
    return (points / pointsPerTenKes) * 10;
  }

  /// Calculate points needed for a target discount.
  ///
  /// Returns the number of points needed for [discountAmount] KES discount.
  static int pointsForDiscount(double discountAmount) {
    return ((discountAmount / 10) * pointsPerTenKes).ceil();
  }

  /// Validate redemption request.
  ///
  /// Returns null if valid, or error message if invalid.
  static String? validateRedemption({
    required int requestedPoints,
    required int availablePoints,
    double? bookingAmount,
  }) {
    if (requestedPoints < minimumRedemption) {
      return 'Minimum redemption is $minimumRedemption points';
    }

    if (requestedPoints > maximumRedemption) {
      return 'Maximum redemption is $maximumRedemption points per transaction';
    }

    if (requestedPoints > availablePoints) {
      return 'Insufficient points. You have $availablePoints available.';
    }

    // Validate against booking amount if provided
    if (bookingAmount != null) {
      final discountValue = calculateRedemptionValue(requestedPoints);
      if (discountValue > bookingAmount) {
        final maxPoints = pointsForDiscount(bookingAmount);
        return 'Maximum redeemable for this booking is $maxPoints points (KES ${bookingAmount.toStringAsFixed(0)})';
      }
    }

    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tier Rules
  // ─────────────────────────────────────────────────────────────────────────

  /// Tier thresholds (total lifetime points).
  static const Map<LoyaltyTier, int> tierThresholds = {
    LoyaltyTier.bronze: 0,
    LoyaltyTier.silver: 500,
    LoyaltyTier.gold: 2000,
    LoyaltyTier.platinum: 5000,
  };

  /// Tier bonus percentages on point earnings.
  static const Map<LoyaltyTier, int> tierBonuses = {
    LoyaltyTier.bronze: 0,
    LoyaltyTier.silver: 5,
    LoyaltyTier.gold: 10,
    LoyaltyTier.platinum: 15,
  };

  /// Determine tier based on total lifetime points.
  static LoyaltyTier getTierForPoints(int totalPoints) {
    if (totalPoints >= tierThresholds[LoyaltyTier.platinum]!) {
      return LoyaltyTier.platinum;
    } else if (totalPoints >= tierThresholds[LoyaltyTier.gold]!) {
      return LoyaltyTier.gold;
    } else if (totalPoints >= tierThresholds[LoyaltyTier.silver]!) {
      return LoyaltyTier.silver;
    }
    return LoyaltyTier.bronze;
  }

  /// Get the next tier after [currentTier].
  ///
  /// Returns null if already at platinum.
  static LoyaltyTier? getNextTier(LoyaltyTier currentTier) {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return LoyaltyTier.silver;
      case LoyaltyTier.silver:
        return LoyaltyTier.gold;
      case LoyaltyTier.gold:
        return LoyaltyTier.platinum;
      case LoyaltyTier.platinum:
        return null;
    }
  }

  /// Calculate points needed to reach the next tier.
  ///
  /// Returns 0 if already at platinum.
  static int pointsToNextTier(int currentTotalPoints, LoyaltyTier currentTier) {
    final nextTier = getNextTier(currentTier);
    if (nextTier == null) return 0;

    final nextThreshold = tierThresholds[nextTier]!;
    return (nextThreshold - currentTotalPoints).clamp(0, nextThreshold);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tier Benefits
  // ─────────────────────────────────────────────────────────────────────────

  /// Get tier benefits description.
  static List<String> getTierBenefits(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return [
          'Earn 1 point per KES 10 spent',
          'Redeem 100 points for KES 10 discount',
          'Access to loyalty rewards',
        ];
      case LoyaltyTier.silver:
        return [
          '5% bonus on all point earnings',
          'Priority customer support',
          'Exclusive Silver member offers',
          'Early access to promotions',
        ];
      case LoyaltyTier.gold:
        return [
          '10% bonus on all point earnings',
          'Priority boarding assistance',
          'Exclusive Gold member offers',
          'Birthday bonus points',
          'Partner discounts',
        ];
      case LoyaltyTier.platinum:
        return [
          '15% bonus on all point earnings',
          'VIP customer support line',
          'Exclusive Platinum member offers',
          'Double birthday bonus points',
          'Premium partner discounts',
          'Free seat upgrades (when available)',
        ];
    }
  }
}
