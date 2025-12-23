import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource _dataSource;

  PaymentRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPayments(int userId) async {
    try {
      final payments = await _dataSource.getPayments(userId);
      return Right(payments);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<List<PaymentEntity>> watchPayments(int userId) {
    return _dataSource.watchPayments(userId);
  }
}
