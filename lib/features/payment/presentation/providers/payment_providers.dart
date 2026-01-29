/// Payment feature providers.
///
/// Provides all payment-related state management and dependencies.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_providers.dart';
import '../../data/datasources/payment_local_datasource.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Filter options for payment list.
enum PaymentFilter { all, topUps, payments }

/// Provider for the current payment filter selection.
final paymentFilterProvider = StateProvider<PaymentFilter>((ref) {
  return PaymentFilter.all;
});

/// Provider for the payment local datasource.
final paymentLocalDataSourceProvider = Provider<PaymentLocalDataSource>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return PaymentLocalDataSourceImpl(database);
});

// Note: paymentRemoteDataSourceProvider is defined in payment_remote_datasource.dart
// and is imported above. We use it directly in paymentRepositoryProvider.

/// Provider for the payment repository.
///
/// Uses both local and remote datasources for hybrid functionality:
/// - Fetches from API when online
/// - Falls back to local database when offline
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final localDataSource = ref.watch(paymentLocalDataSourceProvider);
  final remoteDataSource = ref.watch(paymentRemoteDataSourceProvider);

  return PaymentRepositoryImpl.withRemote(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

/// Provider for the payment repository (local-only variant).
///
/// Use this when you want to bypass the remote API and use only local data.
final paymentRepositoryLocalOnlyProvider = Provider<PaymentRepository>((ref) {
  final dataSource = ref.watch(paymentLocalDataSourceProvider);
  return PaymentRepositoryImpl(dataSource);
});

/// Provider for fetching the user's payments.
///
/// Automatically fetches from API first, falls back to local on failure.
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

/// Provider for filtered payments based on the current filter.
final filteredPaymentsProvider = Provider<AsyncValue<List<PaymentEntity>>>((ref) {
  final paymentsAsync = ref.watch(paymentsProvider);
  final filter = ref.watch(paymentFilterProvider);

  return paymentsAsync.whenData((payments) {
    switch (filter) {
      case PaymentFilter.all:
        return payments;
      case PaymentFilter.topUps:
        return payments.where((p) => p.isTopUp).toList();
      case PaymentFilter.payments:
        return payments.where((p) => p.isTrip).toList();
    }
  });
});

/// Provider for watching payments stream (local database only).
///
/// Use this for real-time updates from the local database.
final paymentsStreamProvider = StreamProvider<List<PaymentEntity>>((ref) {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(paymentRepositoryProvider);

  if (authState.user == null) {
    return Stream.value([]);
  }

  return repository.watchPayments(authState.user!.id);
});

/// Provider for refreshing payments from the API.
///
/// Call this to force a refresh of payments data from the server.
final refreshPaymentsProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // Invalidate the payments provider to trigger a refresh
    ref.invalidate(paymentsProvider);
  };
});
