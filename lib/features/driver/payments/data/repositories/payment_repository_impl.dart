import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../datasources/payments_remote_datasource.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final remoteDataSource = ref.watch(paymentsRemoteDataSourceProvider);
  return PaymentRepositoryImpl(remoteDataSource: remoteDataSource);
});

abstract class PaymentRepository {
  Future<Either<Failure, List<Payment>>> getPayments({
    String? vehicleId,
    int pageNumber = 1,
    int pageSize = 20,
  });
}

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({required this.remoteDataSource});

  final PaymentsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Payment>>> getPayments({
    String? vehicleId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return remoteDataSource.getPayments(
      vehicleId: vehicleId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
