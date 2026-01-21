import 'package:go_router/go_router.dart';

import 'package:komiut_app/core/config/app_constants.dart';
import 'package:komiut_app/core/routes/route_names.dart';
import 'package:komiut_app/core/routes/role_guard.dart';

import 'package:komiut_app/shared/auth/presentation/screens/splash_screen.dart';
import 'package:komiut_app/shared/auth/presentation/screens/login_screen.dart';
import 'package:komiut_app/shared/auth/presentation/screens/otp_screen.dart';

import 'package:komiut_app/driver/dashboard/presentation/screens/driver_dashboard_screen.dart';
import 'package:komiut_app/driver/dashboard/presentation/screens/active_duty_dashboard_screen.dart'; // Import
import 'package:komiut_app/driver/queue/presentation/screens/pre_queue_screen.dart';
import 'package:komiut_app/driver/queue/presentation/screens/queue_management_screen.dart';
import 'package:komiut_app/driver/trip/presentation/screens/start_trip_screen.dart';
import 'package:komiut_app/driver/trip/presentation/screens/trip_in_progress_screen.dart';
import 'package:komiut_app/driver/trip/presentation/screens/end_trip_screen.dart';
import 'package:komiut_app/driver/trip/presentation/screens/trip_details_screen.dart';
import 'package:komiut_app/driver/earnings/presentation/screens/earnings_screen.dart';
import 'package:komiut_app/driver/history/presentation/screens/history_screen.dart';
import 'package:komiut_app/driver/settings/presentation/screens/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.driverDashboard,
    // redirect: RoleGuard.guard,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.otp,
        name: 'otp',
        builder: (context, state) {
          final verificationId = state.extra as String?;
          return OtpScreen(verificationId: verificationId ?? '');
        },
      ),

      GoRoute(
        path: RouteNames.driverDashboard,
        name: 'driverDashboard',
        builder: (context, state) => const DriverDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.activeDuty,
        name: 'activeDuty',
        builder: (context, state) => const ActiveDutyDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.preQueue,
        name: 'preQueue',
        builder: (context, state) => const PreQueueScreen(),
      ),
      GoRoute(
        path: RouteNames.queueManagement,
        name: 'queueManagement',
        builder: (context, state) => const QueueManagementScreen(),
      ),
      GoRoute(
        path: RouteNames.startTrip,
        name: 'startTrip',
        builder: (context, state) => const StartTripScreen(),
      ),
      GoRoute(
        path: RouteNames.tripInProgress,
        name: 'tripInProgress',
        builder: (context, state) => const TripInProgressScreen(),
      ),
      GoRoute(
        path: RouteNames.endTrip,
        name: 'endTrip',
        builder: (context, state) => const EndTripScreen(),
      ),
      GoRoute(
        path: RouteNames.tripDetails,
        name: 'tripDetails',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId'] ?? '';
          return TripDetailsScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: RouteNames.tripEarnings,
        name: 'tripEarnings',
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: RouteNames.tripHistory,
        name: 'tripHistory',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: RouteNames.driverSettings,
        name: 'driverSettings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
