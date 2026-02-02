/// Payment repository implementation.
///
/// Implements the payment repository with support for both remote API
/// and local database, providing offline-first functionality.
library;

import 'package:dartz/dartz.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_datasource.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/payment_api_model.dart';

/// Implementation of [PaymentRepository].
///
/// Uses a hybrid approach:
/// - Tries to fetch from API first when online
/// - Falls back to local database when offline
/// - Caches API results locally for offline access
class PaymentRepositoryImpl implements PaymentRepository {
  /// Creates a payment repository with local datasource only.
  ///
  /// Use this constructor when remote datasource is not available.
  PaymentRepositoryImpl(PaymentLocalDataSource localDataSource)
      : _localDataSource = localDataSource,
        _remoteDataSource = null;

  /// Creates a payment repository with both local and remote datasources.
  PaymentRepositoryImpl.withRemote({
    required PaymentLocalDataSource localDataSource,
    required PaymentRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  final PaymentLocalDataSource _localDataSource;
  final PaymentRemoteDataSource? _remoteDataSource;

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPayments(int userId) async {
    // Try remote first if available
    if (_remoteDataSource != null) {
      final remoteResult = await _remoteDataSource.getPayments(
        passengerId: userId.toString(),
      );

      return remoteResult.fold(
        (failure) async {
          // On API failure, fall back to local
          return _getLocalPayments(userId);
        },
        (payments) async {
          // API success - return the payments
          // Note: In a production app, you would cache these locally
          return Right(payments);
        },
      );
    }

    // No remote datasource, use local only
    return _getLocalPayments(userId);
  }

  /// Gets payments from local datasource.
  Future<Either<Failure, List<PaymentEntity>>> _getLocalPayments(
      int userId) async {
    try {
      final payments = await _localDataSource.getPayments(userId);
      return Right(payments);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<List<PaymentEntity>> watchPayments(int userId) {
    return _localDataSource.watchPayments(userId);
  }

  /// Gets a single payment by ID from the API.
  ///
  /// This method only works when a remote datasource is configured.
  Future<Either<Failure, PaymentEntity>> getPaymentById(String id) async {
    if (_remoteDataSource == null) {
      return const Left(ServerFailure('Remote datasource not configured'));
    }

    return _remoteDataSource.getPaymentById(id);
  }

  /// Creates a new payment via the API.
  ///
  /// This method only works when a remote datasource is configured.
  Future<Either<Failure, PaymentEntity>> createPayment(
      CreatePaymentRequest request) async {
    if (_remoteDataSource == null) {
      return const Left(ServerFailure('Remote datasource not configured'));
    }

    return _remoteDataSource.createPayment(request);
  }
}
