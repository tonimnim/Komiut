import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_constants.dart';
import 'route_names.dart';
import '../../di/injection_container.dart';
import '../../shared/auth/domain/repositories/auth_repository.dart';

class RoleGuard {
  static const List<String> publicRoutes = [
    RouteNames.splash,
    RouteNames.login,
    RouteNames.otp,
  ];

  static Future<String?> guard(
    BuildContext context,
    GoRouterState state,
  ) async {
    final currentPath = state.matchedLocation;

    if (publicRoutes.contains(currentPath)) {
      return null;
    }

    final authRepository = getIt<AuthRepository>();
    final isAuthenticated = await authRepository.isAuthenticated();

    if (!isAuthenticated) {
      return RouteNames.login;
    }

    return null;
  }

  static String getHomeRoute(String role) {
    switch (role) {
      case AppConstants.roleDriver:
        return RouteNames.driverDashboard;
      default:
        return RouteNames.login;
    }
  }
}
