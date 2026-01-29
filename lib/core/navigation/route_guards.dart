/// Route guards for role-based navigation.
///
/// Provides guards to restrict access to routes based on
/// authentication status and user roles.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/route_constants.dart';
import '../providers/role_provider.dart';

/// Redirect function for authentication guard.
///
/// Redirects unauthenticated users to login page.
String? authGuardRedirect(BuildContext context, GoRouterState state, WidgetRef ref) {
  final isAuthenticated = ref.read(isAuthenticatedProvider);
  final isAuthRoute = _isAuthRoute(state.matchedLocation);
  final isSplash = state.matchedLocation == RouteConstants.splash;

  // Allow splash screen always
  if (isSplash) return null;

  // If not authenticated and trying to access protected route
  if (!isAuthenticated && !isAuthRoute) {
    return RouteConstants.login;
  }

  // If authenticated and trying to access auth route
  if (isAuthenticated && isAuthRoute) {
    final role = ref.read(currentRoleProvider);
    return role?.homeRoute ?? RouteConstants.home;
  }

  return null;
}

/// Check if route is an auth route (login, signup, etc.).
bool _isAuthRoute(String path) {
  return path == RouteConstants.login ||
      path == RouteConstants.signUp ||
      path == RouteConstants.forgotPassword ||
      path == RouteConstants.twoFactor;
}

/// Guard that only allows passengers.
///
/// Redirects non-passengers to appropriate home.
class PassengerGuard {
  const PassengerGuard._();

  /// Check if user can access passenger routes.
  static String? redirect(BuildContext context, GoRouterState state, WidgetRef ref) {
    final role = ref.read(currentRoleProvider);

    if (role == null) {
      return RouteConstants.login;
    }

    if (role != AppRole.passenger) {
      return role.homeRoute;
    }

    return null;
  }
}

/// Guard that only allows drivers and touts.
///
/// Redirects non-drivers to appropriate home.
class DriverGuard {
  const DriverGuard._();

  /// Check if user can access driver routes.
  static String? redirect(BuildContext context, GoRouterState state, WidgetRef ref) {
    final role = ref.read(currentRoleProvider);

    if (role == null) {
      return RouteConstants.login;
    }

    if (!role.usesDriverInterface) {
      return role.homeRoute;
    }

    return null;
  }
}

/// Guard widget wrapper for protecting routes.
///
/// Shows a loading indicator while checking access,
/// redirects if access is denied.
class RouteGuardWidget extends ConsumerWidget {
  const RouteGuardWidget({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.redirectTo,
  });

  /// The child widget to show if access is granted.
  final Widget child;

  /// Roles that are allowed to access this route.
  final Set<AppRole> allowedRoles;

  /// Route to redirect to if access is denied.
  final String? redirectTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      // Redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.login);
      });
      return const _LoadingPlaceholder();
    }

    if (role == null || !allowedRoles.contains(role)) {
      // Redirect to appropriate location
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(redirectTo ?? role?.homeRoute ?? RouteConstants.home);
      });
      return const _LoadingPlaceholder();
    }

    return child;
  }
}

/// Loading placeholder shown while checking access.
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Extension on GoRouterState for easier access checks.
extension GoRouterStateX on GoRouterState {
  /// Whether this is an authenticated route.
  bool get isProtectedRoute {
    return !_isAuthRoute(matchedLocation) &&
        matchedLocation != RouteConstants.splash;
  }

  /// Whether this is a passenger route.
  bool get isPassengerRoute {
    return matchedLocation.startsWith('/passenger');
  }

  /// Whether this is a driver route.
  bool get isDriverRoute {
    return matchedLocation.startsWith('/driver');
  }
}
