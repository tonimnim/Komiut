/// Payment remote datasource.
///
/// Handles payment-related API calls.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_response.dart';
import '../../domain/entities/payment_entity.dart';
import '../models/payment_api_model.dart';

/// Provider for payment remote datasource.
final paymentRemoteDataSourceProvider =
    Provider<PaymentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract payment remote datasource.
///
/// Defines the contract for payment-related API operations.
abstract class PaymentRemoteDataSource {
  /// Get payments with optional filters.
  ///
  /// Supports filtering by:
  /// - [passengerId]: Filter payments by passenger
  /// - [vehicleId]: Filter payments by vehicle
  /// - [status]: Filter by payment status
  /// - [pageNumber]: Page number for pagination
  /// - [pageSize]: Number of items per page
  Future<Either<Failure, List<PaymentEntity>>> getPayments({
    String? passengerId,
    String? vehicleId,
    String? status,
    int? pageNumber,
    int? pageSize,
  });

  /// Get paginated payments response.
  ///
  /// Returns full pagination info including total count.
  Future<Either<Failure, PaginatedResponse<PaymentEntity>>>
      getPaymentsPaginated({
    String? passengerId,
    String? vehicleId,
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Get a payment by ID.
  Future<Either<Failure, PaymentEntity>> getPaymentById(String id);

  /// Create a new payment.
  Future<Either<Failure, PaymentEntity>> createPayment(
      CreatePaymentRequest request);
}

/// Implementation of payment remote datasource.
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  /// Creates a payment remote datasource.
  PaymentRemoteDataSourceImpl({required this.apiClient});

  /// API client for making requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPayments({
    String? passengerId,
    String? vehicleId,
    String? status,
    int? pageNumber,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};

    if (passengerId != null) queryParams['passengerId'] = passengerId;
    if (vehicleId != null) queryParams['vehicleId'] = vehicleId;
    if (status != null) queryParams['status'] = status;
    if (pageNumber != null) queryParams['pageNumber'] = pageNumber;
    if (pageSize != null) queryParams['pageSize'] = pageSize;

    final result = await apiClient.get<dynamic>(
      ApiEndpoints.payments,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => data,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          List<PaymentEntity> payments = [];

          if (data is List) {
            // Direct list response
            payments = data
                .map((item) =>
                    PaymentApiModel.fromJson(item as Map<String, dynamic>)
                        .toEntity())
                .toList();
          } else if (data is Map<String, dynamic>) {
            // Paginated response
            if (data.containsKey('items')) {
              final items = data['items'] as List;
              payments = items
                  .map((item) =>
                      PaymentApiModel.fromJson(item as Map<String, dynamic>)
                          .toEntity())
                  .toList();
            } else if (data.containsKey('data')) {
              final items = data['data'] as List;
              payments = items
                  .map((item) =>
                      PaymentApiModel.fromJson(item as Map<String, dynamic>)
                          .toEntity())
                  .toList();
            }
          }

          return Right(payments);
        } catch (e) {
          return Left(ServerFailure('Failed to parse payments: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, PaginatedResponse<PaymentEntity>>>
      getPaymentsPaginated({
    String? passengerId,
    String? vehicleId,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{};

    if (passengerId != null) queryParams['passengerId'] = passengerId;
    if (vehicleId != null) queryParams['vehicleId'] = vehicleId;
    if (status != null) queryParams['status'] = status;

    return apiClient.getPaginated<PaymentEntity>(
      ApiEndpoints.payments,
      page: page,
      pageSize: pageSize,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) => PaymentApiModel.fromJson(json).toEntity(),
    );
  }

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentById(String id) async {
    return apiClient.get<PaymentEntity>(
      ApiEndpoints.paymentById(id),
      fromJson: (data) =>
          PaymentApiModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }

  @override
  Future<Either<Failure, PaymentEntity>> createPayment(
      CreatePaymentRequest request) async {
    return apiClient.post<PaymentEntity>(
      ApiEndpoints.payments,
      data: request.toJson(),
      fromJson: (data) =>
          PaymentApiModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }
}
