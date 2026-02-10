import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/payment.dart';
import '../models/payment_model.dart';

final paymentsRemoteDataSourceProvider =
    Provider<PaymentsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentsRemoteDataSourceImpl(apiClient: apiClient);
});

abstract class PaymentsRemoteDataSource {
  Future<Either<Failure, List<Payment>>> getPayments({
    String? vehicleId,
    int? pageNumber,
    int? pageSize,
  });
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  PaymentsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<Payment>>> getPayments({
    String? vehicleId,
    int? pageNumber,
    int? pageSize,
  }) async {
    return apiClient.get<List<Payment>>(
      ApiEndpoints.payments,
      queryParameters: {
        if (vehicleId != null) 'VehicleId': vehicleId,
        if (pageNumber != null) 'PageNumber': pageNumber.toString(),
        if (pageSize != null) 'PageSize': pageSize.toString(),
      },
      fromJson: (data) {
        if (data is! List) return <Payment>[];
        return data
            .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
