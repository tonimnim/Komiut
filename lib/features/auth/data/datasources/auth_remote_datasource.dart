/// Auth remote datasource.
///
/// Handles authentication API calls.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/user_model.dart';
import '../../../../core/domain/entities/user.dart';
import '../../../../core/domain/enums/enums.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_models.dart';

/// Provider for auth remote datasource.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract auth remote datasource.
abstract class AuthRemoteDataSource {
  /// Login with email and password.
  Future<Either<Failure, LoginResponseModel>> login({
    required String email,
    required String password,
  });

  /// Register a new user.
  Future<Either<Failure, RegisterResponseModel>> register({
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String userName,
  });

  /// Request password reset.
  Future<Either<Failure, ResetPasswordResponseModel>> resetPassword({
    required String phoneNumber,
  });

  /// Get user details by ID.
  Future<Either<Failure, User>> getUserById(String userId);

  /// Get current user details.
  Future<Either<Failure, User>> getCurrentUser();
}

/// Implementation of auth remote datasource.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Creates an auth remote datasource.
  AuthRemoteDataSourceImpl({required this.apiClient});

  /// API client for making requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequestModel(email: email, password: password);

    return apiClient.post<LoginResponseModel>(
      ApiEndpoints.login,
      data: request.toJson(),
      fromJson: (data) =>
          LoginResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, RegisterResponseModel>> register({
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String userName,
  }) async {
    final request = RegisterRequestModel(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
      userName: userName,
    );

    return apiClient.post<RegisterResponseModel>(
      ApiEndpoints.register,
      data: request.toJson(),
      fromJson: (data) =>
          RegisterResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, ResetPasswordResponseModel>> resetPassword({
    required String phoneNumber,
  }) async {
    final request = ResetPasswordRequestModel(phoneNumber: phoneNumber);

    return apiClient.post<ResetPasswordResponseModel>(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
      fromJson: (data) =>
          ResetPasswordResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, User>> getUserById(String userId) async {
    return apiClient.get<User>(
      ApiEndpoints.userById(userId),
      fromJson: (data) =>
          UserModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // This would typically call a /me endpoint
    // For now, return the users endpoint as placeholder
    return apiClient.get<User>(
      '${ApiEndpoints.users}/me',
      fromJson: (data) =>
          UserModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }
}

/// Helper to determine role from login response.
AppRole determineRoleFromResponse(LoginResponseModel response) {
  if (response.role != null) {
    switch (response.role!) {
      case UserRole.driver:
        return AppRole.driver;
      case UserRole.tout:
        return AppRole.tout;
      case UserRole.passenger:
      case UserRole.admin:
        return AppRole.passenger;
    }
  }
  // Default to passenger if role not specified
  return AppRole.passenger;
}

/// App role enum for quick reference.
enum AppRole {
  passenger,
  driver,
  tout,
}
