import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:komiut/core/routes/route_names.dart';

import 'package:komiut/shared/auth/presentation/screens/splash_screen.dart';
import 'package:komiut/shared/auth/presentation/screens/login_screen.dart';
import 'package:komiut/shared/auth/presentation/screens/otp_screen.dart';
import 'package:komiut/driver/dashboard/presentation/screens/driver_dashboard_screen.dart';
import 'package:komiut/driver/queue/presentation/screens/join_queue_screen.dart';
import 'package:komiut/driver/queue/presentation/screens/driver_queue_screen.dart';
import 'package:komiut/driver/queue/presentation/screens/pre_queue_screen.dart';
import 'package:komiut/driver/earnings/presentation/screens/earnings_screen.dart';
import 'package:komiut/driver/trip/presentation/screens/start_trip_screen.dart';
import 'package:komiut/driver/trip/presentation/screens/trip_in_progress_screen.dart';
import 'package:komiut/driver/trip/presentation/screens/end_trip_screen.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut/driver/settings/presentation/screens/edit_profile_screen.dart';
import 'package:komiut/driver/earnings/presentation/screens/trip_history_screen.dart';
import 'package:komiut/driver/earnings/presentation/screens/trip_history_details_screen.dart';
import 'package:komiut/driver/settings/presentation/screens/driver_documents_screen.dart';
import 'package:komiut/driver/settings/presentation/screens/payout_methods_screen.dart';
import 'package:komiut/driver/settings/presentation/screens/vehicle_info_screen.dart';
import 'package:komiut/driver/settings/presentation/screens/app_info_screen.dart';
import 'package:komiut/driver/settings/presentation/screens/privacy_terms_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

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
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final key = extra?['refresh'] == true ? UniqueKey() : null;
          final initialIndex = extra?['initialTab'] as int? ?? 0;
          return DriverDashboardScreen(key: key, initialIndex: initialIndex);
        },
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
          return TripInProgressScreen(
            passengerCount: data?['passengerCount'] as int?,
            profile: data?['profile'] as DriverProfile?,
          );
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
          final tripId = state.extra as String;
          return TripHistoryDetailsScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: RouteNames.driverDocuments,
        name: 'driverDocuments',
        builder: (context, state) => const DriverDocumentsScreen(),
      ),
      GoRoute(
        path: RouteNames.payoutMethods,
        name: 'payoutMethods',
        builder: (context, state) => const PayoutMethodsScreen(),
      ),
      GoRoute(
        path: RouteNames.vehicleInfo,
        name: 'vehicleInfo',
        builder: (context, state) {
          final vehicle = state.extra as Vehicle?;
          return VehicleInfoScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: RouteNames.appInfo,
        name: 'appInfo',
        builder: (context, state) => const AppInfoScreen(),
      ),
      GoRoute(
        path: RouteNames.privacyTerms,
        name: 'privacyTerms',
        builder: (context, state) {
          final isPrivacy = state.extra as bool? ?? true;
          return PrivacyTermsScreen(isPrivacy: isPrivacy);
        },
      ),
      GoRoute(
        path: RouteNames.preQueue,
        name: 'preQueue',
        builder: (context, state) => const PreQueueScreen(),
      ),
    ],
  );
}
