/// Shared profile screen.
///
/// Profile view for passengers with account info, settings, and preferences.
/// Matches driver profile design for consistency.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/domain/entities/user.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/theme_provider.dart';
import '../../../../auth/presentation/providers/auth_controller.dart';

/// Profile screen widget.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
                _SectionHeader(title: 'Account', isDark: isDark),
                const SizedBox(height: 12),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _SettingsItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      isDark: isDark,
                      showDivider: true,
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.history_outlined,
                      title: 'Trip History',
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),

                // Preferences Section
                const SizedBox(height: 28),
                _SectionHeader(title: 'Preferences', isDark: isDark),
                const SizedBox(height: 12),
                _PreferencesCard(isDark: isDark),

                // Support Section
                const SizedBox(height: 28),
                _SectionHeader(title: 'Support', isDark: isDark),
                const SizedBox(height: 12),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _SettingsItem(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      isDark: isDark,
                      showDivider: true,
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),

                // Logout Button
                const SizedBox(height: 28),
                _LogoutButton(
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
            user?.fullName ?? 'User',
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: isDark ? Colors.grey[500] : AppColors.textSecondary,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, required this.isDark});

  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.isDark,
    this.showDivider = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isDark;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            color: isDark ? Colors.grey[850] : Colors.grey[200],
          ),
      ],
    );
  }
}

class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return _SettingsCard(
      isDark: isDark,
      children: [
        // Theme Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDark ? 'On' : 'Off',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[500] : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).setTheme(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                },
                activeTrackColor: AppColors.primaryBlue,
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          indent: 56,
          color: isDark ? Colors.grey[850] : Colors.grey[200],
        ),
        // Notifications
        _SettingsItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          isDark: isDark,
          onTap: () {},
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.2),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
