import 'package:go_router/go_router.dart';

import 'package:komiut_app/core/routes/route_names.dart';

import 'package:komiut_app/shared/auth/presentation/screens/splash_screen.dart';
import 'package:komiut_app/shared/auth/presentation/screens/login_screen.dart';
import 'package:komiut_app/shared/auth/presentation/screens/otp_screen.dart';
import 'package:komiut_app/driver/dashboard/presentation/screens/driver_dashboard_screen.dart';
import 'package:komiut_app/driver/queue/presentation/screens/join_queue_screen.dart';
import 'package:komiut_app/driver/queue/presentation/screens/driver_queue_screen.dart';
import 'package:komiut_app/driver/earnings/presentation/screens/earnings_screen.dart';
import 'package:komiut_app/driver/trip/presentation/screens/start_trip_screen.dart';
import 'package:komiut_app/driver/trip/presentation/screens/trip_in_progress_screen.dart';
import 'package:komiut_app/driver/trip/presentation/screens/end_trip_screen.dart';
import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut_app/driver/settings/presentation/screens/edit_profile_screen.dart';
import 'package:komiut_app/driver/earnings/presentation/screens/trip_history_screen.dart';
import 'package:komiut_app/driver/earnings/presentation/screens/trip_history_details_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.driverDashboard,
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
        path: RouteNames.joinQueue,
        name: 'joinQueue',
        builder: (context, state) {
          final profile = state.extra as DriverProfile?;
          return JoinQueueScreen(profile: profile);
        },
      ),
      GoRoute(
        path: RouteNames.driverQueue,
        name: 'driverQueue',
        builder: (context, state) => const DriverQueueScreen(),
      ),
      GoRoute(
        path: RouteNames.driverEarnings,
        name: 'driverEarnings',
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: RouteNames.startTrip,
        name: 'startTrip',
        builder: (context, state) {
          final circleRoute = state.extra as CircleRoute?;
          return StartTripScreen(route: circleRoute);
        },
      ),
      GoRoute(
        path: RouteNames.tripInProgress,
        name: 'tripInProgress',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return TripInProgressScreen(passengerCount: data?['passengerCount'] as int?);
        },
      ),
      GoRoute(
        path: RouteNames.endTrip,
        name: 'endTrip',
        builder: (context, state) {
          final tripData = state.extra as Map<String, dynamic>?;
          return EndTripScreen(tripData: tripData);
        },
      ),
      GoRoute(
        path: RouteNames.editProfile,
        name: 'editProfile',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return EditProfileScreen(
            profile: data?['profile'] as DriverProfile?,
            vehicle: data?['vehicle'] as Vehicle?,
          );
        },
      ),
      GoRoute(
        path: RouteNames.tripHistory,
        name: 'tripHistory',
        builder: (context, state) {
          final profile = state.extra as DriverProfile?;
          return TripHistoryScreen(profile: profile);
        },
      ),
      GoRoute(
        path: RouteNames.tripHistoryDetails,
        name: 'tripHistoryDetails',
        builder: (context, state) {
          final trip = state.extra as Map<String, dynamic>;
          return TripHistoryDetailsScreen(trip: trip);
        },
      ),
    ],
  );
}

