import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentEntity>>> getPayments(int userId);
  Stream<List<PaymentEntity>> watchPayments(int userId);
}
