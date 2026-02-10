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
    int pageNumber = 1,
    int pageSize = 20,
  });
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  PaymentsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  List<dynamic> _extractItems(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final inner = data['message'];
      if (inner is Map<String, dynamic> && inner['items'] is List) {
        return inner['items'] as List;
      }
      if (data['items'] is List) {
        return data['items'] as List;
      }
    }
    return [];
  }

  @override
  Future<Either<Failure, List<Payment>>> getPayments({
    String? vehicleId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return apiClient.get<List<Payment>>(
      ApiEndpoints.payments,
      queryParameters: {
        if (vehicleId != null) 'VehicleId': vehicleId,
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      },
      fromJson: (data) {
        final items = _extractItems(data);
        return items
            .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
