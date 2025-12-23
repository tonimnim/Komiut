import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/two_factor_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/activity/presentation/screens/activity_screen.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../constants/route_constants.dart';

final appRouter = GoRouter(
  initialLocation: RouteConstants.splash,
  routes: [
    // Splash
    GoRoute(
      path: RouteConstants.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth routes
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

    // Main app routes
    GoRoute(
      path: RouteConstants.home,
      name: 'home',
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
  ],
);
