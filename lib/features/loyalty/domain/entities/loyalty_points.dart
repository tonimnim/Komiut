/// Loyalty points domain entities.
///
/// Contains the core loyalty points domain models.
library;

/// Loyalty tier levels.
///
/// Tiers provide increasing benefits as users accumulate points.
enum LoyaltyTier {
  /// Bronze tier - Entry level (0+ points).
  bronze,

  /// Silver tier - 500+ points (5% bonus on earnings).
  silver,

  /// Gold tier - 2000+ points (10% bonus on earnings).
  gold,

  /// Platinum tier - 5000+ points (15% bonus on earnings).
  platinum;

  /// Display name for the tier.
  String get displayName {
    switch (this) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
    }
  }

  /// Icon for the tier.
  String get icon {
    switch (this) {
      case LoyaltyTier.bronze:
        return 'stars';
      case LoyaltyTier.silver:
        return 'stars';
      case LoyaltyTier.gold:
        return 'stars';
      case LoyaltyTier.platinum:
        return 'workspace_premium';
    }
  }

  /// Color hex for the tier.
  int get colorValue {
    switch (this) {
      case LoyaltyTier.bronze:
        return 0xFFCD7F32; // Bronze
      case LoyaltyTier.silver:
        return 0xFFC0C0C0; // Silver
      case LoyaltyTier.gold:
        return 0xFFFFD700; // Gold
      case LoyaltyTier.platinum:
        return 0xFFE5E4E2; // Platinum
    }
  }

  /// Bonus percentage for the tier.
  int get bonusPercentage {
    switch (this) {
      case LoyaltyTier.bronze:
        return 0;
      case LoyaltyTier.silver:
        return 5;
      case LoyaltyTier.gold:
        return 10;
      case LoyaltyTier.platinum:
        return 15;
    }
  }
}

/// Transaction type for points.
enum PointsTransactionType {
  /// Points earned from trips.
  earned,

  /// Points redeemed for discounts.
  redeemed,

  /// Points that have expired.
  expired,

  /// Bonus points from promotions.
  bonus;

  /// Display name for the transaction type.
  String get displayName {
    switch (this) {
      case PointsTransactionType.earned:
        return 'Earned';
      case PointsTransactionType.redeemed:
        return 'Redeemed';
      case PointsTransactionType.expired:
        return 'Expired';
      case PointsTransactionType.bonus:
        return 'Bonus';
    }
  }

  /// Whether this type adds points (positive) or removes them (negative).
  bool get isPositive {
    return this == PointsTransactionType.earned ||
        this == PointsTransactionType.bonus;
  }
}

/// A loyalty points transaction.
///
/// Represents a single points transaction (earn, redeem, expire, bonus).
class PointsTransaction {
  /// Creates a new points transaction.
  const PointsTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    this.bookingId,
    required this.timestamp,
  });

  /// Unique transaction identifier.
  final String id;

  /// Type of transaction.
  final PointsTransactionType type;

  /// Number of points involved.
  final int points;

  /// Description of the transaction.
  final String description;

  /// Associated booking ID (if applicable).
  final String? bookingId;

  /// When the transaction occurred.
  final DateTime timestamp;

  /// Signed points value (positive for earned/bonus, negative for redeemed/expired).
  int get signedPoints {
    return type.isPositive ? points : -points;
  }

  /// Formatted points string with sign.
  String get formattedPoints {
    if (type.isPositive) {
      return '+$points';
    } else {
      return '-$points';
    }
  }
}

/// User's loyalty points balance and status.
///
/// Contains the user's current points balance, tier, and recent activity.
class LoyaltyPoints {
  /// Creates a new loyalty points instance.
  const LoyaltyPoints({
    required this.userId,
    required this.totalPoints,
    required this.availablePoints,
    required this.pendingPoints,
    required this.tier,
    required this.pointsToNextTier,
    this.recentActivity,
    this.nextTier,
    this.lifetimePoints,
  });

  /// User ID.
  final String userId;

  /// Total points ever earned.
  final int totalPoints;

  /// Currently available points (can be redeemed).
  final int availablePoints;

  /// Pending points (not yet available).
  final int pendingPoints;

  /// Current loyalty tier.
  final LoyaltyTier tier;

  /// Points needed to reach the next tier.
  final int pointsToNextTier;

  /// Recent transaction history.
  final List<PointsTransaction>? recentActivity;

  /// Next tier to achieve (null if at platinum).
  final LoyaltyTier? nextTier;

  /// Lifetime points earned.
  final int? lifetimePoints;

  /// Progress percentage to next tier (0.0 to 1.0).
  double get progressToNextTier {
    if (tier == LoyaltyTier.platinum) return 1.0;

    final currentTierThreshold = _getTierThreshold(tier);
    final nextTierThreshold = _getTierThreshold(nextTier ?? LoyaltyTier.platinum);
    final range = nextTierThreshold - currentTierThreshold;

    if (range <= 0) return 1.0;

    final progress = (totalPoints - currentTierThreshold) / range;
    return progress.clamp(0.0, 1.0);
  }

  /// Get tier threshold points.
  int _getTierThreshold(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 0;
      case LoyaltyTier.silver:
        return 500;
      case LoyaltyTier.gold:
        return 2000;
      case LoyaltyTier.platinum:
        return 5000;
    }
  }

  /// Formatted available points string.
  String get formattedAvailablePoints => '$availablePoints pts';

  /// Whether the user has redeemable points.
  bool get hasRedeemablePoints => availablePoints >= 100;

  /// Redemption value of available points in KES.
  double get redemptionValue => (availablePoints / 100) * 10;

  /// Formatted redemption value.
  String get formattedRedemptionValue => 'KES ${redemptionValue.toStringAsFixed(0)}';
}
