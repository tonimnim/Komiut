/// Role provider for managing user roles.
///
/// Provides state management for the current user role,
/// enabling role-based navigation and feature access.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../domain/entities/user.dart';
import '../domain/enums/enums.dart';
import '../network/api_interceptors.dart';

/// App role enum for role-based routing.
/// This is a simplified version for navigation purposes.
enum AppRole {
  /// Passenger role - can book trips, view routes.
  passenger,

  /// Driver role - can manage trips, view earnings.
  driver,

  /// Tout role - can manage passengers, collect fares.
  tout,
}

/// Extension methods for AppRole.
extension AppRoleX on AppRole {
  /// Convert to UserRole enum.
  UserRole toUserRole() {
    switch (this) {
      case AppRole.passenger:
        return UserRole.passenger;
      case AppRole.driver:
        return UserRole.driver;
      case AppRole.tout:
        return UserRole.tout;
    }
  }

  /// Display label for UI.
  String get label {
    switch (this) {
      case AppRole.passenger:
        return 'Passenger';
      case AppRole.driver:
        return 'Driver';
      case AppRole.tout:
        return 'Tout';
    }
  }

  /// Home route for this role.
  String get homeRoute {
    switch (this) {
      case AppRole.passenger:
        return '/passenger/home';
      case AppRole.driver:
        return '/driver/home';
      case AppRole.tout:
        return '/driver/home'; // Touts use driver interface
    }
  }

  /// Whether this role uses the driver interface.
  bool get usesDriverInterface =>
      this == AppRole.driver || this == AppRole.tout;
}

/// Convert UserRole to AppRole.
AppRole appRoleFromUserRole(UserRole role) {
  switch (role) {
    case UserRole.passenger:
      return AppRole.passenger;
    case UserRole.driver:
      return AppRole.driver;
    case UserRole.tout:
      return AppRole.tout;
    case UserRole.admin:
      return AppRole.passenger; // Default to passenger for admin
  }
}

/// Provider for the current app role.
final currentRoleProvider = StateProvider<AppRole?>((ref) {
  return null;
});

/// Provider for the current user.
final currentUserProvider = StateProvider<User?>((ref) {
  return null;
});

/// Provider for checking if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Provider for checking if user is a passenger.
final isPassengerProvider = Provider<bool>((ref) {
  final role = ref.watch(currentRoleProvider);
  return role == AppRole.passenger;
});

/// Provider for checking if user is a driver or tout.
final isDriverOrToutProvider = Provider<bool>((ref) {
  final role = ref.watch(currentRoleProvider);
  return role == AppRole.driver || role == AppRole.tout;
});

/// Notifier for managing authentication state.
class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  /// Set the current user and role.
  Future<void> setUser(User user) async {
    final storage = ref.read(secureStorageProvider);

    // Store role in secure storage
    await storage.write(
      key: AppConfig.userRoleKey,
      value: user.role.name,
    );
    await storage.write(
      key: AppConfig.userIdKey,
      value: user.id,
    );

    // Update providers
    ref.read(currentUserProvider.notifier).state = user;
    ref.read(currentRoleProvider.notifier).state =
        appRoleFromUserRole(user.role);

    state = AuthState.authenticated(user: user);
  }

  /// Clear user and role (logout).
  Future<void> clearUser() async {
    final storage = ref.read(secureStorageProvider);

    // Clear stored values
    await storage.delete(key: AppConfig.accessTokenKey);
    await storage.delete(key: AppConfig.refreshTokenKey);
    await storage.delete(key: AppConfig.userRoleKey);
    await storage.delete(key: AppConfig.userIdKey);

    // Update providers
    ref.read(currentUserProvider.notifier).state = null;
    ref.read(currentRoleProvider.notifier).state = null;

    state = const AuthState.unauthenticated();
  }

  /// Restore session from stored credentials.
  Future<bool> restoreSession() async {
    final storage = ref.read(secureStorageProvider);

    final token = await storage.read(key: AppConfig.accessTokenKey);
    final roleStr = await storage.read(key: AppConfig.userRoleKey);
    final userId = await storage.read(key: AppConfig.userIdKey);

    if (token != null && roleStr != null && userId != null) {
      // Restore role for now, full user will be fetched later
      final role = userRoleFromString(roleStr);
      ref.read(currentRoleProvider.notifier).state = appRoleFromUserRole(role);
      return true;
    }

    return false;
  }
}

/// Provider for auth state notifier.
final authStateNotifierProvider =
    NotifierProvider<AuthStateNotifier, AuthState>(
  AuthStateNotifier.new,
);

/// Authentication state.
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.authenticated({required User user}) =
      AuthStateAuthenticated;
  const factory AuthState.loading() = AuthStateLoading;
}

/// Initial auth state (checking stored session).
class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

/// Unauthenticated state.
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// Authenticated state with user.
class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated({required this.user});
  final User user;
}

/// Loading state (during auth operations).
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}
