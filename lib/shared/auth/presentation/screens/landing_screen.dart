import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              
              // App Logo / Symbol
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    size: 48,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              const Text(
                'Welcome to Komiut',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Choose how you want to use the platform today.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 3),
              
              // Role Selection Cards
              _buildRoleCard(
                context,
                title: 'I\'m a Passenger',
                subtitle: 'Find rides and travel seamlessly',
                icon: Icons.person_outline_rounded,
                onTap: () => context.push(RouteConstants.login), // Default login
              ),
              
              const SizedBox(height: 16),
              
              _buildRoleCard(
                context,
                title: 'I\'m a Driver / tout',
                subtitle: 'Manage trips and track earnings',
                icon: Icons.badge_outlined,
                onTap: () => context.push(RouteConstants.login), // Same login, but context changes
                isSecondary: true,
              ),
              
              const SizedBox(height: 48),
              
              const Text(
                'Moving cities together, one ride at a time.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSecondary ? AppColors.surface : AppColors.background,
          border: Border.all(
            color: isSecondary ? AppColors.border : AppColors.primaryBlue,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSecondary ? AppColors.textPrimary : AppColors.primaryBlue,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isSecondary ? AppColors.textHint : AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}
