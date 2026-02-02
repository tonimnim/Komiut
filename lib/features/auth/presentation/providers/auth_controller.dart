/// Unified Auth Controller.
///
/// Single source of truth for authentication state management.
/// Handles login, registration, logout, and session restoration.
/// Optimized for performance with minimal rebuilds.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/domain/entities/user.dart';
import '../../../../core/domain/enums/enums.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/models/auth_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth State (Sealed Class Pattern)
// ─────────────────────────────────────────────────────────────────────────────

/// Authentication state - sealed for exhaustive pattern matching.
sealed class AuthState {
  const AuthState();
}

/// Initial state - checking stored session.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - auth operation in progress.
final class AuthLoading extends AuthState {
  const AuthLoading({this.message});
  final String? message;
}

/// Authenticated state - user is logged in.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.user,
    required this.role,
    required this.token,
  });

  final User user;
  final AppRole role;
  final String token;
}

/// Unauthenticated state - no user logged in.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state - auth operation failed.
final class AuthError extends AuthState {
  const AuthError({required this.message, this.failure});

  final String message;
  final Failure? failure;
}

// ─────────────────────────────────────────────────────────────────────────────
// App Role (for navigation)
// ─────────────────────────────────────────────────────────────────────────────

/// App role enum for role-based routing.
enum AppRole {
  passenger,
  driver,
  tout;

  /// Convert from API UserRole.
  static AppRole fromUserRole(UserRole role) {
    return switch (role) {
      UserRole.passenger => AppRole.passenger,
      UserRole.driver => AppRole.driver,
      UserRole.tout => AppRole.tout,
      UserRole.admin => AppRole.passenger, // Admin uses passenger interface
    };
  }

  /// Home route for this role.
  String get homeRoute => switch (this) {
        AppRole.passenger => '/passenger/home',
        AppRole.driver => '/driver/home',
        AppRole.tout => '/driver/home', // Touts use driver interface
      };

  /// Display label.
  String get label => switch (this) {
        AppRole.passenger => 'Passenger',
        AppRole.driver => 'Driver',
        AppRole.tout => 'Tout',
      };

  /// Whether this role uses the driver interface.
  bool get usesDriverInterface =>
      this == AppRole.driver || this == AppRole.tout;
}

// ─────────────────────────────────────────────────────────────────────────────
// Secure Storage Provider
// ─────────────────────────────────────────────────────────────────────────────

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Auth Controller
// ─────────────────────────────────────────────────────────────────────────────

/// Main auth controller provider.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

/// Auth controller - manages all authentication logic.
class AuthController extends AsyncNotifier<AuthState> {
  late final FlutterSecureStorage _storage;
  late final ApiClient _apiClient;
  late final UserRemoteDataSource _userRemoteDataSource;

  @override
  Future<AuthState> build() async {
    _storage = ref.watch(secureStorageProvider);
    _apiClient = ref.watch(apiClientProvider);
    _userRemoteDataSource = ref.watch(userRemoteDataSourceProvider);

    // Try to restore session on startup
    return _restoreSession();
  }

  /// Restore session from stored credentials.
  ///
  /// This method attempts to restore the user session by:
  /// 1. Reading stored credentials (token, role, userId) from secure storage
  /// 2. Attempting to fetch fresh user data from the API
  /// 3. If API fails but we have stored data, using stored data (offline support)
  /// 4. If both fail, logging out the user
  Future<AuthState> _restoreSession() async {
    try {
      final token = await _storage.read(key: AppConfig.accessTokenKey);
      final roleStr = await _storage.read(key: AppConfig.userRoleKey);
      final userId = await _storage.read(key: AppConfig.userIdKey);

      if (token == null || roleStr == null || userId == null) {
        return const AuthUnauthenticated();
      }

      // Parse stored role
      final role = AppRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => AppRole.passenger,
      );

      // Try to fetch fresh user data from API
      final freshUserResult = await _userRemoteDataSource.getUserById(userId);

      return await freshUserResult.fold(
        (failure) async {
          // API failed - try to use stored data (offline support)
          final email = await _storage.read(key: 'user_email');
          final fullName = await _storage.read(key: 'user_name');
          final phone = await _storage.read(key: 'user_phone');
          final organizationId =
              await _storage.read(key: 'user_organization_id');
          final profileImage = await _storage.read(key: 'user_profile_image');

          // If we have minimum required stored data, use it
          if (email != null && email.isNotEmpty) {
            final user = User(
              id: userId,
              email: email,
              phone: phone,
              role: _appRoleToUserRole(role),
              organizationId: organizationId,
              status: UserStatus.active,
              fullName: fullName ?? 'User',
              profileImage: profileImage,
            );

            return AuthAuthenticated(user: user, role: role, token: token);
          }

          // Both API and stored data failed - logout user
          await _clearStorage();
          return const AuthUnauthenticated();
        },
        (user) async {
          // API succeeded - update stored user info
          await _storeUserInfo(user);

          // Determine app role from fresh user data
          final freshRole = AppRole.fromUserRole(user.role);

          // Update stored role if it changed
          if (freshRole.name != roleStr) {
            await _storage.write(
                key: AppConfig.userRoleKey, value: freshRole.name);
          }

          return AuthAuthenticated(user: user, role: freshRole, token: token);
        },
      );
    } catch (e) {
      // Clear corrupted data
      await _clearStorage();
      return const AuthUnauthenticated();
    }
  }

  /// Convert AppRole to UserRole.
  UserRole _appRoleToUserRole(AppRole role) {
    return switch (role) {
      AppRole.passenger => UserRole.passenger,
      AppRole.driver => UserRole.driver,
      AppRole.tout => UserRole.tout,
    };
  }

  /// Store user information in secure storage.
  Future<void> _storeUserInfo(User user) async {
    await _storage.write(key: AppConfig.userIdKey, value: user.id);
    await _storage.write(key: 'user_email', value: user.email);
    if (user.fullName != null) {
      await _storage.write(key: 'user_name', value: user.fullName!);
    }
    if (user.phone != null) {
      await _storage.write(key: 'user_phone', value: user.phone!);
    }
    if (user.organizationId != null) {
      await _storage.write(
          key: 'user_organization_id', value: user.organizationId!);
    }
    if (user.profileImage != null) {
      await _storage.write(
          key: 'user_profile_image', value: user.profileImage!);
    }
  }

  /// Fetches the current user's profile from the API.
  ///
  /// This method makes a GET request to fetch the latest user data
  /// and updates both the state and secure storage with fresh data.
  ///
  /// Use this method when you need to refresh the user's profile,
  /// for example after a profile update or when returning from
  /// background.
  ///
  /// If the fetch fails, the current state is preserved and the
  /// error is logged but not thrown.
  ///
  /// Returns `true` if the fetch was successful, `false` otherwise.
  Future<bool> fetchCurrentUser() async {
    final currentState = state.valueOrNull;

    // Can only fetch if authenticated
    if (currentState is! AuthAuthenticated) {
      return false;
    }

    final userId = currentState.user.id;
    final token = currentState.token;

    // Try to fetch from API
    final result = await _userRemoteDataSource.getUserById(userId);

    return await result.fold(
      (failure) async {
        // Fetch failed - keep current state but return false
        return false;
      },
      (user) async {
        // Update stored user info
        await _storeUserInfo(user);

        // Determine role from fresh user data
        final freshRole = AppRole.fromUserRole(user.role);

        // Update stored role
        await _storage.write(key: AppConfig.userRoleKey, value: freshRole.name);

        // Update state with fresh user data
        state = AsyncData(AuthAuthenticated(
          user: user,
          role: freshRole,
          token: token,
        ));

        return true;
      },
    );
  }

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncData(AuthLoading(message: 'Signing in...'));

    final result = await _apiClient.post<LoginResponseModel>(
      ApiEndpoints.login,
      data: LoginRequestModel(email: email, password: password).toJson(),
      fromJson: (data) =>
          LoginResponseModel.fromJson(data as Map<String, dynamic>),
    );

    state = await result.fold(
      (failure) async => AsyncData(AuthError(
        message: _getErrorMessage(failure),
        failure: failure,
      )),
      (response) async {
        // Store tokens
        await _storage.write(
            key: AppConfig.accessTokenKey, value: response.accessToken);
        if (response.refreshToken != null) {
          await _storage.write(
              key: AppConfig.refreshTokenKey, value: response.refreshToken);
        }

        // Determine role from response
        final userRole = response.role ?? UserRole.passenger;
        final appRole = AppRole.fromUserRole(userRole);

        // Store role and user info for session restoration
        await _storage.write(key: AppConfig.userRoleKey, value: appRole.name);
        await _storage.write(
            key: AppConfig.userIdKey, value: response.userId ?? '');
        await _storage.write(key: 'user_email', value: response.email ?? email);
        await _storage.write(key: 'user_name', value: response.fullName ?? '');

        // Create user object
        final user = User(
          id: response.userId ?? '',
          email: response.email ?? email,
          role: userRole,
          status: UserStatus.active,
          fullName: response.fullName,
          organizationId: response.organizationId,
        );

        return AsyncData(AuthAuthenticated(
          user: user,
          role: appRole,
          token: response.accessToken,
        ));
      },
    );
  }

  /// Register a new passenger account.
  /// Note: Drivers are added manually from backend, they only login.
  Future<void> register({
    required String email,
    required String phoneNumber,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncData(AuthLoading(message: 'Creating account...'));

    final result = await _apiClient.post<RegisterResponseModel>(
      ApiEndpoints.register,
      data: RegisterRequestModel(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: password,
        userName: fullName,
      ).toJson(),
      fromJson: (data) =>
          RegisterResponseModel.fromJson(data as Map<String, dynamic>),
    );

    final registerResult = await result.fold(
      (failure) async => AsyncData<AuthState>(AuthError(
        message: _getErrorMessage(failure),
        failure: failure,
      )),
      (response) async {
        if (response.success) {
          // Auto-login after successful registration
          await login(email: email, password: password);
          return state; // Return current state after login
        } else {
          return AsyncData<AuthState>(AuthError(
            message: response.message ?? 'Registration failed',
          ));
        }
      },
    );

    if (registerResult != state) {
      state = registerResult;
    }
  }

  /// Request password reset.
  Future<bool> resetPassword({required String phoneNumber}) async {
    state = const AsyncData(AuthLoading(message: 'Sending reset code...'));

    final result = await _apiClient.post<ResetPasswordResponseModel>(
      ApiEndpoints.resetPassword,
      data: ResetPasswordRequestModel(phoneNumber: phoneNumber).toJson(),
      fromJson: (data) =>
          ResetPasswordResponseModel.fromJson(data as Map<String, dynamic>),
    );

    return result.fold(
      (failure) {
        state = AsyncData(AuthError(
          message: _getErrorMessage(failure),
          failure: failure,
        ));
        return false;
      },
      (response) {
        state = const AsyncData(AuthUnauthenticated());
        return response.success;
      },
    );
  }

  /// Logout current user.
  Future<void> logout() async {
    await _clearStorage();
    state = const AsyncData(AuthUnauthenticated());
  }

  /// Clear all stored auth data.
  Future<void> _clearStorage() async {
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userRoleKey);
    await _storage.delete(key: AppConfig.userIdKey);
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_phone');
    await _storage.delete(key: 'user_organization_id');
    await _storage.delete(key: 'user_profile_image');
  }

  /// Get user-friendly error message.
  String _getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network.';
    }
    if (failure is ServerFailure) {
      if (failure.statusCode == 401) {
        return 'Invalid email or password.';
      }
      if (failure.statusCode == 404) {
        return 'Account not found.';
      }
      if (failure.statusCode == 500) {
        return 'Server error. Please try again later.';
      }
    }
    if (failure is AuthenticationFailure) {
      return failure.message;
    }
    return failure.message.isNotEmpty ? failure.message : 'An error occurred.';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Derived Providers (Performance Optimized)
// Use these instead of watching full authControllerProvider to minimize rebuilds
// ─────────────────────────────────────────────────────────────────────────────

/// Whether user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider).valueOrNull;
  return authState is AuthAuthenticated;
});

/// Current user (null if not authenticated).
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authControllerProvider).valueOrNull;
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});

/// Current role (null if not authenticated).
final currentRoleProvider = Provider<AppRole?>((ref) {
  final authState = ref.watch(authControllerProvider).valueOrNull;
  if (authState is AuthAuthenticated) {
    return authState.role;
  }
  return null;
});

/// Whether current user is a passenger.
final isPassengerProvider = Provider<bool>((ref) {
  final role = ref.watch(currentRoleProvider);
  return role == AppRole.passenger;
});

/// Whether current user is a driver or tout.
final isDriverOrToutProvider = Provider<bool>((ref) {
  final role = ref.watch(currentRoleProvider);
  return role?.usesDriverInterface ?? false;
});

/// Whether auth is currently loading.
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.isLoading || authState.valueOrNull is AuthLoading;
});

/// Current auth error message (null if no error).
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authControllerProvider).valueOrNull;
  if (authState is AuthError) {
    return authState.message;
  }
  return null;
});

/// Whether auth has been initialized (session check complete).
final isAuthInitializedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  // Not initialized if still loading or in initial state
  if (authState.isLoading) return false;
  final value = authState.valueOrNull;
  return value != null && value is! AuthInitial;
});
