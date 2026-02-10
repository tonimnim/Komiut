/// Loyalty remote datasource.
///
/// Handles loyalty-related API calls.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../domain/entities/loyalty_points.dart';
import '../../domain/loyalty_rules.dart';
import '../models/loyalty_models.dart';

/// API endpoints for loyalty operations.
class LoyaltyEndpoints {
  const LoyaltyEndpoints._();

  /// Get current user's loyalty points.
  static const String myPoints = '/api/Loyalty/my';

  /// Get points history.
  static const String history = '/api/Loyalty/history';

  /// Redeem points.
  static const String redeem = '/api/Loyalty/redeem';
}

/// Provider for loyalty remote datasource.
final loyaltyRemoteDataSourceProvider =
    Provider<LoyaltyRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LoyaltyRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract loyalty remote datasource.
///
/// Defines the contract for loyalty-related API operations.
abstract class LoyaltyRemoteDataSource {
  /// Get the current user's loyalty points.
  Future<Either<Failure, LoyaltyPoints>> getLoyaltyPoints();

  /// Get points transaction history.
  ///
  /// [limit] - Number of transactions to fetch.
  /// [offset] - Offset for pagination.
  Future<Either<Failure, List<PointsTransaction>>> getPointsHistory({
    int limit = 20,
    int offset = 0,
  });

  /// Redeem points for a discount.
  ///
  /// [points] - Number of points to redeem.
  /// [bookingId] - Booking to apply the discount to.
  Future<Either<Failure, RedemptionResult>> redeemPoints({
    required int points,
    required String bookingId,
  });

  /// Calculate the redemption value for given points.
  ///
  /// This is a local calculation, no API call needed.
  double calculateRedemptionValue(int points);

  /// Calculate points that would be earned for an amount.
  ///
  /// [amount] - Amount in KES.
  /// [tier] - Current tier for bonus calculation.
  int calculatePointsEarned(double amount, {LoyaltyTier? tier});
}

/// Implementation of loyalty remote datasource.
class LoyaltyRemoteDataSourceImpl implements LoyaltyRemoteDataSource {
  /// Creates a loyalty remote datasource.
  LoyaltyRemoteDataSourceImpl({required this.apiClient});

  /// API client for making requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, LoyaltyPoints>> getLoyaltyPoints() async {
    final result = await apiClient.get<dynamic>(
      LoyaltyEndpoints.myPoints,
      fromJson: (data) => data,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          if (data is Map<String, dynamic>) {
            final model = LoyaltyPointsApiModel.fromJson(data);
            return Right(model.toEntity());
          }
          return const Left(ServerFailure('Invalid response format'));
        } catch (e) {
          return Left(ServerFailure('Failed to parse loyalty points: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<PointsTransaction>>> getPointsHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await apiClient.get<dynamic>(
      LoyaltyEndpoints.history,
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
      fromJson: (data) => data,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          List<PointsTransaction> transactions = [];

          if (data is List) {
            transactions = data
                .map((item) => PointsTransactionApiModel.fromJson(
                    item as Map<String, dynamic>))
                .map((model) => model.toEntity())
                .toList();
          } else if (data is Map<String, dynamic>) {
            final response = PointsHistoryResponse.fromJson(data);
            transactions =
                response.transactions.map((model) => model.toEntity()).toList();
          }

          return Right(transactions);
        } catch (e) {
          return Left(ServerFailure('Failed to parse points history: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, RedemptionResult>> redeemPoints({
    required int points,
    required String bookingId,
  }) async {
    // Validate redemption locally first
    final validationError = LoyaltyRules.validateRedemption(
      requestedPoints: points,
      availablePoints:
          points, // Will be validated on server with actual balance
    );

    if (validationError != null && points < LoyaltyRules.minimumRedemption) {
      return Left(ValidationFailure(validationError));
    }

    final request = RedeemPointsRequest(
      points: points,
      bookingId: bookingId,
    );

    final result = await apiClient.post<dynamic>(
      LoyaltyEndpoints.redeem,
      data: request.toJson(),
      fromJson: (data) => data,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          if (data is Map<String, dynamic>) {
            final redemptionResult = RedemptionResult.fromJson(data);
            return Right(redemptionResult);
          }
          // If server returns simple success, construct result
          return Right(RedemptionResult(
            success: true,
            pointsRedeemed: points,
            discountValue: calculateRedemptionValue(points),
            remainingPoints: 0, // Unknown, will be refreshed
            message: 'Points redeemed successfully',
          ));
        } catch (e) {
          return Left(ServerFailure('Failed to parse redemption result: $e'));
        }
      },
    );
  }

  @override
  double calculateRedemptionValue(int points) {
    return LoyaltyRules.calculateRedemptionValue(points);
  }

  @override
  int calculatePointsEarned(double amount, {LoyaltyTier? tier}) {
    return LoyaltyRules.calculatePointsEarned(amount, tier: tier);
  }
}
