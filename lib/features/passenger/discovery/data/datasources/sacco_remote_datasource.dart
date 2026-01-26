/// Sacco remote datasource.
///
/// Handles Sacco (Organization) API calls for passenger discovery.
/// Fetches transport organizations from the backend API.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/sacco.dart';
import '../models/sacco_model.dart';

/// Provider for Sacco remote datasource.
final saccoRemoteDataSourceProvider = Provider<SaccoRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SaccoRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract Sacco remote datasource interface.
///
/// Defines the contract for fetching Sacco data from the remote API.
/// All methods return `Either<Failure, T>` for consistent error handling.
abstract class SaccoRemoteDataSource {
  /// Fetches all Saccos (Organizations) from the API.
  ///
  /// Returns a list of [Sacco] entities on success,
  /// or a [Failure] on error.
  Future<Either<Failure, List<Sacco>>> getSaccos();

  /// Fetches a single Sacco by its ID.
  ///
  /// [id] - The unique identifier of the Sacco.
  /// Returns the [Sacco] entity on success,
  /// or a [Failure] on error.
  Future<Either<Failure, Sacco>> getSaccoById(String id);

  /// Fetches all Saccos that operate on a specific route.
  ///
  /// [routeId] - The unique identifier of the route.
  /// Returns a list of [Sacco] entities that operate on the route,
  /// or a [Failure] on error.
  Future<Either<Failure, List<Sacco>>> getSaccosByRoute(String routeId);

  /// Searches Saccos by name or description.
  ///
  /// [query] - The search query string.
  /// Returns a list of [Sacco] entities matching the query,
  /// or a [Failure] on error.
  Future<Either<Failure, List<Sacco>>> searchSaccos(String query);
}

/// Implementation of [SaccoRemoteDataSource].
///
/// Uses [ApiClient] to make HTTP requests to the Organizations API endpoints.
class SaccoRemoteDataSourceImpl implements SaccoRemoteDataSource {
  /// Creates a Sacco remote datasource with the given API client.
  SaccoRemoteDataSourceImpl({required this.apiClient});

  /// API client for making HTTP requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<Sacco>>> getSaccos() async {
    return apiClient.get<List<Sacco>>(
      ApiEndpoints.organizations,
      fromJson: (data) => _parseListResponse(data),
    );
  }

  @override
  Future<Either<Failure, Sacco>> getSaccoById(String id) async {
    return apiClient.get<Sacco>(
      ApiEndpoints.organizationById(id),
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return SaccoModel.fromJson(data).toEntity();
        }
        throw const FormatException('Invalid response format');
      },
    );
  }

  @override
  Future<Either<Failure, List<Sacco>>> getSaccosByRoute(String routeId) async {
    return apiClient.get<List<Sacco>>(
      ApiEndpoints.organizations,
      queryParameters: {'routeId': routeId},
      fromJson: (data) => _parseListResponse(data),
    );
  }

  @override
  Future<Either<Failure, List<Sacco>>> searchSaccos(String query) async {
    return apiClient.get<List<Sacco>>(
      ApiEndpoints.organizations,
      queryParameters: {'search': query},
      fromJson: (data) => _parseListResponse(data),
    );
  }

  /// Parses a list response from the API.
  ///
  /// Handles both direct list responses and wrapped responses.
  List<Sacco> _parseListResponse(dynamic data) {
    if (data is List) {
      return data
          .map((json) => SaccoModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    }

    // Handle wrapped response (e.g., { "data": [...], "total": 10 })
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List)
          .map((json) => SaccoModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    }

    return <Sacco>[];
  }
}
