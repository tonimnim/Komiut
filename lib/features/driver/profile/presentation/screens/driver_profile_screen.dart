/// Driver profile screen.
///
/// Profile view with account info, settings, and preferences.
/// Uses local auth data - always shows UI, never blank.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/domain/entities/user.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/providers/auth_controller.dart';
import '../widgets/profile_preferences_card.dart';
import '../widgets/profile_settings_items.dart';

/// Driver profile screen.
class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: _ProfileHeader(user: user),
          ),

          // Settings Sections
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Account Section
                const ProfileSectionHeader(title: 'Account'),
                const SizedBox(height: 12),
                ProfileSettingsCard(
                  children: [
                    ProfileSettingsItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      showDivider: true,
                      onTap: () {},
                    ),
                    ProfileSettingsItem(
                      icon: Icons.directions_bus_outlined,
                      title: 'Vehicle Info',
                      onTap: () {},
                    ),
                  ],
                ),

                // Preferences Section
                const SizedBox(height: 28),
                const ProfileSectionHeader(title: 'Preferences'),
                const SizedBox(height: 12),
                const ProfilePreferencesCard(),

                // Support Section
                const SizedBox(height: 28),
                const ProfileSectionHeader(title: 'Support'),
                const SizedBox(height: 12),
                ProfileSettingsCard(
                  children: [
                    ProfileSettingsItem(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      showDivider: true,
                      onTap: () {},
                    ),
                    ProfileSettingsItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {},
                    ),
                  ],
                ),

                // Logout Button
                const SizedBox(height: 28),
                ProfileLogoutButton(
                  onTap: () => _handleLogout(context, ref),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).logout();
              context.go(RouteConstants.login);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

/// Profile header with avatar, name, email.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
      ),
      child: Column(
        children: [
          // Back button row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 24),

          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                width: 3,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user?.fullName ?? 'Driver',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
