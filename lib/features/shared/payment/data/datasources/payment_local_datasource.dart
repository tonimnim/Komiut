import '../../../../../core/database/app_database.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/payment_model.dart';

abstract class PaymentLocalDataSource {
  Future<List<PaymentModel>> getPayments(int userId);
  Stream<List<PaymentModel>> watchPayments(int userId);
}

class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  final AppDatabase _database;

  PaymentLocalDataSourceImpl(this._database);

  @override
  Future<List<PaymentModel>> getPayments(int userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final payments = await _database.getPaymentsByUserId(userId);
      return payments.map((p) => PaymentModel.fromDatabase(p)).toList();
    } catch (e) {
      throw CacheException('Failed to get payments: $e');
    }
  }

  @override
  Stream<List<PaymentModel>> watchPayments(int userId) {
    return _database.watchPaymentsByUserId(userId).map(
          (payments) =>
              payments.map((p) => PaymentModel.fromDatabase(p)).toList(),
        );
  }
}
