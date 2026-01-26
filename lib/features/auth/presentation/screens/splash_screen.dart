/// Splash Screen.
///
/// Displays app branding while checking authentication state.
/// Routes to appropriate screen based on auth and role.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Remove native splash once Flutter UI is ready
    FlutterNativeSplash.remove();

    // Start minimum display timer
    _startMinTimer();
  }

  Future<void> _startMinTimer() async {
    await Future.delayed(Duration(seconds: AppConstants.splashDuration));
    if (!mounted) return;
    _minTimeElapsed = true;
    _tryNavigate();
  }

  void _tryNavigate() {
    if (_hasNavigated || !mounted || !_minTimeElapsed) return;

    final authState = ref.read(authControllerProvider);

    // Still loading - wait
    if (authState.isLoading) {
      Future.delayed(const Duration(milliseconds: 100), _tryNavigate);
      return;
    }

    final state = authState.valueOrNull;
    if (state == null) {
      // Still initializing
      Future.delayed(const Duration(milliseconds: 100), _tryNavigate);
      return;
    }

    _hasNavigated = true;

    if (state is AuthAuthenticated) {
      // Navigate to role-based home
      context.go(state.role.homeRoute);
    } else {
      // Not authenticated - go to login
      context.go(RouteConstants.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to navigate when ready
    ref.listen<AsyncValue<AuthState>>(authControllerProvider, (previous, next) {
      _tryNavigate();
    });

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.primaryGreen],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/labellogo.jpeg',
                    width: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_bus,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Loading indicator
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
