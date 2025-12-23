import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_providers.dart';
import '../../data/datasources/payment_local_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

enum PaymentFilter { all, topUps, payments }

final paymentFilterProvider = StateProvider<PaymentFilter>((ref) {
  return PaymentFilter.all;
});

final paymentLocalDataSourceProvider = Provider<PaymentLocalDataSource>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return PaymentLocalDataSourceImpl(database);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dataSource = ref.watch(paymentLocalDataSourceProvider);
  return PaymentRepositoryImpl(dataSource);
});

final paymentsProvider = FutureProvider<List<PaymentEntity>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(paymentRepositoryProvider);

  if (authState.user == null) return [];

  final result = await repository.getPayments(authState.user!.id);
  return result.fold(
    (failure) => [],
    (payments) => payments,
  );
});
