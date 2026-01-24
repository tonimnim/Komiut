/// Wallet remote datasource.
///
/// Handles wallet-related API calls including top-ups and transactions.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/wallet_entity.dart';
import '../models/wallet_api_model.dart';

/// Provider for wallet remote datasource.
final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract wallet remote datasource.
///
/// Defines the contract for wallet-related API operations.
abstract class WalletRemoteDataSource {
  /// Get current user's wallet.
  ///
  /// Fetches the wallet information from /api/Wallets/my endpoint.
  Future<Either<Failure, WalletEntity>> getWallet();

  /// Get wallet balance for a user.
  ///
  /// Fetches the wallet information from the user endpoint since wallet
  /// data is typically embedded in the user response.
  Future<Either<Failure, WalletEntity>> getWalletBalance(String userId);

  /// Get wallet by organization ID.
  ///
  /// Fetches wallet information associated with an organization.
  /// This is useful for SACCO/company wallet views.
  Future<Either<Failure, WalletEntity>> getWalletByOrganization(String orgId);

  /// Initiate wallet top-up.
  ///
  /// Starts M-Pesa STK push for wallet top-up.
  Future<Either<Failure, TopUpResponseModel>> topUp({
    required double amount,
    required String paymentMethod,
    required String phoneNumber,
  });

  /// Check top-up status.
  ///
  /// Polls the server to check if the top-up has been completed.
  Future<Either<Failure, TopUpStatusModel>> getTopUpStatus(String transactionId);

  /// Get wallet transactions.
  ///
  /// Fetches paginated list of wallet transactions.
  Future<Either<Failure, List<WalletTransaction>>> getTransactions({
    int limit = 20,
    int offset = 0,
    TransactionType? type,
  });
}

/// Implementation of wallet remote datasource.
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  /// Creates a wallet remote datasource.
  WalletRemoteDataSourceImpl({required this.apiClient});

  /// API client for making requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, WalletEntity>> getWallet() async {
    final result = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.walletMy,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          final walletModel = WalletApiModel.fromJson(data);
          return Right(walletModel.toEntity());
        } catch (e) {
          return Left(ServerFailure('Failed to parse wallet: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, WalletEntity>> getWalletBalance(String userId) async {
    // Try to get wallet from user endpoint first (wallet may be embedded)
    final userResult = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.userById(userId),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return userResult.fold(
      (failure) => Left(failure),
      (userData) {
        // Check if wallet data is embedded in user response
        if (userData.containsKey('wallet')) {
          final walletData = userData['wallet'] as Map<String, dynamic>;
          final walletModel = WalletApiModel.fromJson(walletData);
          return Right(walletModel.toEntity());
        }

        // Check if balance fields are directly on user
        if (userData.containsKey('balance')) {
          final walletModel = WalletApiModel.fromUserJson(userData);
          return Right(walletModel.toEntity());
        }

        // Return default wallet if no wallet data found
        return Right(WalletEntity(
          id: 0,
          userId: int.tryParse(userId) ?? 0,
          balance: 0.0,
          points: 0,
          currency: 'KES',
        ));
      },
    );
  }

  @override
  Future<Either<Failure, WalletEntity>> getWalletByOrganization(
      String orgId) async {
    // Try daily vehicle totals endpoint which might contain org wallet info
    final result = await apiClient.get<Map<String, dynamic>>(
      '${ApiEndpoints.dailyVehicleTotals}?organizationId=$orgId',
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        // Check if this returns aggregated totals that can be used as wallet
        if (data.containsKey('totalCollected')) {
          return Right(WalletEntity(
            id: 0,
            userId: 0,
            balance: (data['totalCollected'] as num?)?.toDouble() ?? 0.0,
            points: 0,
            currency: data['currency'] as String? ?? 'KES',
          ));
        }

        // Try to extract from items if paginated
        if (data.containsKey('items') && (data['items'] as List).isNotEmpty) {
          final items = data['items'] as List;
          double totalBalance = 0.0;
          String currency = 'KES';

          for (final item in items) {
            if (item is Map<String, dynamic>) {
              totalBalance +=
                  (item['totalCollected'] as num?)?.toDouble() ?? 0.0;
              currency = item['currency'] as String? ?? currency;
            }
          }

          return Right(WalletEntity(
            id: 0,
            userId: 0,
            balance: totalBalance,
            points: 0,
            currency: currency,
          ));
        }

        return const Left(
            ServerFailure('Organization wallet data not available'));
      },
    );
  }

  @override
  Future<Either<Failure, TopUpResponseModel>> topUp({
    required double amount,
    required String paymentMethod,
    required String phoneNumber,
  }) async {
    final request = TopUpRequestModel(
      amount: amount,
      paymentMethod: paymentMethod,
      phoneNumber: phoneNumber,
    );

    final result = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.walletTopUp,
      data: request.toJson(),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          return Right(TopUpResponseModel.fromJson(data));
        } catch (e) {
          return Left(ServerFailure('Failed to parse top-up response: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, TopUpStatusModel>> getTopUpStatus(
      String transactionId) async {
    final result = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.walletTopUpStatus(transactionId),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          return Right(TopUpStatusModel.fromJson(data));
        } catch (e) {
          return Left(ServerFailure('Failed to parse top-up status: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<WalletTransaction>>> getTransactions({
    int limit = 20,
    int offset = 0,
    TransactionType? type,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };

    if (type != null) {
      queryParams['type'] = type.name;
    }

    final result = await apiClient.get<dynamic>(
      ApiEndpoints.walletTransactions,
      queryParameters: queryParams,
      fromJson: (data) => data,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          List<WalletTransaction> transactions = [];

          if (data is List) {
            transactions = data
                .map((item) => WalletTransactionApiModel.fromJson(
                        item as Map<String, dynamic>)
                    .toEntity())
                .toList();
          } else if (data is Map<String, dynamic>) {
            // Handle paginated response
            final items = data['items'] as List? ?? data['data'] as List? ?? [];
            transactions = items
                .map((item) => WalletTransactionApiModel.fromJson(
                        item as Map<String, dynamic>)
                    .toEntity())
                .toList();
          }

          return Right(transactions);
        } catch (e) {
          return Left(ServerFailure('Failed to parse transactions: $e'));
        }
      },
    );
  }
}
