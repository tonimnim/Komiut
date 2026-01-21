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

  static const List<String> driverRoutes = [
    RouteNames.driverDashboard,
    RouteNames.preQueue,
    RouteNames.queueManagement,
    RouteNames.startTrip,
    RouteNames.tripEarnings,
    RouteNames.tripHistory,
    RouteNames.driverSettings,
  ];

  static const List<String> passengerRoutes = [
    RouteNames.passengerHome,
    RouteNames.passengerQueuing,
    RouteNames.passengerTrip,
    RouteNames.passengerPayment,
    RouteNames.passengerHistory,
    RouteNames.passengerSettings,
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

    final userRole = await authRepository.getUserRole();

    if (userRole == AppConstants.roleDriver) {
      if (_isPassengerRoute(currentPath)) {
        return RouteNames.driverDashboard;
      }
    } else if (userRole == AppConstants.rolePassenger) {
      if (_isDriverRoute(currentPath)) {
        return RouteNames.passengerHome;
      }
    }

    return null;
  }

  static bool _isDriverRoute(String path) {
    return path.startsWith('/driver');
  }

  static bool _isPassengerRoute(String path) {
    return path.startsWith('/passenger');
  }

  static String getHomeRoute(String role) {
    switch (role) {
      case AppConstants.roleDriver:
        return RouteNames.driverDashboard;
      case AppConstants.rolePassenger:
        return RouteNames.passengerHome;
      default:
        return RouteNames.login;
    }
  }
}
