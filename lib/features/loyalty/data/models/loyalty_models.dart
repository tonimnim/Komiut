/// Loyalty API models.
///
/// Data transfer objects for Loyalty API operations.
library;

import '../../domain/entities/loyalty_points.dart';
import '../../domain/loyalty_rules.dart';

/// API model for loyalty points response.
///
/// Maps between the API response format and the LoyaltyPoints entity.
class LoyaltyPointsApiModel {
  /// Creates a new LoyaltyPointsApiModel instance.
  const LoyaltyPointsApiModel({
    required this.userId,
    required this.totalPoints,
    required this.availablePoints,
    required this.pendingPoints,
    required this.tier,
    this.lifetimePoints,
    this.recentActivity,
  });

  /// Creates from JSON map.
  factory LoyaltyPointsApiModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyPointsApiModel(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      totalPoints: json['totalPoints'] as int? ?? 0,
      availablePoints: json['availablePoints'] as int? ?? json['points'] as int? ?? 0,
      pendingPoints: json['pendingPoints'] as int? ?? 0,
      tier: _parseTier(json['tier'] as String?),
      lifetimePoints: json['lifetimePoints'] as int?,
      recentActivity: json['recentActivity'] != null
          ? (json['recentActivity'] as List)
              .map((e) => PointsTransactionApiModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Parse tier from string.
  static LoyaltyTier _parseTier(String? tier) {
    if (tier == null) return LoyaltyTier.bronze;
    switch (tier.toLowerCase()) {
      case 'silver':
        return LoyaltyTier.silver;
      case 'gold':
        return LoyaltyTier.gold;
      case 'platinum':
        return LoyaltyTier.platinum;
      default:
        return LoyaltyTier.bronze;
    }
  }

  /// User ID.
  final String userId;

  /// Total points ever earned.
  final int totalPoints;

  /// Currently available points.
  final int availablePoints;

  /// Pending points.
  final int pendingPoints;

  /// Current tier.
  final LoyaltyTier tier;

  /// Lifetime points earned.
  final int? lifetimePoints;

  /// Recent activity.
  final List<PointsTransactionApiModel>? recentActivity;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'totalPoints': totalPoints,
        'availablePoints': availablePoints,
        'pendingPoints': pendingPoints,
        'tier': tier.name,
        if (lifetimePoints != null) 'lifetimePoints': lifetimePoints,
        if (recentActivity != null)
          'recentActivity': recentActivity!.map((e) => e.toJson()).toList(),
      };

  /// Converts to domain entity.
  LoyaltyPoints toEntity() {
    final nextTier = LoyaltyRules.getNextTier(tier);
    final pointsToNext = LoyaltyRules.pointsToNextTier(totalPoints, tier);

    return LoyaltyPoints(
      userId: userId,
      totalPoints: totalPoints,
      availablePoints: availablePoints,
      pendingPoints: pendingPoints,
      tier: tier,
      pointsToNextTier: pointsToNext,
      nextTier: nextTier,
      lifetimePoints: lifetimePoints,
      recentActivity: recentActivity?.map((e) => e.toEntity()).toList(),
    );
  }
}

/// API model for points transaction.
class PointsTransactionApiModel {
  /// Creates a new PointsTransactionApiModel instance.
  const PointsTransactionApiModel({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    this.bookingId,
    required this.timestamp,
  });

  /// Creates from JSON map.
  factory PointsTransactionApiModel.fromJson(Map<String, dynamic> json) {
    return PointsTransactionApiModel(
      id: json['id'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      points: json['points'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      bookingId: json['bookingId'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  /// Parse transaction type from string.
  static PointsTransactionType _parseType(String? type) {
    if (type == null) return PointsTransactionType.earned;
    switch (type.toLowerCase()) {
      case 'redeemed':
      case 'redemption':
        return PointsTransactionType.redeemed;
      case 'expired':
      case 'expiration':
        return PointsTransactionType.expired;
      case 'bonus':
      case 'promotion':
        return PointsTransactionType.bonus;
      default:
        return PointsTransactionType.earned;
    }
  }

  /// Transaction ID.
  final String id;

  /// Transaction type.
  final PointsTransactionType type;

  /// Points amount.
  final int points;

  /// Description.
  final String description;

  /// Associated booking ID.
  final String? bookingId;

  /// Timestamp.
  final DateTime timestamp;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'points': points,
        'description': description,
        if (bookingId != null) 'bookingId': bookingId,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Converts to domain entity.
  PointsTransaction toEntity() {
    return PointsTransaction(
      id: id,
      type: type,
      points: points,
      description: description,
      bookingId: bookingId,
      timestamp: timestamp,
    );
  }
}

/// Request model for redeeming points.
class RedeemPointsRequest {
  /// Creates a new RedeemPointsRequest.
  const RedeemPointsRequest({
    required this.points,
    required this.bookingId,
    this.description,
  });

  /// Points to redeem.
  final int points;

  /// Booking ID to apply discount.
  final String bookingId;

  /// Optional description.
  final String? description;

  /// Converts to JSON map for API request.
  Map<String, dynamic> toJson() => {
        'points': points,
        'bookingId': bookingId,
        if (description != null) 'description': description,
      };
}

/// Response model for redemption result.
class RedemptionResult {
  /// Creates a new RedemptionResult.
  const RedemptionResult({
    required this.success,
    required this.pointsRedeemed,
    required this.discountValue,
    required this.remainingPoints,
    this.message,
    this.transactionId,
  });

  /// Creates from JSON map.
  factory RedemptionResult.fromJson(Map<String, dynamic> json) {
    return RedemptionResult(
      success: json['success'] as bool? ?? true,
      pointsRedeemed: json['pointsRedeemed'] as int? ?? json['points'] as int? ?? 0,
      discountValue: (json['discountValue'] as num?)?.toDouble() ??
          (json['discount'] as num?)?.toDouble() ??
          0.0,
      remainingPoints: json['remainingPoints'] as int? ??
          json['availablePoints'] as int? ??
          0,
      message: json['message'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  /// Whether the redemption was successful.
  final bool success;

  /// Points that were redeemed.
  final int pointsRedeemed;

  /// Discount value in KES.
  final double discountValue;

  /// Remaining available points.
  final int remainingPoints;

  /// Message from server.
  final String? message;

  /// Transaction ID.
  final String? transactionId;

  /// Formatted discount value.
  String get formattedDiscount => 'KES ${discountValue.toStringAsFixed(0)}';
}

/// API model for points history response.
class PointsHistoryResponse {
  /// Creates a new PointsHistoryResponse.
  const PointsHistoryResponse({
    required this.transactions,
    required this.totalCount,
    required this.hasMore,
  });

  /// Creates from JSON map.
  factory PointsHistoryResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['items'] as List? ??
        json['transactions'] as List? ??
        json['data'] as List? ??
        [];

    return PointsHistoryResponse(
      transactions: items
          .map((e) => PointsTransactionApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int? ?? json['total'] as int? ?? items.length,
      hasMore: json['hasMore'] as bool? ??
          (json['page'] != null &&
              json['totalPages'] != null &&
              (json['page'] as int) < (json['totalPages'] as int)),
    );
  }

  /// List of transactions.
  final List<PointsTransactionApiModel> transactions;

  /// Total count of transactions.
  final int totalCount;

  /// Whether there are more transactions to load.
  final bool hasMore;
}
