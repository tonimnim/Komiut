/// User remote datasource.
///
/// Handles user-related API calls for fetching and updating user profiles.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/user_model.dart';
import '../../../../core/domain/entities/user.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// Provider for user remote datasource.
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract user remote datasource.
///
/// Defines the contract for user-related API operations.
abstract class UserRemoteDataSource {
  /// Fetches the current authenticated user's profile.
  ///
  /// Makes a GET request to `/api/Users/me` or falls back to
  /// fetching by user ID if the /me endpoint is not available.
  ///
  /// Returns [Either<Failure, User>] with the user data on success,
  /// or a [Failure] on error.
  Future<Either<Failure, User>> getCurrentUser();

  /// Fetches a user by their unique identifier.
  ///
  /// Makes a GET request to `/api/Users/{userId}`.
  ///
  /// [userId] - The unique identifier of the user to fetch.
  ///
  /// Returns [Either<Failure, User>] with the user data on success,
  /// or a [Failure] on error.
  Future<Either<Failure, User>> getUserById(String userId);

  /// Updates a user's profile information.
  ///
  /// Makes a PUT request to `/api/Users/{userId}` with the provided data.
  ///
  /// [userId] - The unique identifier of the user to update.
  /// [data] - A map containing the fields to update.
  ///
  /// Supported fields include:
  /// - fullName: String
  /// - phone: String
  /// - profileImage: String (URL)
  ///
  /// Returns [Either<Failure, User>] with the updated user data on success,
  /// or a [Failure] on error.
  Future<Either<Failure, User>> updateUser(
    String userId,
    Map<String, dynamic> data,
  );
}

/// Implementation of user remote datasource.
///
/// Uses [ApiClient] for making HTTP requests and [UserModel] for
/// parsing API responses.
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  /// Creates a user remote datasource with the given API client.
  UserRemoteDataSourceImpl({required this.apiClient});

  /// API client for making HTTP requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // Try /me endpoint first
    final result = await apiClient.get<User>(
      '${ApiEndpoints.users}/me',
      fromJson: (data) =>
          UserModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );

    return result;
  }

  @override
  Future<Either<Failure, User>> getUserById(String userId) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    return apiClient.get<User>(
      ApiEndpoints.userById(userId),
      fromJson: (data) =>
          UserModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }

  @override
  Future<Either<Failure, User>> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    if (data.isEmpty) {
      return const Left(ValidationFailure('Update data cannot be empty'));
    }

    return apiClient.put<User>(
      ApiEndpoints.userById(userId),
      data: data,
      fromJson: (data) =>
          UserModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }
}
