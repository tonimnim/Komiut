import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/core/theme/app_colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset('assets/images/appicon.jpg'),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to Komiut',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you driving or riding today?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const Spacer(),
              _buildRoleButton(
                context,
                'Driver',
                Icons.drive_eta,
                () => context.pushNamed('login'),
                isPrimary: true,
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                context,
                'Passenger',
                Icons.person,
                () => context.pushNamed('login'),
                isPrimary: false,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
      BuildContext context, String label, IconData icon, VoidCallback onTap,
      {required bool isPrimary}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white.withOpacity(0.2) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isPrimary ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 16,
                color: isPrimary ? Colors.white : AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
