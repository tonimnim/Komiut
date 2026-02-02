/// Application router configuration.
///
/// Configures GoRouter with all application routes,
/// including auth, passenger, driver, and shared routes.
/// Uses role-based navigation for proper routing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/two_factor_screen.dart';
import '../../features/shared/home/presentation/screens/home_screen.dart';
import '../../features/shared/activity/presentation/screens/activity_screen.dart';
import '../../features/shared/payment/presentation/screens/payment_screen.dart';
import '../../features/shared/payment/presentation/screens/payment_method_screen.dart';
import '../../features/shared/payment/presentation/screens/payment_processing_screen.dart';
import '../../features/shared/payment/presentation/screens/payment_receipt_screen.dart';
import '../../features/shared/payment/presentation/screens/topup_screen.dart';
import '../../features/shared/payment/presentation/screens/topup_processing_screen.dart';
import '../../features/shared/payment/presentation/screens/wallet_history_screen.dart';
import '../../features/shared/settings/presentation/screens/settings_screen.dart';
import '../../features/shared/settings/presentation/screens/about_screen.dart';
import '../../features/shared/settings/presentation/screens/help_screen.dart';
import '../../features/shared/settings/presentation/screens/faq_screen.dart';
import '../../features/shared/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/shared/settings/presentation/screens/terms_screen.dart';
import '../../features/shared/settings/presentation/screens/preferences_screen.dart';
import '../../features/shared/settings/presentation/screens/saved_routes_screen.dart';
import '../../features/shared/settings/presentation/screens/saved_saccos_screen.dart';
import '../../features/shared/settings/presentation/screens/payment_methods_screen.dart';
import '../../features/shared/notifications/presentation/screens/notification_screen.dart';
import '../../features/shared/scan/presentation/screens/scan_screen.dart';
import '../../features/driver/driver.dart';
import '../../features/driver/dashboard/presentation/screens/driver_home_screen.dart';
import '../../features/driver/earnings/presentation/screens/earnings_screen.dart';
import '../../features/driver/queue/presentation/screens/queue_screen.dart' as driver_queue;
import '../../features/driver/trips/presentation/screens/driver_trips_screen.dart';
import '../../features/shared/shared.dart';
import '../../features/passenger/discovery/presentation/screens/saccos_screen.dart';
import '../../features/passenger/discovery/presentation/screens/sacco_detail_screen.dart';
import '../../features/shared/queue/presentation/screens/queue_screen.dart';
import '../../features/passenger/trips/presentation/screens/active_trip_screen.dart';
import '../../features/shared/loyalty/presentation/screens/loyalty_screen.dart';
import '../../features/passenger/tickets/tickets.dart';
import '../config/app_config.dart';
import '../constants/route_constants.dart';

/// Provider for the app router.
final appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter(ref);
});

/// Creates and configures the application router.
GoRouter createAppRouter(Ref ref) {
  return GoRouter(
    // Skip auth: go directly to home, otherwise start at splash
    initialLocation:
        AppConfig.skipAuth ? RouteConstants.home : RouteConstants.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // DEV MODE: Skip all auth checks - no redirects at all
      if (AppConfig.skipAuth) {
        return null;
      }

      final authState = ref.read(authControllerProvider).valueOrNull;
      final isAuthenticated = authState is AuthAuthenticated;
      final currentPath = state.matchedLocation;

      final isAuthRoute = _isAuthRoute(currentPath);
      final isSplash = currentPath == RouteConstants.splash;

      // Always allow splash screen
      if (isSplash) return null;

      // Not authenticated - redirect to login (except for auth routes)
      if (!isAuthenticated && !isAuthRoute) {
        return RouteConstants.login;
      }

      // Authenticated user on auth route - redirect to appropriate home
      if (authState is AuthAuthenticated && isAuthRoute) {
        return authState.role.homeRoute;
      }

      // Authenticated - check role-based access
      if (authState is AuthAuthenticated) {
        // Passenger trying to access driver routes
        if (currentPath.startsWith('/driver') &&
            !authState.role.usesDriverInterface) {
          return authState.role.homeRoute;
        }

        // Driver trying to access passenger-only routes
        if (currentPath.startsWith('/passenger') &&
            authState.role.usesDriverInterface) {
          return authState.role.homeRoute;
        }
      }

      return null;
    },
    routes: [
      // ─────────────────────────────────────────────────────────────────────
      // Auth routes
      // ─────────────────────────────────────────────────────────────────────

      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.signUp,
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteConstants.twoFactor,
        name: 'twoFactor',
        builder: (context, state) {
          final showHint = state.uri.queryParameters['showHint'] == 'true';
          return TwoFactorScreen(showDemoHint: showHint);
        },
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Legacy/shared routes (redirect to role-appropriate version)
      // ─────────────────────────────────────────────────────────────────────

      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        redirect: (context, state) {
          // DEV MODE: Skip auth check
          if (AppConfig.skipAuth) return null;

          final authState = ref.read(authControllerProvider).valueOrNull;
          if (authState is AuthAuthenticated) {
            return authState.role.homeRoute;
          }
          return RouteConstants.login;
        },
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.activity,
        name: 'activity',
        builder: (context, state) => const ActivityScreen(),
      ),
      GoRoute(
        path: RouteConstants.payments,
        name: 'payments',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: RouteConstants.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: RouteConstants.scan,
        name: 'scan',
        builder: (context, state) => const ScanScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Passenger routes
      // ─────────────────────────────────────────────────────────────────────

      GoRoute(
        path: RouteConstants.passengerHome,
        name: 'passengerHome',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.passengerSaccos,
        name: 'passengerSaccos',
        builder: (context, state) => const SaccosScreen(),
      ),
      GoRoute(
        path: RouteConstants.passengerSaccoDetail,
        name: 'passengerSaccoDetail',
        builder: (context, state) {
          final saccoId = state.pathParameters['id']!;
          return SaccoDetailScreen(saccoId: saccoId);
        },
      ),
      GoRoute(
        path: RouteConstants.passengerQueue,
        name: 'passengerQueue',
        builder: (context, state) {
          final routeId = state.pathParameters['routeId']!;
          return PassengerQueueScreen(routeId: routeId);
        },
      ),
      GoRoute(
        path: RouteConstants.passengerActiveTrip,
        name: 'passengerActiveTrip',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId'];
          return ActiveTripScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: RouteConstants.passengerLoyalty,
        name: 'passengerLoyalty',
        builder: (context, state) => const LoyaltyScreen(),
      ),

      // Ticket routes
      GoRoute(
        path: RouteConstants.passengerTicket,
        name: 'passengerTicket',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return TicketScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: RouteConstants.passengerTickets,
        name: 'passengerTickets',
        builder: (context, state) => const MyTicketsScreen(),
      ),
      GoRoute(
        path: RouteConstants.passengerBoarding,
        name: 'passengerBoarding',
        builder: (context, state) {
          final ticketId = state.pathParameters['ticketId']!;
          return BoardingConfirmationScreen(ticketId: ticketId);
        },
      ),

      // Payment flow routes
      GoRoute(
        path: RouteConstants.passengerPaymentMethod,
        name: 'passengerPaymentMethod',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return PaymentMethodScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: RouteConstants.passengerPaymentProcessing,
        name: 'passengerPaymentProcessing',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return PaymentProcessingScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: RouteConstants.passengerPaymentReceipt,
        name: 'passengerPaymentReceipt',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return PaymentReceiptScreen(bookingId: bookingId);
        },
      ),

      // Wallet routes
      GoRoute(
        path: RouteConstants.passengerWalletTopup,
        name: 'passengerWalletTopup',
        builder: (context, state) => const TopupScreen(),
      ),
      GoRoute(
        path: RouteConstants.passengerWalletTopupProcess,
        name: 'passengerWalletTopupProcess',
        builder: (context, state) => const TopupProcessingScreen(),
      ),
      GoRoute(
        path: RouteConstants.passengerWalletHistory,
        name: 'passengerWalletHistory',
        builder: (context, state) => const WalletHistoryScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Driver routes (Musa's domain)
      // ─────────────────────────────────────────────────────────────────────

      GoRoute(
        path: RouteConstants.driverHome,
        name: 'driverHome',
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.driverQueue,
        name: 'driverQueue',
        builder: (context, state) => const driver_queue.QueueScreen(),
      ),
      GoRoute(
        path: RouteConstants.driverTrips,
        name: 'driverTrips',
        builder: (context, state) => const DriverTripsScreen(),
      ),
      GoRoute(
        path: RouteConstants.driverEarnings,
        name: 'driverEarnings',
        builder: (context, state) => const EarningsScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Shared routes (accessible by all roles)
      // ─────────────────────────────────────────────────────────────────────

      GoRoute(
        path: RouteConstants.sharedProfile,
        name: 'sharedProfile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.sharedSettings,
        name: 'sharedSettings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.sharedNotifications,
        name: 'sharedNotifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Settings sub-routes
      // ─────────────────────────────────────────────────────────────────────

      GoRoute(
        path: RouteConstants.settingsAbout,
        name: 'settingsAbout',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RouteConstants.settingsHelp,
        name: 'settingsHelp',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: RouteConstants.settingsFaq,
        name: 'settingsFaq',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: RouteConstants.settingsPrivacy,
        name: 'settingsPrivacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: RouteConstants.settingsTerms,
        name: 'settingsTerms',
        builder: (context, state) => const TermsScreen(),
      ),

      // Passenger settings routes
      GoRoute(
        path: RouteConstants.settingsPreferences,
        name: 'settingsPreferences',
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(
        path: RouteConstants.settingsSavedRoutes,
        name: 'settingsSavedRoutes',
        builder: (context, state) => const SavedRoutesScreen(),
      ),
      GoRoute(
        path: RouteConstants.settingsSavedSaccos,
        name: 'settingsSavedSaccos',
        builder: (context, state) => const SavedSaccosScreen(),
      ),
      GoRoute(
        path: RouteConstants.settingsPaymentMethods,
        name: 'settingsPaymentMethods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
}

/// Check if route is an auth route.
bool _isAuthRoute(String path) {
  return path == RouteConstants.login ||
      path == RouteConstants.signUp ||
      path == RouteConstants.forgotPassword ||
      path == RouteConstants.twoFactor;
}

/// Error screen for unknown routes.
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
