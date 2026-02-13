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

  /// Get loyalty points (single GET endpoint per Swagger).
  static const String myPoints = '/api/LoyaltyPoints';
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

  /// Unwraps the backend's {"message": {...}} envelope for single objects.
  Map<String, dynamic> _unwrapMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['message'];
      if (inner is Map<String, dynamic>) return inner;
      return data;
    }
    return {};
  }



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
          final json = _unwrapMessage(data);
          if (json.isNotEmpty) {
            final model = LoyaltyPointsApiModel.fromJson(json);
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
    // Not available in current API - return empty list
    return const Right([]);
  }

  @override
  Future<Either<Failure, RedemptionResult>> redeemPoints({
    required int points,
    required String bookingId,
  }) async {
    // Not available in current API
    return const Left(ServerFailure('Redemption not yet supported'));
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
