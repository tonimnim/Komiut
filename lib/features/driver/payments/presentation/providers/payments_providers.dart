import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

final recentPaymentsProvider =
    FutureProvider.autoDispose<List<Payment>>((ref) async {
  final profile = await ref.watch(driverProfileProvider.future);

  if (!profile.hasVehicle) {
    return [];
  }

  final repository = ref.watch(paymentRepositoryProvider);
  final result = await repository.getPayments(
    vehicleId: profile.vehicleId,
    pageSize: 10,
  );

  return result.fold(
    (failure) => [],
    (payments) => payments,
  );
});
